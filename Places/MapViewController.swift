//
//  MapViewController.swift
//  Places
//
//  Created by Мирсаит Сабирзянов on 6/26/22.
//

import UIKit
import MapKit
import CoreLocation


protocol MapViewControllerDelegate {
    func getAddress(_ address: String?)
        
}

class MapViewController: UIViewController{
    
    
    let mapManager = MapManager()
    var mapViewControllerDelegate: MapViewControllerDelegate?
    var place = Place()
    let annotationIdetifier = "annotationIdetifier"
    var incomeIdentifier = ""
    
    var previousLocation: CLLocation?{
        didSet{
            mapManager.startTrackingUserLocation(
                for: MapView,
                and: previousLocation) { (currentLocation) in
                    
                    self.previousLocation = currentLocation
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        self.mapManager.userLocation(mapView: self.MapView)
                    }
            }
        }
    }
    

    @IBOutlet var CentralLoc: UIButton!
    @IBOutlet var MapView: MKMapView!
    @IBOutlet var MapPin: UIImageView!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var gotoButton: UIButton!
    
    override func viewDidLoad() {
        if #available(iOS 13.0, *) {
                overrideUserInterfaceStyle = .light
            }
        super.viewDidLoad()
        MapView.delegate = self
        setupMapView()
        addressLabel.text = ""
        
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 25, weight: .bold, scale: .large)
        let largeBoldDoc =  UIImage(systemName: "location.circle", withConfiguration: largeConfig)
        CentralLoc.setImage(largeBoldDoc, for: .normal)
    }
    
    private func setupMapView(){
        gotoButton.isHidden = true
        
        mapManager.checkLocationServices(mapView: MapView, segueIdentifier: incomeIdentifier) {
            mapManager.locationManager.delegate = self
        }
        
        if incomeIdentifier == "showMap"{
            mapManager.setupPlacemark(place: place, mapView: MapView)
            MapPin.isHidden = true
            addressLabel.isHidden = true
            doneButton.isHidden = true
            gotoButton.isHidden = false
        }
    }

    @IBAction func centreView() {
        mapManager.userLocation(mapView: MapView)
    }
    
    @IBAction func goButton() {
        mapManager.getDirections(for: MapView) { (location) in
            self.previousLocation = location}
    }
    
    @IBAction func getAddress() {
        mapViewControllerDelegate?.getAddress(addressLabel.text)
        self.navigationController?.popViewController(animated: true)
    }
    

  
}

extension MapViewController: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard !(annotation is MKUserLocation) else{ return nil}
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdetifier) as? MKPinAnnotationView
        
        if annotationView == nil{
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdetifier)
            annotationView?.canShowCallout = true
        }
        
        if let imageData = place.imageData{
            
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            imageView.layer.cornerRadius = 10
            imageView.clipsToBounds = true
            imageView.image = UIImage(data: imageData)
            annotationView?.leftCalloutAccessoryView = imageView
        }
        return annotationView
        
        
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = mapManager.getCenterLocation(for: mapView)
        let geocoder = CLGeocoder()
        
        if incomeIdentifier == "showPlace" && previousLocation != nil{
            DispatchQueue.main.asyncAfter(deadline: .now() + 5){
                self.mapManager.userLocation(mapView: self.MapView)

            }
        }
        
        geocoder.reverseGeocodeLocation(center){(placemarks, error) in
            if let error = error{
                print(error)
                return
            }
            guard let placemarks = placemarks else { return }
            
            let placemark = placemarks.first
            let city = placemark?.locality
            let streetname = placemark?.thoroughfare
            var buildNum = placemark?.subThoroughfare
            if buildNum != nil{
                buildNum = buildNum!.components(separatedBy: " ")[0]
            }
            DispatchQueue.main.async {
                if streetname != nil && buildNum != nil{ self.addressLabel.text = "\(city!), \(streetname!), \(buildNum!)"}
                else if streetname != nil{ self.addressLabel.text = "\(city!), \(streetname!)"}
                else{self.addressLabel.text = ""}
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .systemBlue
        
        return renderer
    }
}

extension MapViewController: CLLocationManagerDelegate {
        
    func locationManager(_ manager: CLLocationManager,
                            didChangeAuthorization status: CLAuthorizationStatus) {
        mapManager.checkAuthLocation(mapView: MapView,
                                     segueIdentifier: incomeIdentifier)
    }
}
