//
//  PhotoManager.swift
//  EAT
//
//  Created by Emlyn Murphy on 2/6/15.
//  Copyright (c) 2015 Nitemotif. All rights reserved.
//

import UIKit
import ImageIO

private let PhotoManagerOriginalImageQuality = CGFloat(0.8)
private let PhotoManagerFileExtension = "jpg"
private let PhotoManagerPhotosFolderName = "Photos"

class PhotoManager: NSObject {
    class var sharedInstance: PhotoManager {
        struct Static {
            static let instance: PhotoManager = PhotoManager()
        }
        
        return Static.instance
    }
    
    private var originalPhotosDirectoryURL: NSURL {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).last as! String
        return NSURL(fileURLWithPath: documentsPath.stringByAppendingPathComponent(PhotoManagerPhotosFolderName))!
    }
    
    private func fileURLWithBaseURL(baseURL: NSURL, uuid: NSUUID) -> NSURL {
        let pathComponents = split(uuid.UUIDString){ $0 == "-" }
        
        let directoryComponents = pathComponents[0 ..< pathComponents.endIndex - 1]
        let directoryURL = directoryComponents.reduce(baseURL) { (directoryURL, pathComponent) -> NSURL in
            return directoryURL.URLByAppendingPathComponent(pathComponent, isDirectory: true)
        }
        
        var error: NSError?
        if NSFileManager.defaultManager().createDirectoryAtURL(directoryURL, withIntermediateDirectories: true, attributes: nil, error: &error) == false {
            println("Error creating directory: \(error)")
        }
        
        let fileName = pathComponents.last!
        
        return directoryURL.URLByAppendingPathComponent(fileName.stringByAppendingPathExtension(PhotoManagerFileExtension)!, isDirectory: false)
    }
    
    func addImage(image: UIImage, toMeal meal: EATMeal) {
        PersistenceManager.sharedInstance.backgroundContextWithExistingObject(meal) { (backgroundMeal) -> Bool in
            let uuid = NSUUID()
            let fileURL = self.fileURLWithBaseURL(self.originalPhotosDirectoryURL, uuid: uuid)
            let imageData = UIImageJPEGRepresentation(image, PhotoManagerOriginalImageQuality)
            
            if imageData.writeToURL(fileURL, atomically: true) == false {
                println("Error writing JPEG data for image.")
                return false
            }
            
            let photo = NSEntityDescription.insertNewObjectForEntityForName("Photo", inManagedObjectContext: backgroundMeal.managedObjectContext!) as! Photo
            
            photo.uuid = uuid.UUIDString
            photo.meal = backgroundMeal as! EATMeal
            photo.width = Int32(image.size.width)
            photo.height = Int32(image.size.height)
            
            return true
        }
    }
    
    func photo(photo: Photo, withSize size: PhotoSize, completion: (UIImage?) -> Void) {
        if let photoUUID = NSUUID(UUIDString: photo.uuid) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                let fileURL = self.fileURLWithBaseURL(self.originalPhotosDirectoryURL, uuid: photoUUID)
                
                if let imageSource = CGImageSourceCreateWithURL(fileURL, nil) {
                    let scale = UIScreen.mainScreen().scale
                    let options = NSMutableDictionary()
                    options.setValue(NSNumber(int: Int32(CGFloat(max(size.0, size.1)) * scale)), forKey: kCGImageSourceThumbnailMaxPixelSize as String)
                    options.setValue(NSNumber(bool: true), forKey: kCGImageSourceCreateThumbnailFromImageIfAbsent as String)
                    options.setValue(NSNumber(bool: true), forKey: kCGImageSourceCreateThumbnailWithTransform as String)
                    
                    let scaledImage = UIImage(CGImage: CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options))
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        completion(scaledImage)
                    }
                }
                else {
                    dispatch_async(dispatch_get_main_queue()) {
                        completion(nil)
                    }
                }
            }
        }
        else {
            dispatch_async(dispatch_get_main_queue()) {
                completion(nil)
            }
        }
    }
}
