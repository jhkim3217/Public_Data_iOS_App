//
//  ItemInfo.swift
//  moo
//
//  Created by 김종현 on 2016. 11. 24..
//  Copyright © 2016년 DIT. All rights reserved.
//

import UIKit
import MapKit

class ItemInfo: NSObject, MKAnnotation {
    var title: String? // location
    var subtitle: String? // addrJibun
    var coordinate: CLLocationCoordinate2D
    var detailLoc: String? // detailLocation
    var instName: String? // instName
    var opHours: String? // operationHours
    var petType: String? // petitionType
    var tel: String? // tel
    
    init(title: String,
         subtitle: String,
         coordinate: CLLocationCoordinate2D,
         detailLoc: String,
         instName: String,
         opHours: String,
         petType: String,
         tel: String
         )
    {
        
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        self.detailLoc = detailLoc
        self.instName = instName
        self.opHours = opHours
        self.petType = petType
        self.tel = tel
    }
    
    
}
