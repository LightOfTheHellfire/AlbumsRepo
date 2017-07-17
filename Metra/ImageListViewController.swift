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
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var overallLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    var urls: [String] = []
    var images: [Image] = []
    var metaData: [StorageMetadata] = []
    var section = Section()
    var image: UIImage?
    var selectedItem: IndexPath?
    let reuseIdentifier = "ImageCollectionViewCell"
    
    let storageRef = Storage.storage()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getData()
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
    }
    
//MARK: Actions
    @IBAction func goBack(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func getData() {
        Database.database().reference(withPath: "sectionList").child(section.name).child("urls").observeSingleEvent(of: .value, with: { (dataSnapshot:DataSnapshot) in
            for object in dataSnapshot.children.allObjects as! [DataSnapshot] {
                for obj in object.value as! NSArray {
                    let url = obj as! String
                    self.urls.append(url)
                    self.getMetaData(url: url)
                    self.getImage(url: url)
                }
            }
        })
    }
    
    func getMetaData(url: String) {
        storageRef.reference(withPath: url).getMetadata(completion: { data, error in
            if let data = data {
                self.metaData.append(data)
            }
        })
    }
    
    func getImage(url: String){
        storageRef.reference(withPath: url).getData(maxSize: 10 * 1024 * 1024, completion:  { data, error in
            if let data = data {
                let img = Image(image: UIImage(data: data)!, metadata: self.metaData[self.images.count])
                if self.images.count != self.urls.count - 1 {
                    self.images.append(img)
                    self.imageCollectionView.reloadData()
                } else {
                    self.imageView.image = img.image
                    self.nameLabel.text = "Name: \(img.name)"
                    self.dateLabel.text = "Date: \(img.date)"
                }
            }
        })
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
            self.addData(imageName: name)
        })
        alert.addAction(confirmAction)
        self.present(alert, animated: true, completion:  nil)

    }
    
    func addData(imageName: String?) {
        if imageName != nil && image != nil {
            let imageDataObject = Image(name: imageName!, section: self.section, image: self.image!)
            images.append(Image(image: imageView.image!, metadata: metaData[images.count]))
            imageView.image = imageDataObject.image
            image = nil
            imageCollectionView.reloadData()
        }
    }
    
//MARK: CollectionView
    func deleteRow(_ sender: UIButton?) {
        let item = images[(sender?.tag)!]
        storageRef.reference(withPath: "images/\(item.metadata.name)").delete { _ in
            self.images.remove(at: (sender?.tag)!)
            self.section.urls.remove(at: (sender?.tag)!)
            self.urls.remove(at: (sender?.tag)!)
            self.section.ref?.updateChildValues(["urls": self.urls])
            self.imageCollectionView.reloadData()
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
            image = originalImage
        }
        self.dismiss(animated: true, completion: nil)
        self.addName()
    }
}
