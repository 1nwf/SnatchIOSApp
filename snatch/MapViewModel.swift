//
//  map2.swift
//  snatch
//
//  Created by Nawaf on 5/21/21.
//

import Foundation
import MapKit
import CoreLocation
class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var mapView = MKMapView()
    @Published var region: MKCoordinateRegion!
    @Published var permissionDenied = false
    let manager = CLLocationManager()
    @Published var mapType: MKMapType = .standard
    @Published var searchTxt = ""
    @Published var user_Location : CLLocation!

    @Published var places: [Place] = []
    @Published var currentPlace: Place?

    func updateMapType(){
        if mapType == .standard{
            mapType = .hybrid
            mapView.mapType = mapType
        } else{
            mapType = .standard
            mapView.mapType = mapType
        }
    }

    func focusLocation(){
        guard let _ =  region else {return}
        let loc = MKCoordinateRegion(center: manager.location!.coordinate, latitudinalMeters: 10000, longitudinalMeters: 1000)
        mapView.setRegion(loc, animated: true)
        mapView.setVisibleMapRect(mapView.visibleMapRect, animated: true)
    }

    func getCityState() -> String {
        let location = CLLocation(latitude: manager.location?.coordinate.latitude ?? 0, longitude: manager.location?.coordinate.longitude ?? 0)
        var location_string = ""
            let geocoder = CLGeocoder()

            // Look up the location and pass it to the completion handler
            geocoder.reverseGeocodeLocation(location,
                        completionHandler: { (placemarks, error) in
                if error == nil {
                    let firstLocation = placemarks?[0]
                    location_string =  "\(String(describing: firstLocation!.locality)), \(String(describing: firstLocation!.administrativeArea))"
                }
                else {
                    location_string = "no location found"
                }
            })
        return location_string
        }






    func searchQuery(){
        places.removeAll()

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchTxt

        MKLocalSearch(request: request).start { (response, _) in
            guard let result = response else {return}
            self.places = result.mapItems.compactMap( {(item) -> Place? in
                    return Place(place: item.placemark)
        })
        }
    }

    func selectPlace(place: Place){
        searchTxt = ""

        guard let coordinate = place.place.location?.coordinate else {return}

        let pointAnnotation = MKPointAnnotation()
        pointAnnotation.coordinate = coordinate
        pointAnnotation.title = place.place.name ?? "no name"

        currentPlace = place

        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(pointAnnotation)

        let coordinateRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: 10000, longitudinalMeters: 1000)
        mapView.setRegion(coordinateRegion, animated: true)
        mapView.setVisibleMapRect(mapView.visibleMapRect, animated: true)
    }


    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .denied:
            permissionDenied.toggle()
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case.authorizedWhenInUse:
            manager.requestLocation()
        default:
            ()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        guard let location = locations.first else {return}
        user_Location = location
        self.region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
        self.mapView.setRegion(self.region, animated: true)
        self.mapView.setVisibleMapRect(self.mapView.visibleMapRect, animated: true)

    }
}
