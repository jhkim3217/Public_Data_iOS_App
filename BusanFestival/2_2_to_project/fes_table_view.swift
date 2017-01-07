//
//  fes_table_view.swift
//  2_2_to_project
//
//  Created by L703 on 2016. 10. 26..
//  Copyright © 2016년 DIT. All rights reserved.
//

import UIKit

class fes_table_view: UITableViewController, NSXMLParserDelegate 
    {
    
    let key = "XvbbhgxojihU59b%2BzI27UNzRTxEsexjg3suPdRbu%2F5rSpomO7FP7SOjZVpkM7E9JwzLeXf4GY49rLLHE8kgzgQ%3D%3D"
    //인증키    
    var item:[String:String] = [:]
    var items:[[String:String]] = []
    var se_item:[String:String] = [:]
    var se_items:[[String:String]] = []
    var data_sid:String = ""
    var currentElement = ""
    var isInItem = false
    let now = NSDate()
    var year_count = NSDate()
    
    override func viewDidLoad() 
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        var strURL = "http://tourapi.busan.go.kr/openapi/service/CultureInfoService/getFestivalList?ServiceKey=\(key)&board_id=TOUR_FESTIVAL&CATEGORY_CODE1=kpu0403&END_DATE=201409&Data_title=%EC%A0%9C2%ED%9A%8C%20%EB%B6%80%EC%82%B0%EA%B5%AD%EC%A0%9C%EC%BD%94%EB%AF%B8%EB%94%94%ED%8E%98%EC%8A%A4%ED%8B%B0%EB%B2%8C&DELETE_STATUS=N&numOfRows=15&pageSize=10&pageNo=1&startPage=1"   
        var se_strURL = "http://tourapi.busan.go.kr/openapi/service/CultureInfoService/getMusicDanceList?serviceKey=\(key)&board_id=TOUR_FESTIVAL&CATEGORY_CODE1=kpu0402_3&END_DATE=201409&Data_title=%EC%A0%9C2%ED%9A%8C%20%EC%9D%B4%ED%99%94%EC%84%B1%20%EA%B0%9C%EC%9D%B8%EA%B3%B5%EC%97%B0%20%E2%80%98%EB%82%98%EB%8A%94%20%EA%B0%80%EB%81%94%20%EB%B0%B1%EC%A1%B0%EB%A5%BC%20%EA%BF%88%EA%BE%BC%EB%8B%A4%E2%80%99&DELETE_STATUS=N&numOfRows=10&pageSize=10&pageNo=1&startPage=1" 
    
        var url = NSURL(string: strURL)!
        let se_url = NSURL(string: se_strURL)!
        //url 객체 선언, url 잘못됬을 수도 있으므로 unrapping해줌
        
        
        var parser = NSXMLParser(contentsOfURL: url)!
              
        parser.delegate = self
                if parser.parse()
        {
            //print(items)
            let parser2 = NSXMLParser(contentsOfURL: se_url)! 
            parser2.delegate = self
            if parser2.parse()
            {
                print("-------------------")
                print(items)
            }
            else
            {
                
            }
        }
        else
        {
            print("parsing fail")
        }
        

       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int 
    {
        // #warning Incomplete implementation, return the number of rows
        return items.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell 
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        for (var i = 0; i < items.count; i++)
        {       
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"

                let sort_item = items[i]
                var sort_date = dateFormatter.dateFromString(sort_item["startDate"]!)
            for(var j = i+1; j < items.count ; j++)
            {
                let lie_item = items[j]
                let lie_date = dateFormatter.dateFromString(lie_item["startDate"]!) 
                if lie_date?.laterDate(sort_date!) != sort_date
                {
                    var temp_data = items[i]
                    items[i] = items[j]
                    items[j] = temp_data
                }
            }
        }
        let item = items[indexPath.row]
//        print("----------------------------")
//        print("\(item["dataTitle")")
        cell.textLabel?.text = item["dataTitle"]
        cell.detailTextLabel?.text = item["startDate"]! + " ~ " + item["endDate"]!
        
        return cell
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        title = "부산 축제/문화/공연"
    }

    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String])
    {
        currentElement = elementName
        if elementName == "items"
        {
            //items = []
        }
        else if elementName == "item"
        {
            //item = [:]
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
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let DateInFormat = dateFormatter.stringFromDate(now)
        var date = dateFormatter.dateFromString("2016-01-01")
        
        
        //print(lie_date)

            if elementName == "item"
            {
                isInItem = false
                var lie_date = dateFormatter.dateFromString(item["endDate"]!)
                year_count = lie_date!.laterDate(date!)
                if year_count != date
                {
                items.append(item)
                }
        }
    }
//    func parser2(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String])
//    {
//        currentElement = elementName
//        if elementName == "items"
//        {
//            se_items = []
//        }
//        else if elementName == "item"
//        {
//            se_item = [:]
//            isInItem = true
//        }
//        
//    }
//    
//    func parser2(parser: NSXMLParser, foundCharacters string: String)
//    {   
//        if isInItem
//        {
//            se_item[currentElement] = string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
//        }
//        
//    }
//    func parser2(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?)
//    {        
//        let dateFormatter = NSDateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd"
//        let DateInFormat = dateFormatter.stringFromDate(now)
//        var date = dateFormatter.dateFromString("2016-01-01")
//        
//        
//        //print(lie_date)
//        
//        if elementName == "item"
//        {
//            isInItem = false
//            var lie_date = dateFormatter.dateFromString(se_item["endDate"]!)
//            let year_count = lie_date!.laterDate(date!)
//            if year_count != date
//            {
//                se_items.append(se_item)
//            }
//        }
//    }
    

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) 
    {   
        if segue.identifier != nil {
            self.title = ""
        }
        if segue.identifier == "goes" 
        {
            let sendtimer=segue.destinationViewController as! se_table
            let path = tableView.indexPathForSelectedRow
            item = items[(path?.row)!]
            sendtimer.data_key = item["dataSid"]!
            //print(item["dataSid"])
        }
        else if segue.identifier == "go_map"
        {
            let sendtimer=segue.destinationViewController as! we_map
            sendtimer.map_items = items
        }
    }
    
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

}
