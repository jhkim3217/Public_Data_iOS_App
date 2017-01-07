//
//  MapViewController.swift
//  parksearch
//
//  Created by L703 on 2016. 10. 11..
//  Copyright © 2016년 Psyke. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController , MKMapViewDelegate ,NSXMLParserDelegate, CLLocationManagerDelegate  {
    @IBOutlet weak var MyMap: MKMapView!
    @IBOutlet weak var OutletMapCtr: UISegmentedControl!
    
    var location : CLLocationCoordinate2D!
    var locationManager = CLLocationManager()
    
    //파싱받은 정보를 저장할 변수
    var parkName:String?
    var Jibun:String?
    var Road:String?
    var ChargeInfo:String?
    var rundate:String?
    var weekDayStartTime:String?
    var tel:String?
    var coordinate:CLLocationCoordinate2D?
    
    //selectSegment이벤트
    //지도의 범위를 변경한다.
    @IBAction func ActionMapCtr(sender: AnyObject) {
        if OutletMapCtr.selectedSegmentIndex == 0
        {
            let center = locationManager.location?.coordinate
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let region = MKCoordinateRegionMake(center!, span)
            MyMap.setRegion(region, animated: true)

        }
        else if OutletMapCtr.selectedSegmentIndex == 1
        {
            let center = locationManager.location?.coordinate
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.03)
            let region = MKCoordinateRegionMake(center!, span)
            MyMap.setRegion(region, animated: true)

        }
        else if OutletMapCtr.selectedSegmentIndex == 2
        {
            let center = locationManager.location?.coordinate
            let span = MKCoordinateSpan(latitudeDelta: 0.07, longitudeDelta: 0.05)
            let region = MKCoordinateRegionMake(center!, span)
            MyMap.setRegion(region, animated: true)

        }
        else if OutletMapCtr.selectedSegmentIndex == 3
        {
            let location = CLLocationCoordinate2DMake(35.165812, 129.072553)
            let span = MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.3)
            let region = MKCoordinateRegionMake(location, span)
            MyMap.setRegion(region, animated: true)
            
        }
    }
    
    //파싱을 위한 변수를 생성한다.
    let key = "aT2qqrDmCzPVVXR6EFs6I50LZTIvvDrlvDKekAv9ltv9dbO%2F8i8JBz2wsrkpr9yrPEODkcXYzAqAEX1m%2Fl4nHQ%3D%3D"
    var item:[String:String] = [:] // Dictionary
    var items:[[String:String]] = [] // Array of Dictionary
    var currentElement = ""
    var isInItem = false // 어디서 check?
    
    var areaIndex: [String:String] = [:]
    var strURL = ""
    var elementCount = 0    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var annotations:Array = [StationPoint]()
        var i = 0

        MyMap.delegate = self
        
        // 위치 트랙킹 설정
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        
        // 현재 위치(Currnet location) 표시
        MyMap.showsUserLocation = true
        MyMap.userLocation.title = "현재 위치"
        
        // 최초 지도 위치
        // 현재 위치
        zoomToRegion()
        
        //파싱 시작
        if let path = NSBundle.mainBundle().URLForResource("parkPlaceInfoMation", withExtension: "xml"){
            if let parser = NSXMLParser(contentsOfURL: path){
                parser.delegate = self
            
                if parser.parse() {
                
                    print("parsing succeed")
                
                } else {
                    print("parsing failed")
                }
            }
        }else {
            print("xml 파일 찾기 실패")
        }
        //파싱 끝
        
        //item의 갯수만큼 for문을 반복해서 데이터를 받아온다.
        for item in items{
            Jibun = item["addrJibun"]!          //지번주소
            Road = item["addrRoad"]!            //도로명 주소
            parkName = item["parkingName"]!     //주차장 이름
            ChargeInfo = item["chargeInfo"]!    //주차장 무료 유료 유무
            let lat = item["latitude"]
            let long = item["longitude"]
            rundate = item["runDate"]!
            weekDayStartTime = item["weekdayStartTime"]!
            tel = item["tel"]!

            var dLong:Double
            var dLat:Double
            
            if long != nil {
                dLong = Double(long!)!
            } else {
                dLong = 36.670253
            }
            
            if lat != nil {
                dLat = Double(lat!)!
            } else {
                dLat = 127.879783
            }
            
          
            //핀 클래스에 값을 추가.
            let annotation = StationPoint(title: parkName!, coordinate: CLLocationCoordinate2D(latitude: dLat, longitude: dLong), addr: Jibun!, subtitle:Road!,rundate: rundate!,weekDayStartTile:weekDayStartTime!,Tel: tel!)
            
            annotation.title = parkName         //타이틀
            annotation.subtitle = ChargeInfo          //서브 타이틀
            annotation.runDate = rundate
            annotation.weekdayStartTime = weekDayStartTime
            annotation.tel = tel
            annotation.addr = Road!
            annotations.append(annotation)      //핀 배열에 핀을 추가
            
            print(annotation.coordinate)
            i = i + 1
            print(i)
            //맵에 핀 배열을 하나씩 등록한다.
            
            self.MyMap.addAnnotations(annotations)
            mapView(MyMap, viewForAnnotation: annotation)
        }
        
    } 
    
    func zoomToRegion() {
        // 현재 위치의 위도, 경도
        let center = locationManager.location?.coordinate
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        if (center != nil){
        let region = MKCoordinateRegionMake(center!, span)
        MyMap.setRegion(region, animated: true)
        }
    }
    
    // 현재 위치정보 트랙킹(currnet location tracking)
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation: CLLocation = locations[0]
        
        let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        MyMap.setRegion(region, animated: true)
        manager.stopUpdatingLocation()
    }
    
    // annotation 객체에 대한 View를 반환, pin color, callout 등 pin의 형태를 처리
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let idenifier = "Mypin"
        var annoView = MyMap.dequeueReusableAnnotationViewWithIdentifier("RE") as? MKPinAnnotationView
        
        // 사용자의 현재 위치 annotation을 제외함
        if annotation.isKindOfClass(MKUserLocation) {
            return nil
        }
        
        if annotation.isKindOfClass(StationPoint) {
            
            //요금정보가 무료일경우 초록색 핀을, 유료일경우 빨간색 핀을 출력한다.
            if annoView == nil{
                annoView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: idenifier)
                annoView!.canShowCallout = true
                if annotation.subtitle! == "무료"{
                annoView!.pinTintColor = UIColor.greenColor()
                }
                else if annotation.subtitle! == "유료"{
                    annoView!.pinTintColor = UIColor.redColor()
                }
                
                let btn = UIButton(type: .DetailDisclosure)
                annoView!.rightCalloutAccessoryView = btn
            }
            
        }else {
            annoView!.annotation = annotation
        }
        return annoView
    }
    
    //  Callout Accessary를 누르면 DetailView로 전환
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        //Annotation객체에 파싱받은 값을 입력한다.
        let AnnoView = view.annotation as! StationPoint
        parkName = AnnoView.title!
        Road = AnnoView.addr
        ChargeInfo = AnnoView.subtitle!
        weekDayStartTime = AnnoView.weekdayStartTime!
        tel = AnnoView.tel!
        coordinate = AnnoView.coordinate
        
        if(view.tag == 0){
            print(view.tag)
            view.tintColor = UIColor.orangeColor()
        }
        //클릭한 정보를 세그먼트 함수를 호출해서 다음 페이지에 값을 전달한다.
        if control == view.rightCalloutAccessoryView {
            self.performSegueWithIdentifier("GoDetail", sender: self)
            
        }

    }
    
    // element의 start tag를 만날때 실행
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        currentElement = elementName
        
        if elementName == "items" {
            items = []
        } else if (elementName == "item"){
            item = [:]
//            isInItem = true
        }
    }
    
    // 현재 element 내의 값을 받아온다
    func parser(parser: NSXMLParser, foundCharacters string: String) {
         let data = string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if !data.isEmpty{
           
            item[currentElement] = string
//            print(elementCount)
        }
    }
    
    // element의 end tag를 만날때 실행
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if (elementName == "item") {
            items.append(item)
            elementCount = elementCount+1
        }
    }
    
    //다음페이지로 값을 전달할 segue함수
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if segue.identifier == "GoDetail" {
            if let mapVC = segue.destinationViewController as?
                InfomationViewController {
                mapVC.parkName = parkName
                mapVC.chargeInfo = ChargeInfo
                mapVC.runDate = rundate
                mapVC.weekdayStartTime = weekDayStartTime
                mapVC.tel = tel
                mapVC.Road = Road
                mapVC.coordinate = coordinate
            }
        }
    }
    
}
