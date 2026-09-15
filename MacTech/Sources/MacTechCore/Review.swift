import Foundation

public struct ReviewCategory: Sendable, Identifiable {
    public let id: String
    public let title: String
    public let relativePath: String
    public let impact: String
    public let decision: String
    public var url: URL { FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(relativePath) }
}

public enum CleanupEngine {
    public static let categories: [ReviewCategory] = [
        .init(id: "npx", title: "Execucoes npx", relativePath: ".npm/_npx", impact: "Pacotes podem precisar de novo download. Confirmar que nenhuma tarefa npx esta ativa.", decision: "REVIEW"),
        .init(id: "xcode", title: "Compilacoes Xcode", relativePath: "Library/Developer/Xcode/DerivedData", impact: "Proxima compilacao refaz artefatos. Preservar projetos ativos.", decision: "REVIEW"),
        .init(id: "brew", title: "Downloads Homebrew", relativePath: "Library/Caches/Homebrew", impact: "Novo download necessario. Usar revisao nativa do gerenciador.", decision: "REVIEW"),
        .init(id: "caches", title: "Caches de aplicativos", relativePath: "Library/Caches", impact: "Podem acelerar aplicativos e conter trabalho em andamento. Preservados.", decision: "REVIEW"),
        .init(id: "logs", title: "Logs de diagnostico", relativePath: "Library/Logs", impact: "Historico necessario para investigar falhas. Preservado.", decision: "REVIEW"),
        .init(id: "ios", title: "Backups iOS", relativePath: "Library/Application Support/MobileSync/Backup", impact: "Perda de possibilidade de restaurar dispositivos. Exclusao bloqueada.", decision: "REMOVE"),
        .init(id: "archives", title: "Distribuicoes Xcode", relativePath: "Library/Developer/Xcode/Archives", impact: "Perda de builds e simbolos para diagnosticar crashes. Exclusao bloqueada.", decision: "REMOVE"),
        .init(id: "adobe", title: "Plugins Adobe", relativePath: "Library/Application Support/Adobe/Common/Plug-ins/7.0/MediaCore", impact: "Remocao quebra recursos dos aplicativos. Exclusao bloqueada.", decision: "REMOVE")
    ]

    // A review estimates stored bytes, never claims physically reclaimable APFS blocks.
    public static func estimate(_ category: ReviewCategory) throws -> Measurement {
        try SafetyPolicy.validateLocalPath(category.url, under: FileManager.default.homeDirectoryForCurrentUser)
        guard FileManager.default.fileExists(atPath: category.url.path) else {
            throw SafetyError.refused("Categoria ausente neste Mac.")
        }
        return DiagnosticsEngine.command("/usr/bin/du", ["-skx", category.url.path], name: category.title)
    }

    // Cleanup stays in review mode. No third-party data is deleted by this engine.
    public static func dryRun() -> [String] {
        categories.map { "\($0.decision) | \($0.title) | ~/\($0.relativePath) | \($0.impact) | nenhuma exclusao automatica" }
    }
}
