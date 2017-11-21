//
//  GiftFormViewController.swift
//  gifts
//
//  Created by Colby L Williams on 11/19/17.
//  Copyright © 2017 Colby L Williams. All rights reserved.
//

import Foundation
import Eureka


class GiftFormNavigationController : UINavigationController { }

class GiftFormViewController : FormViewController {
    
    @IBOutlet var cancelButton: UIBarButtonItem!
    
    var changed = false
    
    var gift: Gift { return OccasionManager.shared.selectedGift }
    
    var currencyFormatter: CurrencyFormatter { return OccasionManager.shared.currencyFormatter }
    
    
    let initialDate = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let recipient   = Gift.FormTag.recipient
        let budget      = Gift.FormTag.budget
        let saveButton  = Gift.FormTag.saveButton
        
        form
        +++ Section("Gift")
        <<< NameRow (recipient.tag) { row in
                row.title = recipient.title
                row.placeholder = recipient.placeholder
                row.value = gift.recipient
                //row.cell.textField.becomeFirstResponder()
            }.onChange {
                self.changed = true
                self.gift.recipient = $0.value
            }
        <<< DecimalRow(budget.tag) { row in
                row.useFormatterDuringInput = true
                row.title = budget.title
                row.placeholder = budget.placeholder
                row.formatter = currencyFormatter
                row.value = gift.budget
            }.onChange {
                self.changed = true
                self.gift.budget = $0.value
            }
        +++ MultivaluedSection(multivaluedOptions: [.Insert, .Delete], header: "Purchases", footer: "") { section in
                section.addButtonProvider = { _ in
                    return ButtonRow { row in
                        row.title = "Add Purchase"
                    }.cellUpdate { cell, _ in
                        cell.textLabel?.textAlignment = .left
                    }
                }
                section.multivaluedRowToInsertAt = { _ in
                    return ButtonRow (UUID().uuidString) { row in
                        row.title = "New Purchase"
                        row.presentationMode = .segueName(segueName: "PurchaseFormViewController", onDismiss: nil)
                    }
                }
                for purchase in gift.purchases {
                    section
                    <<< ButtonRow (purchase.id) { row in
                        row.title = purchase.name
                        row.presentationMode = .segueName(segueName: "PurchaseFormViewController", onDismiss: nil)
                    }
                }
            }
            
        if navigationController is GiftFormNavigationController {
            form
            +++ ButtonRow(saveButton.tag) { row in
                row.title = saveButton.title
            }.onCellSelection { _, _ in
                self.saveAndDismiss()
            }
            
            navigationItem.leftBarButtonItem = cancelButton
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }
    

    override func rowsHaveBeenRemoved(_ rows: [BaseRow], at indexes: [IndexPath]) {
        super.rowsHaveBeenRemoved(rows, at: indexes)
        changed = true
        if let i = indexes.first?.row {
            OccasionManager.shared.delete(purchaseAt: i)
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !isMovingToParentViewController {
        
            let purchase = OccasionManager.shared.selectedPurchase
        
            if let row = form.rowBy(tag: purchase.id) as? ButtonRow {

                // saved
                if gift.purchases.contains(purchase) {
                    
                    row.title = purchase.name ?? "New purchase"
                    row.updateCell()
                
                // canceled
                } else if let i = row.section?.index(of: row) {

                    row.section?.remove(at: i)
                }
            }
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if changed && !(navigationController is GiftFormNavigationController) {
            print("gift return 0")
            OccasionManager.shared.saveSelectedGiftSilent()
            print("gift return 1")
        }
    }
    
    
    @IBAction func saveButtonTouchUpInside(_ sender: Any) { saveAndDismiss() }

    
    @IBAction func cancelButtonTouchUpInside(_ sender: Any) { dismiss() }
    
    
    func saveAndDismiss() {
        OccasionManager.shared.saveSelectedGift (self.dismiss)
    }
    
    
    func dismiss() {
        if navigationController is GiftFormNavigationController {
            dismiss(animated: true) { }
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    
    // Workaround: https://github.com/xmartlabs/Eureka/issues/1135
    //override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle { return .none }
    
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is PurchaseFormViewController, let tag = (sender as? ButtonRow)?.tag {
            OccasionManager.shared.selectedPurchase = gift.purchases.first(where: { $0.id == tag }) ?? Purchase(withId: tag)
        }
    }
}
