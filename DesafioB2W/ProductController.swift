//
//  ProductController.swift
//  DesafioB2W
//
//  Created by Rafael on 4/30/18.
//  Copyright © 2018 Rafael. All rights reserved.
//

import Alamofire
import Foundation

// Manages all the requests related to the products with the API
class ProductController {
    
    //Singleton
    fileprivate init() {}
    static let shared: ProductController = ProductController()
    
    var productBaseURL = "https://restql-server-api-v1-americanas.b2w.io/run-query/catalogo/product-without-promotion/5?id="
    
    // API URL related to Americanas Notebook Department
    var productListURL = "https://mystique-v2-americanas.b2w.io/search?sortBy=relevance&source=omega&filter=%7B%22id%22%3A%22category.id%22%2C%22value%22%3A%22267868%22%2C%22fixed%22%3Atrue%7D&limit=48&suggestion=true"
    
    // another URL example - Apple Department
    //"https://mystique-v2-americanas.b2w.io/search?sortBy=topSelling&source=omega&filter=%7B%22id%22%3A%22category.id%22%2C%22value%22%3A%22268228%22%2C%22fixed%22%3Atrue%7D&limit=48&suggestion=true"
    
    
    // Fetches a list of products Ids from the chosen API, calls getProductList to get an array of products informations and returns it to the caller
    func getProductsIds(completion: @escaping ([ProductInfo])->()){
        Alamofire.request(productListURL).responseJSON { (response) in
            guard let data = response.data else { return }
                do{
                    let productsIds = try JSONDecoder().decode(ProductIdList.self, from: data)
                    self.getProductList(productsIds.products, completion)
                }catch{
                    print("Request Error - Failed to get products list data")
                }
        }
    }
    
    // Fetches a list of products information based on a list of products Ids received
    func getProductList(_ productsIds: [ProductId], _ completion: @escaping ([ProductInfo])->()){
        
        let dispatchGroup = DispatchGroup()
        var productsList: [ProductInfo] = []
        
        for i in 0..<productsIds.count {
            let productCompleteUrl = productBaseURL + productsIds[i].id
            dispatchGroup.enter()
            Alamofire.request(productCompleteUrl).responseJSON { (response) in
                guard let data = response.data else {return }
                do{
                    let productInfo = try JSONDecoder().decode(ProductInfo.self, from: data)
                    productsList.append(productInfo)
                }catch{
                    print("Request Error - Failed to get product data")
                }
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: .main, execute: {
            completion(productsList)
        })
    }
    
}




    

