//
//  ResultsTableViewController.swift
//  BusinessSearch
//
//  Created by Samuel Hobel on 4/17/18.
//  Copyright © 2018 Samuel Hobel. All rights reserved.
//

import UIKit
import SwiftSpinner
import SwiftyJSON

class ResultsTableViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,BusinessTableViewCellDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var noResultsView: UIView!
    
    var selectedBusiness : Business!
    var responseJSON : JSON?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        enableDisableButtons()
        
        noResultsView.isHidden = true
        tableView.isHidden = false
        if (Dataholder.pages.isEmpty) {
            noResultsView.isHidden = false
            tableView.isHidden = true
        }
        setUpNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    func setUpNavigationBar(){
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Dataholder.getCurrentPage().count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessCell", for: indexPath) as! BusinessTableViewCell
        cell.delegate = self
        
        let business = Dataholder.getCurrentPage()[indexPath.row]
        
        if (Dataholder.favorites.contains(business)){
            cell.favoritesButton.setImage(UIImage(named: "favorite-filled"), for: .normal)
        } else {
            cell.favoritesButton.setImage(UIImage(named: "favorite-empty"), for: .normal)
        }
        
        if (business.iconImage != nil) {
            cell.iconImageView.image = business.iconImage
        }
        cell.rownum = indexPath.row
        cell.nameLabel.text = business.name
        cell.locationLabel.text = business.address
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedBusiness = Dataholder.getCurrentPage()[indexPath.row]
        getPlaceDetails()
    }
    
    //Adds or removes an item from the favorites array depending on if it is already favorited or not
    func favoritesTapped(rownum: Int) {
        let isFavorite = Dataholder.favoritesTapped(index: rownum)
        let business = Dataholder.getCurrentPage()[rownum]
        var text = business.name + " was removed from favorites"
        if (isFavorite){
            text = business.name + " was added to favorites"
        }
        self.view.showToast(text, position: .bottom, popTime: 3, dismissOnTap: true)
    }

    @IBAction func prevButtonAction(_ sender: Any) {
        Dataholder.currentPage-=1
        tableView.reloadData()
        enableDisableButtons()
    }
    
    @IBAction func nextButtonAction(_ sender: Any) {
        if (!Dataholder.nextPageId.isEmpty) {
            requestNextPage()
        } else {
            nextButtonCallback()
        }
    }
    
    func nextButtonCallback(){
        Dataholder.currentPage+=1
        tableView.reloadData()
        enableDisableButtons()
    }
    
    func enableDisableButtons(){
        if (!Dataholder.hasNextPage() && Dataholder.nextPageId.isEmpty){
            nextButton.isEnabled = false
        } else {
            nextButton.isEnabled = true
        }
        if (Dataholder.hasPrevPage()){
            prevButton.isEnabled = true
        } else {
            prevButton.isEnabled = false
        }
    }
    
    func requestNextPage(){
        SwiftSpinner.show("Loading next page...")
        HTTPRequest.makeRequest(url: Dataholder.RequestBaseUrl, params: ["page": Dataholder.nextPageId], view: self.view) { (responseJSON) in
            SwiftSpinner.hide()
            self.parseJSON(json: responseJSON)
            self.nextButtonCallback()
        }
    }
        
    func parseJSON(json : JSON){
        var results = [Business]()
        Dataholder.nextPageId = json["nextPageToken"].stringValue
        for result in json["results"].arrayValue{
            let business = Business(jsonObj: result)
            results.append(business)
        }
        Dataholder.pages.append(results)
    }
    
    func getPlaceDetails() {
        let placeid = selectedBusiness.placeid
        if let placeDetails = Dataholder.cache[placeid] {
            self.responseJSON = placeDetails.getData(type: DetailData.DataType.json) as? JSON
            self.performSegue(withIdentifier: "showDetails", sender: self)
        } else {
            SwiftSpinner.show("Fetching place details...")
            HTTPRequest.makeRequest(url: Dataholder.RequestBaseUrl, params:  ["id": placeid], view: self.view) { (responseJSON) in
                //SwiftSpinner.hide()
                self.responseJSON = responseJSON["result"]
                self.performSegue(withIdentifier: "showDetails", sender: self)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? DetailsTabBarController {
            dest.business = selectedBusiness
            dest.json = responseJSON
        }
    }
}
