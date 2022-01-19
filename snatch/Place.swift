//
//  place.swift
//  snatch
//
//  Created by Nawaf on 5/22/21.
//

import Foundation
import MapKit

struct Place: Identifiable{
    var id = UUID().uuidString
    var place: CLPlacemark
}

