//
//  ViewController.swift
//  Busan Dust Map
//
//  Created by 김종현 on 2016. 11. 5..
//  Copyright © 2016년 김종현. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, NSXMLParserDelegate, MKMapViewDelegate, CLLocationManagerDelegate {
    
    
    @IBOutlet weak var DistSegment: UISegmentedControl!
    
    @IBOutlet weak var DustMapView: MKMapView!
    
    //var center: CLLocationCoordinate2D?
    // 공공데이터 인증키
    let key = "aT2qqrDmCzPVVXR6EFs6I50LZTIvvDrlvDKekAv9ltv9dbO%2F8i8JBz2wsrkpr9yrPEODkcXYzAqAEX1m%2Fl4nHQ%3D%3D"
    
    var item:[String:String] = [:]
    var items:[[String:String]] = []
    var currnetElement = ""
    var isInItem = false
    
    let cais = ["좋음", "보통", "나쁨", "매우나쁨"]
    
    var p10Cais = ""
    var p25Cais = ""
    
    //var subtitle = ""
    var lat = ""
    var long = ""
    
    var dLong:Double = 0.0
    var dLat:Double = 0.0
    
    var annotation: StationPoint?
    var annotations:Array = [StationPoint]()
    
    var locationManager = CLLocationManager()

    
    let addrs:[String:[String]] = [
        "광복동" : ["중구 광복로 55번길 10", "35.0999630", "129.0304170"],
        "장림동" : ["사하구 장림로 161번길 2", "35.0829920", "128.9668750"],
        "학장동" : ["사상구 대동로 205", "35.1460850", "128.9838270"],
        "덕천동" : ["북구 만덕대로 155번길 81", "35.2158660", "129.0197570"],
        "연산동" : ["연제구 중앙대로 1065번길 14", "35.1841140", "129.0786090"],
        "대연동" : ["남구수영로 196번길 80", "35.1303210", "129.0876850"],
        "청룡동" : ["금정구 청룡로 25", "35.2752570", "129.0898810"],
        "전포동" : ["부산진구 전포대로 175번길 22", "35.1530480", "129.0635640"],
        "태종대" : ["영도구 전망로 24", "35.0597260", "129.0798400"],
        "기장읍" : ["기장군 기장읍 읍내로 69", "35.2460560", "129.2118280"],
        "대저동" : ["강서구 낙동북로 236", "35.2114600", "128.9547110"],
        "부곡동" : ["금정구 부곡로 156번길 7", "35.2298390", "129.0927140"],
        "광안동" : ["수영구 수영로 521번길 55", "35.1527040", "129.1078090"],
        "명장동" : ["동래구 명장로 32", "35.2047550", "129.1043270"],
        "녹산동" : ["강서구 녹산산업중로 333", "35.0953270", "128.8556680"],
        "용수리" : ["기장군 정관면 용수로4", "35.3255580", "129.1801400"],
        "좌동"  : ["해운대구 양운로 91", "35.1708900", "129.1742250"],
        "수정동" : ["동구 구청로 1", "35.1293350", "129.0454230"],
        "대신동" : ["서구 대신로 150", "35.1173230", "129.0156410"],
        "온천동" : ["동래구 중앙대로 동래역", "35.2056140", "129.0785020"]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.title = "부산 실시간 미세먼지 지도"
        
        let strURL = "http://opendata.busan.go.kr/openapi/service/AirQualityInfoService/getAirQualityInfoClassifiedByStation?ServiceKey=\(key)&numOfRows=21&pageSize=21&pageNo=1&startPage=1"
        
        let url = NSURL(string: strURL)!
        
        let parser = NSXMLParser(contentsOfURL: url)!
        
        parser.delegate = self
        
        if parser.parse() {
            print("parsing success")
            print(items)
            print(item)
        } else {
            print("parsing fail")
        }
        
        
        DustMapView.delegate = self
        
        // 위치 트랙킹
        locationManager.delegate = self
        locationManager.stopUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()
        
        DustMapView.showsUserLocation = true
        DustMapView.userLocation.title = "현재 위치"
        
        /// 지도 작업
        zoomToRegion()
        
        // StationPoint 객체 생성 및 데이터 입력
        // coordinate는 공공데이터에 없으므로 geocoding 데이터를 배열에 저장하여 index로 불러옴
        // addr도 똑같이 처리
        for item in items {
            let title = item["site"]
            
            print("title = \(title)")
            
            for (key, value) in addrs {
                //print("\(key) -> \(value)")
                
                if key == title {
//                    subtitle = value[0]
//                    print("subtitle = \(subtitle)")
                    
                    lat = value[1]
                    long = value[2]
                    
                    dLong = Double(long)!
                    dLat = Double(lat)!
                    
                    print("lat = \(dLat)")
                    print("long = \(dLong)")
                    
                    
                }
            }
            
            let pm10 = item["pm10"]
            let pm25 = item["pm25"]
            var pm10Cai = item["pm10Cai"]
            var pm25Cai = item["pm25Cai"]
            
            if pm25Cai! == "1" {
                p25Cais = cais[0]
            } else if pm25Cai == "2" {
                p25Cais = cais[1]
            } else if pm25Cai == "3" {
                p25Cais = cais[2]
            } else if pm25Cai == "4" {
                p25Cais = cais[3]
            } else {
                p25Cais = "error"
            }
            
            if pm10Cai! == "1" {
                p10Cais = cais[0]
            } else if pm10Cai == "2" {
                p10Cais = cais[1]
            } else if pm10Cai == "3" {
                p10Cais = cais[2]
            } else if pm10Cai == "4" {
                p10Cais = cais[3]
            } else {
                p10Cais = "error"
            }

            
            let subtitlePM10 = "PM 10" + "(" + p10Cais + ")"
            let subtitlePM25 = "PM2.5" + "(" + p25Cais + ")"
            let subtitlePM = subtitlePM10 + " " + subtitlePM25
            
            let subtitle = subtitlePM

            
            // 각 충전소 정보를 가지고 있는 객체 생성(for loop로 모는 충전소 객체(StationPoint.swift 생성)
            annotation = StationPoint(title: title!,
                                          subtitle: subtitle,
                                          coordinate: CLLocationCoordinate2D(latitude: dLat, longitude: dLong),
                                          pm10: pm10!,
                                          pm25: pm25!,
                                          pm10Cai: pm10Cai!,
                                          pm25Cai: pm25Cai!)
            
            annotation!.title = title
            annotations.append(annotation!)
        }
        
        DustMapView.showAnnotations(annotations, animated: true)
        DustMapView.addAnnotations(annotations)


    }
    
    // parsing delegate method
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        currnetElement = elementName
        
        // 다시 파싱할 경우도 있으므로
        if elementName == "items" {
            items = []
        } else if elementName == "item" {
            item = [:]
            isInItem = true
        }
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        
        if isInItem {
            item[currnetElement] = string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        }
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            isInItem = false
            items.append(item)
        }
    }

    
    // 초기 맵 region 설정
    func zoomToRegion() {
        
        print("zoom to Location")
        
        // 부산지도 구글 중심정 35.163246, 129.066297
        
        let location = CLLocationCoordinate2D(latitude: 35.163246, longitude: 129.066297)
        let region = MKCoordinateRegionMakeWithDistance(location, 26000.0, 26000.3)
        DustMapView.setRegion(region, animated: true)
    }
    
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        // 1
        
        let identifier = "MyPin"
        
        // 사용자의 현재 위치 annotation을 제외함
        if annotation.isKindOfClass(MKUserLocation) {
            return nil
        }
        
        // 2
        if annotation .isKindOfClass(StationPoint) {
            // if annotation is ViewPoint
            // 3
            var annotationView = DustMapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
            
            if annotationView == nil {
                //4
                annotationView = MKPinAnnotationView(annotation:annotation, reuseIdentifier:identifier)
                annotationView!.canShowCallout = true
                
                // 5
                let btn = UIButton(type: .DetailDisclosure)
                annotationView!.rightCalloutAccessoryView = btn
            } else {
                // 6
                annotationView!.annotation = annotation
            }
            
            // 5
            let btn = UIButton(type: .DetailDisclosure)
            annotationView!.rightCalloutAccessoryView = btn
            
            return annotationView
        }
        // 7
        return nil
    }
 
    
    
    // Pin View의 Accessary를 눌러을때 Alert View 보여줌
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        let viewAnno = view.annotation as! StationPoint // MKAnnotation
        let statName = viewAnno.title
        let cPM10 = viewAnno.pm10
        let cPM25 = viewAnno.pm25
        let cPM10Cai = viewAnno.pm10Cai
        let cPm25Cai = viewAnno.pm25Cai
        
        let tMessage01 = "PM 10: " + cPM10Cai!
        let tMessage02 = "PM 2.5: " + cPm25Cai!
        let tMessage = tMessage01 + "\n" + tMessage02
        
        let ac = UIAlertController(title: statName, message: tMessage, preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(ac, animated: true, completion: nil)
    }
    
    // 현재 위치정보 트랙킹(currnet location tracking)
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation: CLLocation = locations[0]
        
        let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.11, longitudeDelta: 0.11))
        
        DustMapView.setRegion(region, animated: true)
        
        
    }
    
    // segmentControl Action 함수
    @IBAction func segmentSelected(sender: AnyObject) {
        
        let location = CLLocationCoordinate2D(latitude: 35.163246, longitude: 129.066297)

        if DistSegment.selectedSegmentIndex == 0 {
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegionMake(location, span)
            DustMapView.setRegion(region, animated: true)
            
            
        } else if DistSegment.selectedSegmentIndex == 1 {
            let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            let region = MKCoordinateRegionMake(location, span)
            DustMapView.setRegion(region, animated: true)
            
            
        } else {
            let span = MKCoordinateSpan(latitudeDelta: 0.7, longitudeDelta: 0.7)
            let region = MKCoordinateRegionMake(location, span)
            DustMapView.setRegion(region, animated: true)
            
            
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

