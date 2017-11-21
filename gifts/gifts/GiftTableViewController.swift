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
    
    @IBOutlet weak var daysLeftLabel: UILabel!
    @IBOutlet weak var spentLabel: UILabel!
    @IBOutlet weak var budgetLabel: UILabel!
    @IBOutlet weak var budgetedLabel: UILabel!
    
    var currencyFormatter: CurrencyFormatter { return OccasionManager.shared.currencyFormatter }
    
    var occasion: Occasion { return OccasionManager.shared.selectedOccasion }
    var gifts: [Gift] { return OccasionManager.shared.selectedOccasion.gifts }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = occasion.name
        
        navigationItem.rightBarButtonItems = [addButton, editButtonItem]
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let spent = gifts.reduce(0.0) { $0 + ( $1.purchases.reduce(0.0) { $0 + ( $1.price ?? 0) } ) }
        let budgeted = gifts.reduce(0.0) { $0 + ( $1.budget ?? 0 ) }
        
        spentLabel.text = currencyFormatter.string(from: NSNumber(value: spent)) ?? "$0.00"
        budgetLabel.text = currencyFormatter.string(from: NSNumber(value: occasion.budget ?? 0)) ?? "$0.00"
        budgetedLabel.text = currencyFormatter.string(from: NSNumber(value: budgeted)) ?? "$0.00"
        
        if let seconds = (occasion.deadline ?? occasion.date)?.timeIntervalSinceNow {
            
            let minutes = seconds / 60
            let hours = minutes / 60
            let days = round(hours / 24)
            
            daysLeftLabel.text = "\(days)"
            
        }
        
        tableView.reloadData()
    }

    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return gifts.count }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "giftCell", for: indexPath)
        
        let gift = gifts[indexPath.row]
        
        cell.textLabel?.text = gift.recipient
        cell.detailTextLabel?.text = OccasionManager.shared.currencyFormatter.string(from: NSNumber(value: gift.budget ?? 0))
        
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
    
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let cell = sender as? UITableViewCell, let index = tableView.indexPath(for: cell) {
            OccasionManager.shared.selectedGift = gifts[index.row]
        } else {
            OccasionManager.shared.selectedGift = Gift()
        }
    }
}
