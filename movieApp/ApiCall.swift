//
//  Api.swift
//  movieApp
//
//  Created by Pavithra on 16/12/21.
//

import Foundation

enum ApiErrors: Error {
    case networkFail(description: String)
    case jsonSerializationFail
    case dataNotReceived
    case castFail
    case internalError
    case unknown
}

extension ApiErrors: LocalizedError {
    public var errorDescription: String? {
        let defaultMessage = "Unknown error!"
        let internalErrorMessage = "Something's wrong! Please contact our support team."
        switch self {
        case .networkFail(let localizedDescription):
            print(localizedDescription)
            return localizedDescription
        case .jsonSerializationFail:
            return internalErrorMessage
        case .dataNotReceived:
            return internalErrorMessage
        case .castFail:
            return internalErrorMessage
        case .internalError:
            return internalErrorMessage
        case .unknown:
            return defaultMessage
        }
    }
}


@objc protocol ApiCallDelegate: NSObjectProtocol {
    func theMovieDB(didFinishUpdatingMovies movies: [Movie])
    @objc optional func theMovieDB(didFinishUpdatingMoviesDetails movies: MovieDetails)
    @objc optional func theMovieDB(didFailWithError error: Error)
}

class ApiCall: NSObject {
    static let apiKey: String = "b9bd48a6"
    static let imageBaseStr: String = "https://image.tmdb.org/t/p/"
    
    var delegate: ApiCallDelegate?
    var endpoint: String
    
    init(endpoint: String) {
        self.endpoint = endpoint
    }
    
    func getSearchResult(serchKey:String) {
        var urlRequest = URLRequest(url: URL(string: "http://www.omdbapi.com/?apikey=\(ApiCall.apiKey)&s=\(serchKey)&type=movie")!)
        urlRequest.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate: nil,
            delegateQueue: OperationQueue.main
        )
        
        let task : URLSessionDataTask = session.dataTask(with: urlRequest, completionHandler:
        { (data, response, error) in
            
            
            guard error == nil else {
                self.delegate?.theMovieDB?(didFailWithError: ApiErrors.networkFail(description: error!.localizedDescription))
                print("ApiCall: \(error!.localizedDescription)")
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                self.delegate?.theMovieDB?(didFailWithError: ApiErrors.unknown)
                print("ApiCall: Unknown error. Could not get response!")
                return
            }
            
            guard response.statusCode == 200 else {
                self.delegate?.theMovieDB?(didFailWithError: ApiErrors.internalError)
                print("ApiCall: Response code was either 401 or 404.")
                return
            }
            
            guard let data = data else {
                self.delegate?.theMovieDB?(didFailWithError: ApiErrors.dataNotReceived)
                print("ApiCall: Could not get data!")
                return
            }
            
            do {
                let movies = try self.movieObjects(with: data)
                self.delegate?.theMovieDB(didFinishUpdatingMovies: movies)
            } catch (let error) {
                self.delegate?.theMovieDB?(didFailWithError: error)
                print("ApiCall: Some problem occurred during JSON serialization.")
                return
            }
            
        });
        task.resume()
    }
    
    func getMovieDetails(imdbID:String) {
        var urlRequest = URLRequest(url: URL(string: "http://www.omdbapi.com/?apikey=\(ApiCall.apiKey)&i=\(imdbID)")!)
        urlRequest.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate: nil,
            delegateQueue: OperationQueue.main
        )
        
        let task : URLSessionDataTask = session.dataTask(with: urlRequest, completionHandler:
        { (data, response, error) in
            
            
            guard error == nil else {
                self.delegate?.theMovieDB?(didFailWithError: ApiErrors.networkFail(description: error!.localizedDescription))
                print("ApiCall: \(error!.localizedDescription)")
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                self.delegate?.theMovieDB?(didFailWithError: ApiErrors.unknown)
                print("ApiCall: Unknown error. Could not get response!")
                return
            }
            
            guard response.statusCode == 200 else {
                self.delegate?.theMovieDB?(didFailWithError: ApiErrors.internalError)
                print("ApiCall: Response code was either 401 or 404.")
                return
            }
            
            guard let data = data else {
                self.delegate?.theMovieDB?(didFailWithError: ApiErrors.dataNotReceived)
                print("ApiCall: Could not get data!")
                return
            }
            
            do {
                let movieDetails = try self.movieDetails(with: data)
                self.delegate?.theMovieDB?(didFinishUpdatingMoviesDetails: movieDetails)
            } catch (let error) {
                self.delegate?.theMovieDB?(didFailWithError: error)
                print("ApiCall: Some problem occurred during JSON serialization.")
                return
            }
            
        });
        task.resume()
    }
    func movieDetails(with data: Data) throws -> MovieDetails {
        do {
            
            guard let responseDictionary = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary else {
                throw ApiErrors.castFail
            }
            
            
            return MovieDetails.movieDetails(with: responseDictionary)
            
        } catch (let error) {
            print("ApiCall: \(error.localizedDescription)")
            throw error
        }
    }
    func movieObjects(with data: Data) throws -> [Movie] {
        do {
            
            guard let responseDictionary = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary else {
                throw ApiErrors.castFail
            }
            
            guard let movieDictionaries = responseDictionary["Search"] as? [NSDictionary] else {
                print("ApiCall: Movie dictionary not found.")
                throw ApiErrors.unknown
            }
            
            return Movie.movies(with: movieDictionaries)
            
        } catch (let error) {
            print("ApiCall: \(error.localizedDescription)")
            throw error
        }
    }
}
