//
//  OccasionTableViewController.swift
//  gifts
//
//  Created by Colby L Williams on 11/19/17.
//  Copyright © 2017 Colby L Williams. All rights reserved.
//

import Foundation
import UIKit
import AzureData

class OccasionTableViewController : UITableViewController {
    
    @IBOutlet var addButton: UIBarButtonItem!
    

    var occasions: [Occasion] { return OccasionManager.shared.occasions }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshData()
        
        navigationItem.rightBarButtonItems = [addButton, editButtonItem]
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
     
        self.tableView.reloadData()
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        OccasionManager.shared.clearSelectedOccasion()
    }
    
    
    func refreshData() {
        OccasionManager.shared.refresh {
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }
    }
    
    
    @IBAction func refreshControlValueChanged(_ sender: Any) { refreshData() }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return occasions.count }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "occasionCell", for: indexPath)
        
        let occasion = occasions[indexPath.row]
        
        cell.textLabel?.text = occasion.name ?? occasion.id
        cell.detailTextLabel?.text = OccasionManager.shared.currencyFormatter.string(from: NSNumber(value: occasion.budget ?? 0))
        
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
        OccasionManager.shared.delete(occasionAt: indexPath.row) { success in
            if success {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            callback?(success)
        }
    }

    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? UITableViewCell, let index = tableView.indexPath(for: cell) {
            OccasionManager.shared.selectedOccasion = occasions[index.row]
        }
    }
}
