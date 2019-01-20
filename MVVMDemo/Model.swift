//
//  Model.swift
//  MVVMDemo
//
//  Created by Аскар on 1/20/19.
//  Copyright © 2019 askar.ulubayev168. All rights reserved.
//

import Foundation
import RxSwift

struct GithubSearchResult: Codable {
    var items: [GithubRepository]
    var totalCount: Int
}

struct GithubRepository: Codable {
    var fullName: String
    var stargazersCount: Int
}

class Model {
    
    func search(with keyword: String) -> Observable<GithubSearchResult> {
        let url = URL(string: "https://api.github.com/search/repositories?q=\(keyword)")!
        let request = URLRequest(url: url)
        return URLSession.shared.rx.response(request: request)
            .map { (response, data) in
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                do {
                    return try decoder.decode(GithubSearchResult.self, from: data)
                } catch {
                    print(error.localizedDescription)
                }
                return GithubSearchResult(items: [], totalCount: 0)
        }
    }
}

