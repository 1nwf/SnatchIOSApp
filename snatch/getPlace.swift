//
//  MatchView.swift
//  snatch
//
//  Created by Nawaf on 6/8/21.
//

import SwiftUI
import Kingfisher
import MapKit



class getPlace {
    func lookUpCurrentLocation(long: Double, lat: Double, completionHandler: @escaping (CLPlacemark?)
                    -> Void ) {
        let location = CLLocation(latitude: lat, longitude: long)

            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location,
                        completionHandler: { (placemarks, error) in
                if error == nil {
                    let firstLocation = placemarks?[0]
                    completionHandler(firstLocation)
                }
                else {
                    completionHandler(nil)
                }
            })  
        }
}


