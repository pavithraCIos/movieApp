//
//  Movie.swift
//  movieApp
//
//  Created by Pavithra on 16/12/21.
//

import Foundation

class Movie: NSObject {
    private(set)var title: String?
    private(set)var posterImageURL: URL?
    private(set)var imdbID: String?
    
    init(dictionary: NSDictionary) {
        let posterImagePath = dictionary["Poster"] as? String
        let title = dictionary["Title"] as? String
        let imdbID = dictionary["imdbID"] as? String
        self.title = title
        self.imdbID = imdbID
        
        if let posterImagePath = posterImagePath {
            self.posterImageURL = URL(string: posterImagePath)
        }
    }
    
    class func movies(with dictionaries: [NSDictionary]) -> [Movie] {
        return dictionaries.map {Movie(dictionary: $0)}
    }
}
