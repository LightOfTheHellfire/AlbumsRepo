//
//  SectionsTableViewController.swift
//  Metra
//
//  Created by Admin on 14.07.17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import Firebase

class SectionListTableViewController: UITableViewController {
    var items: [Section] = []
    var ref = Database.database().reference(withPath: "sectionList")
    override func viewDidLoad() {
        super.viewDidLoad()
        ref.observe(.value, with: { snapshot in
            var newItems: [Section] = []
            
            for item in snapshot.children {
                let groceryItem = Section(snapshot: item as! DataSnapshot)
                newItems.append(groceryItem)
            }
            self.items = newItems
            self.tableView.reloadData()
        })
    }

    // MARK: - Table view data source



    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Section Cell", for: indexPath) as! SectionCell
        let section = items[indexPath.row]
        cell.editButton.tag = indexPath.row
        cell.editButton.addTarget(self, action: #selector(self.editButtonTapped(_:)), for: .touchUpInside)
        
        cell.nameLabel?.text = section.name
        cell.dateLabel?.text = section.date
        return cell
    }
    
    func editButtonTapped(_ sender: UIButton!) {
        performSegue(withIdentifier: "showSectionSegue", sender: items[sender.tag])
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 90.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showImages", sender: items[indexPath.row])
    }
    
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let item = items[indexPath.row]
            for url in item.urls {
                Storage.storage().reference(forURL: url as String).delete(completion: nil)
            }
            item.ref?.removeValue()
        }
    }
    
    
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSectionSegue" {
            let nav = segue.destination as! UINavigationController
            let destination = nav.topViewController as! SectionViewController
            if let section = sender as? Section {
                destination.section = section
            }
        } else if segue.identifier == "showImages" {
            let nav = segue.destination as! UINavigationController
            let destination = nav.topViewController as! ImageListViewController
            destination.section = sender as! Section
            
        }
    }
    
    @IBAction func unwindToSectionList(sender: UIStoryboardSegue) {
        if let source = sender.source as? SectionViewController {
            if let section = source.section {
                ref.child(section.name).setValue(section.toAnyObject())
            }
        }
    }

 

}
