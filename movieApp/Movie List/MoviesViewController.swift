//
//  ViewController.swift
//  movieApp
//
//  Created by Pavithra on 16/12/21.
//

import UIKit
import MBProgressHUD
import AFNetworking

class MoviesViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet var searchBar: UISearchBar!
    
    // MARK: - Stored Properties
    
    @IBOutlet var collectionView: UICollectionView!
    var profileBarButtonItem: UIBarButtonItem!
    var collectionViewRefreshControl: UIRefreshControl!
    var endpoint = ""
    var movieAPI: ApiCall!
    var errorBannerView: UIView!
    var movies = [Movie]()
    
    // MARK: - Property Observers
    
    
    var filteredMovies = [Movie]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var isErrorBannerDisplayed: Bool! {
        didSet {
            errorBannerView.isHidden = !isErrorBannerDisplayed
        }
    }
    
    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        movieAPI = ApiCall(endpoint: endpoint)
        movieAPI.delegate = self
        
        self.edgesForExtendedLayout = []
        isErrorBannerDisplayed = false
        searchBar.delegate = self
        profileBarButtonItem.image = #imageLiteral(resourceName: "user")
    }
    
    @objc func refreshData() {
        fetchDataFromWeb()
    }
}


// MARK: - Network Requests

extension MoviesViewController {
    func fetchDataFromWeb() {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        movieAPI.getSearchResult(serchKey: searchBar.text ?? "")
    }
}

// MARK: - SearchBar Delegate

extension MoviesViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredMovies = searchText.isEmpty ? movies :  movies.filter {($0.title ?? "").range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil }
        collectionView.reloadData()

    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        filteredMovies = movies
        searchBar.resignFirstResponder()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        fetchDataFromWeb()
        searchBar.resignFirstResponder()
    }
}

// MARK: - TheMovieDbApi Delegate

extension MoviesViewController: ApiCallDelegate {
    func theMovieDB(didFinishUpdatingMovies movies: [Movie]) {
        MBProgressHUD.hide(for: self.view, animated: true)
        self.movies = movies
        self.filteredMovies = movies
        DispatchQueue.main.async {
            self.collectionViewRefreshControl.endRefreshing()
        }
        isErrorBannerDisplayed = false
    }
    
    func theMovieDB(didFailWithError error: Error) {
        MBProgressHUD.hide(for: self.view, animated: true)
        DispatchQueue.main.async {
            self.collectionViewRefreshControl.endRefreshing()
        }
        isErrorBannerDisplayed = true
    }
}

// MARK: - Navigation

extension MoviesViewController {
    
    func pushToDetailVC(with indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detailVC = storyboard.instantiateViewController(withIdentifier: "movieDetailVC") as! MovieDetailViewController
        detailVC.imdbID = filteredMovies[indexPath.row].imdbID
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - CollectionView Delegate

extension MoviesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        pushToDetailVC(with: indexPath)
    }
}
extension MoviesViewController: UICollectionViewDataSource {
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return movies.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "movieCollectionCell", for: indexPath) as! MovieCollectionCell
            cell.titleLabel?.text = movies[indexPath.row].title
            if let posterImageURL = movies[indexPath.row].posterImageURL {
                cell.posterImageView?.setImageWith(posterImageURL, placeholderImage: #imageLiteral(resourceName: "placeholderImage"))
            } else {
                cell.posterImageView?.image = #imageLiteral(resourceName: "user")
            }
            return cell
        }
}
// MARK: - Helpers

extension MoviesViewController {
    func setupViews() {
        setupErrorBannerView()
        setupCollectionView()
        setupRefreshControls()
        setupChangeLayoutBarButton()
    }
    
    func setupCollectionView() {
        collectionView.collectionViewLayout = createCollectionViewLayout()
        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.dataSource = self
    }
    private func createCollectionViewLayout() -> UICollectionViewLayout {
      //  let heightDimension = NSCollectionLayoutDimension.estimated(100)
        
        let itemSize = NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1),
          heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 10, trailing: 2)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .fractionalWidth(2/2.7))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        
        let section = NSCollectionLayoutSection(group: group)
        return UICollectionViewCompositionalLayout(section: section)
    }
    func setupRefreshControls() {
        collectionViewRefreshControl = UIRefreshControl()
        collectionViewRefreshControl.addTarget(self, action: #selector(self.refreshData), for: .valueChanged)
        collectionView.insertSubview(collectionViewRefreshControl, at: 0)
    }
    
    func setupChangeLayoutBarButton() {
        profileBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "user"), style: .plain, target: self, action: nil)
        self.navigationItem.rightBarButtonItem = profileBarButtonItem
    }
    
    func setupErrorBannerView() {
        let errorView = UIView(frame: CGRect(x: 0, y: UIScreen.main.bounds.size.height*0.5, width: collectionView.frame.size.width, height: 45))
        errorView.backgroundColor = .darkGray
        let errorLabel = UILabel(frame: CGRect(x: errorView.bounds.origin.x + 8, y: errorView.bounds.origin.y + 8, width: errorView.bounds.width - 8, height: errorView.bounds.height - 8))
        errorLabel.textColor = .white
        let mutableString = NSMutableAttributedString(attributedString: NSAttributedString(string: "Search result not found", attributes: [NSAttributedString.Key.font : UIFont(name: "HelveticaNeue-Bold", size: 15)!, NSAttributedString.Key.foregroundColor : UIColor.white]))
        errorLabel.attributedText = mutableString
        errorLabel.textAlignment = .center
        errorView.addSubview(errorLabel)
        errorBannerView = errorView
        self.view.addSubview(errorBannerView)
    }
}
