import AppKit
import SwiftUI
import ServiceManagement
import MacTechCore
import OSLog

let servicePlist = "com.danilonovais.mactech.login.plist"

@main
struct Entry {
    @MainActor static func main() async {
        let args = Array(CommandLine.arguments.dropFirst())
        guard !args.isEmpty else { MacTechApp.main(); return }
        let logger = Logger(subsystem: DiagnosticsEngine.subsystem, category: "Startup")
        do {
            switch args {
            case ["--startup-status"]:
                print("status=\(SMAppService.agent(plistName: servicePlist).status.rawValue)")
            case ["--enable-startup"]:
                try SMAppService.agent(plistName: servicePlist).register()
                print("status=\(SMAppService.agent(plistName: servicePlist).status.rawValue)")
            case ["--disable-startup"]:
                try await SMAppService.agent(plistName: servicePlist).unregister()
                print("startup_disabled")
            case ["--dry-run"]:
                print("Dry Run: nenhuma alteracao de sistema, arquivo ou configuracao.")
                print(CleanupEngine.dryRun().joined(separator: "\n"))
            case ["--analyze"], ["--automatic"]:
                let root = DiagnosticsEngine.stateRoot
                let automatic = args == ["--automatic"]
                let boot = try DiagnosticsEngine.bootID()
                if try automatic && DiagnosticsEngine.hasCompleted(boot: boot, root: root) {
                    logger.notice("automatic_skipped already_completed")
                    print("already_completed_this_boot")
                    return
                }
                if automatic {
                    logger.notice("automatic_deferred delay_seconds=120")
                    try await Task.sleep(for: .seconds(120))
                }
                let lock = try ExecutionLock(root: root)
                defer { withExtendedLifetime(lock) {} }
                if try automatic && DiagnosticsEngine.hasCompleted(boot: boot, root: root) {
                    logger.notice("automatic_skipped completed_during_delay")
                    print("already_completed_this_boot")
                    return
                }
                let report = await Task.detached(priority: .background) {
                    DiagnosticsEngine.collect(reason: automatic ? "login" : "manual-cli")
                }.value
                let file = try DiagnosticsEngine.save(report)
                if report.result == "concluido" { try DiagnosticsEngine.markCompleted(boot: boot, root: root) }
                print("\(report.result) | \(file.path) | \(report.duration)s | recuperado=0")
            default:
                throw SafetyError.refused("Argumento desconhecido. Use --analyze, --dry-run, --automatic ou --startup-status.")
            }
        } catch {
            logger.error("operation_failed \(error.localizedDescription, privacy: .private)")
            fputs("MacTech: \(error.localizedDescription)\n", stderr)
            exit(1)
        }
    }
}

@MainActor
final class Model: ObservableObject {
    @Published var report: Report?
    @Published var busy = false
    @Published var status = "Pronto para analisar"
    @Published var preview = ""
    @Published var startupStatus = ""
    @Published var startupEnabled = false

    init() { refresh() }
    func refresh() {
        let service = SMAppService.agent(plistName: servicePlist)
        startupEnabled = service.status == .enabled
        switch service.status {
        case .enabled: startupStatus = "Ativado: 120s apos login; no maximo uma vez por boot."
        case .requiresApproval: startupStatus = "Aguardando aprovacao nos Ajustes do Sistema."
        case .notRegistered: startupStatus = "Desativado"
        case .notFound: startupStatus = "Servico nao encontrado no bundle"
        @unknown default: startupStatus = "Estado desconhecido"
        }
        if let data = try? Data(contentsOf: DiagnosticsEngine.stateRoot.appendingPathComponent("latest.json")) {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            report = try? decoder.decode(Report.self, from: data)
        }
    }
    func analyze() {
        guard !busy else { return }
        busy = true
        status = "Analisando..."
        Task {
            do {
                let lock = try ExecutionLock(root: DiagnosticsEngine.stateRoot)
                defer { withExtendedLifetime(lock) {} }
                let value = await Task.detached(priority: .utility) {
                    DiagnosticsEngine.collect(reason: "manual-ui")
                }.value
                _ = try DiagnosticsEngine.save(value)
                if value.result == "concluido" {
                    try DiagnosticsEngine.markCompleted(boot: DiagnosticsEngine.bootID(), root: DiagnosticsEngine.stateRoot)
                }
                report = value
                status = "\(value.result) em \(String(format: "%.2f", value.duration))s; nenhum arquivo removido."
            } catch { status = error.localizedDescription }
            busy = false
        }
    }
    func measure(_ category: ReviewCategory) {
        guard !busy else { return }
        busy = true
        Task {
            do {
                let lock = try ExecutionLock(root: DiagnosticsEngine.stateRoot)
                defer { withExtendedLifetime(lock) {} }
                let value = try await Task.detached(priority: .utility) { try CleanupEngine.estimate(category) }.value
                preview = "\(category.title) | tamanho em KiB (du)\n\(value.output)\nStatus: \(value.exitCode)\n\(category.impact)"
            } catch { preview = error.localizedDescription }
            busy = false
        }
    }
    func startup(_ enabled: Bool) {
        Task {
            do {
                let service = SMAppService.agent(plistName: servicePlist)
                if enabled { try service.register() } else { try await service.unregister() }
            } catch { status = error.localizedDescription }
            refresh()
        }
    }
}

