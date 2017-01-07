//  2016_heartpink
//
//  Created by 진연경,김시원 2016. 10. 27
//  Copyright © 2016년 DIT. 진연경,김시원

import UIKit
import MapKit
import CoreLocation

var item:[String:String] = [:]
var items:[[String:String]] = []
// pin array
var annotations:Array = [PinPoint]()

class MapTotalController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, XMLParserDelegate {
    
    @IBOutlet var zoomin: UIButton!
    @IBOutlet var zoomout: UIButton!
    
    @IBOutlet weak var totalMap: MKMapView!
    @IBOutlet weak var sgmControl: UISegmentedControl!
    
    let aedKey = "85pxiQNHO6gsxSjBFQfzN5lxPOIub30SlkWNkEvKSFjX%2BBl0sCbOltv6etE002jZB5OQkf9LFYqVZgpr2%2FivQg%3D%3D"
    
    // element
    var addressData:[String] = []
    var gugunData:[String] = []
    var orgData:[String] = []
    var sidoData:[String] = []
    var DataLong:[String] = []
    var DataLat:[String] = []

    var currentElement = ""
    var elementCount = 0
    var zoomValue = 0.04
    var locationManager = CLLocationManager()
    var locationUser: CLLocation!
    
    // user location
    var myLat:Double = 0.0
    var myLong:Double = 0.0
    
    // best AED location
    var preValue:Double = 10000
    var memoLat:Double = 0.0
    var memoLong:Double = 0.0
    var longData:Double? = 0.0
    var latData:Double? = 0.0
    var memoTitle:String? = ""
    var memoSubtitle:String? = ""
    var memoSido:String? = ""
    var memoGugun:String? = ""
    var memoMntel:String? = ""
    var memoMn:String? = ""
    
    // Annotation 받기
    var arrayAnnotation = [MKAnnotation]()
    
    // zoom
    @IBAction func zoomIn(_ sender: AnyObject) {
        let userLocation = locationManager.location?.coordinate
        if(zoomValue >= 0.04)
        {
            zoomValue = zoomValue - 0.02
        }
        else if(0.004 < zoomValue && zoomValue < 0.04)
        {
            zoomValue = zoomValue - 0.004
        }

        let span = MKCoordinateSpan(latitudeDelta: zoomValue, longitudeDelta: zoomValue)
        let region = MKCoordinateRegionMake(userLocation!, span)
        totalMap.setRegion(region, animated: true)
    }
    
    @IBAction func zoomOut(_ sender: AnyObject) {
        let userLocation = locationManager.location?.coordinate
        
        zoomValue = zoomValue + 0.02
      
        let span = MKCoordinateSpan(latitudeDelta: zoomValue, longitudeDelta: zoomValue)
        let region = MKCoordinateRegionMake(userLocation!, span)
        totalMap.setRegion(region, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.backIndicatorImage = UIImage(named: "back.png")
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "back.png")
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        
        self.title = "자동심장충격기(AED) 찾기"
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        totalMap.delegate = self
        totalMap.showsUserLocation = true
        totalMap.userLocation.title = "현재 위치"
    }
    
    // MARK : - Parsing

    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        myLat = userLocation.coordinate.latitude
        myLong = userLocation.coordinate.longitude
        
