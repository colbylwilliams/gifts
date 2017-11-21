//
//  Purchase.swift
//  gifts
//
//  Created by Colby L Williams on 11/20/17.
//  Copyright © 2017 Colby L Williams. All rights reserved.
//

import Foundation

class Purchase : Codable {
    
    var id:             String
    var name:           String?
    var price:          Double?
    var purchasedOn:    Date?
    
    var purchased: Bool { return purchasedOn != nil }
    
    init() { id = UUID().uuidString }
    
    init(withId id: String) { self.id = id }
}


private extension Purchase {
    
    private enum CodingKeys : String, CodingKey {
        case id
        case name
        case price
        case purchasedOn
    }
}


extension Purchase {
    
    convenience init(withTagDictionary dict: [String:Any?]) {
        self.init()
        
        self.name           = dict[.name]           as? String
        self.price          = dict[.price]          as? Double
        self.purchasedOn    = dict[.purchasedOn]    as? Date
    }
}


extension Purchase : Equatable {
    static func ==(lhs: Purchase, rhs: Purchase) -> Bool {
        return lhs.id == rhs.id
    }
}


extension Purchase {
    
    enum FormTag : String {
        
        case name           = "name"
        case price          = "price"
        case purchased      = "purchased"
        case purchasedOn    = "purchasedOn"
        case saveButton     = "saveButton"
        
        
        var tag: String { return self.rawValue }
        
        
        var title: String {
            switch self {
            case .name:         return "Name"
            case .price:        return "Price"
            case .purchased:    return "Purchased"
            case .purchasedOn:  return "Purchased On"
            case .saveButton:   return "Save"
            }
        }
        
        
        var placeholder: String {
            switch self {
            case .name:         return "Purchase Name"
            case .price:        return "$0.00"
            case .purchased:    return "Purchased"
            case .purchasedOn:  return "Purchased On"
            case .saveButton:   return "Save"
            }
        }
    }
}


fileprivate extension Dictionary where Key == String, Value == Any? {
    subscript (key: Purchase.FormTag) -> Any? {
        return self[key.rawValue] ?? nil
    }
}
