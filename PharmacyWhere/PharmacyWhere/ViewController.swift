//
//  ViewController.swift
//  PharmacyWhere
//
//  Created by DIT on 2016. 11. 11..
//  Copyright © 2016년 MinWook. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

var item:[String:String] = [:]
var items:[[String:String]] = []
var elementCount = 0

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var segControl: UISegmentedControl!
    @IBOutlet weak var lblRoute: UILabel!
    
    var myRoute : MKRoute!
    var myOverlay : MKOverlay!
    var annotations = [ViewPoint]()
    var location:CLLocationCoordinate2D? 
    var locationManager = CLLocationManager()
    
    var msg:String?
    var s_time:String?
    var c_time:String?
    var telNum:String?
    var latDestination:Double?
    var longDestination:Double?

    let pharKey = "g%2BV76gKu50XVsTS5jt93A3dY1%2F95gN85mgXSVxGc7qScxvjjOAhUxc0PvjNEDL3fyZ2baDQicYrfowQqIpP8nw%3D%3D"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
	
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        mapView.delegate = self
        mapView.showsUserLocation = true
        
        let parseHandle = ParserHandle()
        self.title = "부산 약국 어디?"
        
        let strURL = "http://openapi.e-gen.or.kr/openapi/service/rest/ErmctInsttInfoInqireService/getParmacyListInfoInqire?serviceKey=\(pharKey)&Q0=%EB%B6%80%EC%82%B0%EA%B4%91%EC%97%AD%EC%8B%9C&numOfRows=999&pageSize=999&pageNo=1&startPage=1"
        
        if let url = NSURL(string: strURL) {
            if let parser = NSXMLParser(contentsOfURL: url) {
                parser.delegate = parseHandle
                
                if parser.parse() {
                    print("parsing succed")
                    print(items)
                    //print("totalCount = \(item["totalCount"])")
                } else {
                    print("parsing failed")
                }
            }
        } else {
            print("URL error")
        }
        
        makeAnnotation()
    }


    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation: CLLocation = locations[0]
        // print(userLocation)

        location = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        let span:MKCoordinateSpan
        
        if(segControl.selectedSegmentIndex == 0) {
            span = MKCoordinateSpanMake(0.05, 0.05)
        } else if (segControl.selectedSegmentIndex == 1) {
            span = MKCoordinateSpanMake(0.1, 0.1)
        } else {
            span = MKCoordinateSpanMake(0.35, 0.35)
        }
        
        let region = MKCoordinateRegion(center: location!, span: span)
        mapView.setRegion(region, animated: true)

        if myOverlay != nil {
            self.getDirection()
        }
    }
    
    
    func makeAnnotation() {
        for i in 0 ... elementCount-1 {
            
            let latitude = Double(items[i]["wgs84Lat"] ?? "0.0")
            let longitude = Double(items[i]["wgs84Lon"] ?? "0.0")
            let title = items[i]["dutyName"] ?? ""
            let addr = items[i]["dutyAddr"] ?? ""
            
            let annotation = ViewPoint(title: title, coordinate: CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!), subtitle: addr)
            annotations.append(annotation)
        }
        
        mapView.addAnnotations(annotations)
    }
    
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "myPin"
        
        // 사용자의 현재 위치 annotation을 제외함
        if annotation.isKindOfClass(MKUserLocation) {
            return nil
        }
        
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            annotationView!.pinTintColor = UIColor.redColor()
            annotationView?.rightCalloutAccessoryView = UIButton(type: .InfoLight)
        } else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
    
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if (self.s_time != nil && self.c_time != nil) {
            msg = "오전 \(self.s_time!) ~ 오후 \(self.c_time!)"
        } else {
            msg = "쉬는 날"
        }
        
       
        let alertController = UIAlertController(title: "영업시간", message: "\(self.msg!)", preferredStyle: .Alert)
        
        let callAction = UIAlertAction(title: "전화하기", style: UIAlertActionStyle.Default) { (action: UIAlertAction) -> Void in
            
            let urlString = "tel://" + "\(self.telNum!)"
            let numberURL = NSURL(string: urlString)
            UIApplication.sharedApplication().openURL(numberURL!)
        }
        
        let cancel = UIAlertAction(title: "취소", style: UIAlertActionStyle.Destructive, handler: nil)

        alertController.addAction(cancel)
        alertController.addAction(callAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    
    }
    
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
    
        if(myOverlay != nil) {
            mapView.removeOverlay(self.myOverlay!)
            self.myOverlay = nil
        }
        
        // 사용자의 현재 위치 annotation을 제외함

        if let viewAnno = view.annotation as? ViewPoint {
            
            let subtitle = viewAnno.subtitle
            
            for item in items {
                if(item["dutyAddr"] == subtitle) {
                    latDestination = Double(item["wgs84Lat"]!)!
                    longDestination = Double(item["wgs84Lon"]!)!
                    telNum = String(UTF8String: item["dutyTel1"]!)!
                    
                    let now = getCurrentDate()
                    print(now)
                    
                    if(now == "월요일") {
                        self.s_time = String(UTF8String: item["dutyTime1s"]!)!
                        self.c_time = String(UTF8String: item["dutyTime1c"]!)!
                    } else if (now == "화요일") {
                        self.s_time = String(UTF8String: item["dutyTime2s"]!)!
                        self.c_time = String(UTF8String: item["dutyTime2c"]!)!
                    } else if (now == "수요일") {
                        self.s_time = String(UTF8String: item["dutyTime3s"]!)!
                        self.c_time = String(UTF8String: item["dutyTime3c"]!)!
                    } else if (now == "목요일") {
                        self.s_time = String(UTF8String: item["dutyTime4s"]!)!
                        self.c_time = String(UTF8String: item["dutyTime4c"]!)!
                    } else if (now == "금요일") {
                        self.s_time = String(UTF8String: item["dutyTime5s"]!)!
                        self.c_time = String(UTF8String: item["dutyTime5c"]!)!
                    } else if (now == "토요일") {
                        self.s_time = String(UTF8String: item["dutyTime6s"]!)!
                        self.c_time = String(UTF8String: item["dutyTime6c"]!)!
                    } else if (now == "일요일") {
                        self.s_time = String(UTF8String: item["dutyTime7s"]!)!
                        self.c_time = String(UTF8String: item["dutyTime7c"]!)!
                    }
                }
            }
            
            self.getDirection()
            
        }
    }
    
    
    func getCurrentDate() -> String {
        let dateformatter = NSDateFormatter()
        dateformatter.locale = NSLocale(localeIdentifier: "ko_KR") // 로케일 설정
        dateformatter.dateFormat = "EEEE"
    
        return dateformatter.stringFromDate(NSDate())
    }

	
    func getDirection() {
        let directionsRequest = MKDirectionsRequest()
        let current = MKPlacemark(coordinate: location!, addressDictionary: nil)
        let destination = MKPlacemark(coordinate: CLLocationCoordinate2DMake(latDestination!, longDestination!), addressDictionary: nil)
        
        directionsRequest.source = MKMapItem(placemark: current)
        directionsRequest.destination = MKMapItem(placemark: destination)
        
        directionsRequest.transportType = MKDirectionsTransportType.Automobile
        let directions = MKDirections(request: directionsRequest)
        
        directions.calculateDirectionsWithCompletionHandler({
            response, error in
            
            if error != nil {
                print("Error getting directions")
            } else {
                self.showRoute(response!)
            }
        })
    }


    func showRoute(response: MKDirectionsResponse) {
         self.myRoute = response.routes[0] as MKRoute

	 if(myOverlay == nil) {
	     self.myOverlay = self.myRoute.polyline
	     self.mapView.addOverlay(self.myOverlay!)
	 }

        let distance = myRoute.distance // meters
        lblRoute.text = "경로 : \(myRoute.steps[0].instructions) (\(distance / 1000)km) "
        
        //print("\(distance / 1000)km")
        //print("경로 : \(myRoute.steps[0].instructions)")
    }
    

    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let myLineRenderer = MKPolylineRenderer(overlay: overlay)
        myLineRenderer.strokeColor = UIColor.orangeColor()
        myLineRenderer.lineWidth = 4
        return myLineRenderer
    }
    
    
    @IBAction func segPressed(sender: AnyObject) {
        let span:MKCoordinateSpan
        
        if(segControl.selectedSegmentIndex == 0) {
            span = MKCoordinateSpanMake(0.05, 0.05)
        } else if (segControl.selectedSegmentIndex == 1) {
            span = MKCoordinateSpanMake(0.1, 0.1)
        } else {
            span = MKCoordinateSpanMake(0.35, 0.35)
        }

        let region = MKCoordinateRegion(center: location!, span: span)
        mapView.setRegion(region, animated: true)
    }
  

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