        startParsing()
        processItems()
        region()
    }
    
    func startParsing() {
        let url = "http://openapi.e-gen.or.kr/openapi/service/rest/AEDInfoInqireService/getAedLcinfoInqire?serviceKey=\(aedKey)&WGS84_LON=\(myLong)&WGS84_LAT=\(myLat)&numOfRows=100&pageSize=100&pageNo=1&startPage=1"
        
        if let url = URL(string: url) {
            if let parser = XMLParser(contentsOf: url) {
                parser.delegate = self
                
                if parser.parse() {
                    print("parsing succed")
                } else {
                    print("parsing failed")
                }
            }
        } else {
            print("url error")
        }
    }
    
    func processItems() {
        for item in items {
            let addr = item["buildAddress"]
            let gugun = item["gugun"]
            let sido = item["sido"]
            let org = item["org"]
            let lat = Double(item["wgs84Lat"]!)
            let long = Double(item["wgs84Lon"]!)
            
            let manager = item["manager"]
            let managerTel = item["managerTel"]
            
            let locationa = CLLocation(latitude: lat!, longitude: long!)
            let userlocationa = CLLocation(latitude:myLat, longitude: myLong)
            let distance = locationa.distance(from: userlocationa)
            
            if distance < preValue {
                memoLat = lat!
                memoLong = long!
                preValue = distance
                memoTitle = org
                memoSubtitle = gugun! + " " + addr!
                memoMntel = managerTel
                memoMn = manager
                memoSido = sido
                memoGugun = gugun
            }
            
            let annotation = PinPoint(org: org!, sido: sido!, gugun: gugun!, address: addr!,managerTel: managerTel!,manager: manager!, coordinate: CLLocationCoordinate2D(latitude: lat!, longitude: long!))
            annotation.title = org
            annotation.subtitle? = gugun! + " " + addr!
            annotations.append(annotation)
            
            arrayAnnotation = annotations
        }
        
        totalMap.addAnnotations(annotations)
        totalMap.showAnnotations(annotations, animated: true)
    }
    
    // MARK : - Parsing2
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        currentElement = elementName
        if elementName == "items" {
            items = []
        } else if elementName == "item" {
            item = [:]
        }
    }
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let data = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        item[currentElement] = data
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            items.append(item)
            elementCount = elementCount+1
        }
    }
    
    // MARK : - Segmented
    
    @IBAction func sgmAction(_ sender: AnyObject) {
        let userLocation = locationManager.location?.coordinate
        
        switch sgmControl.selectedSegmentIndex
        {
        case 0:
            let annotation = PinPoint(org: memoTitle!, sido: memoSido!, gugun: memoGugun!, address: memoSubtitle!,managerTel: memoMntel!,manager: memoMn!, coordinate: CLLocationCoordinate2D(latitude: memoLat, longitude: memoLong))
            annotation.title = memoTitle
            annotation.subtitle = memoSubtitle
            totalMap.addAnnotation(annotation)
            totalMap.selectAnnotation(annotation, animated: true)
            let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            let region = MKCoordinateRegionMake(userLocation!, span)
            totalMap.setRegion(region, animated: true)
            zoomValue = 0.02
            break;
        case 1:
            let span = MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)
            let region = MKCoordinateRegionMake(userLocation!, span)
            totalMap.setRegion(region, animated: true)
            zoomValue = 0.04
            break;
        case 2:
            let span = MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
            let region = MKCoordinateRegionMake(userLocation!, span)
            totalMap.setRegion(region, animated: true)
            zoomValue = 0.08
            break;
        default:
            print("Error")
            break;
        }
    }

    // MARK : - Map
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let identifier = "MyPin"
        var annotationView = totalMap.dequeueReusableAnnotationView(withIdentifier: identifier)
    
        if annotation.isKind(of: MKUserLocation.self) {
            return nil
        }
        
        if annotation.isKind(of: PinPoint.self) {

            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView!.canShowCallout = true
                annotationView!.image = UIImage(named: "heart_2.png")
                
                let button = UIButton(type: UIButtonType.system) as UIButton
                button.frame.size.width = 15
                button.frame.size.height = 15
                button.setImage(UIImage(named: "plus.png"), for: UIControlState())
                annotationView!.rightCalloutAccessoryView = button
            }
            else {
                annotationView!.annotation = annotation
            }
            
            let button = UIButton(type: UIButtonType.system) as UIButton
            button.frame.size.width = 15
            button.frame.size.height = 15
            button.setImage(UIImage(named: "plus.png"), for: UIControlState())
            annotationView!.rightCalloutAccessoryView = button
            
            return annotationView
        }
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        // pin accessory touch
        let viewAnnotation = view.annotation as! PinPoint
        let org = viewAnnotation.title
        let managerTel = viewAnnotation.managerTel
        let manager = viewAnnotation.manager

        let memo = "관리자 : " + manager! + "\n" + " " + "연락처 : " + managerTel!
        
        let alert = UIAlertController(title: org, message: memo, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler:nil))
        
        alert.addAction(UIAlertAction(title: "전화 걸기", style: .default, handler: { (action: UIAlertAction!) in
            let number = "telprompt://" + managerTel!
            let numberURL = URL(string: number)
            //UIApplication.shared.openURL(numberURL!)
            UIApplication.shared.open(numberURL!, options: [:], completionHandler: nil)
        }))
        present(alert, animated: true, completion: nil)
    }

    func region() {
        let userLocation = locationManager.location?.coordinate
        let span = MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)
        let region = MKCoordinateRegionMake(userLocation!, span)
        totalMap.setRegion(region, animated: true)
    }
    
}
