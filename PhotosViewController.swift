//
//  PhotosViewController.swift
//  Photorama
//
//  Created by Adam Hogan on 8/1/17.
//  Copyright © 2017 Adam Hogan. All rights reserved.
//

import UIKit

class PhotosViewController: UIViewController, UICollectionViewDelegate {
    
    @IBOutlet var collectionView: UICollectionView!
    @IBAction func showFavorites(_ sender: UIBarButtonItem) {
        
        favoritePhotos()
    }
    @IBAction func showFeed(_ sender: UIBarButtonItem) {
        collectionView.dataSource = photoDataSource
        collectionView.delegate = self
        
        updateDataSource()
        
        interestingPhotos()
   
    }
    
    var photo: Photo!
    var store: PhotoStore!
    let photoDataSource = PhotoDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = photoDataSource
        collectionView.delegate = self
        
        updateDataSource()
        
        interestingPhotos()
    }
    
    func favoritePhotos() {
        self.store.fetchFavoritePhotos {
            (photosResult) -> Void in
            
            switch photosResult {
            case let .success(photos):
                print("Successfully found \(photos.count) photos.")
                self.photoDataSource.photos = photos
            case let .failure(error):
                print("Error fetching interesting photos: \(error)")
                self.photoDataSource.photos.removeAll()
            }
        }
//        self.collectionView.reloadSections(IndexSet(integer: 0))
        self.collectionView.reloadData()
    }
    
    func feedPhotos() {
        self.store.fetchAllPhotos {
            (photosResult) -> Void in
            
            switch photosResult {
            case let .success(photos):
                print("Successfully found \(photos.count) photos.")
                self.photoDataSource.photos = photos
            case let .failure(error):
                print("Error fetching interesting photos: \(error)")
                self.photoDataSource.photos.removeAll()
            }
        }
        self.collectionView.reloadSections(IndexSet(integer: 0))
//        self.collectionView.reloadData()
    }
    
    
    func interestingPhotos() {
        store.fetchInterestingPhotos {
        (photosResult) -> Void in
        
        self.updateDataSource()
        }
    }
    
    
    func recentPhotos() {
        store.fetchRecentPhotos {
            (photosResult) -> Void in
            
            switch photosResult {
            case let .success(photos):
                print("Successfully found \(photos.count) photos.")
                self.photoDataSource.photos = photos
            case let .failure(error):
                print("Error fetching interesting photos: \(error)")
                self.photoDataSource.photos.removeAll()
            }
            
        }
        self.collectionView.reloadSections(IndexSet(integer: 0))
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let photo = photoDataSource.photos[indexPath.row]
        
        //download the image data, which could take some time
        store.fetchImage(for: photo) { (result) -> Void in
        
            //the index path for hte photo might have changed between the time the request
            //started and finished, so find hte most recent index path
        
            //note: you will have an error on the next line; you will fix it soon
            guard let photoIndex = self.photoDataSource.photos.index(of: photo),
                case let .success(image) = result else {
                    return
            }
            let photoIndexPath = IndexPath(item: photoIndex, section: 0)
        
        //when the request finishes, only update the cell if it's still visible
        if let cell = self.collectionView.cellForItem(at: photoIndexPath) as? PhotoCollectionViewCell {
            
            cell.update(with: image)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showPhoto"?:
            if let selectedIndexPath = collectionView.indexPathsForSelectedItems?.first {
                
                let photo = photoDataSource.photos[selectedIndexPath.row]
                
                let destinationVC = segue.destination as! PhotoInfoViewController
                destinationVC.photo = photo
                destinationVC.store = store
            }
        default:
            preconditionFailure("Unexpected segue identifier.")
        }
    }
    
    private func updateDataSource() {
        store.fetchAllPhotos {
            (PhotosResult) in
            
            switch PhotosResult {
            case let .success(photos):
                self.photoDataSource.photos = photos
            case .failure:
                self.photoDataSource.photos.removeAll()
            }
            self.collectionView.reloadSections(IndexSet(integer: 0))
        }
    }
}

extension PhotosViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidth = collectionView.bounds.size.width
        let numberOfItemsPerRow: CGFloat = 4
        let itemWidth = collectionViewWidth / numberOfItemsPerRow
        
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.reloadData()
    }
}
