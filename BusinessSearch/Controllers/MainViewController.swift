//
//  MainViewController.swift
//  BusinessSearch
//
//  Created by Samuel Hobel on 4/17/18.
//  Copyright © 2018 Samuel Hobel. All rights reserved.
//

import UIKit
import CoreLocation
import McPicker
import GooglePlacePicker
import SwiftyJSON
import SwiftSpinner

extension MainViewController: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        searchParamsChanged = true
        fromLocation.text = place.formattedAddress
        fromLocationName = place.name
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}

extension MainViewController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Dataholder.favorites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoritesCell", for: indexPath) as! FavoritesTableViewCell
        
        let business = Dataholder.favorites[indexPath.row]
        
        if (business.iconImage != nil) {
            cell.iconImageView.image = business.iconImage
        } else {
            let url = URL(string: business.icon)
            if let data = try? Data(contentsOf: url!) {
                cell.iconImageView.image = UIImage(data: data)
                business.iconImage = cell.iconImageView.image
            }
        }
        
        cell.rownum = indexPath.row
        cell.nameLabel.text = business.name
        cell.locationLabel.text = business.address
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            let business = Dataholder.favorites[indexPath.row]
            Dataholder.favorites.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            let text = business.name + " was removed from favorites"
            self.view.showToast(text, position: .bottom, popTime: 3, dismissOnTap: true)
            formChanged(formSelector)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedBusiness = Dataholder.favorites[indexPath.row]
        getPlaceDetails()
    }
}

class MainViewController: UIViewController,CLLocationManagerDelegate,UITextFieldDelegate {

    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var favoritesView: UITableView!
    @IBOutlet weak var noFavoritesView: UIView!
    @IBOutlet weak var categoryTextField: McTextField!
    @IBOutlet weak var fromLocation: UITextField!
    @IBOutlet weak var keywordTextField: UITextField!
    @IBOutlet weak var distanceTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var formSelector: UISegmentedControl!
    
