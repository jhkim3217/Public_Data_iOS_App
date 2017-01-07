//
//  ViewController.swift
//  moo
//
//  Created by L703 on 2016. 11. 14..
//  Copyright © 2016년 DIT. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, NSXMLParserDelegate, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var stepper: UIStepper!
    var annotations: Array = [ItemInfo]()
    
    var dLong: Double?
    var dLat: Double?
    var nSubtitle: String?
    var nTel: String?
    var inDelta: Double = 0.08 // stepper 값으로 맵 반경 설정

    var count: Int?
    var totalSeq = 0
    var item : [String:String] = [:]
    var items = NSMutableArray()
    var currentElement = ""
    var elementCount = 0
    var isFirstTime = false
    var itemCount = 0
    var forTotalCount = false
    
//    let key = "aT2qqrDmCzPVVXR6EFs6I50LZTIvvDrlvDKekAv9ltv9dbO%2F8i8JBz2wsrkpr9yrPEODkcXYzAqAEX1m%2Fl4nHQ%3D%3D"
    let key = "xHwlbu%2BRqU5PHBk184zSnKDvoUolPZL7na5YwH1QtYFP7KM1AYxxM3ttaiiMtwmUBHyDxn%2BAUVMBKamFAcOX9Q%3D%3D"

    @IBOutlet weak var myMapView: MKMapView!
    @IBOutlet weak var myIndicatorView: UIView!
    
    var locationManager = CLLocationManager()

    //폰에서 앱의 도큐먼트폴더를 찾는 함수
    func getFileName(fileName:String) -> String {
        let docsDir = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let docPath = docsDir[0] as NSString
        let fullName = docPath.stringByAppendingPathComponent(fileName)
        return fullName
    }
    
    
    @IBAction func stepperValueChanged(sender: AnyObject) {
        
        let center = locationManager.location?.coordinate
        
        inDelta = sender.value / 60
        print("1. inDelta = \(inDelta)")
        
        let span = MKCoordinateSpan(latitudeDelta: inDelta, longitudeDelta: inDelta)
        let region = MKCoordinateRegionMake(center!, span)
        myMapView.setRegion(region, animated: true)
    }

    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        print("viewDidLoad go......")
        
        myMapView.delegate = self
        // 위치 트랙킹 설정
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        //locationManager.requestAlwaysAuthorization()
        
        // 현재 위치(Currnet location) 표시
        myMapView.showsUserLocation = true
        myMapView.userLocation.title = "현재 위치"
        
        // stepper init
        stepper.wraps = false
        stepper.autorepeat = true
        stepper.maximumValue = 6
        stepper.minimumValue = 1
        stepper.value = 6
        //stepper.tintColor = UIColor.orangeColor()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        print("viewDidAppear go.......")
        
        //최초 실행시 도큐먼트 폴더에 items.plist가 없으면 패키지에서 도큐먼트 폴더로 복사
        let targetPath = getFileName("items.plist")
        let fileManager = NSFileManager.defaultManager()
        if !fileManager.fileExistsAtPath(targetPath) {
            let orgPath = NSBundle.mainBundle().pathForResource("items", ofType: "plist")
            do {
                try fileManager.copyItemAtPath(orgPath!, toPath: targetPath)
            } catch {
                print("copy failed")
            }
        }
        
        print(getFileName("items.plist"))
        items = NSMutableArray(contentsOfFile: getFileName("items.plist"))!
        itemCount = items.count
        
                do {
                    for item in items {
                        print("======================")
        
                        print(item["instName"]!)
                        print(item["addrJibun"]!)
                        print(item["location"]!)
                        print(item["detailLocation"])
                        print(item["operationHours"]!)
                        print(item["petitionType"]!)
                        print(item["tel"]!)
                        print(item["latitude"]!)
                        print(item["longitude"]!)
        
                    }
                }
        
        self.title = "부산 무인민원발급기 지도"
        //zoomToRegion()
        
        // 무인발급기 정보 1 URL
        let URL = "http://opendata.busan.go.kr/openapi/service/PetitionKiosk/getPetitionKioskInfoList?ServiceKey=\(key)"
        
        forTotalCount = true
        // 총 데이터의 건수(seq) 뽑아 오기
        if let url = NSURL(string: URL) {
            if let parser = NSXMLParser(contentsOfURL: url) {
                parser.delegate = self
                
                if parser.parse() {
                    print("totalCount = \(item["totalCount"])")
                    totalSeq = Int(item["totalCount"]!)!
                    print(totalSeq)
                } else {
                    print("parsing failed")
                }
            }
        } else {
            print("URL error")
        }
        
        if (totalSeq != itemCount) {
            forTotalCount = false
            items = NSMutableArray()
            
            
            // seq(count) 횟수 만큼 파싱 호출
            for count in 1...totalSeq {
                myParse(count)
            }
        }
        
        // ItemInfo 객체 생성 및 멤버 데이터 입력
        for item in items {
            let title = item["location"] as? String
            let subtitle = item["addrJibun"] as? String
            //print("title = \(title)")
            let detailLoc = item["detailLocation"] as? String
            let instName = item["instName"] as? String
            let opHours = item["operationHours"] as? String
            let petType = item["petitionType"] as? String
            let tel = item["tel"] as? String
            let lat = item["latitude"] as? String
            let long = item["longitude"] as? String
            //print("lat = \(lat)")
            
            if subtitle != nil {
                nSubtitle = subtitle
            } else {
                nSubtitle = "X"
            }
            
            if tel != nil {
                nTel = tel
            } else {
                nTel = "X"
            }
            
            // 36.670253, 127.879783
            if long != nil {
                dLong = Double(long!)
            } else {
                dLong = 129.121017
            }
            
            if lat != nil {
                dLat = Double(lat!)
            } else {
                dLat = 35.118002
                //dLat = 0.00
            }
            
            //print("detailLoc = \(detailLoc)")
            
            let annotation = ItemInfo(title: title!,
                                      subtitle: nSubtitle!,
                                      coordinate: CLLocationCoordinate2D(latitude: dLat!, longitude: dLong!),
                                      detailLoc: detailLoc!,
                                      instName: instName!,
                                      opHours: opHours!,
                                      petType: petType!,
                                      tel: nTel!
            )
            
            annotation.title = title
            annotations.append(annotation)
            
        }
        
        //zoomToRegion()
        
        myMapView.showAnnotations(annotations, animated: true)
        myMapView.addAnnotations(annotations)
        //myMapView.selectAnnotation(annotations[9], animated: true)
        
    }
    
    
    func mapViewDidFinishLoadingMap(mapView: MKMapView) {
        myIndicatorView.hidden = true
    }
    
    func myParse(count: Int) {
        
        let URL = "http://opendata.busan.go.kr/openapi/service/PetitionKiosk/getPetitionKioskInfoDetail?ServiceKey=\(key)&seq=\(count)"
        
        if let url = NSURL(string: URL) {
            if let parser = NSXMLParser(contentsOfURL: url) {
                parser.delegate = self
                
                if parser.parse() {
                    
                } else {
                    print("parsing failed")
                }
            }
        } else {
            print("URL error")
        }
        
        ///
        
    }
     
    // 초기 맵 region 설정
