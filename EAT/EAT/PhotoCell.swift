//
//  PhotoCell.swift
//  EAT
//
//  Created by Emlyn Murphy on 2/4/15.
//  Copyright (c) 2015 Nitemotif. All rights reserved.
//

import UIKit

class PhotoCell: UITableViewCell {
    @IBOutlet var photoImageView: UIImageView?
    @IBOutlet var cameraIconImageView: UIImageView?
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView?

    var managedObjectContext: NSManagedObjectContext?
    
    var meal: EATMeal? {
        willSet {
            if let meal = meal {
                meal.removeObserver(self, forKeyPath: "photo")
            }
        }
        
        didSet {
            meal?.addObserver(self, forKeyPath: "photo", options: .Initial | .New, context: nil)
        }
    }
    
    deinit {
        meal?.removeObserver(self, forKeyPath: "photo")
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if keyPath == "photo" {
            configureView()
        }
    }
    
    private func configureView() {
        if meal?.photo == nil {
            photoImageView?.image = nil
            cameraIconImageView?.hidden = false
            activityIndicatorView?.stopAnimating()
        }
        else {
            photoImageView?.image = nil
            cameraIconImageView?.hidden = true
            activityIndicatorView?.startAnimating()
            
            PhotoManager.sharedInstance.photo(meal!.photo, withSize: (Int32(photoImageView!.frame.size.width), Int32(photoImageView!.frame.size.height)), completion: { (image) -> Void in
                self.photoImageView?.image = image
                self.activityIndicatorView?.stopAnimating()
                return
            })
        }
    }
}
