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
    var metaData = StorageMetadata()
    var name: String
    var image: UIImage?
    var section: Section?
    var date: String
    let dateFormatter  = DateFormatter()
    
    init(image: UIImage, metaData: StorageMetadata) {
        self.name = metaData.name!
        self.metaData = metaData
        self.image = image
        dateFormatter.dateFormat = "dd-MM-yyyy"
        self.date = dateFormatter.string(from: metaData.timeCreated!)
    }
    
    init(name: String, section: Section, image: UIImage) {
        self.name = name.hasSuffix(".jpg") ? name : "\(name).jpg"
        let tmpRef = storage.child("images/\(name)")
        self.section = section
        self.image = image
        metaData.contentType = "image/jpeg"
        dateFormatter.dateFormat = "dd-MM-yyyy"
        self.date = dateFormatter.string(from: Date())
        tmpRef.putData(UIImageJPEGRepresentation(image, 0.5)!, metadata: metaData, completion: nil)
        self.section?.addUrl(url: "images/\(name)")
    }
    
    
}
