//  2016_heartpink
//
//  Created by 진연경 2016. 10. 31
//  Copyright © 2016년 DIT. 진연경,김시원

import UIKit
import MapKit

class PinPoint: NSObject,MKAnnotation {

    var title:String?
    var sido:String?
    var gugun:String?
    var subtitle:String?
    var managerTel:String?
    var manager:String?
    var coordinate:CLLocationCoordinate2D
    
    init(org: String,sido: String,gugun: String,address: String,managerTel: String,manager: String,coordinate: CLLocationCoordinate2D) {
        self.title = org
        self.sido = sido
        self.gugun = gugun
        self.subtitle = address
        self.coordinate = coordinate
        self.manager = manager
        self.managerTel = managerTel
    }
    
}
