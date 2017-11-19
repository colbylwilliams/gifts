//
//  Gift.swift
//  gifts
//
//  Created by Colby L Williams on 11/19/17.
//  Copyright © 2017 Colby L Williams. All rights reserved.
//

import AzureData
import Foundation

class Gift : Codable {
    
    var id:             String
    var recipient:      String?
    var budget:         Decimal?
    var price:          Decimal?
    var purchasedOn:    Date?
    
    init() { id = UUID().uuidString }
    
    
    convenience init(withTagDictionary dict: [String:Any?]) {
        self.init()
        self.recipient      = dict[.recipient] as? String
        self.budget         = dict[.budget] as? Decimal
        self.price          = dict[.price] as? Decimal
        self.purchasedOn    = dict[.purchasedOn] as? Date
    }

    private enum CodingKeys : String, CodingKey {
        case id
        case recipient
        case budget
        case price
        case purchasedOn
    }
}

extension Gift {
    
    enum FormTag : String {
        case recipient      = "ownerId"
        case budget         = "collaborators"
        case price          = "name"
        case purchasedOn    = "date"
        case saveButton     = "saveButton"
        
        var tag: String {
            return self.rawValue
        }
        
        var title: String {
            switch self {
            case .recipient:    return "Recipient"
            case .budget:       return "Budget"
            case .price:        return "Price"
            case .purchasedOn:  return "Purchased On"
            case .saveButton:   return "Save"
            }
        }
        
        var placeholder: String {
            switch self {
            case .recipient:    return "Recipient"
            case .budget:       return "Budget"
            case .price:        return "$0.00"
            case .purchasedOn:  return "Purchased On"
            case .saveButton:   return "Save"
            }
        }
    }
}

fileprivate extension Dictionary where Key == String, Value == Any? {
    subscript (key: Gift.FormTag) -> Any? {
        return self[key.rawValue] ?? nil
    }
}

