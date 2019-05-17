//
//  PokemonController.swift
//  Pokedex
//
//  Created by Hayden Hastings on 5/17/19.
//  Copyright © 2019 Hayden Hastings. All rights reserved.
//

import UIKit

class PokemonController {
    
    
    private let baseURL = URL(string: "https://pokeapi.co/api/v2/pokemon")!
    
    // MARK: - Methods
    
    func searchForPokemon(with searchTerm: String, completion: @escaping (Result<Pokemon, NetworkError>) -> Void) {
        
        let requestURL = baseURL.appendingPathComponent("name")
        
        var urlComponents = URLComponents(url: requestURL, resolvingAgainstBaseURL: true)
        let searchQueryItem = URLQueryItem(name: "search", value: searchTerm)
        urlComponents?.queryItems = [searchQueryItem]
        
        var request = URLRequest(url: requestURL)
        
        request.httpMethod = HTTPMethod.get.rawValue
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            
            if let error = error {
                NSLog("Error searching for pokemon: \(error)")
                completion(.failure(.apiError))
                return
            }
            
            guard let data = data else {
                NSLog("No data returned from data task.")
                completion(.failure(.noDataReturned))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                
                let pokemonSearch = try decoder.decode(Pokemon.self, from: data)
                
                completion(.success(pokemonSearch))
                
            } catch {
                NSLog("Error decoding PokemonSearch from data: \(error)")
                completion(.failure(.noDecode))
            }
        }.resume()
    }
    
    func fetchImage(at urlString: String, completion: @escaping (Result<UIImage, NetworkError>) -> Void) {
        let imageURL = URL(string: urlString)!
        
        var request = URLRequest(url: imageURL)
        request.httpMethod = HTTPMethod.get.rawValue
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                completion(.failure(.apiError))
                return
            }
            
            guard let data = data else {
                completion(.failure(.noDataReturned))
                return
            }
            
            let image = UIImage(data: data)!
            completion(.success(image))
        }.resume()
    }
    
    // MARK: - Properties
    
    var pokemon: [Pokemon] = []
    
    enum NetworkError: Error {
        case noDataReturned
        case noBearer
        case badAuth
        case apiError
        case noDecode
    }
    
    enum HTTPMethod: String {
        case get = "GET"
        case put = "PUT"
        case post = "POST"
        case delete = "DELETE"
    }
}
