//
//  MapViewController.swift
//  전기자동차 충전소
//
//  Created by 김종현 on 2016. 9. 27..
//  Copyright © 2016년 김종현. All rights reserved.
//

// 메인 뷰 테이블뷰의 Cell을 선택할때 해당 충전소(선택한 충전소)의 지도 서비스(지도, Pin, Callout Accessary) 제공
import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate  {

    @IBOutlet weak var myMapView: MKMapView!
    var latData:Double?
    var longData:Double?
    var statNmData:String?
    var useTimeData:String?
    var addrData:String?
    var chgerTypeData:String?
    var statData:String?
    
    var locationManager = CLLocationManager()
    
    //var cType = ["DC차데모", "DC차데모+AC3상", "DC차데모+AC차상+DC콤보"]
    var chType = ""
    var cStat = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // 델리게이트 연결
        myMapView.delegate = self
        
        // 위치정보를 받기 설정
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        //locationManager.requestAlwaysAuthorization()
        
        // 현재 위치 표시
        myMapView.showsUserLocation = true
        myMapView.userLocation.title = "현재 위치"
        
        title = "전기자동차 충전소"
        
        print("latData = \(latData)")
        
        let location = CLLocationCoordinate2DMake(latData!, longData!)
        let span = MKCoordinateSpan(latitudeDelta: 0.47, longitudeDelta: 0.47)
        let region = MKCoordinateRegionMake(location, span)
        
        myMapView.setRegion(region, animated: true)
        
        // add annotation
        let anno = MKPointAnnotation()
        anno.coordinate = location
        anno.title = statNmData
        anno.subtitle = addrData
        
        myMapView.addAnnotation(anno)
        myMapView.selectAnnotation(anno, animated: true)
    }
    
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        // 사용자의 현재 위치(Current location) annotation을 제외함
        if annotation.isKindOfClass(MKUserLocation) {
            return nil
        }
        
        var annoView = myMapView.dequeueReusableAnnotationViewWithIdentifier("RE") as? MKPinAnnotationView
        
        if annoView == nil {
            annoView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "RE")
            annoView!.canShowCallout = true
            //annoView!.pinTintColor = UIColor.greenColor()
            
            let btn = UIButton(type: .DetailDisclosure)
            annoView!.rightCalloutAccessoryView = btn
        } else {
            // 6
            annoView!.annotation = annotation
        }
        return annoView
    }


    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        let viewAnno = view.annotation
        //let viewTitle = viewAnno!.title
        //let viewSubTitle = viewAnno?.subtitle
        
        let statName = viewAnno!.title
        let cType = chgerTypeData
        var useTime = useTimeData
        let stat =  statData

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
        
        // Alert View에 데이터(충전소 현황) 전달
        let ac = UIAlertController(title: statName!, message: tMessage, preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(ac, animated: true, completion: nil)
    }
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
