//
//  PostController.swift
//  Post
//
//  Created by Kyle Jennings on 11/18/19.
//  Copyright © 2019 DevMtnStudent. All rights reserved.
//

import Foundation

class PostController {
    
    
    var posts: [Post] = []
    
    func fetchPosts(completion: @escaping (Result<[Post], PostError>) -> Void) {
        let baseURL = URL(string: "http://devmtn-posts.firebaseio.com/posts")
        guard let url = baseURL else {return completion(.failure(.invalidURL))}
        
        let getterEndpoint = url.appendingPathExtension("json")
        
        var request = URLRequest(url: getterEndpoint)
        request.httpBody = nil
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: getterEndpoint) { (data, _, error) in
            if let error = error {
                print(error, error.localizedDescription)
                return completion(.failure(.communicationError))
            }
            guard let data = data else {return completion(.failure(.noData))}
            let decoder = JSONDecoder()
            do {
                let postsDictionary = try decoder.decode([String:Post].self, from: data)
                let posts = postsDictionary.compactMap({$0.value})
                self.posts = posts
                return completion(.success(posts))
            } catch {
                print(error, error.localizedDescription)
                return completion(.failure(.noPost))
            }
        }.resume()
    }
}

enum PostError: LocalizedError {
    case invalidURL
    case communicationError
    case noData
    case noPost
}
