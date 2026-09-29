import Foundation
import Darwin

public enum SafetyError: Error, LocalizedError {
    case refused(String)
    public var errorDescription: String? {
        switch self { case .refused(let message): return message }
    }
}

public enum SafetyPolicy {
    public static func validateLocalPath(_ url: URL, under root: URL) throws {
        let path = url.standardizedFileURL.path
        let base = root.standardizedFileURL.path
        guard path == base || path.hasPrefix(base + "/"), !path.hasPrefix("/Volumes/") else {
            throw SafetyError.refused("Caminho fora da categoria autorizada.")
        }
        var part = URL(fileURLWithPath: "/")
        for component in url.standardizedFileURL.pathComponents.dropFirst() {
            part.appendPathComponent(component)
            var info = stat()
            if lstat(part.path, &info) == 0 {
                guard (info.st_mode & S_IFMT) != S_IFLNK else {
                    throw SafetyError.refused("Links simbolicos nao sao permitidos.")
                }
            } else if errno != ENOENT {
                throw SafetyError.refused("Nao foi possivel validar permissoes do caminho.")
            }
        }
    }

    public static func prepareState(_ root: URL) throws {
        guard geteuid() != 0 else { throw SafetyError.refused("Nao execute como root.") }
        try validateLocalPath(root, under: root)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true,
                                               attributes: [.posixPermissions: 0o700])
        var info = stat()
        guard lstat(root.path, &info) == 0, info.st_uid == geteuid(),
              (info.st_mode & 0o077) == 0 else {
            throw SafetyError.refused("Diretorio de estado precisa ser privado (0700).")
        }
    }
}

public final class ExecutionLock {
    private var descriptor: Int32 = -1
    public init(root: URL) throws {
        try SafetyPolicy.prepareState(root)
        descriptor = open(root.appendingPathComponent("execution.lock").path,
                          O_CREAT | O_RDWR | O_NOFOLLOW | O_CLOEXEC, 0o600)
        guard descriptor >= 0 else { throw SafetyError.refused("Falha ao abrir bloqueio.") }
        var info = stat()
        guard fstat(descriptor, &info) == 0, info.st_uid == geteuid(),
              (info.st_mode & S_IFMT) == S_IFREG, info.st_nlink == 1,
              flock(descriptor, LOCK_EX | LOCK_NB) == 0 else {
            close(descriptor)
            descriptor = -1
            throw SafetyError.refused("Outra execucao esta ativa ou bloqueio invalido.")
        }
    }
    deinit { if descriptor >= 0 { flock(descriptor, LOCK_UN); close(descriptor) } }
}