    var locationManager:CLLocationManager!
    var coords = (lat: 0.0, lng: 0.0)
    var fromLocationName : String!
    var responseJSON : JSON?
    var selectedBusiness : Business?
    var searchParamsChanged = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        keywordTextField.delegate = self
        addDoneButtonToKeyboard()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        initUserLocation()
        initMcPicker()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        formChanged(formSelector)
        if (!favoritesView.isHidden){
            tableView.reloadData()
        }
    }

    func initUserLocation(){
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations.first!
        coords.lat = userLocation.coordinate.latitude
        coords.lng = userLocation.coordinate.longitude
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error){
        print("Location error: \(error)")
    }
    
    func initMcPicker(){
        let data: [[String]] = [["Default","Airport","Amusement Park","Aquarium","Art Gallery","Baker","Bar","Beauty Salon","Bowling Alley","Bus Station","Cafe","Campground","Car Rental","Casino","Lodging","Movie Theater","Museum","Night Club","Park","Parking","Restaurant","Shopping Mall","Stadium","Subway Station","Taxi Stand","Train Station","Transit Station","Travel Agency","Zoo"]]
        let mcInputView = McPicker(data: data)
        categoryTextField.inputViewMcPicker = mcInputView
        categoryTextField.doneHandler = { [weak categoryTextField] (selections) in
            categoryTextField?.text = selections[0]!
        }
        categoryTextField.selectionChangedHandler = { [weak categoryTextField] (selections, componentThatChanged) in
            self.searchParamsChanged = true
            categoryTextField?.text = selections[componentThatChanged]!
        }
        categoryTextField.textFieldWillBeginEditingHandler = { [weak categoryTextField] (selections) in
            self.dismissKeyboard()
            if categoryTextField?.text == "" {
                //default to the first value
                categoryTextField?.text = selections[0]
            }
        }
    }
    
    @IBAction func searchAction(_ sender: Any) {
        if (!searchParamsChanged){
            searchParamsChanged = false
            performSegue(withIdentifier: "searchResults", sender: self)
            return
        }
        
        if (coords.lat == 0.0 && coords.lng == 0.0){
            self.view.showToast("Could not get your location", position: .bottom, popTime: 3, dismissOnTap: true)
            return
        }
        
        if (validateKeyword()){
            searchParamsChanged = false
            SwiftSpinner.show("Searching...")
            Dataholder.currentPage = 0
            let category = categoryTextField.text?.lowercased().replacingOccurrences(of: " ", with: "_")
            var from = fromLocation.text!
            if (fromLocation.text == "Your Location"){
                let lat = (coords.lat).description
                let lng = (coords.lng).description
                from = lat + "," + lng
            }
            let params:[String:Any] = ["keyword": keywordTextField.text!, "category": category!, "distance": distanceTextField.text!, "from": from]
            HTTPRequest.makeRequest(url: Dataholder.RequestBaseUrl, params: params, view: self.view) { (responseJSON) in
                SwiftSpinner.hide()
                self.parseJSON(json: responseJSON)
                self.performSegue(withIdentifier: "searchResults", sender: self)
            }
        }
    }
    
    func parseJSON(json : JSON){
        var results = [Business]()
        Dataholder.nextPageId = json["nextPageToken"].stringValue
        for result in json["results"].arrayValue{
            let business = Business(jsonObj: result)
            
            let url = URL(string: business.icon)
            let data = try? Data(contentsOf: url!)
            let image = UIImage(data: data!)
            business.iconImage = image
            
            results.append(business)
        }
        Dataholder.pages.removeAll()
        if (!results.isEmpty) {
            Dataholder.pages.append(results)
        }
    }
    
    @IBAction func formChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            searchView.isHidden = false
            favoritesView.isHidden = true
        } else {
            searchView.isHidden = true
            if (Dataholder.favorites.isEmpty){
                favoritesView.isHidden = true
                noFavoritesView.isHidden = false
            } else {
                tableView.reloadData()
                favoritesView.isHidden = false
                noFavoritesView.isHidden = true
            }
        }
    }
    
    @IBAction func locationClicked(_ sender: Any) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
    @IBAction func clearAction(_ sender: Any) {
        searchParamsChanged = true
        keywordTextField.text = ""
        categoryTextField.text = "Default"
        distanceTextField.text = ""
        fromLocation.text = "Your Location"
    }
    
    func getPlaceDetails() {
        if let placeid = selectedBusiness?.placeid {
            if let placeDetails = Dataholder.cache[placeid] {
                self.responseJSON = placeDetails.getData(type: DetailData.DataType.json) as? JSON
                self.performSegue(withIdentifier: "showDetails", sender: self)
            } else {
                SwiftSpinner.show("Fetching place details...")
                let params:[String:Any] = ["id": placeid]
                HTTPRequest.makeRequest(url: Dataholder.RequestBaseUrl, params: params, view: self.view) { (responseJSON) in
                    self.responseJSON = responseJSON["result"]
                    self.performSegue(withIdentifier: "showDetails", sender: self)
                }
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard()
        return false
    }
    
    @objc func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    func addDoneButtonToKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = UIBarStyle.default
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem  = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(doneButtonAction))
        
        var baritems = [UIBarButtonItem]()
        baritems.append(flexibleSpace)
        baritems.append(done)
        doneToolbar.items = baritems
        doneToolbar.sizeToFit()
        distanceTextField.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction() {
        distanceTextField.resignFirstResponder()
    }
    
    func validateKeyword()->Bool{
        if (keywordTextField.text!.isEmpty || keywordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty){
            self.view.showToast("Keyword cannot be empty", position: .bottom, popTime: 3, dismissOnTap: true)
            return false
        }
        return true
    }
    
    @IBAction func keywordChanged(_ sender: Any) {
        searchParamsChanged = true
    }
    @IBAction func distanceChanged(_ sender: Any) {
        searchParamsChanged = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? DetailsTabBarController {
            dest.business = selectedBusiness
            dest.json = responseJSON
        }
    }
}
