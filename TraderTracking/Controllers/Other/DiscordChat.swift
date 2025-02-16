//
//  DiscordChat.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 6/29/24.
//

import Foundation
import Alamofire
import RealmSwift
import UIKit
import SwiftUI


class DiscordBot: NSObject, ObservableObject {
    private let realm: RealmController = RealmController.shared
    

    
    private let baseAPIURL = "https://discord.com/api/v9"
    
    var discordTokens: DiscordTokens
    override init() {
        discordTokens = DiscordTokens()
        super.init()
    }
    
    
    func fetchMessages(channelId: String, fromDate: Date, completion: @escaping ([DiscordMessage]) -> Void) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        // Convert the date to Unix timestamp
        let fromTimestamp = snowflake(from: fromDate)
        
        // Add the `before` and `after` parameters to filter messages by date range
        let url = "\(baseAPIURL)/channels/\(channelId)/messages?after=\(fromTimestamp)"
        let headers: HTTPHeaders = [
            "Authorization": "Bot \(discordTokens.discordToken)",
            "Content-Type": "application/json"
        ]
        
        AF.request(url, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                if let messagesData = try? JSONSerialization.data(withJSONObject: value),
                   let messages = try? JSONDecoder().decode([DiscordMessage].self, from: messagesData) {
                    completion(messages)
                } else {
                    completion([])
                }
            case .failure(let error):
                print("Error fetching messages: \(error)")
                completion([])
            }
        }
    }
    
    func snowflake(from date: Date) -> String {
        // Discord epoch: 1420070400000 (January 1, 2015)
        let discordEpoch: Int64 = 1420070400000
        let timestamp = Int64(date.timeIntervalSince1970 * 1000)
        let snowflake = (timestamp - discordEpoch) << 22 // Shift by 22 bits to fit Discord's structure
        return String(snowflake)
    }

    
    
    func updateTradesJournal(completion: @escaping () -> Void) {
        let fromDate = UserDefaults.standard.object(forKey: "discordLastTradeFetched") as! Date
        fetchMessages(channelId: discordTokens.tradeChannelId, fromDate: fromDate) { messages in
            let discordMessages: [DiscordMessage] = messages
            for i in discordMessages {
                let temp = Trade_Journal()
                temp.date = Date().discordMessageStringToDate(dateString: i.date!) ?? Date()
                self.downloadImages(from: i.attachments ?? []) { images, urls, thumbnails  in
                    temp.imageLocalUrl = self.saveImagesToDirectory(imageDataList: images, directoryName: "Journal/Trades/" + temp._id.stringValue)?.absoluteString ?? ""
                    temp.thumbnailImages.append(objectsIn: thumbnails)
                    temp.webImages.append(objectsIn: urls)
                    temp.content = i.content ?? ""
                    self.realm.addTradeJournal(entry: temp)
                }
            }
            if messages.count > 0 {
                let lastMessageDate = Date().discordMessageStringToDate(dateString: (discordMessages.first?.date ?? "")) ?? Date()
                UserDefaults.standard.set(lastMessageDate.addingTimeInterval(1), forKey: "discordLastTradeFetched")
            }
            completion()  // Notify the completion
        }
    }
    
    func updateForecastJournal(completion: @escaping () -> Void) {
        let fromDate = UserDefaults.standard.object(forKey: "discordLastForecastFetched") as! Date
        fetchMessages(channelId: discordTokens.forecastChannelId, fromDate: fromDate) { messages in
            let discordMessages: [DiscordMessage] = messages
            for i in discordMessages {
                let temp = Forecast_Journal()
                temp.date = Date().discordMessageStringToDate(dateString: i.date!) ?? Date()
                self.downloadImages(from: i.attachments ?? []) { images, urls, thumbnails  in
                    temp.imageLocalUrl = self.saveImagesToDirectory(imageDataList: images, directoryName: "Journal/Forecast/" + temp._id.stringValue)?.absoluteString ?? ""
                    temp.thumbnailImages.append(objectsIn: thumbnails)
                    temp.webImages.append(objectsIn: urls)
                    temp.content = i.content ?? ""
                    self.realm.addForecastJournal(forecast: temp)
                }
            }
            if messages.count > 0 {
                let lastMessageDate = Date().discordMessageStringToDate(dateString: (discordMessages.first?.date ?? "")) ?? Date()
                UserDefaults.standard.set(lastMessageDate.addingTimeInterval(1), forKey: "discordLastForecastFetched")
            }
            completion()  // Notify the completion
        }
    }
    
    func updateReviewJournal(completion: @escaping () -> Void) {
        let fromDate = UserDefaults.standard.object(forKey: "discordLastReviewFetched") as! Date
        fetchMessages(channelId: discordTokens.reviewChannelId, fromDate: fromDate) { messages in
            let discordMessages: [DiscordMessage] = messages
            for i in discordMessages {
                let temp = Review_Journal()
                temp.date = Date().discordMessageStringToDate(dateString: i.date!) ?? Date()
                self.downloadImages(from: i.attachments ?? []) { images, urls, thumbnails  in
                    temp.imageLocalUrl = self.saveImagesToDirectory(imageDataList: images, directoryName: "Journal/Reviews/" + temp._id.stringValue)?.absoluteString ?? ""
                    temp.thumbnailImages.append(objectsIn: thumbnails)
                    temp.webImages.append(objectsIn: urls)
                    temp.content = i.content ?? ""
                    self.realm.addReviewJournal(review: temp)
                }
            }
            if messages.count > 0 {
                let lastMessageDate = Date().discordMessageStringToDate(dateString: (discordMessages.first?.date ?? "")) ?? Date()
                UserDefaults.standard.set(lastMessageDate.addingTimeInterval(1), forKey: "discordLastReviewFetched")
            }
            completion()  // Notify the completion
        }
    }
    
    func downloadImages(from attachments: [DiscordAttachment], completion: @escaping ([Data], [String], [Data]) -> Void) {
        var images = [Data]()
        var webImages: [String] = []
        var thumbnails = [Data]()
        let group = DispatchGroup()
        
        for attachment in attachments {
            webImages.append(attachment.url)
            if let url = URL(string: attachment.url) {
                group.enter()
                downloadImageData(from: url) { data, thumbnail in
                    defer { group.leave() }
                    if let imageData = data {
                        images.append(imageData)
                        thumbnails.append(thumbnail)
                    } else {
                        print("Failed to download image")
                    }
                }
            }
        }
        
        group.notify(queue: DispatchQueue.main) {
            completion(images, webImages, thumbnails)
        }
    }
    
    func downloadImageData(from url: URL, completion: @escaping (Data?, Data) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error downloading image: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil, Data())
                return
            }
            completion(data, self.createThumbnail(from: data, thumbnailSize: CGSize(width: 400, height: 300))!)
        }
        task.resume()
    }
    
    func createThumbnail(from imageData: Data, thumbnailSize: CGSize) -> Data? {
        // Convert Data to UIImage
        guard let image = UIImage(data: imageData) else {
            print("Failed to create UIImage from Data.")
            return nil
        }
        
        // Create a thumbnail from the UIImage
        let renderer = UIGraphicsImageRenderer(size: thumbnailSize)
        let thumbnailImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: thumbnailSize))
        }
        
        // Convert the thumbnail UIImage back to Data (PNG format)
        return thumbnailImage.pngData()
    }
    
    func createDirectory(named directoryName: String) -> URL? {
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Could not find documents directory.")
            return nil
        }
        
        let directoryURL = documentsDirectory.appendingPathComponent(directoryName)
        
        if !fileManager.fileExists(atPath: directoryURL.path) {
            do {
                try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
                print("Directory created at \(directoryURL)")
            } catch {
                print("Error creating directory: \(error)")
                return nil
            }
        }
        
        return directoryURL
    }
    
    func saveImagesToDirectory(imageDataList: [Data], directoryName: String) -> URL? {
        
        // Create or get the directory
        guard let directoryURL = createDirectory(named: directoryName) else {
            print("Could not create or find directory.")
            return nil
        }
        
        for (index, imageData) in imageDataList.enumerated() {
            // Create a unique file name for each image
            let fileName = "image_\(index + 1).png"
            let fileURL = directoryURL.appendingPathComponent(fileName)
            
            do {
                // Write the data to the file
                try imageData.write(to: fileURL)
                print("File saved successfully at \(fileURL)")
                
            } catch {
                print("Error saving file: \(error)")
            }
        }
        
        return directoryURL
    }
}


struct DiscordMessage: Codable, Identifiable {
    let id: UUID = UUID()
    let content: String?
    let date: String?
    let attachments: [DiscordAttachment]?
    
    var scrollPosition: UUID?
    
    enum CodingKeys: String, CodingKey {
        case content = "content"
        case attachments = "attachments"
        case date = "timestamp"
    }
}

struct DiscordAttachment: Codable, Identifiable {
    let id: UUID = UUID()
    let filename: String
    let url: String
    let proxyUrl: String
    let size: Int
    let height: Int?
    let width: Int?
    
    var scrollPosition: UUID?
    
    enum CodingKeys: String, CodingKey {
        case filename = "filename"
        case url = "url"
        case proxyUrl = "proxy_url"
        case size = "size"
        case height = "height"
        case width = "width"
    }
}


