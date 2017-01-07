//
//  ViewController.swift
//  JejuEVChargeStation
//
//  Created by Tae Jong Yoo on 2016. 11. 16..
//  Copyright © 2016년 Tae-Jong Yu. All rights reserved.
//

import UIKit
import MapKit

typealias XMLItem = Dictionary<String,String>

let eCarKey = "aT2qqrDmCzPVVXR6EFs6I50LZTIvvDrlvDKekAv9ltv9dbO%2F8i8JBz2wsrkpr9yrPEODkcXYzAqAEX1m%2Fl4nHQ%3D%3D"
let strURL = "http://open.ev.or.kr:8080/openapi/services/rest/EvChargerService?serviceKey=\(eCarKey)"

let jejuCoordinate = CLLocationCoordinate2DMake(33.3608753685742, 126.5628658686)
let jejuSpan = MKCoordinateSpanMake(1.15690443838806, 0.901451256488542)
let jejuRegion = MKCoordinateRegionMake(jejuCoordinate, jejuSpan)

var item:XMLItem = [:]
var items:[XMLItem] = []
var itemsJeju:[XMLItem] = []
var annotations = [StationPoint]()

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, XMLParserDelegate {
    
    var currentElement = ""
    var elementCount = 0
    
    let locationManager = CLLocationManager()
    
    var selected = StationPoint()
    
    var manualZoom = false
    var mapInit = false
    
    @IBOutlet weak var scZoom: UISegmentedControl!
    @IBOutlet weak var mvMain: MKMapView!
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
    @IBAction func scZoomChanged(_ sender: UISegmentedControl) {
        let selected = sender.selectedSegmentIndex
        switch selected {
        case 0:
            print("Nearst selected")
            sortAnnotations()
            let selected = annotations[0]
            mvMain.selectAnnotation(selected, animated: true)
            setZoomLevel(100, center:selected.coordinate)
        case 1, 2:
            print("\(1*selected)km selected")
            setZoomLevel(1000 * selected, center: nil)
        case 3:
            print("fullscreen selected")
            manualZoom = false
            mvMain.setRegion(jejuRegion, animated: true)
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
    
    func parseData() {
        if let url = URL(string: strURL) {
            if let parser = XMLParser(contentsOf: url) {
                parser.delegate = self
                
                if parser.parse() {
                    print("parsing succeeded")
                } else {
                    print("parsing failed")
                }
            }
        } else {
            print("incorrect url")
        }
    }
    
    func filterJejuItemsOnly() {
        itemsJeju = items.filter {
            isCoordinate(
                CLLocationCoordinate2DMake(Double($0["lat"]!)!, Double($0["lng"]!)!),
                inside: jejuRegion)
        }
    }
    
    func addAnnotations() {
        for item in itemsJeju {
            let long = item["lng"]
            let lat = item["lat"]
            let title = item["statNm"]
            var useTime = item["useTime"]
            let addr = item["addrDoro"]
            let chgerType = item["chgerType"]
            var stat = item["stat"]
            
            let dLong = Double(long!)!
            let dLat = Double(lat!)!
            
            if useTime == nil {
                useTime = " 정보 없음"
            }
            
            if stat == nil {
                stat = "정보 없음"
            }
            
            let annotation = StationPoint(
                title: title!,
                coordinate: CLLocationCoordinate2D(
                    latitude: dLat, longitude: dLong),
                addr: addr!,
                subtitle: addr!,
                chgerType: chgerType!,
                stat: stat!,
                useTime: useTime!
            )
            
            annotations.append(annotation)
        }
        
        mvMain.addAnnotations(annotations)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("#{\(strURL)}")
        
        mvMain.delegate = self
        
        parseData()
        filterJejuItemsOnly()
    }
    
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        if elementName == "items" {
            items = []
        } else if elementName == "item" {
            item = [:]
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let data = string.trimmingCharacters(in: .whitespacesAndNewlines)
        item[currentElement] = data
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if elementName == "item" {
            items.append(item)
            elementCount = elementCount+1
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
    
    func mapViewWillStartLoadingMap(_ mapView: MKMapView) { //
        print("willStartLoadingMap")
        if !mapInit {
            manualZoom = false
            mvMain.setRegion(jejuRegion, animated: false)
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
        
        sortAnnotations()
        addAnnotations()
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
        if (view.annotation?.isKind(of: StationPoint.self))! {
            if annotations.contains(view.annotation as! StationPoint) {
                self.selected = view.annotation as! StationPoint
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        print("didDeselectView")
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        print("didUpdateUserLocation")
        scZoom.setEnabled(true, forSegmentAt: 0)
//        let coord = userLocation.coordinate
//        manualZoom = false
//        mapView.setCenter(coord, animated: true)
//        let lat = coord.latitude
//        let lng = coord.longitude
//        let geoCoder = CLGeocoder();
//        geoCoder.reverseGeocodeLocation(CLLocation.init(latitude: lat, longitude: lng), completionHandler: { (placemarks, error) in
//            if error != nil {
//                print(error ?? "Error geocoding")
//                return
//            }
//            
//            if placemarks != nil {
//                self.mvMain.userLocation.title = placemarks?[0].name
//            }
//        })
        self.mvMain.userLocation.title = "현재위치"
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) { //
        print("regionWillChange")
        if manualZoom && scZoom.selectedSegmentIndex == 3 {
            scZoom.selectedSegmentIndex = UISegmentedControlNoSegment
        }
        manualZoom = true
        
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print("regionDidChange")
    }
    
    func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
        print("didChangeTrackingMode")
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        print("viewForAnnotation")
        
        if let annotation = annotation as? StationPoint {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.pinTintColor = annotation.pinColor()
                view.canShowCallout = true
                view.animatesDrop = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIView
            }
            return view
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("calloutAccessoryControlTapped")
        if view.annotation is StationPoint {
            performSegue(withIdentifier: "showDetail", sender: self)
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        if let userLocation = manager.location {
//            let coords = userLocation.coordinate
//            let lat = coords.latitude
//            let lng = coords.longitude
//            if scZoom.selectedSegmentIndex != 3 {
//                mvMain.setCenter(CLLocationCoordinate2D(
//                    latitude: lat, longitude: lng), animated: true)
//                
//            }
//        }
        sortAnnotations()
        mvMain.selectAnnotation(annotations[0], animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("#{\(error.localizedDescription)}")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "showDetail":
            print("#showDetail prepared")
            let navVC = segue.destination as! UINavigationController
            let detailVC = navVC.topViewController as! DetailViewController
            detailVC.selectedForDetail = self.selected
        default:
            break
        }
    }

}

