//
//  GiftTableViewController.swift
//  gifts
//
//  Created by Colby L Williams on 11/19/17.
//  Copyright © 2017 Colby L Williams. All rights reserved.
//

import AzureData
import Foundation
import UIKit

class GiftTableViewController : UITableViewController {

    @IBOutlet var addButton: UIBarButtonItem!
    
    var occasion: Occasion? { return OccasionManager.shared.occasion }

    var gifts: [Gift] { return OccasionManager.shared.occasion?.gifts ?? [] }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = occasion?.name
        
        navigationItem.rightBarButtonItems = [addButton, editButtonItem]
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }

    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return gifts.count }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "giftCell", for: indexPath)
        
        let gift = gifts[indexPath.row]
        
        cell.textLabel?.text = gift.recipient
        cell.detailTextLabel?.text = gift.id
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction.init(style: .destructive, title: "Delete") { (action, view, callback) in
            self.deleteResource(at: indexPath, from: tableView, callback: callback)
        }
        return UISwipeActionsConfiguration(actions: [ action ] );
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteResource(at: indexPath, from: tableView)
        }
    }
    
    
    func deleteResource(at indexPath: IndexPath, from tableView: UITableView, callback: ((Bool) -> Void)? = nil) {
        OccasionManager.shared.delete(giftAt: indexPath.row) { success in
            if success {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            callback?(success)
        }
    }
}
