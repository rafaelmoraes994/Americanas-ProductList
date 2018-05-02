//
//  Product.swift
//  DesafioB2W
//
//  Created by Rafael on 4/30/18.
//  Copyright © 2018 Rafael. All rights reserved.
//
//
// This file contains structures that represent the API’s JSON structure from Americanas website that is beeing used in this application

import Foundation

struct ProductIdList: Codable {
    let products: [ProductId]
}

struct ProductId: Codable {
    let id: String
}

struct ProductInfo: Codable {
    let product: ProductDetails?
    let installment: ProductInstallment?
}

struct ProductDetails: Codable{
    let result: ProductResult?
}

struct ProductResult: Codable {
    let images: [ResultImage]?
    let name: String?
    let id: String?
    let rating: ProductRating?
}

struct ResultImage: Codable{
    let medium: String?
    let large: String?
}

struct ProductRating: Codable {
    let reviews: Int?
    let average: Double?
}

struct ProductInstallment: Codable {
    let result: InstallmenteResultOrArray?
}

struct InstallmentResult: Codable {
    let interestRate: Int?
    let value: Double?
    let total: Double?
    let quantity: Int?
}

// Installment inside JSON can be an array or a single object. This struct checks the type to be able to decode the correct object
struct InstallmenteResultOrArray: Codable {
    let installment: [InstallmentResult]
    
    init(from decoder: Decoder) throws {
        if let type = try? InstallmentResult(from: decoder) {
            installment = [type]
            return
        }
        installment = try [InstallmentResult](from: decoder)
    }
}



