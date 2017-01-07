//
//  StationPoint.swift
//  JejuEVChargeStation
//
//  Created by Tae Jong Yoo on 2016. 11. 17..
//  Copyright © 2016년 Tae-Jong Yu. All rights reserved.
//

import MapKit

class ShelterPoint: NSObject, MKAnnotation {
    var title: String? = "이름정보없음"  // 대피소 명
    var subtitle:String? = "주소정보없음" // 주소
    var coordinate: CLLocationCoordinate2D // 위도, 경도
    var capacity:Int = 0 // 수용인원
    
    init(title: String,
         coordinate: CLLocationCoordinate2D,
         subtitle: String,
         capacity: Int) {
        
        self.title = title
        self.coordinate = coordinate
        self.subtitle = subtitle
        self.capacity = capacity
    }
    
}
