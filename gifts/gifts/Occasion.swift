//
//  Occasion.swift
//  gifts
//
//  Created by Colby L Williams on 11/19/17.
//  Copyright © 2017 Colby L Williams. All rights reserved.
//

import Foundation
import AzureData

class Occasion: Document {
    
    var ownerId:        String?
    var collaborators:  [String] = []
    
    var name:           String?
    var date:           Date?
    var deadline:       Date?
    var budget:         Double?
    var gifts:          [Gift] = []
    
    
    var hasDeadline: Bool { return deadline != nil }
    
    
    override init() { super.init() }
    
    
    override func encode(to encoder: Encoder) throws {
        
        try super.encode(to: encoder)
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(ownerId,       forKey: .ownerId)
        try container.encode(collaborators, forKey: .collaborators)
        try container.encode(name,          forKey: .name)
        try container.encode(date,          forKey: .date)
        try container.encode(deadline,      forKey: .deadline)
        try container.encode(budget,        forKey: .budget)
        try container.encode(gifts,         forKey: .gifts)
    }
    
    
    required init(from decoder: Decoder) throws {
        
        try super.init(from: decoder)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)

        ownerId         = try container.decode(String?.self,    forKey: .ownerId)
        collaborators   = try container.decode([String].self,   forKey: .collaborators)
        name            = try container.decode(String?.self,    forKey: .name)
        date            = try container.decode(Date?.self,      forKey: .date)
        deadline        = try container.decode(Date?.self,      forKey: .deadline)
        budget          = try container.decode(Double?.self,   forKey: .budget)
        gifts           = try container.decode([Gift].self, 	forKey: .gifts)
    }
    
    
    init(withTagDictionary dict: [String:Any?]) {
        super.init()
        
        self.name       = dict[.name]       as? String
        self.date       = dict[.date]       as? Date
        self.deadline   = dict[.deadline]   as? Date
        self.budget     = dict[.budget]     as? Double
    }
}


private extension Occasion {
    
    private enum CodingKeys : String, CodingKey {
        case ownerId
        case collaborators
        case name
        case date
        case deadline
        case budget
        case gifts
    }
}


extension Occasion : Equatable {
    static func ==(lhs: Occasion, rhs: Occasion) -> Bool {
        return lhs.id == rhs.id
    }
}


extension Occasion {
    
    enum FormTag : String {
        
        case ownerId        = "ownerId"
        case collaborators  = "collaborators"
        case name           = "name"
        case date           = "date"
        case deadline       = "deadline"
        case hasDeadline    = "hasDeadline"
        case budget         = "budget"
        case type           = "type"
        case gifts          = "gifts"
        case saveButton     = "saveButton"
        
        
        var tag: String { return self.rawValue }
        
        
        var title: String {
            switch self {
            case .ownerId:          return "ownerId"
            case .collaborators:    return "collaborators"
            case .name:             return "Name"
            case .date:             return "Date"
            case .deadline:         return "Deadline"
            case .hasDeadline:      return "Deadline"
            case .budget:           return "Budget"
            case .type:             return "type"
            case .gifts:            return "gifts"
            case .saveButton:       return "Save"
            }
        }
        
        
        var placeholder: String {
            switch self {
            case .ownerId:          return "ownerId"
            case .collaborators:    return "collaborators"
            case .name:             return "Name"
            case .date:             return "Date"
            case .deadline:         return "deadline"
            case .hasDeadline:      return "hasDeadline"
            case .budget:           return "$0.00"
            case .type:             return "type"
            case .gifts:            return "gifts"
            case .saveButton:       return "saveButton"
            }
        }
    }
}


fileprivate extension Dictionary where Key == String, Value == Any? {
    subscript (key: Occasion.FormTag) -> Any? {
        return self[key.rawValue] ?? nil
    }
}
