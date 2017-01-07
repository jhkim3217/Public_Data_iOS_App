//
//  se_table.swift
//  2_2_to_project
//
//  Created by L703 on 2016. 12. 6..
//  Copyright © 2016년 DIT. All rights reserved.
//

import UIKit
import MapKit

class se_table: UITableViewController, NSXMLParserDelegate, MKMapViewDelegate, CLLocationManagerDelegate 
{
    @IBOutlet weak var location_cell: UITableViewCell!
    @IBOutlet weak var myMap: MKMapView!
    @IBOutlet weak var tel_cell: UITableViewCell!
    @IBOutlet weak var contents_cell: UITableViewCell!
    @IBOutlet weak var name_title: UINavigationItem!
    var region_bool = false
    var data_key = ""
    var locationManager = CLLocationManager()
    var item:[String:String] = [:]
    var items:[[String:String]] = []
    var currentElement = ""
    var isInItem = false

    override func viewDidLoad() 
    {
        super.viewDidLoad()
        
        print(data_key)
        let se_URL = "http://tourapi.busan.go.kr/openapi/service/CultureInfoService/getFestivalDetail?ServiceKey=XvbbhgxojihU59b%2BzI27UNzRTxEsexjg3suPdRbu%2F5rSpomO7FP7SOjZVpkM7E9JwzLeXf4GY49rLLHE8kgzgQ%3D%3D&data_sid=\(data_key)&numOfRows=999&pageSize=999&pageNo=1&startPage=1"
        let se_url = NSURL(string: se_URL)!
        let parser = NSXMLParser(contentsOfURL: se_url)!
        parser.delegate = self
        if parser.parse()
        {
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
        
//        location_cell.layer.borderColor = UIColor.grayColor().CGColor
//        location_cell.layer.borderWidth = 0.5
//        contents_cell.layer.borderColor = UIColor.grayColor().CGColor
//        contents_cell.layer.borderWidth = 0.5
//        image_cell.layer.borderColor = UIColor.grayColor().CGColor
//        image_cell.layer.borderWidth = 0.5
//        tel_cell.layer.borderColor = UIColor.grayColor().CGColor
//        tel_cell.layer.borderWidth = 0.5
        if item["dataTitle"] == nil || item["dataTitle"] == "-"
        {
            name_title.title = "부산 축제/문화/공연"
        }
        else
        {
            name_title.title = item["dataTitle"]
        }                
        if item["tel"] == nil || item["tel"] == "-"
        {
            tel_cell.detailTextLabel?.text = "데이터가 없습니다."
        }
        else
        {
            tel_cell.detailTextLabel?.text = item["tel"]
        }
        if item["place"] == nil || item["place"] == "-"
        {
           location_cell.detailTextLabel?.text = "데이터가 없습니다."
        }
        else
        {
            location_cell.detailTextLabel?.text = item["place"]
        }
        if item["dataContent"] == nil || item["dataContent"] == "-"
        {
            contents_cell.detailTextLabel?.text = "데이터가 없습니다."
        }
        else
        {
            contents_cell.detailTextLabel?.text = item["dataContent"]
        }
    }

    override func didReceiveMemoryWarning() 
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int 
    {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int 
    {
        // #warning Incomplete implementation, return the number of rows
        return 3
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
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) 
    {
        let userLocation: CLLocation = locations[0]
        //print(userLocation)
        
        let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03))
        
        myMap.setRegion(region, animated: true)
        
        if item["wgsy"] == nil || item["wgsx"] == nil || item["wgsx"] == "-" || item["wgsy"] == "-"
        {
            if region_bool == false
            {
                let annotation = MKPointAnnotation()
                annotation.coordinate = center
                annotation.title = "위치 정보 API가 없습니다."
                
                myMap.addAnnotation(annotation)
                myMap.selectAnnotation(annotation, animated: true)
                region_bool = true
            }
        }
    }
//    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell 
//    {
//        let cell = tableView.dequeueReusableCellWithIdentifier("tel_cell", forIndexPath: indexPath)
////        let lbltel = tel_cell.viewWithTag(1) as? UILabel
////        lbltel?.text = item["tel"]
//        
//        return cell
//    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
