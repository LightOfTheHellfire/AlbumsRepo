//
//  ImageListViewController.swift
//  Metra
//
//  Created by Admin on 14.07.17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import Firebase

class ImageListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

//MARK: Properties
    @IBOutlet weak var lastLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var overallLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    var urls: [String] = []
    var images: [Image] = []
    var tempImages: [Image] = []
    var section = Section()
    var newImage: UIImage?
    var lastImage: Image?
    var selectedItem: IndexPath?
    let reuseIdentifier = "ImageCollectionViewCell"
    
    let storageRef = Storage.storage()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getUrls()
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
    }
    
//MARK: Actions
    @IBAction func goBack(_ sender: UIBarButtonItem) {
        urls.removeAll()
        images.removeAll()
        tempImages.removeAll()
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func getUrls() {
        if section.urls.count > 0 {
            for url in section.urls {
                urls.append(url)
                getData(url: url)
            }
        }
//        Database.database().reference(withPath: "sectionList").child(section.name).child("urls").observeSingleEvent(of: .value, with: { (dataSnapshot:DataSnapshot) in
//            for object in dataSnapshot.children.allObjects as! [DataSnapshot] {
//                if let urls = object.value as? NSArray {
//                    for obj in urls {
//                        if let url = obj as? String {
//                            self.urls.append(url)
//                            self.getData(url: url)
//                        }
//                    }
//
//                } else {
//                    let url = object.value as! String
//                    self.urls.append(url)
//                    self.getData(url: url)
//                }
//            }
//        })
    }
    
    func getData(url: String) {
        storageRef.reference(withPath: url).getMetadata(completion: { data, error in
            if let data = data {
                self.getImage(url: url, metaData: data)
            }
        })
    }
    
    func getImage(url: String, metaData: StorageMetadata){
        storageRef.reference(withPath: url).getData(maxSize: 10 * 1024 * 1024, completion:  { data, error in
            if let data = data {
                let img = Image(image: UIImage(data: data)!, metaData: metaData)
                if self.tempImages.count < self.urls.count - 1 {
                    self.tempImages.append(img)
                    self.imageCollectionView.reloadData()
                } else {
                    self.tempImages.append(img)
                    self.sortImages()
                }
            }
        })
    }
    
    func sortImages() {
        if tempImages.count > 0 {
            images = tempImages.sorted(by: { $0.metaData.timeCreated! > $1.metaData.timeCreated! })
            imageView.image = images[0].image
            overallLabel.text = "Overall: \(tempImages.count)"
            nameLabel.text = "Name: \(images[0].name)"
            dateLabel.text = "Date: \(images[0].date)"
            lastImage = images[0]
            lastLabel.isHidden = false
            images.remove(at: 0)
            imageCollectionView.reloadData()
        }
    }
    
    

    @IBAction func addImage(_ sender: AnyObject) {
        let alert = UIAlertController(title: "Select a source", message: "", preferredStyle: .actionSheet)
        let addNewImage = UIAlertAction(title: "Take a new Image", style: .default, handler: {(_ action: UIAlertAction) -> Void in
            self.addNewImage(isNewImage: true)
        })
        let addExistingImage = UIAlertAction(title: "Choose from Photo Library", style: .default, handler: {(_ action: UIAlertAction) -> Void in
            self.addNewImage(isNewImage: false)
        })
        alert.addAction(addNewImage)
        alert.addAction(addExistingImage)
        self.present(alert, animated: true) {
            alert.view.superview?.subviews[1].isUserInteractionEnabled = true
            alert.view.superview?.subviews[1].addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
        }
    }
    
    func alertControllerBackgroundTapped()
    {
        self.dismiss(animated: true, completion: nil)
    }

    
    func addNewImage(isNewImage: Bool) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = isNewImage ? .camera : .photoLibrary
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func addName() {
        let alert = UIAlertController(title: "Type a name to the image", message: "", preferredStyle: .alert)
        alert.addTextField(configurationHandler: {(_ textField: UITextField) -> Void in
            textField.placeholder = "Type a name here"
        })
        let confirmAction = UIAlertAction(title: "OK", style: .default, handler: {(_ action: UIAlertAction) -> Void in
            let name = (alert.textFields?.first?.text)!
            self.addData(imageName: ("\(name)"))
        })
        alert.addAction(confirmAction)
        self.present(alert, animated: true, completion:  nil)

    }
    
    func addData(imageName: String?) {
        if imageName != nil && newImage != nil {
            let newImageObject = Image(name: imageName!, section: self.section, image: self.newImage!)
            if imageView.image != nil {
                images.append(lastImage!)
            }
            lastImage = newImageObject
            nameLabel.text = "Name: \(lastImage?.name)"
            dateLabel.text = "Date: \(lastImage?.date)"
            overallLabel.text = "Overall: \(images.count + 1)"
            imageView.image = newImageObject.image
            newImage = nil
            lastLabel.isHidden = false
            imageCollectionView.reloadData()
        }
    }
    
//MARK: CollectionView
    func deleteRow(_ sender: UIButton?) {
        print("Item = \(sender?.tag)")
        let item = images[(sender?.tag)!]
        let name = item.name.components(separatedBy: ".jpg").joined()
        Storage.storage().reference(withPath: "images/\(name)").delete { error in
            if let err = error {
                print("errorr\(err.localizedDescription)")
            } else {
                for (i, url) in self.section.urls.enumerated() {
                    if url.components(separatedBy: "images/").joined() == item.name {
                        self.section.urls.remove(at: i)
                    }
                }
                self.section.ref?.updateChildValues(["urls": self.section.urls])
                self.images.remove(at: (sender?.tag)!)
                self.overallLabel.text = "Overall: \(self.images.count + 1)"
                self.imageCollectionView.reloadData()
            }
        }
    }

    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if images.count == 0 {
            return UICollectionViewCell()
        }
        let index = indexPath.item
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                      for: indexPath) as! ImageCollectionViewCell
        cell.nameLabel.text = images[index].name
        cell.dateLabel.text = images[index].date
        cell.imageView.image = images[index].image
        cell.deleteItem.addTarget(self, action: #selector(self.deleteRow(_:)), for: .touchUpInside)
        cell.deleteItem.tag = index
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.item)
        selectedItem = indexPath
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenSize = UIScreen.main.bounds
        let width = screenSize.width / 2.55
        
        return CGSize(width: width, height: width)
    }
    

}

////MARK: ImagePickerController
extension  ImageListViewController {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            newImage = originalImage
        }
        self.dismiss(animated: true, completion: nil)
        self.addName()
    }
}
