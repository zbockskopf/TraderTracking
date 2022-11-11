//
//  ImageHandeling.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 9/20/22.
//

import Foundation
import UIKit
import SwiftUI


class MyImages {
    func saveImages(directory: String, images: [UIImage]) {
        
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        let directoryURL = documentsDirectory.appendingPathComponent(directory)
        
        //Create a new directory
        if !FileManager.default.fileExists(atPath: directoryURL.path) {
            do {
                try FileManager.default.createDirectory(atPath: directoryURL.path, withIntermediateDirectories: true, attributes: nil)
            } catch let removeError {
                print("couldn't remove file at path", removeError)
            }
            
        }
        //Add new files to the directory
        var count = 1
        for i in images {
            let fileName = String(count)
            let fileURL = directoryURL.appendingPathComponent(fileName)
            guard let data = i.pngData() else { return }
            //Checks if file exists, removes it if so.
            if FileManager.default.fileExists(atPath: fileURL.path) {
                do {
                    try FileManager.default.removeItem(atPath: fileURL.path)
                    print("Removed old image")
                } catch let removeError {
                    print("couldn't remove file at path", removeError)
                }
                
            }
            
            do {
                try data.write(to: fileURL)
            } catch let error {
                print("error saving file with error", error)
            }
            
            count += 1
        }
    }
    
    func loadImageFromDiskWith(directory: String) -> [UIImage]? {
        var temp: [UIImage] = []

        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        let directoryURL = documentsDirectory.appendingPathComponent(directory)
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil)
            let newArr = fileURLs.sorted { ($0.pathComponents.last?.components(separatedBy: ".").first)! < ($1.pathComponents.last?.components(separatedBy: ".").first)!}
            for file in newArr {
                let image = UIImage(contentsOfFile: file.path)
                if image != nil {
                    temp.append(image!)
                }
            }
            
            return temp
        } catch {
            print("Error while enumerating files \(directoryURL.path): \(error.localizedDescription)")
        }
        
        return nil
    }
    
    
    func deleteImage(fileName: String) {
        
        let documentDirectory = FileManager.SearchPathDirectory.documentDirectory
        
        let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)
        
        if let dirPath = paths.first {
            let imageUrl = URL(fileURLWithPath: dirPath).appendingPathComponent(fileName)
            do {
                try FileManager.default.removeItem(at: imageUrl)
            } catch let error as NSError {
                print("Error: \(error.domain)")
            }
        }
    }
    
    func deleteAllImages(directories: [String]) {
        do {
            let fileManager = FileManager.default
            guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
            
            for i in directories {
                // Check if file exists
                let directoryURL = documentsDirectory.appendingPathComponent(i)
                if fileManager.fileExists(atPath: directoryURL.path) {
                    // Delete file
                    try fileManager.removeItem(atPath: directoryURL.path)
                } else {
                    print("File does not exist")
                }
            }
            
        } catch {
            print("An error took place: \(error)")
        }
    }
}
