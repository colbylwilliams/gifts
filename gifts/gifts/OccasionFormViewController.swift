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
    
    var currencyFormatter: CurrencyFormatter { return OccasionManager.shared.currencyFormatter }
    
    var occasion: Occasion { return OccasionManager.shared.selectedOccasion }
    

    let initialDate = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let name        = Occasion.FormTag.name
        let date        = Occasion.FormTag.date
        let hasDeadline = Occasion.FormTag.hasDeadline
        let deadline    = Occasion.FormTag.deadline
        let budget      = Occasion.FormTag.budget
        let saveButton  = Occasion.FormTag.saveButton
        
        form
        +++ Section("Occasion")
        <<< TextRow (name.tag) { row in
                row.title = name.title
                row.placeholder = name.placeholder
                row.value = occasion.name
            }.onChange {
                self.occasion.name = $0.value
            }
        <<< DateInlineRow(date.tag) { row in
                row.title = date.title
                row.value = occasion.date
            }.onChange {
                self.occasion.date = $0.value
                if let deadline = self.form.rowBy(tag: deadline.tag) as? DateInlineRow, deadline.value == nil {
                    deadline.value = $0.value
                }
            }
        <<< SwitchRow(hasDeadline.tag) { row in
                row.title = hasDeadline.title
                row.value = occasion.hasDeadline
            }.onChange {
                
                let date = ($0.value ?? false) ? (self.form.rowBy(tag: date.tag) as? DateInlineRow)?.value : nil
                
                (self.form.rowBy(tag: deadline.tag) as? DateInlineRow)?.value = date
            }
        <<< DateInlineRow(deadline.tag) { row in
                row.hidden = Condition.function([hasDeadline.tag]) { form in
                    return !((form.rowBy(tag: hasDeadline.tag) as? SwitchRow)?.value ?? false)
                }
                row.title = deadline.title
                row.value = occasion.deadline
            }.onChange {
                self.occasion.deadline = $0.value
            }
        <<< DecimalRow(budget.tag) { row in
                row.useFormatterDuringInput = true
                row.title = budget.title
                row.placeholder = budget.placeholder
                row.formatter = currencyFormatter
                row.value = occasion.budget
            }.onChange {
                self.occasion.budget = $0.value
            }
        +++ ButtonRow(saveButton.tag) { row in
                row.title = saveButton.title
            }.onCellSelection { _, _ in
                self.saveAndDismiss()
            }
    }

    
    @IBAction func saveButtonTouchUpInside(_ sender: Any) {
        saveAndDismiss()
    }
    
    
    @IBAction func cancelButtonTouchUpInside(_ sender: Any) {
        dismiss(animated: true) { }
    }
    
    
    func saveAndDismiss() {
        OccasionManager.shared.saveSelectedOccasion {
            self.dismiss(animated: true) { }
        }
    }
}
