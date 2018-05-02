//
//  ProductListTableViewController.swift
//  DesafioB2W
//
//  Created by Rafael on 4/30/18.
//  Copyright © 2018 Rafael. All rights reserved.
//

import UIKit
import AlamofireImage

class ProductListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var productsListTableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var searchButton: UIBarButtonItem!
    @IBOutlet var cancelSearchButton: UIBarButtonItem!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    // Original List of Products gotten from the API
    var productsList: [ProductInfo] = []
    
    // A Copy of the original list of products used for filtering operations preserving the original integrity
    var filteredProductsList: [ProductInfo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setting navigation bar items
        navigationItem.title = "Americanas - Notebook"
        let textAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        navigationItem.leftBarButtonItem = nil  //cancel button must not be seen at start
        
        // Attempt to get Products cached in Disk
        productsList = DataPersistenceController.shared.getProductsFromDisk()
        filteredProductsList = productsList
        
        if productsList.count == 0 {
            loadingIndicator.startAnimating()
            loadingIndicator.isHidden = false
        }
        
        // Download Products from the API
        ProductController.shared.getProductsIds() { (productsList) in
            self.loadingIndicator.stopAnimating()
            DataPersistenceController.shared.saveProductsToDisk(productsList) // Saving downloaded Data in Disk
            self.productsList = productsList
            self.filteredProductsList = productsList
            self.productsListTableView.reloadData()
        }
    }
    
    // Search specific Product
    @IBAction func searchProduct(_ sender: UIBarButtonItem) {
        self.searchBar.becomeFirstResponder()
        navigationItem.rightBarButtonItem = nil
        navigationItem.leftBarButtonItem = cancelSearchButton
        navigationItem.titleView = searchBar
        
        // Search bar opening animation
        searchBar.transform = CGAffineTransform(translationX: UIScreen.main.bounds.width, y: 0)
        UIView.animate(withDuration: 0.5, animations: {
            self.searchBar.transform = CGAffineTransform(translationX: 0, y: 0)
        })
    }
    
    @IBAction func closeSearch(_ sender: AnyObject) {
        self.searchBar.resignFirstResponder()
        UIView.animate(withDuration: 0.5, animations: {
            self.searchBar.frame.origin.x = UIScreen.main.bounds.width
        }) { (completed) in
            self.navigationItem.titleView = nil
            self.navigationItem.rightBarButtonItem = self.searchButton
            self.navigationItem.leftBarButtonItem = nil
            self.filteredProductsList = self.productsList
            self.searchBar.text = nil
            self.productsListTableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredProductsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "productListCell", for: indexPath) as! ProductTableViewCell
        
        cell.productName.text = filteredProductsList[indexPath.row].product?.result?.name
        if let imageURL = filteredProductsList[indexPath.row].product?.result?.images?[0].medium{
            cell.imageURL = imageURL
        } else
        if let imageURL = filteredProductsList[indexPath.row].product?.result?.images?[0].large{
            cell.imageURL = imageURL
        }
        
        // Installment Info - Ex: 8x de R$ 569,49 sem juros
        let installmentQty = filteredProductsList[indexPath.row].installment?.result?.installment[0].quantity
        let installmentValue = filteredProductsList[indexPath.row].installment?.result?.installment[0].value
        let interestRate = filteredProductsList[indexPath.row].installment?.result?.installment[0].interestRate
        let installmentSuffix: String
        if interestRate == 0 {
            installmentSuffix = "sem juros"
        } else {
            installmentSuffix = "com juros"
        }
        if let productValue = filteredProductsList[indexPath.row].installment?.result?.installment[0].total {
            cell.productValue.text = getFormattedProductValue(productValue)
            cell.productInstallmentInfo.text = "\(installmentQty ?? 0)x de R$\(installmentValue ?? 0) \(installmentSuffix)"
        } else {
            cell.productValue.text = "PRODUTO INDISPONIVEL"
            cell.productInstallmentInfo.text = ""
        }
        
        // set product star rating
        if let average = filteredProductsList[indexPath.row].product?.result?.rating?.average {
            let roundAverage = Double(round(10*average/10))
            for i in 0..<Int(roundAverage) {
                cell.reviewRate[i].image = #imageLiteral(resourceName: "yellow-rate-star")
            }
        }
        
        // set number of reviews
        if let numReviews = filteredProductsList[indexPath.row].product?.result?.rating?.reviews {
            cell.numReviews.text = "\(numReviews)"
        }
        
        return cell
    }
    
    func getFormattedProductValue(_ value: Double)->String{
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = Locale(identifier: "pt_BR")
        
        if let productValue = currencyFormatter.string(from: NSNumber(value: value)){
            return productValue
        }
        return ""   
    }
    
    
    // Searchs for products that contaim a specifc word used in search
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        // Updates array with the filtered products found
         filteredProductsList = filteredProductsList.filter { (product) -> Bool in
            if let productName = product.product?.result?.name {
                if productName.lowercased().contains(searchBar.text!.lowercased()) {
                    return true
                }
            }
            return false
        }
        searchBar.resignFirstResponder()
        productsListTableView.reloadData()
    }

}
