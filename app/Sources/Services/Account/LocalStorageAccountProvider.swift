//
//  LocalStorageProfileProvider.swift
//  App
//
//  Created by Anthony Humay on 5/6/22.
//

import Foundation

// TODO: Ideally these functions are all defined in protocols, overkill for hackathon
struct LocalStorageProfileProvider {
    private let fileManager = DefaultFileManager()
    
    // Load from disk (if it exists)
    func loadProfile() -> Profile? {
        do {
            let accountData = try fileManager.read(fileNamed: Constants.accountDataKey)
            let decoder = JSONDecoder()
            let existingProfile = try decoder.decode(Profile.self, from: accountData)
            print("Existing account username: \(existingProfile.username ?? "")")
            return existingProfile
        } catch {
            print("ERROR loading account: \(error)")
            return nil
        }
    }
    
    // Create account, returns true if successful
    func storeProfile(newProfile: Profile) -> Bool {
        let encoder = JSONEncoder()
        do {
            let encodedAccountData = try encoder.encode(newProfile)
            try fileManager.save(fileNamed: Constants.accountDataKey, data: encodedAccountData)
            print("Created account with username: \(newProfile.username ?? "")")
        } catch {
            print("ERROR creating account: \(error)")
            return false
        }
        return true
    }

    // Delete account data from disk
    func deleteAccount() -> Bool {
        do {
            try fileManager.remove(fileNamed: Constants.accountDataKey)
            print("Deleted account!")
        } catch {
            print("ERROR deleting account: \(error)")
            return false
        }
        return true
    }
        
    func createDemoAccount() -> Profile {
        return Profile(username: "username", publicKey: "0xpublickey", privateKey: "0xprivatekey", multisigAuthenticationKey: "0xhula")
    }
}
