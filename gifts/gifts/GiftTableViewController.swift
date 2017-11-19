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
    
    var collection: DocumentCollection?
    var documents = [Document]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItems = [editButtonItem]
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshData()
    }
    
    
    func refreshData() {
        
        AzureData.get(collectionWithId: "Gift", inDatabase: "Gift") { response in
            
            self.collection = response.resource
            
            self.collection?.get(documentsAs: Document.self) { response in
                if let documents = response.resource?.items {
                    
                    self.documents = documents
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    
                } else if let clientError = response.error as? DocumentClientError {
                    print(clientError.message ?? clientError.localizedDescription)
                } else if let error = response.error {
                    print(error.localizedDescription)
                }
            }
        }
    }
    

    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return documents.count }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "giftCell", for: indexPath)
        
        let resource = documents[indexPath.row]
        
        cell.textLabel?.text = resource.id
        cell.detailTextLabel?.text = resource.resourceId
        
        return cell
    }
}
