//
//  APICaller.swift
//  NewsApp
//
//  Created by Nikolaos Mikrogeorgiou on 14/11/21.
//

import Foundation

final class APICaller {
    // instance of API (singleton)
    static let shared = APICaller()
    
    struct Constants {
        static let topHeadlinesURL = URL(string: "https://newsapi.org/v2/top-headlines?country=gr&apiKey=b11e48a26d9d4be2aecb6ecbbdbd81a7")
        // search functionality (add &q=Query, where query is difined in the search)
        static let searchUrlString = "https://newsapi.org/v2/everything?sortedBy=popularity&apiKey=b11e48a26d9d4be2aecb6ecbbdbd81a7&q="
    }
    
    private init() {}
    
    // Network call
    public func getTopStories(completion: @escaping (Result<[Article], Error>) -> Void) {
        guard let url = Constants.topHeadlinesURL else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) {data, _, error in
            if let error = error {
                completion(.failure(error))
            }
            else if let data = data {
                do {
                    let result = try JSONDecoder().decode(APIResponse.self, from: data)
                    
                    print("Articles: \(result.articles.count)")
                    completion(.success(result.articles))
                }
                catch {
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
    }
    
    // Search function
    public func search(with query: String, completion: @escaping (Result<[Article], Error>) -> Void) {
        // if user types in a bunch of spaces, trim them
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        
        let urlString = Constants.searchUrlString + query
        guard let url = URL(string: urlString) else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) {data, _, error in
            if let error = error {
                completion(.failure(error))
            }
            else if let data = data {
                do {
                    let result = try JSONDecoder().decode(APIResponse.self, from: data)
                    
                    print("Articles: \(result.articles.count)")
                    completion(.success(result.articles))
                }
                catch {
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
    }
}

// -MARK: Models

struct APIResponse: Codable {
    let articles: [Article]
}

struct Article: Codable {
    let source: Source
    let title: String
    let description: String?
    let url: String?
    let urlToImage: String?
    let publishedAt: String
}

struct Source: Codable {
    let name: String
}
