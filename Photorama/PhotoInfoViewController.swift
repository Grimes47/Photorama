//
//  PhotoInfoViewController.swift
//  Photorama
//
//  Created by Adam Hogan on 8/10/17.
//  Copyright © 2017 Adam Hogan. All rights reserved.
//

import UIKit

class PhotoInfoViewController: UIViewController {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var numberOfViews: UILabel!
    @IBAction func addToFavorites(_ sender: UISegmentedControl!) {
        photo.favorite = true
        do {
            try self.store.persistentContainer.viewContext.save()
        } catch let error {
            print("Core Data save failed: \(error)")
        }
    }
    
    var photo: Photo! {
        didSet {
            navigationItem.title = photo.title
            
        }
    }
    var store: PhotoStore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.accessibilityLabel = photo.title
        photo.numberOfViews += 1
        numberOfViews.text = "\(photo.numberOfViews)"
        
        store.fetchImage(for: photo) { (result) -> Void in
            switch result {
            case let .success(image):
                self.imageView.image = image
            case let .failure(error):
                print("Error fetching image for photo: \(error)")
                }
            }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showTags"?:
            let navController = segue.destination as! UINavigationController
            let tagController = navController.topViewController as! TagsViewController
            
            tagController.store = store
            tagController.photo = photo
        default:
            preconditionFailure("Unexpected segue identifier")
        }
    }
}
