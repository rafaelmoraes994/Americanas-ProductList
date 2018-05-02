//
//  DataPersistence.swift
//  DesafioB2W
//
//  Created by Rafael on 5/1/18.
//  Copyright © 2018 Rafael. All rights reserved.
//
//
//

import Foundation

//This class controls the data persistence of the App. Saving and retrieving data from the disk
class DataPersistenceController {
    
    //Singleton
    fileprivate init() {}
    static let shared: DataPersistenceController = DataPersistenceController()
    
    func getDocumentsURL() -> URL {
        if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            return url
        } else {
            fatalError("Could not retrieve documents directory")
        }
    }

    func saveProductsToDisk(_ products: [ProductInfo]){
        // Create a URL for documents-directory/productsList.json
        let url = getDocumentsURL().appendingPathComponent("productsList.json")
        // Endcode [ProductInfo] data to JSON Data
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(products)
            // Write data to the url specified
            try data.write(to: url, options: [])
        } catch {
            print("Error - Couldn't save file")
        }
    }
    
    func getProductsFromDisk() -> [ProductInfo] {
        // Create a url for documents-directory/productsList.json
        let url = getDocumentsURL().appendingPathComponent("productsList.json")
        let decoder = JSONDecoder()
        do {
            // Retrieve the data on the file in this path (if there is any)
            let data = try Data(contentsOf: url, options: [])
            // Decode an array of Products from this Data
            let products = try decoder.decode([ProductInfo].self, from: data)
            return products
        } catch {
            return []
        }
    }
    
}