//    func zoomToRegion() {
//        
//        print("zoom to Location")
//        // 부산지도 구글 중심정 35.163246, 129.066297
//        let location = CLLocationCoordinate2D(latitude: 35.118002, longitude: 129.066297)
//        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
//        let region = MKCoordinateRegionMake(location, span)
//        myMapView.setRegion(region, animated: true)
//        
//    }

    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        currentElement = elementName
        //print("currentElement = \(currentElement)")
        
        if elementName == "items" {

        } else if elementName == "item" {
            item = [:]
        }
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        
        let data = string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        item[currentElement] = data
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if !forTotalCount && elementName == "item" {
            items.addObject(item)
            elementCount = elementCount+1
            let seq = Int(item["seq"]!)!
            //items에 추가된 아이템의 seq가 totalSeq와 같으면 모두 추가된것이라 판단해서 파일로 저장
            if seq == totalSeq {
                items.writeToFile(getFileName("items.plist"), atomically: true)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        // 1
        let identifier = "MyPin"
        
        // 사용자의 현재 위치 annotation을 제외함
        if annotation.isKindOfClass(MKUserLocation) {
            return nil
        }
        
        // 2
        if annotation .isKindOfClass(ItemInfo) {
            // if annotation is ViewPoint
            // 3
            var annotationView = myMapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
            
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
        
        let viewAnno = view.annotation as! ItemInfo // MKAnnotation
        //let pLocation = viewAnno.title     // 위치
        //let pDetailLoc = viewAnno.subtitle // 주소
        let pInstName = viewAnno.instName  // 관리기관
        let pOpHours = viewAnno.opHours    // 운영시간
        let pPetType = viewAnno.petType    // 증명서 종류
        let pTel = viewAnno.tel            // 전화번호
        
        let pMessage01 = "운영시간 : " + pOpHours! + "\n" + "증명서 : " + pPetType!
        let pMessage02 = "\n 전화번호 : " + pTel! + "\n" + "관리기관 : " + pInstName!
        let pMessage = pMessage01 + pMessage02
        
        let ac = UIAlertController(title: "무인민원발급 정보", message: pMessage, preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(ac, animated: true, completion: nil)
    }

    
    // 현재 위치정보 트랙킹(currnet location tracking)
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //print("didUpdateLocations")
        print("2. inDelta = \(inDelta)")
        
        let userLocation: CLLocation = locations[0]
        
        let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        
        print("center = \(center)")
        
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: inDelta, longitudeDelta: inDelta))
        
        myMapView.setRegion(region, animated: true)
        
    }

}

