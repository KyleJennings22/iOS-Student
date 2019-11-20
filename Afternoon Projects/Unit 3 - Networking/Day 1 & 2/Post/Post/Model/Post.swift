//
//  Post.swift
//  Post
//
//  Created by Kyle Jennings on 11/18/19.
//  Copyright © 2019 DevMtnStudent. All rights reserved.
//

import Foundation

struct Post: Codable {
    var text: String
    var username: String
    var timestamp: TimeInterval?
    var queryTimestamp: TimeInterval? {
        guard var timestamp = self.timestamp else {return nil}
        timestamp += 0.00001
        return timestamp
    }
    
    init(text: String, username: String, timestamp: TimeInterval = Date().timeIntervalSince1970) {
        self.text = text
        self.username = username
        self.timestamp = timestamp
    }
    
}
