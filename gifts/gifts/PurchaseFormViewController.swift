//
//  PurchaseFormViewController.swift
//  gifts
//
//  Created by Colby L Williams on 11/20/17.
//  Copyright © 2017 Colby L Williams. All rights reserved.
//

import Foundation
import Eureka

class PurchaseFormViewController : FormViewController {
    
    var purchase: Purchase { return OccasionManager.shared.selectedPurchase }
    
    var currencyFormatter: CurrencyFormatter { return OccasionManager.shared.currencyFormatter }
    
    var changed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let name        = Purchase.FormTag.name
        let price       = Purchase.FormTag.price
        let purchased   = Purchase.FormTag.purchased
        let purchasedOn = Purchase.FormTag.purchasedOn
        //let saveButton  = Purchase.FormTag.saveButton
        
        form
        +++ Section("New Purchase")
        <<< NameRow (name.tag) { row in
            row.title = name.title
            row.placeholder = name.placeholder
            row.value = purchase.name
            }.onChange {
                self.changed = true
                self.purchase.name = $0.value
            }
        <<< SwitchRow(purchased.tag) { row in
            row.title = purchased.title
            row.value = purchase.purchased
            }.onChange {
                self.changed = true
                (self.form.rowBy(tag: purchasedOn.tag) as? DateInlineRow)?.value = ($0.value ?? false) ? Date() : nil
                if ($0.value ?? false) { (self.form.rowBy(tag: price.tag) as? DecimalRow)?.value = nil }
            }
        <<< DateInlineRow(purchasedOn.tag) { row in
            row.hidden = Condition.function([purchased.tag]) { form in
                return !((form.rowBy(tag: purchased.tag) as? SwitchRow)?.value ?? false)
            }
            row.title = purchasedOn.title
            row.value = purchase.purchasedOn
            }.onChange {
                self.changed = true
                self.purchase.purchasedOn = $0.value
            }
        <<< DecimalRow(price.tag) { row in
            row.hidden = Condition.function([purchased.tag]) { form in
                return !((form.rowBy(tag: purchased.tag) as? SwitchRow)?.value ?? false)
            }
            row.useFormatterDuringInput = true
            row.title = price.title
            row.placeholder = price.placeholder
            row.formatter = currencyFormatter
            row.value = purchase.price
            }.onChange {
                self.changed = true
                self.purchase.price = $0.value
            }
//        +++ ButtonRow(saveButton.tag) { row in
//            row.title = saveButton.title
//            }.onCellSelection { (cell, row) in
//                self.saveAndDismiss()
//            }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //if changed && !(navigationController is GiftFormNavigationController) {
        if changed {
            print("purchase return 0")
            OccasionManager.shared.saveSelectedPurchaseSilent()
            print("purchase return 1")
        }
    }
    
    
//    func saveAndDismiss() {
//        OccasionManager.shared.saveSelectedPurchase {
//            self.navigationController?.popViewController(animated: true)
//        }
//    }
}
