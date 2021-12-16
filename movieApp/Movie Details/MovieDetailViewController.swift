//
//  MovieDetailViewController.swift
//  movieApp
//
//  Created by Pavithra on 16/12/21.
//

import UIKit
import MBProgressHUD

class MovieDetailViewController: UIViewController {
    @IBOutlet var backdropImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var yearLabel: UILabel!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var ratingLabel: UILabel!
    @IBOutlet var overViewLabel: UILabel!
    @IBOutlet var scoreLabel: UILabel!
    @IBOutlet var reviewsLabel: UILabel!
    @IBOutlet var popularityLabel: UILabel!
    @IBOutlet var directorLabel: UILabel!
    @IBOutlet var writerLabel: UILabel!
    @IBOutlet var authorLabel: UILabel!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var contentView: UIView!
    
    var imdbID: String!
    
    var endpoint = "MovieDetails"
    var movieAPI: ApiCall!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        movieAPI = ApiCall(endpoint: endpoint)
        movieAPI.delegate = self
        self.getMovieDetails()
        // Do any additional setup after loading the view.
    }
}
extension MovieDetailViewController {
    func getMovieDetails() {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        movieAPI.getMovieDetails(imdbID: imdbID)
    }
}
extension MovieDetailViewController: ApiCallDelegate {
    func theMovieDB(didFinishUpdatingMovies movies: [Movie]) {}
    
    func theMovieDB(didFinishUpdatingMoviesDetails movies: MovieDetails) {
        MBProgressHUD.hide(for: self.view, animated: true)
        DispatchQueue.main.async {
            self.titleLabel.text = movies.title
            self.yearLabel.text = movies.year
            self.categoryLabel.text = movies.type
            self.overViewLabel.text = movies.overview
            
            if let value:Int = Int(movies.runtime?.trimmingCharacters(in: CharacterSet(charactersIn: "0123456789.").inverted) ?? ""){
            
                let hour = "\(value / 60)h"
                let min = "\(value % 60)m"
            
            self.timeLabel.text = hour + min
            }
            self.scoreLabel.text = movies.score
           self.reviewsLabel.text = movies.imdbVotes
            self.ratingLabel.text = movies.imdbRating
            self.directorLabel.text = movies.director
            self.authorLabel.text = movies.actors
            self.writerLabel.text = movies.writer
            if let posterImageURL = movies.posterImageURL {
                self.backdropImageView?.setImageWith(posterImageURL, placeholderImage: #imageLiteral(resourceName: "placeholderImage"))
            } else {
                self.backdropImageView?.image = #imageLiteral(resourceName: "user")
            }
        }
       
    }
    
    func theMovieDB(didFailWithError error: Error) {
        MBProgressHUD.hide(for: self.view, animated: true)
        DispatchQueue.main.async {
          
        }
       
    }
}
