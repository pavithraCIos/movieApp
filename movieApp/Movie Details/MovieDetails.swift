//
//  Movie.swift
//  movieApp
//
//  Created by Pavithra on 16/12/21.
//

import Foundation

class MovieDetails: NSObject {
    private(set)var avgRating: Double?
    private(set)var title: String?
    private(set)var year: String?
    private(set)var type: String?
    
    
    private(set)var runtime: String?
    private(set)var imdbRating: String?
    private(set)var director: String?
    private(set)var actors: String?
    private(set)var writer: String?
   // private(set)var type: String?
    
    private(set)var overview: String?
    private(set)var posterImageURL: URL?
    private(set)var backdropImageURL: URL?
    private(set)var releaseYear: String?
    private(set)var score: String?
    private(set)var imdbVotes: String?
    
    init(dictionary: NSDictionary) {
        let title = dictionary["Title"] as? String
        let year = dictionary["Year"] as? String
        let type = dictionary["Type"] as? String
        
        
        
        let runtime = dictionary["Runtime"] as? String

        let score = dictionary["Metascore"] as? String
        let imdbRating = dictionary["imdbRating"] as? String
        let director = dictionary["Director"] as? String
        let actors = dictionary["Actors"] as? String
        let writer = dictionary["Writer"] as? String
        let imdbVotes = dictionary["imdbVotes"] as? String
        
    
        let posterImagePath = dictionary["Poster"] as? String
        let backdropImagePath = dictionary["backdrop_path"] as? String
       
        let overview = dictionary["Plot"] as? String
        let releaseYear = "209"
        //(dictionary["release_date"] as? String)?.Characters.split(separator: "-").map {String($0)}[0]
        
        self.title = title
        self.overview = overview
        self.releaseYear = releaseYear
        self.score = score
        
        self.year = year
        self.type = type
        self.runtime = runtime
        self.imdbRating = imdbRating
        self.director = director
        self.actors = actors
        self.writer = writer
        self.imdbVotes = imdbVotes
        
        if let backdropPath = backdropImagePath {
            self.backdropImageURL = URL(string: backdropPath)
        }
        
        if let posterImagePath = posterImagePath {
            self.posterImageURL = URL(string: posterImagePath)
        }
        
    }
    
    class func movieDetails(with dictionaries: NSDictionary) -> MovieDetails {
        return MovieDetails(dictionary: dictionaries)
    }
    
}
