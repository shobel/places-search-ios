//
//  MapViewController.swift
//  BusinessSearch
//
//  Created by Samuel Hobel on 4/19/18.
//  Copyright © 2018 Samuel Hobel. All rights reserved.
//

import UIKit
import GoogleMaps
import SwiftyJSON
import GooglePlaces
import EasyToast

extension MapViewController: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        fromLocation.text = place.formattedAddress
        coords = place.coordinate
        requestDirections(from: place.formattedAddress!)
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

class MapViewController: UIViewController {

    @IBOutlet weak var fromLocation: UITextField!
    @IBOutlet weak var travelModeControl: UISegmentedControl!
    @IBOutlet weak var mapView: GMSMapView!
    
    var parentController : DetailsTabBarController?
    var json : JSON?
    var coords: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        parentController = tabBarController as? DetailsTabBarController
        json = parentController?.json
        loadMap()
    }
    
    func loadMap(){
        let lat = json?["geometry"]["location"]["lat"].doubleValue
        let lng = json?["geometry"]["location"]["lng"].doubleValue
        
        mapView.isMyLocationEnabled = true
        let camera = GMSCameraPosition.camera(withLatitude: lat!, longitude: lng!, zoom: 15.0)
        mapView.camera = camera

        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: lat!, longitude: lng!)
        marker.map = mapView
    }
    
    func requestDirections(from: String){
        self.mapView.clear()
        loadMap()
        let params:[String:Any] = ["origin": from, "destination": parentController?.business.address ?? "", "mode": travelModeControl.titleForSegment(at: travelModeControl.selectedSegmentIndex)?.lowercased() ?? "driving"]
        HTTPRequest.makeRequest(url: Dataholder.GoogleDirectionsUrl, params: params, view: self.view) { (responseJSON) in
            self.addDirectionPathWithMarker(json: responseJSON)
        }
    }
    
    func addDirectionPathWithMarker(json: JSON){
        if (!json["routes"].arrayValue.isEmpty) {
            if let route = json["routes"].arrayValue.first {
                let line = route["overview_polyline"]
                let encodedPath = line["points"].stringValue
                if (!encodedPath.isEmpty) {
                    self.addFromLocationMarker()
                    let gmsPath = GMSMutablePath(fromEncodedPath: encodedPath)
                    let polyline = GMSPolyline(path: gmsPath)
                    polyline.strokeWidth = 4
                    polyline.map = self.mapView
                    let bounds = GMSCoordinateBounds().includingPath(gmsPath!)
                    self.mapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 50.0))
                }
            }
        } else {
            self.view.showToast("No routes found", position: .bottom, popTime: 3, dismissOnTap: true)
        }
        
    }
    
    func addFromLocationMarker(){
        let marker = GMSMarker.init()
        marker.isDraggable = false
        let location = CLLocationCoordinate2DMake((coords?.latitude)!, (coords?.longitude)!)
        marker.position = location
        marker.map = mapView
    }
    
    @IBAction func fromLocationClicked(_ sender: Any) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
    @IBAction func travelModeChanged(_ sender: Any) {
        requestDirections(from: fromLocation.text!)
    }
    
}
