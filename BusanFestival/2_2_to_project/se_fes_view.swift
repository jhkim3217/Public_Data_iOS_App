//
//  se_fes_view.swift
//  2_2_to_project
//
//  Created by L703 on 2016. 11. 1..
//  Copyright © 2016년 DIT. All rights reserved.
//

import UIKit
import MapKit

class se_fes_view: UIViewController, NSXMLParserDelegate, MKMapViewDelegate, CLLocationManagerDelegate
{
    @IBOutlet weak var ing_img: UIActivityIndicatorView!
    @IBOutlet weak var data_place: UITextView!
    @IBOutlet weak var data_title: UITextView!
    @IBOutlet weak var data_image: UIImageView!
    @IBOutlet weak var myMap: MKMapView!
    var locationManager = CLLocationManager()
    var data_key = ""
    var item:[String:String] = [:]
    var items:[[String:String]] = []
    var currentElement = ""
    var isInItem = false

    override func viewDidLoad() 
    {
        super.viewDidLoad()
        ing_img.startAnimating()
        let se_URL = "http://tourapi.busan.go.kr/openapi/service/CultureInfoService/getFestivalDetail?ServiceKey=XvbbhgxojihU59b%2BzI27UNzRTxEsexjg3suPdRbu%2F5rSpomO7FP7SOjZVpkM7E9JwzLeXf4GY49rLLHE8kgzgQ%3D%3D&data_sid=\(data_key)&numOfRows=999&pageSize=999&pageNo=1&startPage=1"
        let se_url = NSURL(string: se_URL)!
        let parser = NSXMLParser(contentsOfURL: se_url)!
        parser.delegate = self
       
        if parser.parse()
        {
            //print("parsing success")
            ing_img.stopAnimating()
            ing_img.hidden = true
            data_title.text? = "제목 : " + item["dataTitle"]!
            if item["tel"] == nil
            {
                if item["place"] == nil
                {
                    if item["dataContent"] == nil
                    {
                        data_place.text? = "공공데이터의 내용이 없습니다."
                    }
                    else
                    {
                        data_place.text? = "내용 : " + item["dataContent"]!
                    }
                }
                else
                {
                    data_place.text? = "장소 : " + item["place"]! + "\n\n" + "내용 : " + item["dataContent"]!
                }
            }
            else if item["place"] == nil
            {
                    if item["dataContent"] == nil
                    {
                        data_place.text? = "전화 번호 : " + item["tel"]!
                    }
                    else
                    {
                        data_place.text? = "전화 번호 : " + item["tel"]! + "\n\n" + "내용 : " + item["dataContent"]!
                    }
            }
            else if item["dataContent"] == nil
            {
                data_place.text? = "전화 번호 : " + item["tel"]! + "\n\n" + "장소 : " + item["place"]!
            }
            else
            {
                data_place.text? = "전화 번호 : " + item["tel"]! + "\n\n" + "장소 : " + item["place"]!
                    + "\n\n" + "내용 : " + item["dataContent"]!
            }
            print(item)
            let urlImage = NSURL(string:item["mainimgthumb"]!)!
            //NSData를 이용하여 이미지 리소스 로딩
            let data = NSData(contentsOfURL: urlImage)
            //NSData에서 이미지 객체를 생성
            data_image.image = UIImage(data: data!)            
            //wgsy, wgsx
            if item["wgsy"] == nil || item["wgsx"] == nil || item["wgsx"] == "-" || item["wgsy"] == "-"
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
                let cu_x = Double(item["wgsx"]!) 
                let cu_y = Double(item["wgsy"]!) 
                let cu_location = CLLocationCoordinate2DMake(cu_x!,cu_y!)
                let cu_span = MKCoordinateSpanMake(0.04, 0.04)
                let cu_region = MKCoordinateRegionMake(cu_location, cu_span)
                
                myMap.setRegion(cu_region, animated: true)
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = cu_location
                annotation.title = item["dataTitle"]
                if item["place"] == nil
                {
                    annotation.subtitle = "장소 정보가 없습니다."
                }
                else
                {
                    annotation.subtitle = item["place"]
                }
                myMap.addAnnotation(annotation)
                myMap.selectAnnotation(annotation, animated: true)
                myMap.delegate = self              
                
            }
        }
        else
        {
            print("parsing fail")
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
            items = []
        }
        else if elementName == "item"
        {
            item = [:]
            isInItem = true
        }    
    }    
    func parser(parser: NSXMLParser, foundCharacters string: String)
    {
        if isInItem
        {
            item[currentElement] = string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        }
        
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?)
    {        
        if elementName == "item"
        {
            isInItem = false
            items.append(item)
        }
    }
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) 
    {
        let userLocation: CLLocation = locations[0]
        //print(userLocation)
        
        let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03))
        
        myMap.setRegion(region, animated: true)
        
        if item["wgsy"] == nil || item["wgsx"] == nil || item["wgsx"] == "-" || item["wgsy"] == "-"
        {
            let annotation = MKPointAnnotation()
            annotation.coordinate = center
            annotation.title = "위치 정보 API가 없습니다."
        
            myMap.addAnnotation(annotation)
        }
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) 
    {   
            if segue.identifier == "twogoes" 
            {
                let sendtimer = segue.destinationViewController as! third_fes_view
               
                sendtimer.str_query = item["dataTitle"]!                
                sendtimer.str_url = "https://search.naver.com/search.naver?where=nexearch&sm=top_hty&fbm=1&ie=utf8&query="           
                sendtimer.save_data_key = data_key
            }
    }

}
