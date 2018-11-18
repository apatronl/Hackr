//
//  HackerNewsStory.swift
//  Hackr
//
//  Created by Alejandrina Patron on 11/17/18.
//  Copyright © 2018 Alejandrina Patron. All rights reserved.
//

import Foundation

struct HackerNewsStory {

    let by: String?
    let descendants: Int?
    let id: String?
    let kids: [String]?
    let score: Int?
    //    let time: Date
    let title: String?
    let url: String?
    
    init(by: String?, descendants: Int?, id: String?, kids: [String]?, score: Int?, title: String?,
         url: String?) {
        self.by = by
        self.descendants = descendants
        self.id = id
        self.kids = kids
        self.score = score
        self.title = title
        self.url = url
    }
    
}

//extension HackerNewsStory: Decodable {
//
//    init(from decoder: Decoder) throws {
//        
//    }
//
//}
