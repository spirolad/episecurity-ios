//
//  JailbreakDetector.swift
//  EpiBrother
//
//  Created by Guest User on 23/11/2026.
//

import Foundation

#if canImport(UIKit)
import UIKit
#endif

public class JailbreakDetector {
    public static let shared = JailbreakDetector()
    
    private let suspiciousFiles = [
        "/Applications/Cydia.app",
        "/Library/MobileSubstrate/MobileSubstrate.dylib",
        "/bin/bash",
        "/usr/sbin/sshd",
        "/etc/apt",
        "/private/var/lib/apt/",
        "/usr/bin/ssh"
    ]
    
    private init() {}
    
    public func isJailbroken() -> Bool {
        #if targetEnvironment(simulator)
        return false
        #else
        return checkSuspiciousFiles() || checkWriteAccessOutsideSandbox()
        #endif
    }
    
    private func checkSuspiciousFiles() -> Bool {
        let fileManager = FileManager.default
        for path in suspiciousFiles {
            if fileManager.fileExists(atPath: path) {
                return true
            }
        }
        return false
    }
    
    private func checkWriteAccessOutsideSandbox() -> Bool {
        let testPath = "/private/epibrother_jailbreak_check.txt"
        do {
            try "check".write(toFile: testPath, atomically: true, encoding: .utf8)
            try? FileManager.default.removeItem(atPath: testPath)
            return true
        } catch {
            return false
        }
    }
}
