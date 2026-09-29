import XCTest
import Foundation
@testable import MacTechCore

final class SafetyTests: XCTestCase {
    func temporaryRoot() throws -> URL {
        // macOS /var is a symlink. Fixtures use a physical user path so valid-path
        // tests do not accidentally test rejection of the platform's /var alias.
        let base = FileManager.default.homeDirectoryForCurrentUser
        let root = base.appendingPathComponent(".MacTechTests-" + UUID().uuidString)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: false,
                                               attributes: [.posixPermissions: 0o700])
        addTeardownBlock { try FileManager.default.removeItem(at: root) }
        return root
    }

    func testTraversalAndSiblingRejected() throws {
        let root = try temporaryRoot()
        XCTAssertThrowsError(try SafetyPolicy.validateLocalPath(root.appendingPathComponent("../escape"), under: root))
        XCTAssertThrowsError(try SafetyPolicy.validateLocalPath(URL(fileURLWithPath: root.path + "-other"), under: root))
        XCTAssertThrowsError(try SafetyPolicy.validateLocalPath(URL(fileURLWithPath: "/Volumes/External/file"), under: root))
    }

    func testSymlinkAncestorRejected() throws {
        let root = try temporaryRoot()
        let link = root.appendingPathComponent("link")
        try FileManager.default.createSymbolicLink(at: link, withDestinationURL: root)
        XCTAssertThrowsError(try SafetyPolicy.validateLocalPath(link.appendingPathComponent("child"), under: root))
    }

    func testLockExcludesAndReleases() throws {
        let root = try temporaryRoot()
        var first: ExecutionLock? = try ExecutionLock(root: root)
        XCTAssertThrowsError(try ExecutionLock(root: root))
        withExtendedLifetime(first) {}
        first = nil
        XCTAssertNoThrow(try ExecutionLock(root: root))
    }

    func testUnsafeStatePermissionsRejected() throws {
        let root = try temporaryRoot()
        try FileManager.default.setAttributes([.posixPermissions: 0o777], ofItemAtPath: root.path)
        XCTAssertThrowsError(try ExecutionLock(root: root))
    }

    func testSymlinkLockRejected() throws {
        let root = try temporaryRoot()
        let other = root.appendingPathComponent("other")
        try Data("preserve".utf8).write(to: other)
        try FileManager.default.createSymbolicLink(at: root.appendingPathComponent("execution.lock"), withDestinationURL: other)
        XCTAssertThrowsError(try ExecutionLock(root: root))
        XCTAssertEqual(try String(contentsOf: other, encoding: .utf8), "preserve")
    }

    func testCycleMarkerAndMissingState() throws {
        let root = try temporaryRoot()
        XCTAssertFalse(try DiagnosticsEngine.hasCompleted(boot: "one", root: root))
        try DiagnosticsEngine.markCompleted(boot: "one", root: root)
        XCTAssertTrue(try DiagnosticsEngine.hasCompleted(boot: "one", root: root))
        XCTAssertFalse(try DiagnosticsEngine.hasCompleted(boot: "two", root: root))
        XCTAssertEqual((try FileManager.default.attributesOfItem(atPath: root.appendingPathComponent("last-automatic-boot.txt").path)[.posixPermissions] as? NSNumber)?.intValue, 0o600)
        XCTAssertFalse(try DiagnosticsEngine.bootID().isEmpty)
    }

    func testDryRunDoesNotWrite() throws {
        let root = try temporaryRoot()
        let before = try FileManager.default.contentsOfDirectory(atPath: root.path)
        let plan = CleanupEngine.dryRun()
        XCTAssertEqual(plan.count, 8)
        XCTAssertTrue(plan.allSatisfy { $0.contains("nenhuma exclusao automatica") })
        XCTAssertEqual(try FileManager.default.contentsOfDirectory(atPath: root.path), before)
    }

    func testReportPreservesErrorAndWritesPrivateFile() throws {
        let root = try temporaryRoot()
        let measurement = DiagnosticsEngine.command("/does-not-exist", [], name: "missing")
        XCTAssertEqual(measurement.exitCode, -1)
        let report = Report(id: UUID(), version: "test", reason: "test", started: Date(), duration: 0,
                            measurements: [measurement], recommendations: [], changes: [], recoveredBytes: 0, result: "parcial")
        let url = try DiagnosticsEngine.save(report, root: root)
        XCTAssertEqual((try FileManager.default.attributesOfItem(atPath: url.path)[.posixPermissions] as? NSNumber)?.intValue, 0o600)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let saved = try decoder.decode(Report.self, from: Data(contentsOf: url))
        XCTAssertEqual(saved.measurements[0].exitCode, -1)
        XCTAssertEqual(saved.recoveredBytes, 0)
    }
}
