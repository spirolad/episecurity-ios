//
//  DatabaseManager.swift
//  EpiBrother
//
//  Created by Guest User on 23/11/2026.
//

import Foundation

public class DatabaseManager {
    public static let shared = DatabaseManager()
    
    private let fileManager = FileManager.default
    private let cacheDirectoryName = "EpiBrotherCache"
    
    private var cacheURL: URL? {
        guard let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return nil
        }
        let dir = appSupport.appendingPathComponent(cacheDirectoryName)
        if !fileManager.fileExists(atPath: dir.path) {
            try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }
    
    private init() {}
    
    public func save<T: Encodable>(_ object: T, forKey key: String) {
        guard let url = cacheURL?.appendingPathComponent("\(key).json") else { return }
        do {
            let data = try NetworkClient.jsonEncoder.encode(object)
            try data.write(to: url, options: .atomic)
        } catch {
            print("Erreur de sauvegarde locale: \(error)")
        }
    }
    
    public func load<T: Decodable>(forKey key: String, as type: T.Type) -> T? {
        guard let url = cacheURL?.appendingPathComponent("\(key).json"),
              let data = try? Data(contentsOf: url) else {
            return nil
        }
        return try? NetworkClient.jsonDecoder.decode(type, from: data)
    }
    
    public func delete(forKey key: String) {
        guard let url = cacheURL?.appendingPathComponent("\(key).json") else { return }
        try? fileManager.removeItem(at: url)
    }
    
    public func clearAll() {
        guard let dir = cacheURL else { return }
        try? fileManager.removeItem(at: dir)
    }
}
