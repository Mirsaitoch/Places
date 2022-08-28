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

class MapViewController: UIViewController {
    
    var mapViewControllerDelegate: MapViewControllerDelegate?
    var place = Place()
    let annotationIdetifier = "annotationIdetifier"
    let locationManager = CLLocationManager()
    let mapScaleShow = 5_000.00
    var incomeIdentifier = ""
    

    @IBOutlet var CentralLoc: UIButton!
    @IBOutlet var MapView: MKMapView!
    @IBOutlet var MapPin: UIImageView!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var doneButton: UIButton!
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MapView.delegate = self
        setupMapView()
        checkLocationServices()
        addressLabel.text = ""
//      setting of button
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 25, weight: .bold, scale: .large)
        let largeBoldDoc =  UIImage(systemName: "location.circle", withConfiguration: largeConfig)
        CentralLoc.setImage(largeBoldDoc, for: .normal)
    }
    
    private func setupMapView(){
        if incomeIdentifier == "showMap"{
            setupPlacemark()
            MapPin.isHidden = true
            addressLabel.isHidden = true
            doneButton.isHidden = true
        }
    }
    
    @IBAction func centreView() {
        userLocation()
    }
    
    @IBAction func doneAdress() {
        mapViewControllerDelegate?.getAddress(addressLabel.text)
        dismiss(animated: true)
    }
    
    private func getCenterLocation(for mapView: MKMapView) -> CLLocation{
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    private func userLocation(){
        if let location = locationManager.location?.coordinate{
            let region = MKCoordinateRegion(center: location, latitudinalMeters: mapScaleShow, longitudinalMeters: mapScaleShow)
            MapView.setRegion(region, animated: true)
        }
    }
    
    private func setupPlacemark(){
        guard let location =  place.location else {return}
        
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(location) { placemarks, error in
            if let error = error{
                    print(error)
                return
            }
            
            guard let placemarks = placemarks else { return}
            
            let placemark = placemarks.first
            
            let annotation = MKPointAnnotation()
            
            annotation.title = self.place.name
            
            annotation.subtitle = self.place.type
            
            guard let placeMarkLocation = placemark?.location else { return}
            
            annotation.coordinate = placeMarkLocation.coordinate
            
            self.MapView.showAnnotations([annotation], animated: true)
            self.MapView.selectAnnotation(annotation, animated: true)
            
            
            
        }
    }
    private func showAlert(title: String, message: String) {

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)

        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
    private func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkAuthLocation()
        }
        else{
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(
                    title: "Location Services are Disabled",
                    message: "To enable it go: Settings -> Privacy -> Location Services and turn On"
                )
            }
        }
    }
        
    private func setupLocationManager(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
        
    private func checkAuthLocation(){
        switch CLLocationManager.authorizationStatus(){
        case .authorizedWhenInUse:
            MapView.showsUserLocation = true
            if incomeIdentifier == "showLocation"{
                userLocation()
                
            }
            break
        case .denied:
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(
                    title: "Location Services are Disabled",
                    message: "To enable it go: Settings -> Privacy -> Location Services and turn On"
                )
            }
             break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            break
        case .authorizedAlways:
            break
        @unknown default:
            print("new case")
        }
    
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
        let center = getCenterLocation(for: mapView)
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(center){(placemarks, error) in
            if let error = error{
                print(error)
                return
            }
            guard let placemarks = placemarks else { return }
            let placemark = placemarks.first
            let streetname = placemark?.thoroughfare
            let buildNum = placemark?.subThoroughfare
            DispatchQueue.main.async {
                if streetname != nil && buildNum != nil{ self.addressLabel.text = "\(streetname!), \(buildNum!)"}
                else if streetname != nil{ self.addressLabel.text = "\(streetname!)"}
                else{self.addressLabel.text = ""}
            }
        }
    }
}


extension MapViewController: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkAuthLocation()
    }
}
