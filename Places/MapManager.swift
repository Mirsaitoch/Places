//
//  MapManager.swift
//  Places
//
//  Created by Мирсаит Сабирзянов on 9/10/22.
//

import Foundation
import MapKit
import UIKit

class MapManager{
    let locationManager = CLLocationManager()
    let mapScaleShow = 1_500.00
    var placeCoordinate: CLLocationCoordinate2D?
    var diractionsArray: [MKDirections] = []
    
    
    func setupPlacemark(place: Place, mapView: MKMapView){
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
            
            annotation.title = place.name
            annotation.subtitle = place.type
            
            guard let placeMarkLocation = placemark?.location else { return}
            
            self.placeCoordinate = placeMarkLocation.coordinate
            annotation.coordinate = placeMarkLocation.coordinate
            mapView.showAnnotations([annotation], animated: true)
            mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    func checkLocationServices(mapView: MKMapView, segueIdentifier: String, closure:() -> ()) {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            checkAuthLocation(mapView: mapView, segueIdentifier: segueIdentifier)
            closure()
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
    
    // Фокус карты на местоположении пользователя
    func userLocation(mapView: MKMapView){
        if let location = locationManager.location?.coordinate{
            let region = MKCoordinateRegion(center: location, latitudinalMeters: mapScaleShow, longitudinalMeters: mapScaleShow)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func checkAuthLocation(mapView:MKMapView, segueIdentifier: String){
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            if segueIdentifier == "showLocation"{ userLocation(mapView: mapView) }
            break
        case .denied:
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(
                    title: "Location Services are Disabled",
                    message: "To enable it go: Settings -> Privacy -> Location Services and turn On")
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

    
    // Строим маршрут от местоположения пользователя до локации

    func getDirections(for mapView: MKMapView, previousLocation: (CLLocation) -> ()){
        
        guard let location = locationManager.location?.coordinate
        else {
            showAlert(title: "problems with location!", message: "Current location is not found")
            return
        }
        
        locationManager.startUpdatingLocation()
        previousLocation(CLLocation(latitude: location.longitude, longitude: location.longitude))
        
        guard let request = createDirectionRequest(from: location)
            else { showAlert(title: "error", message: "Destination is not found")
            return
        }
        
        let directions = MKDirections(request: request)
        
        resetMapView(withNew: directions, mapView: mapView)
        
        directions.calculate{(response, error) in
            if let error = error{
                self.showAlert(title: "Any problems", message: "\(error)")
                return
            }
            
            
            guard let response = response else{
                self.showAlert(title: "Error", message: "Directions is not avalible")
                return
            }
            
            for route in response.routes{
                mapView.addOverlay(route.polyline)
                mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                break
            }
        }
    }
    
    
    private func createDirectionRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request?{
        guard let destinationCoordinate = placeCoordinate else { return nil }
        let startLocation = MKPlacemark(coordinate: coordinate)
        let destination = MKPlacemark(coordinate: destinationCoordinate)
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startLocation)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .walking
        request.requestsAlternateRoutes = true
        return request
    }
    
    func startTrackingUserLocation(for mapView: MKMapView, and location: CLLocation?, closure: (_ currentLocation: CLLocation) -> ()) {
        guard let location = location else { return }
        let center = getCenterLocation(for: mapView)
        guard center.distance(from: location) > 5 else { return }
        
//        closure(center)
    }
    
    private func resetMapView(withNew dirations: MKDirections, mapView: MKMapView){
        
        mapView.removeOverlays(mapView.overlays)
        diractionsArray.append(dirations)
        let _ = diractionsArray.map { $0.cancel()
            diractionsArray.removeAll()
        }
    }
    
    func getCenterLocation(for mapView: MKMapView) -> CLLocation{
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    private func showAlert(title: String, message: String) {

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)

        alert.addAction(okAction)
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindow.Level.alert + 1
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alert, animated: true)
        
    }
    
    
}