struct MacTechApp: App {
    @StateObject private var model = Model()
    var body: some Scene {
        WindowGroup("Otimizador MacTech") {
            ContentView(model: model).frame(minWidth: 830, minHeight: 600)
        }
        .windowResizability(.contentMinSize)
    }
}

struct ContentView: View {
    @ObservedObject var model: Model
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "desktopcomputer.and.shield.checkmark").font(.largeTitle).foregroundStyle(.green)
                VStack(alignment: .leading) {
                    Text("Otimizador MacTech").font(.title2).bold()
                    Text("4.0.0 · Diagnostico e manutencao").foregroundStyle(.secondary)
                }
                Spacer()
                if model.busy { ProgressView().controlSize(.small) }
                Button { model.analyze() } label: { Label("Analisar", systemImage: "magnifyingglass") }.disabled(model.busy)
                Button { model.preview = CleanupEngine.dryRun().joined(separator: "\n\n") } label: {
                    Label("Dry Run", systemImage: "checklist")
                }
            }
            Text(model.status).font(.callout).accessibilityIdentifier("execution-status")
            TabView {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        if let report = model.report {
                            Text("Ultima execucao: \(report.started.formatted()) · \(report.result)").bold()
                            Text("Espaco recuperado: 0 bytes · Alteracoes: \(report.changes.count)")
                            ForEach(report.recommendations, id: \.self) { Text($0).foregroundStyle(.secondary) }
                            Divider()
                            ForEach(report.measurements) { item in
                                DisclosureGroup("\(item.name) · status \(item.exitCode)") {
                                    Text(item.output).font(.system(.caption, design: .monospaced))
                                        .textSelection(.enabled).frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        } else { Text("Nenhuma analise registrada.") }
                    }.frame(maxWidth: .infinity, alignment: .leading).padding()
                }.tabItem { Label("Diagnostico", systemImage: "waveform.path.ecg") }
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(CleanupEngine.categories) { category in
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("\(category.title) · \(category.decision)").bold()
                                    Text("~/\(category.relativePath)").font(.caption).textSelection(.enabled)
                                    Text(category.impact).foregroundStyle(.secondary)
                                }
                                Spacer()
                                Button { model.measure(category) } label: { Image(systemName: "ruler") }
                                    .help("Medir tamanho").disabled(model.busy)
                                Button { NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: category.url.path) } label: {
                                    Image(systemName: "folder")
                                }.help("Revisar no Finder")
                            }
                            Divider()
                        }
                    }.padding()
                }.tabItem { Label("Limpeza e revisao", systemImage: "folder.badge.questionmark") }
                ScrollView {
                    Text(model.preview.isEmpty ? "Nenhuma alteracao planejada." : model.preview)
                        .textSelection(.enabled).frame(maxWidth: .infinity, alignment: .leading).padding()
                }.tabItem { Label("Plano / Dry Run", systemImage: "checklist") }
                Form {
                    Toggle("Diagnostico automatico no login", isOn: Binding(get: { model.startupEnabled }, set: model.startup))
                    Text(model.startupStatus)
                    Text("Proxima execucao: primeiro login do proximo boot; atraso de 120 segundos.")
                    Button("Atualizar estado") { model.refresh() }
                    Button("Abrir Ajustes de Login") { SMAppService.openSystemSettingsLoginItems() }
                    Button("Abrir relatorios") {
                        NSWorkspace.shared.open(DiagnosticsEngine.stateRoot.appendingPathComponent("Reports"))
                    }
                }.padding().tabItem { Label("Configuracoes", systemImage: "gearshape") }
            }
        }.padding(20)
    }
}
