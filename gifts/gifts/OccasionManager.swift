//
//  OccasionManager.swift
//  gifts
//
//  Created by Colby L Williams on 11/19/17.
//  Copyright © 2017 Colby L Williams. All rights reserved.
//

import Foundation
import UIKit
import AzureData
import Eureka

class OccasionManager {
    
    static let shared: OccasionManager = {
        return OccasionManager()
    }()
    
    
    let databaseId = "Occasion"
    let collectionId = "Occasion"
    
    var collection: DocumentCollection?
    
    var occasions = [Occasion]()
    
    var occasion: Occasion?
    
    let currencyFormatter: CurrencyFormatter = {
        let formatter = CurrencyFormatter()
        formatter.locale = .current
        formatter.numberStyle = .currency
        return formatter
    }()

    
    func refresh(callback: @escaping () -> ()) {

        if collection == nil {
            refreshOccasionCollection {
                self.refreshOccasionDocuments {
                    DispatchQueue.main.async { callback() }
                }
            }
        } else {
            refreshOccasionDocuments {
                DispatchQueue.main.async { callback() }
            }
        }
    }
    
    
    func add(_ occasion: Occasion, _ callback: @escaping () -> ()) {
        
        collection?.create(occasion){ response in
            
            if let document = response.resource {
                
                self.occasions.append(document)
                
            } else if let clientError = response.error as? DocumentClientError {
                print(clientError.message ?? clientError.localizedDescription)
            } else if let error = response.error {
                print(error.localizedDescription)
            }
            DispatchQueue.main.async { callback() }
        }
    }
    
    
    func add(_ gift: Gift, _ callback: @escaping () -> ()) {
        
        if let occasion = occasion {
            
            occasion.gifts.append(gift)
            
            collection?.replace(occasion) { response in
                
                if let document = response.resource {
                
                    self.occasion = document
                    
                } else if let clientError = response.error as? DocumentClientError {
                    print(clientError.message ?? clientError.localizedDescription)
                } else if let error = response.error {
                    print(error.localizedDescription)
                }
                DispatchQueue.main.async { callback() }
            }
        }
    }
    
    
    func delete(occasionAt index: Int, _ callback: @escaping (Bool) -> ()) {
        
        var success = false
        
        let occasionToRemove = occasions.remove(at: index)
        
        collection?.delete(occasionToRemove) { response in
            if response.result.isSuccess {
                success = true
            } else if let clientError = response.error as? DocumentClientError {
                print(clientError.message ?? clientError.localizedDescription)
            } else if let error = response.error {
                print(error.localizedDescription)
            }
            
            DispatchQueue.main.async { callback(success) }
        }
    }
    
    
    func delete(giftAt index: Int, _ callback: @escaping (Bool) -> ()) {
        
        var success = false

        if let occasion = occasion {
            
            occasion.gifts.remove(at: index)
            
            collection?.replace(occasion) { response in
                
                if let document = response.resource {
                    
                    success = true
                    self.occasion = document
                } else if let clientError = response.error as? DocumentClientError {
                    print(clientError.message ?? clientError.localizedDescription)
                    success = false
                } else if let error = response.error {
                    print(error.localizedDescription)
                    success = false
                }
                DispatchQueue.main.async { callback(success) }
            }
        } else {
            callback(success)
        }
    }
    
    
    fileprivate func refreshOccasionCollection(callback: @escaping () -> ()) {
        
        AzureData.get(collectionWithId: collectionId, inDatabase: databaseId) { response in
            
            if let collection = response.resource {
                
                self.collection = collection
            
            } else if let clientError = response.error as? DocumentClientError {
                print(clientError.message ?? clientError.localizedDescription)
            } else if let error = response.error {
                print(error.localizedDescription)
            }
            callback()
        }
    }
    
    
    fileprivate func refreshOccasionDocuments(callback: @escaping () -> ()) {
        
        self.collection?.get(documentsAs: Occasion.self) { response in
            
            if let documents = response.resource?.items {
                
                self.occasions = documents
                
            } else if let clientError = response.error as? DocumentClientError {
                print(clientError.message ?? clientError.localizedDescription)
            } else if let error = response.error {
                print(error.localizedDescription)
            }
            callback()
        }
    }
}


class CurrencyFormatter : NumberFormatter, FormatterProtocol {
    
    override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?, for string: String, range rangep: UnsafeMutablePointer<NSRange>?) throws {
        
        guard
            obj != nil
            else { return }
        
        var str = string.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "")
        
        if !string.isEmpty, numberStyle == .currency && !string.contains(currencySymbol) {
            
            // Check if the currency symbol is at the last index
            if let formattedNumber = self.string(from: 1), String(formattedNumber[formattedNumber.index(before: formattedNumber.endIndex)...]) == currencySymbol {
                
                // This means the user has deleted the currency symbol. We cut the last number and then add the symbol automatically
                str = String(str[..<str.index(before: str.endIndex)])
            }
        }
        obj?.pointee = NSNumber(value: (Double(str) ?? 0.0)/Double(pow(10.0, Double(minimumFractionDigits))))
    }
    
    func getNewPosition(forPosition position: UITextPosition, inTextInput textInput: UITextInput, oldValue: String?, newValue: String?) -> UITextPosition {
        return textInput.position(from: position, offset:((newValue?.count ?? 0) - (oldValue?.count ?? 0))) ?? position
    }
}

