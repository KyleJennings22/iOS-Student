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
    
    func fetchPosts(reset: Bool = true, completion: @escaping (Result<[Post], PostError>) -> Void) {
        let queryEndInterval = reset ? Date().timeIntervalSince1970 : posts.last?.queryTimestamp ?? Date().timeIntervalSince1970
        let baseURL = URL(string: "http://devmtn-posts.firebaseio.com/posts")
        guard let theURL = baseURL else {return completion(.failure(.invalidURL))}
        
        let urlParameters = [
        "orderBy": "\"timestamp\"",
        "endAt": "\(queryEndInterval)",
        "limitToLast": "15",
        ]
        
        let queryItems = urlParameters.compactMap( { URLQueryItem(name: $0.key, value: $0.value) } )
        
        var urlComponents = URLComponents(url: theURL, resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = queryItems
        
        guard let url = urlComponents?.url else {return completion(.failure(.invalidURL))}
        
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
                if reset {
                    self.posts = posts
                } else {
                    self.posts.append(contentsOf: posts)
                }
                
                return completion(.success(posts))
            } catch {
                print(error, error.localizedDescription)
                return completion(.failure(.noPost))
            }
        }.resume()
    }
    
    func addNewPostWith(username: String, text: String, completion: @escaping (Result<Post, PostError>) -> Void) {
        let post = Post(text: text, username: username)
        var postData: Data?
        do {
            postData = try JSONEncoder().encode(post)
        } catch {
            print(error)
        }
        let baseURL = URL(string: "http://devmtn-posts.firebaseio.com/posts")
        guard let url = baseURL else {return completion(.failure(.invalidURL))}
        let postEndpoint = url.appendingPathExtension("json")
        
        var request = URLRequest(url: postEndpoint)
        request.httpMethod = "POST"
        request.httpBody = postData
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                print(error)
                completion(.failure(.communicationError))
            }
            guard let data = data else {return completion(.failure(.noData))}
            if let dataAsString = String(data: data, encoding: .utf8) {
                print(dataAsString)
            }
        }.resume()
    }
    
}// end of class

enum PostError: LocalizedError {
    case invalidURL
    case communicationError
    case noData
    case noPost
}
