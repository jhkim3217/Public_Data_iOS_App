//
//  ViewController.swift
//  EarthQuake_Shelter
//
//  Created by L703 on 2016. 11. 25..
//  Copyright © 2016년 L703. All rights reserved.
//

import UIKit
import MapKit

// 36.19099682414 127.638872893098 6.10389763978336 4.75055026889356
let koreaCoordinate = CLLocationCoordinate2DMake(36.19099682414, 127.638872893098)
let koreaSpan = MKCoordinateSpanMake(6.10389763978336, 4.75055026889356)
let koreaRegion = MKCoordinateRegionMake(koreaCoordinate, koreaSpan)

var annotations = [ShelterPoint]()

var overlayRepository = [MKOverlay]()

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, XMLParserDelegate {
    
    func fixOverlay(_ sender: UIButton) {
        
        //if currentOverlay != nil {
            print("Media time: \(CACurrentMediaTime())")
            mvMain.removeOverlays(mvMain.overlays)
            mvMain.addOverlays([currentOverlay])
        //}
    }
    var s_title: String = "이름정보없음speed"  // 충전소 명
    var s_subtitle:String = "주소정보없음" // 주소
    var s_coordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(0.0, 0.0) // 위도, 경도
    var s_capacity:Int = 0
    
    var s_latitude: Double = 0
    var s_longitude: Double = 0
    
    var currentElement = ""
    var elementCount = 0
    
    var passData:Bool = false //현재 진행과정이 태그안에 있는지 없는지를 검사
    var parser = XMLParser()
    var data_count = 0 //몆번째 대피소인지 카운트(컴파일용)
    var data_type = ""
    var sw_is_first = true
    
    let data_api_key = "AA225C68-D794-33A9-91A2-8E4A2E07C0E6" // api key
    let data_domain = "http://byeonghoon.dothome.co.kr" // 도메인
    
    let locationManager = CLLocationManager()
    
    var cnt = 0
    
    var isInitalLoad = true
    
    var userLocation = CLLocationCoordinate2DMake(0, 0)
    var selectedAnnotation = ShelterPoint.init(title: "", coordinate: CLLocationCoordinate2DMake(0, 0), subtitle: "", capacity: 0)
    var currentOverlay = MKPolyline()
    
    var autoSelect = true
    var manualSelection = false
    
    var findcount = 0
    
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var scZoom: UISegmentedControl!
    @IBOutlet weak var mvMain: MKMapView!
//    @IBAction func bbiRefreshPressed(_ sender: UIBarButtonItem) {
//        print("refresh pressed")
//        if let userLocation = locationManager.location {
//            let coords = userLocation.coordinate
//            let lat = coords.latitude
//            let lng = coords.longitude
//            mvMain.setCenter(CLLocationCoordinate2D(
//                latitude: lat, longitude: lng), animated: true)
//        }
//    }
    
    func sortAnnotations() {
        if let userLocation = locationManager.location {
            annotations.sort { (a, b) -> Bool in
                let locationA = CLLocation.init(
                    latitude: a.coordinate.latitude, longitude: a.coordinate.longitude)
                let locationB = CLLocation.init(
                    latitude: b.coordinate.latitude, longitude: b.coordinate.longitude)
                let distanceA = userLocation.distance(from: locationA)
                let distenceB = userLocation.distance(from: locationB)
                return distanceA < distenceB
            }
        }
    }
    
    func zoomIntoNearest() {
        sortAnnotations()
        let selected = annotations[0]
        if manualSelection {
            setZoomLevel(1000, center: userLocation)
        } else {
            setZoomLevel(1000, center:selected.coordinate)
        }
        mvMain.selectAnnotation(selected, animated: true)
    }
    
    @IBAction func scZoomChanged(_ sender: UISegmentedControl) {
        let selected = sender.selectedSegmentIndex
        switch selected {
        case 0:
            manualSelection = true
            zoomIntoNearest()
            findRoad(UIAlertAction())
        case 1:
            setZoomLevel(2000, center: userLocation)
        case 2:
            setZoomLevel(5000, center: userLocation)
        case 3:
            setZoomLevel(30000, center: userLocation)
        default:
            break
        }
    }
    var currentZoomLevel = CLLocationDistance(100)
    func setZoomLevel(_ meters: CLLocationDistance, center: CLLocationCoordinate2D?) {
        var useCurrentZoom = false
        if meters < 0 { return }
        if meters == 0 {
            useCurrentZoom = true
        } else {
            currentZoomLevel = meters
        }
        let center = center ?? mvMain.region.center
        var viewRegion = MKCoordinateRegionMakeWithDistance(center, meters, meters)
        if useCurrentZoom {
            viewRegion = MKCoordinateRegionMakeWithDistance(center, currentZoomLevel, currentZoomLevel)
        }
        let adjustedRegion = mvMain.regionThatFits(viewRegion)
        mvMain.setRegion(adjustedRegion, animated: true)
    }
    
    @IBAction func mapTapped(_ sender: UITapGestureRecognizer) {
        let currentRegion = mvMain.region
        let currentCenter = currentRegion.center
        let currentSpan = currentRegion.span
        let centerLatitude = currentCenter.latitude
        let centerLongitude = currentCenter.longitude
        let spanLatitude = currentSpan.latitudeDelta
        let spanLongitude = currentSpan.longitudeDelta
        print(centerLatitude, centerLongitude, spanLatitude, spanLongitude)
        print(annotations[0].title ?? "이름정보 없음")
    }
    
    func isCoordinate(_ coordinate: CLLocationCoordinate2D, inside region: MKCoordinateRegion) -> Bool {
        let center = region.center
        var northWestCorner = CLLocationCoordinate2D()
        var southEastCorner = CLLocationCoordinate2D()
        northWestCorner.latitude = center.latitude - (region.span.latitudeDelta / 2.0)
        northWestCorner.longitude = center.longitude - (region.span.longitudeDelta / 2.0)
        southEastCorner.latitude = center.latitude + (region.span.latitudeDelta / 2.0)
        southEastCorner.longitude = center.longitude + (region.span.longitudeDelta / 2.0)
        return (coordinate.latitude >= northWestCorner.latitude && coordinate.latitude <= southEastCorner.latitude && coordinate.longitude >= northWestCorner.longitude && coordinate.longitude <= southEastCorner.longitude)
    }
    func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    
    func find_geometry(_ x: Double, _ y:Double)->String{
        
        // 경도 = x
        
        // 위도 = y
        
        
        
        // 최소 경도 ( x - 0.2 )
        let min_x = x-0.2
        // 최고 경도 ( x + 0.2 )
        let max_x = x+0.2
        // 최소 위도 ( y - 0.2 )
        let min_y = y-0.2
        // 최고 경도 ( y + 0.2 )
        let max_y = y+0.2
        
        // x, min_y
        
        print(String(x) + " , " + String(min_y))
        
        
        
        // min_x , y
        
        print(String(min_x) + " , " + String(y))
        
        
        
        // x, max_y
        
        print(String(x) + " , " + String(max_y))
        
        
        
        // max_x , y
        
        print(String(max_x) + " , " + String(y))
        
        
        
        
        
        // POLYGON((x1 y1, x2 y2[, xn yn])[, (x1 y1, x2 y2[, xn yn])])
        
        // POLYGON((127.697 36.0956999991003, / 127.797 36.0956999991003, / 127.797 36.1956999991003, / 127.697 36.1956999991003, /127.697 36.0956999991003))
        
        // POLYGON((127.697 36.0956999991003,127.797 36.0956999991003,127.797 36.1956999991003,127.697 36.1956999991003,127.697 36.0956999991003))
        
        // POLYGON((129.071409 34.964737,128.871409 35.164737,129.071409 35.364737,129.271409 35.164737))
        
        let temp_geometry_data = "POLYGON((" + String(x) + " " + String(min_y) + "," +
            
            String(min_x) + " " + String(y) + "," +
            
            String(x) + " " + String(max_y) + "," +
            
            String(max_x) + " " + String(y) + "," +
            
            String(x) + " " + String(min_y) + "))"
        
        
        
        print(temp_geometry_data)
        
        return temp_geometry_data;
        
    }
    
    func addAnnotations() {
        mvMain.addAnnotations(annotations)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mvMain.delegate = self
        
    }
    
    func startParsing(x: CLLocationDegrees, y: CLLocationDegrees) {
        
        for i in 1...20 {
            let data_url = "http://apis.vworld.kr/2ddata/edrse002/data?apiKey=\(data_api_key)&domain=\(data_domain)&geometry=\(find_geometry(x,y))&pageUnit=100&pageIndex=\(String(i))"
            
            print("#{url: \(data_url)}")
            let urlToSend: NSURL = NSURL(string: data_url.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)!)!
            parser = XMLParser(contentsOf: urlToSend as URL)!
            parser.delegate = self
            parser.parse()
            
            if cnt > 0  {
                break
            }
            
            //            if success {
            //                print("parse success!")
            //            } else {
            //                print("parse failure!")
            //            }
            
        }
        
        //        for i in 0...10{
        //            let name = annotations[i].title
        //            let addr = annotations[i].subtitle
        //            print("\(i)  이름 : \(name) // 주소 : \(addr)")
        //        }

    }
    
    
    //시작 태그(<)를 만나면 호출
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        currentElement=elementName;
        if(sw_is_first == true){
            
        }else{
            //            print("$" + currentElement)
            if ["shel_nm", "shel_ad", "shel_av", "lat", "lon"].contains(currentElement) {
                data_type = currentElement
                
                //                print("compile-1")
                passData=true;
            }
        }
    }
    //닫는 태그(>)를 만나면 호출
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if ["shel_nm", "shel_ad", "shel_av", "lat", "lon"].contains(currentElement) {
            //            print("compile-2")
            data_type=""
            passData=false
        }
        currentElement="";
    }
    //현재 태그에 담겨있는 string값 전달
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        print("#{foundCharacters} \(data_type):\(string) #{passData} \(passData)")
        
        if(sw_is_first == true){
            sw_is_first = false
        }
        if(passData)
        {
            print("##{dataType} \(data_type)")
            if(data_type == "shel_nm"){
                data_count = data_count + 1
                if(string != "0"){//공공데이터 shel_nm값이 0일때 예외처리
                    print("###{shel_nm} \(string)")
                    s_title = string
                    print("####{s_title} \(s_title)")
                }
                
            } else if (data_type == "lat") {
                print("###{lat} \(string)")
                s_latitude = Double(string)!
                print("####{s_lat} \(s_latitude)")
            } else if (data_type == "lon") {
                print("###{lon} \(string)")
                s_longitude = Double(string)!
                print("####{s_lon} \(s_longitude)")
            }
            else if(data_type == "shel_ad"){
                print("###{shel_ad} \(string)")
                s_subtitle = string
                print("####{s_subtitle} \(s_subtitle)")
                
                cnt = annotations.filter { (sp: ShelterPoint) -> Bool in
                    if (sp.subtitle == s_subtitle) {
                        return true
                    }
                    
                    return false
                }.count
            }
            else if(data_type == "shel_av"){
                print("###{shel_av} \(string)")
                s_capacity = Int(string)!
                print("####{s_capacity} \(s_capacity)")
                
                s_coordinate = CLLocationCoordinate2DMake(s_latitude, s_longitude)
                
                print(">>##{} \(s_title) \(s_subtitle) \(s_capacity) \(s_coordinate.latitude) \(s_coordinate.longitude)")
                if cnt == 0 {
                    annotations.append(ShelterPoint.init(
                        title: s_title,
                        coordinate: s_coordinate,
                        subtitle: s_subtitle,
                        capacity: s_capacity
                    ))
                }
            }
            //            print("compile-3_1")
            //            print(string + "#" + String(data_count) + "\n")
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        print("annotationViewDidChange")
    }
    
    func mapViewWillStartRenderingMap(_ mapView: MKMapView) { //
        print("willStartRenderingMap")
    }
    
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) { //
        print("didFinishRenderingMap")
    }
    
    var mapInit = false
    func mapViewWillStartLoadingMap(_ mapView: MKMapView) { //
        print("willStartLoadingMap")
        if !mapInit {
            mvMain.setRegion(koreaRegion, animated: false)
            mapInit = true;
        }
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) { //
        print("didFinishLoadingMap")
    }
    
    func mapViewDidFailLoadingMap(_ mapView: MKMapView, withError error: Error) {
        print("didFailLoadingMap")
    }
    
    func mapViewWillStartLocatingUser(_ mapView: MKMapView) { //
        print("willStartLocatingUser")
        locationManager.delegate = self
        checkLocationAuthorizationStatus()
    }
    
    func mapViewDidStopLocatingUser(_ mapView: MKMapView) {
        print("didStopLocatingUser")
    }
    
    func mapView(_ mapView: MKMapView, didFailToLocateUserWithError error: Error) {
        print("didFailToLocateUser")
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        print("didAddView")
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("didSelectView")
        
        if !manualSelection {
            scZoom.selectedSegmentIndex = -1
        }
        manualSelection = false
        
        if let selected = view.annotation {
            if selected.isKind(of: ShelterPoint.self) {
                
                self.selectedAnnotation = selected as! ShelterPoint
                findRoad(UIAlertAction())
            }
//            mapView.setCenter(selected.coordinate, animated: true)
        }
    }
    
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        print("didUpdateUserLocation")
        self.userLocation = userLocation.coordinate
        scZoom.setEnabled(true, forSegmentAt: 0)
        let coord = userLocation.coordinate
        let lat = coord.latitude
        let lng = coord.longitude
        
        print("#{\(lat),\(lng)}")
        
        if scZoom.selectedSegmentIndex == 0 {
            mapView.setCenter(coord, animated: true)
        }
        
        if isInitalLoad {
            
            mapView.setCenter(coord, animated: true)
            
            startParsing(x: lng, y: lat)
            
            addAnnotations()
            
            finishedLoading()
//            zoomIntoNearest()
//            findRoad(UIAlertAction())
            setZoomLevel(5000, center: self.userLocation)
            isInitalLoad = false
        }
    }
    
    func finishedLoading() {
        loadingView.isHidden = true
        title = "전국 지진 대피소" // title 뷰 컨트롤러 제목
        setZoomLevel(5000, center: self.userLocation)
    }
    
