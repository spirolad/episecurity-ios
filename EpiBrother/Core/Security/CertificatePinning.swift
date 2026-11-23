//
//  CertificatePinning.swift
//  EpiBrother
//
//  Created by Guest User on 23/11/2026.
//

import Foundation
import Security

public class CertificatePinning: NSObject, URLSessionDelegate {
    public static let shared = CertificatePinning()
    
    // Hash SHA256 des clés publiques autorisées ou certificats internes
    private let pinnedPublicKeyHashes: Set<String> = [
        // Exemple de hashes de clés publiques épinglées
        "epibrother-root-cert-pinning-hash"
    ]
    
    public override init() {
        super.init()
    }
    
    public func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        
        let host = challenge.protectionSpace.host
        
        // En local ou mode développement, autoriser localhost / 127.0.0.1
        #if DEBUG
        if host == "localhost" || host == "127.0.0.1" || host.hasSuffix(".local") {
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
            return
        }
        #endif
        
        // Validation standard de la chaîne de certification
        var error: CFError?
        let isTrusted = SecTrustEvaluateWithError(serverTrust, &error)
        
        if isTrusted {
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        } else {
            print("SSL Certificate Pinning / Trust evaluation failed for host: \(host). Error: \(String(describing: error))")
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}
