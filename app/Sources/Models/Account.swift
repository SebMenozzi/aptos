//
//  Account.swift
//  App
//
//  Created by Anthony Humay on 5/6/22.
//

import Foundation

struct Account: Equatable, Encodable {
    let username: String
    let publicKey: String
    let privateKey: String
    let multisigAuthenticationKey: String

    enum CodingKeys: String, CodingKey {
        case username = "username"
        case publicKey = "publicKey"
        case privateKey = "privateKey"
        case multisigAuthenticationKey = "multisigAuthenticationKey"
    }
}

extension Account: Decodable {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        let publicKey = try? values.decode(String.self, forKey: .publicKey)
        let privateKey = try? values.decode(String.self, forKey: .privateKey)
        let username = try? values.decode(String.self, forKey: .username)
        let multisigAuthenticationKey = try? values.decode(String.self, forKey: .multisigAuthenticationKey)
        
        self.publicKey = publicKey ?? ""
        self.privateKey = privateKey ?? ""
        self.username = username ?? ""
        self.multisigAuthenticationKey = multisigAuthenticationKey ?? ""
    }
}
