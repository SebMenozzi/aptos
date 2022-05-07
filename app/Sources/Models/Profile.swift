//
//  Profile.swift
//  App
//
//  Created by Anthony Humay on 5/6/22.
//

import Foundation

struct Profile: Equatable, Encodable {
    let username: String
    let keyPairData: String
    let sharedWalletAddress: String

    enum CodingKeys: String, CodingKey {
        case username = "username"
        case keyPairData = "keyPairData"
        case sharedWalletAddress = "sharedWalletAddress"
    }
}

extension Profile: Decodable {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        let keyPairData = try? values.decode(String.self, forKey: .keyPairData)
        let sharedWalletAddress = try? values.decode(String.self, forKey: .sharedWalletAddress)
        let username = try? values.decode(String.self, forKey: .username)
        
        self.keyPairData = keyPairData ?? ""
        self.username = username ?? ""
        self.sharedWalletAddress = sharedWalletAddress ?? ""
    }
}
