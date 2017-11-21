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
    
    fileprivate
    var _selectedOccasion: Occasion? {
        didSet { _selectedGift = nil }
    }
    var selectedOccasion: Occasion {
        get {
            if _selectedOccasion == nil {
                _selectedOccasion = Occasion()
            }
            return _selectedOccasion!
        }
        set { _selectedOccasion = newValue }
    }
    
    fileprivate
    var _selectedGift: Gift? {
        didSet { _selectedPurchase = nil }
    }
    var selectedGift: Gift {
        get {
            if _selectedGift == nil {
                _selectedGift = Gift()
            }
            return _selectedGift!
        }
        set { _selectedGift = newValue }
    }
    
    fileprivate
    var _selectedPurchase: Purchase?
    var selectedPurchase: Purchase {
        get {
            if _selectedPurchase == nil {
                _selectedPurchase = Purchase()
            }
            return _selectedPurchase!
        }
        set { _selectedPurchase = newValue }
    }
    
    
    let currencyFormatter: CurrencyFormatter = {
        let formatter = CurrencyFormatter()
        formatter.locale = .current
        formatter.numberStyle = .currency
        return formatter
    }()

    
    
    func clearSelectedOccasion() {
        _selectedOccasion = nil
    }
    
    
    
    // Mark: - Refresh
    
    func refresh(_ callback: @escaping () -> ()) {

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
    
    
    fileprivate func refreshOccasionCollection(_ callback: @escaping () -> ()) {
        
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
    
    
    fileprivate func refreshOccasionDocuments(_ callback: @escaping () -> ()) {
        
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

    
    
    
    // Mark: - Save
    
    func saveSelectedOccasion(_ callback: @escaping () -> ()) {
        
        if occasions.contains(selectedOccasion) {
            assert(!(selectedOccasion.selfLink?.isEmpty ?? true), "nope")
            
            collection?.replace(selectedOccasion) { response in
                self.handleSaveResponse(response, callback: callback)
            }
        } else {
            assert((selectedOccasion.selfLink?.isEmpty ?? true), "nope")
            
            collection?.create(selectedOccasion) { response in
                self.handleSaveResponse(response, callback: callback)
            }
        }
    }
 
    
    func handleSaveResponse (_ response: Response<Occasion>, callback: @escaping () -> ()) {
        
        if let document = response.resource {
            
            selectedOccasion = document
            
            if let i = occasions.index(of: selectedOccasion) {
                occasions[i] = selectedOccasion
            } else {
                occasions.append(selectedOccasion)
            }
            
        } else if let clientError = response.error as? DocumentClientError {
            print(clientError.message ?? clientError.localizedDescription)
        } else if let error = response.error {
            print(error.localizedDescription)
        }
        
        DispatchQueue.main.async { callback() }
    }
    
    
    func saveSelectedGift(_ callback: @escaping () -> ()) {
        _saveSelectedGift()
        
        saveSelectedOccasion(callback)
    }
    
    func saveSelectedGiftSilent() {
        _saveSelectedGift()

        DispatchQueue.global().async {
            self.saveSelectedOccasion { print("finished") }
        }
    }

    fileprivate func _saveSelectedGift() {
        if let i = selectedOccasion.gifts.index(of: selectedGift) {
            selectedOccasion.gifts[i] = selectedGift
        } else {
            selectedOccasion.gifts.append(selectedGift)
        }
    }
    
    
    func saveSelectedPurchase(_ callback: @escaping () -> ()) {
        _saveSelectedPurchase()
        
        if selectedOccasion.gifts.contains(selectedGift) {
            saveSelectedOccasion(callback)
        } else {
            print("na")
        }
    }
    
    func saveSelectedPurchaseSilent() {
        _saveSelectedPurchase()

        if selectedOccasion.gifts.contains(selectedGift) {
            DispatchQueue.global().async {
                self.saveSelectedOccasion { print("finished") }
            }
        } else {
            print("na")
        }
    }

    fileprivate func _saveSelectedPurchase() {
        if let i = selectedGift.purchases.index(of: selectedPurchase) {
            selectedGift.purchases[i] = selectedPurchase
        } else {
            selectedGift.purchases.append(selectedPurchase)
        }
    }


    
    // Mark: - Delete
    
    func delete(occasionAt index: Int, _ callback: (Bool) -> ()) {

        if (index < 0 || index >= occasions.count) {
            callback(false); return;
        }

        let occasion = occasions.remove(at: index)
        
        if occasion == selectedOccasion {
            _selectedOccasion = nil
        }
        
        callback(true)

        print("delete occasion")
        
        collection?.delete(occasion) { response in
            if response.result.isSuccess {

            } else if let clientError = response.error as? DocumentClientError {
                print(clientError.message ?? clientError.localizedDescription)
            } else if let error = response.error {
                print(error.localizedDescription)
            }
        }
    }
    
    
    func delete(giftAt index: Int, _ callback: (Bool) -> ()) {
        
        if (index < 0 || index >= selectedOccasion.gifts.count) {
            callback(false); return;
        }

        selectedOccasion.gifts.remove(at: index)
        
        callback(true)
        
        print("delete gift")
        saveSelectedOccasion { }
    }

    
    func delete(purchaseAt index: Int, _ callback: (Bool) -> ()) {
        
        if (index < 0 || index >= selectedGift.purchases.count) {
            callback(false); return;
        }
        
        selectedGift.purchases.remove(at: index)
        
        callback(true)

        print("delete purchase")
        saveSelectedOccasion { }
    }
    
    func delete(purchaseAt index: Int) {
        if (index < 0 || index >= selectedGift.purchases.count) {
            return;
        }
        
        selectedGift.purchases.remove(at: index)
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

