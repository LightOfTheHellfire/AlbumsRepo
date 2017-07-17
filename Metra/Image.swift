//
//  Image.swift
//  Metra
//
//  Created by Admin on 15.07.17.
//  Copyright © 2017 Admin. All rights reserved.
//

import Foundation
import Firebase

struct Image {
    let storage = Storage.storage().reference()
    let ref = Database.database().reference()
    var metadata = StorageMetadata()
    var name: String
    var image: UIImage?
    var section: Section?
    var date: String
    
    init(image: UIImage, metadata: StorageMetadata) {
        self.name = metadata.name!
        self.metadata = metadata
        self.image = image
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        self.date = dateFormatter.string(from: metadata.timeCreated!)
    }
    
    init(name: String, section: Section, image: UIImage) {
        let tmpRef = storage.child("images/\(name).jpg")
        self.name = name
        self.section = section
        self.image = image
        metadata.contentType = "image/jpeg"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        self.date = dateFormatter.string(from: Date())
        tmpRef.putData(UIImageJPEGRepresentation(image, 0.7)!, metadata: metadata, completion: nil)
        self.section?.addUrl(url: "images/\(name).jpg")
    }
    
    
}
