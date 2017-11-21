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
    
    var id:         String
    var recipient:  String?
    var budget:     Double?
    var purchases:  [Purchase] = []
    
    
    init() { id = UUID().uuidString }
}


private extension Gift {
    
    private enum CodingKeys : String, CodingKey {
        case id
        case recipient
        case budget
        case purchases
    }
}


extension Gift {
    
    convenience init(withTagDictionary dict: [String:Any?]) {
        self.init()
        
        self.recipient  = dict[.recipient]  as? String
        self.budget     = dict[.budget]     as? Double
    }
}


extension Gift : Equatable {
    static func ==(lhs: Gift, rhs: Gift) -> Bool {
        return lhs.id == rhs.id
    }
}


extension Gift {
    
    enum FormTag : String {
        
        case recipient  = "recipient"
        case budget     = "budget"
        case saveButton = "saveButton"
        
        
        var tag: String { return self.rawValue }
        
        
        var title: String {
            switch self {
            case .recipient:    return "For"
            case .budget:       return "Budget"
            case .saveButton:   return "Save"
            }
        }
        
        
        var placeholder: String {
            switch self {
            case .recipient:    return "Recipient"
            case .budget:       return "$0.00"
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