//    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
//        if animated {
//            overlayRepository = mapView.overlays
//            mapView.removeOverlays(overlayRepository)
//        }
//    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print("regionDidChange")
        if animated {
            mapView.addOverlays(overlayRepository)
            overlayRepository.removeAll()
        }
    }
    
    func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
        print("didChangeTrackingMode")
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        print("viewForAnnotation")
        
        if let annotation = annotation as? ShelterPoint {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
                as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
//                view.animatesDrop = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIView
            }
            return view
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.orange
        renderer.lineWidth = 10.0
        
        return renderer
    }
    
    func findRoad(_ action: UIAlertAction) -> Void {
        print("#{findRoad}")
        
        let sourcePlacemark = MKPlacemark(coordinate: userLocation, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: selectedAnnotation.coordinate, addressDictionary: nil)
        
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        let destinationAnnotation = MKPointAnnotation()
        destinationAnnotation.title = selectedAnnotation.title
        
        if let location = destinationPlacemark.location {
            destinationAnnotation.coordinate = location.coordinate
        }
        
//        self.mvMain.showAnnotations([destinationAnnotation], animated: true)
        
        let directionRequest = MKDirectionsRequest()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .automobile
        
        // Calculate the direction
        let directions = MKDirections(request: directionRequest)
        
        directions.calculate {
            (response, error) -> Void in
            
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                
                return
            }
            
            let route = response.routes[0]
            self.mvMain.removeOverlays([self.currentOverlay])
            self.mvMain.removeOverlays(self.mvMain.overlays)
            self.currentOverlay = route.polyline
            self.mvMain.add(self.currentOverlay, level: MKOverlayLevel.aboveRoads)
            
            
//            let rect = route.polyline.boundingMapRect
//            let regionThatFitsRect = MKCoordinateRegionForMapRect(rect)
//            let spanOfRegion = regionThatFitsRect.span
//            var adjustedRegion:MKCoordinateRegion? = nil
            
            self.findcount += 1
//            if self.findcount < 2 {
//                adjustedRegion = MKCoordinateRegionMake(self.userLocation, spanOfRegion)
//                self.mvMain.setRegion(adjustedRegion ?? regionThatFitsRect, animated: true)
//                print("Region set \(self.findcount)")
//            }
        }
        
        if #available(iOS 10.0, *) {
            let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { (timer: Timer) -> Void in
                self.fixOverlay(UIButton())
            })
            
            timer.fire()
            timer.invalidate()
        } else {
            print("Timer method not supported")
        }
    }
    
    private func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let myLineRenderer = MKPolylineRenderer(overlay: overlay)
        myLineRenderer.strokeColor = UIColor.orange
        myLineRenderer.lineWidth = 4
        return myLineRenderer
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("calloutAccessoryControlTapped")
        //        let location = view.annotation as! StationPoint
//        performSegue(withIdentifier: "showDetail", sender: self)
        
        //alertdialog
//        let shelter = view.annotation as! ShelterPoint
//        let title = shelter.title ?? "대피소 정보"
//        let subtitle = shelter.subtitle ?? "주소를 찾을 수 없습니다"
//        let capacity = shelter.capacity
        
//        let alert = UIAlertController(title: title, message: "\n주소: \(subtitle)\n수용인원: \(capacity)명", preferredStyle: .alert)
//        let doneButton = UIAlertAction(title: "닫기", style: .cancel, handler: nil)
//        alert.addAction(doneButton)
//        present(alert, animated: true, completion: nil)

        performSegue(withIdentifier: "showDetail", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier != nil {
            switch segue.identifier! {
            case "showDetail":
                title = ""
                let destVC = segue.destination as! TableViewController
                destVC.selected = selectedAnnotation
                destVC.segue = segue
            default:
                break
            }
        }
    }
    
}
