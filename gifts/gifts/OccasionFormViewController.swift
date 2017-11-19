//
//  OccasionFormViewController.swift
//  gifts
//
//  Created by Colby L Williams on 11/19/17.
//  Copyright © 2017 Colby L Williams. All rights reserved.
//

import Foundation
import Eureka

class OccasionFormViewController : FormViewController {
    
    var currencyFormatter: CurrencyFormatter {
        return OccasionManager.shared.currencyFormatter
    }

    let initialDate = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let name = Occasion.FormTag.name
        let date = Occasion.FormTag.date
        let deadlineEnabled = Occasion.FormTag.deadlineEnabled
        let deadline = Occasion.FormTag.deadline
        let budget = Occasion.FormTag.budget
        let saveButton = Occasion.FormTag.saveButton
        
        form
        +++ Section("Occasion")
        <<< TextRow (name.tag) { row in
            row.title = name.title
            row.placeholder = name.placeholder
        }
        <<< DateInlineRow(date.tag) {
            $0.title = date.title
            $0.value = initialDate
        }.onChange { row in
            if let deadline = self.form.rowBy(tag: deadline.tag) as? DateInlineRow, deadline.value == nil {
                deadline.value = row.value
            }
        }
        <<< SwitchRow(deadlineEnabled.tag){
            $0.title = deadlineEnabled.title
        }.onChange { row in
            let date = (row.value ?? false) ? (self.form.rowBy(tag: date.tag) as? DateInlineRow)?.value : nil
            (self.form.rowBy(tag: deadline.tag) as? DateInlineRow)?.value = date
        }
        <<< DateInlineRow(deadline.tag) {
            $0.hidden = Condition.function([deadlineEnabled.tag]) { form in
                return !((form.rowBy(tag: deadlineEnabled.tag) as? SwitchRow)?.value ?? false)
            }
            $0.title = deadline.title
            $0.value = nil
        }
        <<< DecimalRow(budget.tag) {
            $0.useFormatterDuringInput = true
            $0.title = budget.title
            $0.placeholder = budget.placeholder
            $0.formatter = currencyFormatter
        }
        +++ Section()
        <<< ButtonRow(saveButton.tag) {
            $0.title = saveButton.title
        }.onCellSelection { (cell, row) in
            let occasion = Occasion(withTagDictionary: self.form.values())
            OccasionManager.shared.add(occasion) {
                self.dismiss(animated: true) { }
            }
        }
    }

    
    @IBAction func cancelButtonTouchUpInside(_ sender: Any) {
        dismiss(animated: true) { }
    }
}
