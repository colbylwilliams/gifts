//
//  GiftFormViewController.swift
//  gifts
//
//  Created by Colby L Williams on 11/19/17.
//  Copyright © 2017 Colby L Williams. All rights reserved.
//

import Foundation
import Eureka

class GiftFormViewController : FormViewController {
    
    var currencyFormatter: CurrencyFormatter {
        return OccasionManager.shared.currencyFormatter
    }
    
    let initialDate = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let recipient = Gift.FormTag.recipient
        let budget = Gift.FormTag.budget
        let price = Gift.FormTag.price
        let purchasedOn = Gift.FormTag.purchasedOn
        let saveButton = Gift.FormTag.saveButton
        
        form
        +++ Section("Gift")
        <<< NameRow (recipient.tag) { row in
            row.title = recipient.title
            row.placeholder = recipient.placeholder
        }
        <<< DecimalRow(budget.tag) {
            $0.useFormatterDuringInput = true
            $0.title = budget.title
            $0.placeholder = budget.placeholder
            $0.formatter = currencyFormatter
        }
        +++ Section("Purchase")
        <<< DecimalRow(price.tag) {
            $0.useFormatterDuringInput = true
            $0.title = price.title
            $0.placeholder = price.placeholder
            $0.formatter = currencyFormatter
        }
        <<< DateInlineRow(purchasedOn.tag) {
            $0.title = purchasedOn.title
            $0.value = nil
        }
        <<< ButtonRow(saveButton.tag) {
            $0.title = saveButton.title
        }.onCellSelection { (cell, row) in
            let gift = Gift(withTagDictionary: self.form.values())
            OccasionManager.shared.add(gift) {
                self.dismiss(animated: true) { }
            }
        }
    }
    
    
    @IBAction func cancelButtonTouchUpInside(_ sender: Any) {
        dismiss(animated: true) { }
    }
}

