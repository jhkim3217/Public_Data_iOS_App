//
//  StationPoint.swift
//  Famous Resturant Parsing
//
//  Created by 김종현 on 2016. 9. 27..
//  Copyright © 2016년 김종현. All rights reserved.
//

import UIKit
import MapKit

class StationPoint: NSObject, MKAnnotation {
    var title: String?  // 충전소 명
    var subtitle: String? //
    var coordinate: CLLocationCoordinate2D // 위도, 경도
    var addr: String  // 주소
    var chgerType: String? // 충전기 타입--- 01.DC차데모, 02.DC차데모+AC3상, 06.DC차데모+AC3상+DC콤보
    var stat: String? // 충전기 상태--- 1.통신이상 2.충전대기 3.충전중 4.운영중지 5.점검중
    var useTime: String? // 사용시간
    
    
    init(title: String,
         coordinate: CLLocationCoordinate2D,
         addr: String,
         subtitle: String,
         chgerType: String,
         stat: String,
         useTime: String) {
        
        self.title = title
        self.coordinate = coordinate
        self.addr = addr
        self.subtitle = subtitle
        self.chgerType = chgerType
        self.stat = stat
        self.useTime = useTime
    }
}
