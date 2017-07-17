//
//  Section.swift
//  Metra
//
//  Created by Admin on 15.07.17.
//  Copyright © 2017 Admin. All rights reserved.
//

import Foundation
import Firebase

class Section {
    var key: String
    var name: String
    var description: String
    var date: String
    var urls: [String] = []
    var ref: DatabaseReference?
    
    init(name: String, description: String, date: String, key: String = "") {
        self.key = key
        self.name = name
        self.description = description
        self.ref = nil
        self.date = date
    }
    
    init(snapshot: DataSnapshot) {
        key = snapshot.key
        ref = snapshot.ref
        let snapshotValue = snapshot.value as! [String: AnyObject]
        name = snapshotValue["name"] as! String
        description = snapshotValue["description"] as! String
        date = snapshotValue["date"] as! String        
        snapshot.ref.child("urls").observeSingleEvent(of: .value, with: { (dataSnapshot:DataSnapshot) in
            for object in dataSnapshot.children.allObjects as! [DataSnapshot] {
                for obj in object.value as! NSArray {
                    self.urls.append(obj as! String)
                }
            }
            
        })

    }
    
    init() {
        self.key = ""
        self.name = ""
        self.description = ""
        self.ref = nil
        self.date = ""
    }
    
    func addUrl(url: String) {
        self.urls.append(url)
        self.ref?.updateChildValues(["urls": [self.urls]])
        
    }
    
    func toAnyObject() -> Any {
        return [
            "name": name,
            "description": description,
            "date": date,
            "urls": urls
        ]
    }

}
