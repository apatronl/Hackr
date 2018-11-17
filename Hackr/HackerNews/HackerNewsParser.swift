//
//  HackerNewsParser.swift
//  Hackr
//
//  Created by Alejandrina Patron on 11/17/18.
//  Copyright © 2018 Alejandrina Patron. All rights reserved.
//

import Foundation

struct HackerNewsParser {
    
    static func parseDataForType(type: HackerNewsItemType, data: Data) {
        switch type {
        case .topStories:
            if let text = String(data: data, encoding: String.Encoding.utf8) {
                let trimemdText = text.trimmingCharacters(in: CharacterSet.init(
                    charactersIn: "[]")).replacingOccurrences(of: " ", with: "")
                let itemIds = trimemdText.components(separatedBy: ",")
                for itemId in itemIds {
                    print(itemId)
                }
            }
        default:
            print("HackerNewsItemType \'\(type.rawValue)\' not yet supported")
        }
    }
    
}
