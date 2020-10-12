//
//  TrustPolicy.swift
//  NetworkKit
//
//  Created by Aleksandar Sergeev Petrov on 7.10.20.
//

import Foundation
import Alamofire

public typealias RevocationOptions = Alamofire.RevocationTrustEvaluator.Options

public enum APITrustPolicyType {
    /// **THIS SHOULD NEVER BE USED IN PRODUCTION!**
    case none
    ///
    case host
    ///
    case revocation(options: RevocationOptions)
    ///
    case pinnedCertificates(certificatesProvider: PinnedCertificatesProvider)
    ///
    case publicKeys(keysProvider: PublicKeysProvider)
}

public protocol PinnedCertificatesProvider {
    var certificates: [SecCertificate] { get }
    var acceptSelfSignedCertificates: Bool { get }
}

extension PinnedCertificatesProvider {
    var certificates: [SecCertificate] {
        Bundle.main.af.certificates
    }

    var acceptSelfSignedCertificates: Bool {
        false
    }
}

public protocol PublicKeysProvider {
    var keys: [SecKey] { get }
}

extension PinnedCertificatesProvider {
    var keys: [SecKey] {
        Bundle.main.af.publicKeys
    }
}
