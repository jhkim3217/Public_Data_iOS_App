//
//  we_map.swift
//  2_2_to_project
//
//  Created by L703 on 2016. 11. 24..
//  Copyright © 2016년 DIT. All rights reserved.
//

import UIKit
import MapKit

class we_map: UIViewController, MKMapViewDelegate , CLLocationManagerDelegate, NSXMLParserDelegate
{

    @IBOutlet weak var myMap: MKMapView!
    var map_items:[[String:String]]?
    var map_re_items:[[String:String]] = []
    var map_item:[String:String] = [:]
    var map_re_item:[String:String] = [:]
    var locationManager = CLLocationManager()
    var map_bool = false
    var annotations = [MKPointAnnotation]()
    var data_key = ""
    var currentElement = ""
    var isInItem = false
    
    override func viewDidLoad() 
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        for(var i = 0; i < map_items?.count ; i++)
        {
            map_item = map_items![i]
            data_key = map_item["dataSid"]!
            let se_URL = "http://tourapi.busan.go.kr/openapi/service/CultureInfoService/getFestivalDetail?ServiceKey=XvbbhgxojihU59b%2BzI27UNzRTxEsexjg3suPdRbu%2F5rSpomO7FP7SOjZVpkM7E9JwzLeXf4GY49rLLHE8kgzgQ%3D%3D&data_sid=\(data_key)&numOfRows=999&pageSize=999&pageNo=1&startPage=1"
            let se_url = NSURL(string: se_URL)!
            let parser = NSXMLParser(contentsOfURL: se_url)!
            parser.delegate = self
            if parser.parse()
            {
                    print(map_re_items)
            }
            else
            {
                print("parsing fail")
            }
        }
        for(var j = 0; j < map_re_items.count ; j++)
        {
            map_re_item = map_re_items[j]
            if map_re_item["wgsx"] == nil || map_re_item["wgsy"] == nil || map_re_item["wgsx"] == "-" || map_re_item["wgsy"] == "-"
            {
                locationManager.delegate = self
                locationManager.startUpdatingLocation()
                locationManager.requestWhenInUseAuthorization()
                locationManager.startUpdatingLocation()
                locationManager.requestAlwaysAuthorization()
                
                myMap.showsUserLocation = true 
            }
            else
            {
                let map_x = Double(map_re_item["wgsx"]!)
                let map_y = Double(map_re_item["wgsy"]!)
                let map_location = CLLocationCoordinate2DMake(map_x!,map_y!)
                let cu_annotation = MKPointAnnotation()
                cu_annotation.coordinate = map_location
                cu_annotation.title = map_re_item["dataTitle"]
                if map_re_item["place"] == nil
                {
                    cu_annotation.subtitle = "장소 정보가 없습니다."
                }
                else
                {
                    cu_annotation.subtitle = map_re_item["place"]
                }  
                annotations.append(cu_annotation)
            }

        }
     
        myMap.addAnnotations(annotations)
        myMap.delegate = self
    }
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) 
    {
        let userLocation: CLLocation = locations[0]
        //print(userLocation)
        
        let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.3))
    
        if map_bool == false
        {
            myMap.setRegion(region, animated: true)
            map_bool = true
        }
    }

    override func didReceiveMemoryWarning() 
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String])
    {
        currentElement = elementName
        if elementName == "items"
        {
            map_re_items = []
        }
        else if elementName == "item"
        {
            map_re_item = [:]
            isInItem = true
        }    
    }    
    func parser(parser: NSXMLParser, foundCharacters string: String)
    {
        if isInItem
        {
            map_re_item[currentElement] = string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        }
        
    }
    func parser2(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String])
    {
        
        currentElement = elementName
        if elementName == "items"
        {
            map_re_items = []
        }
        else if elementName == "item"
        {
            map_re_item = [:]
            isInItem = true
        }
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?)
    {        
        if elementName == "item"
        {
            isInItem = false
            map_re_items.append(map_re_item)
        }
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
