import Foundation
import OSLog
import Darwin

public struct Measurement: Codable, Sendable, Identifiable {
    public var id: String { name }
    public let name: String
    public let output: String
    public let exitCode: Int32
    public let duration: Double
}

public struct Report: Codable, Sendable {
    public let id: UUID
    public let version: String
    public let reason: String
    public let started: Date
    public var duration: Double
    public var measurements: [Measurement]
    public var recommendations: [String]
    public var changes: [String]
    public var recoveredBytes: Int64
    public var result: String
}

public enum DiagnosticsEngine {
    public static let version = "4.0.0"
    public static let subsystem = "com.danilonovais.mactech"
    public static var stateRoot: URL {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Application Support/MacTech")
    }
    private static let logger = Logger(subsystem: subsystem, category: "Diagnostics")

    // Only fixed, read-only system commands are admitted; no user command strings.
    public static func command(_ path: String, _ arguments: [String], name: String) -> Measurement {
        let start = Date()
        let task = Process()
        let pipe = Pipe()
        task.executableURL = URL(fileURLWithPath: path)
        task.arguments = arguments
        task.environment = ["PATH": "/usr/bin:/bin:/usr/sbin:/sbin", "LC_ALL": "C"]
        task.standardInput = FileHandle.nullDevice
        task.standardOutput = pipe
        task.standardError = pipe
        do {
            try task.run()
            let deadline = DispatchWorkItem {
                if task.isRunning { task.terminate() }
                DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                    if task.isRunning { kill(task.processIdentifier, SIGKILL) }
                }
            }
            DispatchQueue.global().asyncAfter(deadline: .now() + 12, execute: deadline)
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            task.waitUntilExit()
            deadline.cancel()
            return Measurement(name: name, output: String(decoding: data.prefix(64_000), as: UTF8.self),
                               exitCode: task.terminationStatus, duration: Date().timeIntervalSince(start))
        } catch {
            return Measurement(name: name, output: error.localizedDescription, exitCode: -1,
                               duration: Date().timeIntervalSince(start))
        }
    }

    public static func bootID() throws -> String {
        var length = 0
        guard sysctlbyname("kern.bootsessionuuid", nil, &length, nil, 0) == 0, length > 0 else {
            throw SafetyError.refused("Ciclo de boot indisponivel.")
        }
        var bytes = [CChar](repeating: 0, count: length)
        guard sysctlbyname("kern.bootsessionuuid", &bytes, &length, nil, 0) == 0 else {
            throw SafetyError.refused("Nao foi possivel identificar o boot.")
        }
        return String(decoding: bytes.prefix(while: { $0 != 0 }).map { UInt8(bitPattern: $0) }, as: UTF8.self)
    }

    public static func hasCompleted(boot: String, root: URL) throws -> Bool {
        let url = root.appendingPathComponent("last-automatic-boot.txt")
        try SafetyPolicy.validateLocalPath(url, under: root)
        guard FileManager.default.fileExists(atPath: url.path) else { return false }
        return try String(contentsOf: url, encoding: .utf8) == boot
    }

    public static func markCompleted(boot: String, root: URL) throws {
        let marker = root.appendingPathComponent("last-automatic-boot.txt")
        try SafetyPolicy.validateLocalPath(marker, under: root)
        try boot.write(to: marker, atomically: true, encoding: .utf8)
        try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: marker.path)
    }

    public static func collect(reason: String) -> Report {
        let start = Date()
        logger.notice("run_started version=4.0.0 reason=\(reason, privacy: .public)")
        let measurements = [
            command("/usr/bin/sw_vers", [], name: "macOS"),
            command("/usr/sbin/sysctl", ["hw.model", "hw.memsize", "hw.ncpu", "machdep.cpu.brand_string"], name: "Hardware"),
            command("/bin/df", ["-k", "/System/Volumes/Data"], name: "Armazenamento APFS"),
            command("/usr/bin/vm_stat", [], name: "Memoria"),
            command("/usr/sbin/sysctl", ["vm.swapusage", "kern.memorystatus_vm_pressure_level"], name: "Swap e pressao"),
            command("/bin/ps", ["-arcwwwxo", "pid,ppid,%cpu,%mem,etime,comm"], name: "CPU e processos"),
            command("/usr/bin/pmset", ["-g", "therm"], name: "Temperatura"),
            command("/usr/bin/pmset", ["-g", "batt"], name: "Energia")
        ]
        var recommendations = [
            "Preservar backups iOS, arquivos .xcarchive, plugins Adobe e volumes Docker.",
            "Caches de compilacao e pacotes evitam downloads e recompilacoes; revisar por projeto.",
            "Nenhuma alteracao de DNS, servicos, snapshots ou memoria foi indicada por este diagnostico."
        ]
        if let attributes = try? FileManager.default.attributesOfFileSystem(forPath: "/System/Volumes/Data"),
           let available = attributes[.systemFreeSize] as? NSNumber,
           let total = attributes[.systemSize] as? NSNumber, total.doubleValue > 0,
           available.doubleValue / total.doubleValue < 0.1 {
            recommendations.insert("Menos de 10% do armazenamento disponivel. Revisar arquivos grandes e projetos arquivados.", at: 0)
        }
        let failures = measurements.filter { $0.exitCode != 0 }.count
        let result = failures == 0 ? "concluido" : "parcial: \(failures) verificacoes indisponiveis"
        logger.notice("run_finished result=\(result, privacy: .public)")
        return Report(id: UUID(), version: version, reason: reason, started: start,
                      duration: Date().timeIntervalSince(start), measurements: measurements,
                      recommendations: recommendations, changes: [], recoveredBytes: 0, result: result)
    }

    public static func save(_ report: Report, root: URL = stateRoot) throws -> URL {
        try SafetyPolicy.prepareState(root)
        let folder = root.appendingPathComponent("Reports")
        try SafetyPolicy.validateLocalPath(folder, under: root)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true,
                                               attributes: [.posixPermissions: 0o700])
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(report)
        let file = folder.appendingPathComponent(report.id.uuidString + ".json")
        guard !FileManager.default.fileExists(atPath: file.path) else {
            throw SafetyError.refused("Identificador de relatorio duplicado.")
        }
        try data.write(to: file, options: .atomic)
        try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: file.path)
        let latest = root.appendingPathComponent("latest.json")
        try SafetyPolicy.validateLocalPath(latest, under: root)
        try data.write(to: latest, options: .atomic)
        try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: latest.path)
        return file
    }
}
