//
//  StationPoint.swift
//  Famous Resturant Parsing
//
//  Created by Psyke on 2016. 11. 23..
//  Copyright © 2016년 Psyke. All rights reserved.
//

import UIKit
import MapKit

class StationPoint: NSObject, MKAnnotation {
    var title: String?  //주차장명
    var coordinate: CLLocationCoordinate2D // 위도, 경도
    var addr: String  // 도로명 주소
    var subtitle: String?   //요금정보
    var runDate:String?     //주차장 운영요일
    var weekdayStartTime:String?    //평일 운영시간
    var tel:String?                 //전화번호
    
    init(title: String,
         coordinate: CLLocationCoordinate2D,
         addr: String,
         subtitle: String,
         rundate:String,
         weekDayStartTile:String,
         Tel:String) {
        
        self.title = title
        self.coordinate = coordinate
        self.addr = addr
        self.runDate = rundate
        self.weekdayStartTime = weekDayStartTile
        self.tel = Tel
    }
}
