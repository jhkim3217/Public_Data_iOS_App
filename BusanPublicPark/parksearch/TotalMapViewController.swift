//
//  TotalMapViewController.swift
//  전기자동차 충전소
//
//  Created by 김종현 on 2016. 9. 27..
//  Copyright © 2016년 김종현. All rights reserved.

// barButtonItem을 선택하면 전체 전기자동차 충전소 현황을 지도에 표시

import UIKit
import MapKit
import CoreLocation

class TotalMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var totalMapView: MKMapView!
    
    var chType = ""
    var cStat = ""
    
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "전기자동차 충전소"
        
        zoomToRegion()
        
        // pin의 empty 배열, mutable하게 객체 추가
        var annotations:Array = [StationPoint]()
        
        totalMapView.delegate = self
        
        // 위치 트랙킹 설정
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        //locationManager.requestAlwaysAuthorization()
        
        // 현재 위치(Currnet location) 표시
        totalMapView.showsUserLocation = true
        totalMapView.userLocation.title = "현재 위치"

        //var chgerType: String? // 충전기 타입--- 01.DC차데모, 02.DC차데모+AC3상, 06.DC차데모+AC3상+DC콤보
        //var stat: String? // 충전기 상태--- 1.통신이상 2.충전대기 3.충전중 4.운영중지 5.점검중
        
        for item in items {
            let long = item["lng"]
            let lat = item["lat"]
            let title = item["statNm"]
            var useTime = item["useTime"]
            let addr = item["addrDoro"]
            let chgerType = item["chgerType"]
            var stat = item["stat"]
            
            var dLong:Double
            var dLat:Double
            
            // 36.670253, 127.879783
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
            
            
            //let dLong = Double(long!)
            //let dLat = Double(lat!)
            
            //print("useTime = \(useTime)")
            
            // 원 공공데이터에 nil이 하나 있어 check(이렇게 처리해야 optional 오류를 피함)
            if useTime == nil {
                useTime = "X"
            }
            
            if stat == nil {
                stat = "X"
            }
            
            // 각 충전소 정보를 가지고 있는 객체 생성(for loop로 모는 충전소 객체(StationPoint.swift 생성)
            let annotation = StationPoint(title: title!,
                                          coordinate: CLLocationCoordinate2D(latitude: dLat, longitude: dLong),
                                          addr: addr!,
                                          subtitle: addr!,
                                          chgerType: chgerType!,
                                          stat: stat!,
                                          useTime: useTime!)
                
            annotation.title = title
            annotations.append(annotation)
        }
        
        totalMapView.showAnnotations(annotations, animated: true)
        totalMapView.addAnnotations(annotations)
        
    }
    
    // 초기 맵 region 설정
    func zoomToRegion() {
        
        print("zoom to Location")
        
        let location = CLLocationCoordinate2D(latitude: 35.118002, longitude: 129.121017)
        let region = MKCoordinateRegionMakeWithDistance(location, 1000.0, 1000.3)
        totalMapView.setRegion(region, animated: true)
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
            var annotationView = totalMapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
            
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
        let cType = viewAnno.chgerType
        var useTime = viewAnno.useTime
        let stat =  viewAnno.stat
        
        
        // 충전기 타입--- 01.DC차데모, 02.DC차데모+AC3상, 06.DC차데모+AC3상+DC콤보
        if cType == "01" {
            chType = "DC차데모"
        } else if cType == "02" {
            chType = "DC차데모+AC3상"
        } else {
            chType = "DC차데모+AC3상+DC콤보"
        }
        
        // 충전기 상태--- 1.통신이상 2.충전대기 3.충전중 4.운영중지 5.점검중
        if stat == "1" {
            cStat = "통신이상"
        } else if stat == "2" {
            cStat = "충전대기"
        } else if stat == "3" {
            cStat = "충전중"
        } else if stat == "4" {
            cStat = "운영중지"
        } else {
            cStat = "점검중"
        }
        
        if useTime == "시간 이용가능" {
            useTime = "24 시간 이용가능"
        }
        
        let tMessage = useTime! + "\n" + chType + "\n"  + cStat
    
        let ac = UIAlertController(title: statName, message: tMessage, preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(ac, animated: true, completion: nil)
    }
    
    // 현재 위치정보 트랙킹(currnet location tracking)
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation: CLLocation = locations[0]
        
        let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.11, longitudeDelta: 0.11))
        
        totalMapView.setRegion(region, animated: true)
        
        
    }

}
