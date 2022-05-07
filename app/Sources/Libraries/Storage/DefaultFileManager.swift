//
//  DefaultFileManager.swift
//  App
//
//  Created by Anthony Humay on 5/6/22.
//

import Foundation

class DefaultFileManager {
    enum Error: Swift.Error {
        case fileAlreadyExists
        case invalidDirectory
        case writingFailed
        case fileDoesNotExist
        case readingFailed
    }
    
    let fileManager: FileManager
    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }
    
    func read(fileNamed: String) throws -> Data {
        let documentDirectoryUrl = try! FileManager.default.url(
           for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true
        )
        let fileUrl = documentDirectoryUrl.appendingPathComponent(fileNamed).appendingPathExtension("txt")

        do {
           return try Data(contentsOf: fileUrl)
        } catch let error as NSError {
           print(error)
            throw Error.readingFailed
        }
   }

    func save(fileNamed: String, data: Data) throws {
        let documentDirectoryUrl = try! FileManager.default.url(
           for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true
        )
        let fileUrl = documentDirectoryUrl.appendingPathComponent(fileNamed).appendingPathExtension("txt")
        do {
            try data.write(to: fileUrl, options: .atomic)
        } catch let error as NSError {
           print(error)
        }
    }
    
    func remove(fileNamed: String) throws {
        let documentDirectoryUrl = try! FileManager.default.url(
           for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true
        )
        let fileUrl = documentDirectoryUrl.appendingPathComponent(fileNamed).appendingPathExtension("txt")
        do {
           return try FileManager.default.removeItem(at: fileUrl)
        } catch let error as NSError {
           print(error)
        }
   }
}
