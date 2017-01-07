//
//  ViewPoint.swift
//  PharmacyWhere
//
//  Created by L703 on 2016. 11. 11..
//  Copyright © 2016년 MinWook. All rights reserved.
//

import UIKit
import MapKit

class ViewPoint: NSObject, MKAnnotation {
    var title: String?
    var coordinate: CLLocationCoordinate2D
    var subtitle: String?
    
    init(title: String, coordinate: CLLocationCoordinate2D, subtitle: String) {
        self.title = title
        self.coordinate = coordinate
        self.subtitle = subtitle
    }
}
