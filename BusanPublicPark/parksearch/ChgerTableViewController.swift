//
//  ChgerTableViewController.swift
//  전기자동차 충전소
//
//  Created by 김종현 on 2016. 9. 25..
//  Copyright © 2016년 김종현. All rights reserved.
//

import UIKit

var item:[String:String] = [:]
var items:[[String:String]] = []

class ChgerTableViewController: UITableViewController, NSXMLParserDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var myRefreshControl = UIRefreshControl()
    
    var searchActive : Bool = false
    
    // 모든 주소 데이터(value)를 가지고 있음
    var addrData:[String] = []
    
    var filtered:[String] = []
    
    var filteredItems:[[String:String]] = []
    
    var currentElement = ""
    var elementCount = 0
    
    // 위도, 경도 저장
    var cLat = 0.0
    var cLong = 0.0
    
    let eCarKey = "aT2qqrDmCzPVVXR6EFs6I50LZTIvvDrlvDKekAv9ltv9dbO%2F8i8JBz2wsrkpr9yrPEODkcXYzAqAEX1m%2Fl4nHQ%3D%3D"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // searchBar delegate 연결
        searchBar.delegate = self
        // searchBar 속성 변경
        searchBar.setValue("취소", forKey:"_cancelButtonText")
        searchBar.placeholder = "지역, 주소검색"
        
        self.title = "전기자동차 충전소 조회 서비스"
        
        //tableView.rowHeight = 80
        
        let strURL = "http://open.ev.or.kr:8080/openapi/services/rest/EvChargerService?serviceKey=\(eCarKey)"
        
        print(strURL)
        
        if let url = NSURL(string: strURL) {
            if let parser = NSXMLParser(contentsOfURL: url) {
                parser.delegate = self
                
                if parser.parse() {
                    print("parsing succed")
                    
                    // 검색을 위한 모든 주소 데이터 뽑아 addrData[] 배열에 저장
                    for item in items {
                        let addr = item["addrDoro"]
                        addrData.append(addr!)
                    }
                    // 주소 데이터 확인
                    //print(addrData)
                    
                } else {
                    print("parsing failed")
                }
            }
        } else {
            print("URL error")
        }
        
    }
    
    // 검색에서 TableView를 scroll down 하면 keyboard 숨김
    override func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        if searchActive == true {
            
            if(filtered.count == 0){
                searchActive = false;
            } else {
                searchActive = true;
            }

            if(velocity.y>0){
                print("dragging Up");
            } else {
                print("dragging Down");
                
                // 키패드 내림
                searchBar.resignFirstResponder()
                
                if(filtered.count == 0){
                    searchActive = false;
                } else {
                    searchActive = true;
                }
                self.tableView.reloadData()
            }
        }
    }
    
//    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
//        if searchText == "" {
//            print("UISearchBar.text cleared!")
//        }
//    }
    
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        currentElement = elementName
        //print("currentElement = \(currentElement)")
        
        if elementName == "items" {
            items = []
        } else if elementName == "item" {
            item = [:]
        }
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        
        let data = string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        item[currentElement] = data
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            items.append(item)
            elementCount = elementCount+1
        }
    }

    
    // UISearchBar delegate methods
    //  SearchBar에 Text 입력이 시작되면...
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true;
        searchBar.showsCancelButton = true
        
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false;
        searchBar.showsCancelButton = false
        
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
        searchBar.text = ""
        searchBar.showsCancelButton = false
        self.tableView.reloadData()
        searchBar.resignFirstResponder()
        
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
        searchBar.text = ""
        
        searchBar.resignFirstResponder()
        
        if(filtered.count == 0){
            searchActive = false;
        } else {
            searchActive = true;
        }
        self.tableView.reloadData()
        
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        // Search Text에서 Clear button(x)를 눌렀을때 runtime 오류 처리
        if searchText == "" {
                       print("UISearchBar.text cleared!")
        } else {
        
            filtered = addrData.filter({ (text) -> Bool in
                let tmp: NSString = text
                let range = tmp.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
                return range.location != NSNotFound
            })
        
            if(filtered.count == 0){
                searchActive = false;
            } else {
                searchActive = true;
            }
            self.tableView.reloadData()
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

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        if searchActive {
            return filtered.count
        }
        return items.count
    }
    

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)

        // Configure the cell...
        var item = items[indexPath.row]
        
        if searchActive {

            for item in items {
                if item["addrDoro"] == filtered[indexPath.row] {
                    let stN = item["statNm"]
                    cell.textLabel?.text = stN
                    cell.detailTextLabel?.text = filtered[indexPath.row]
                }
            }
            
        } else {
        
            cell.textLabel?.text = item["statNm"]
            cell.detailTextLabel?.text = item["addrDoro"]
        }

        return cell
    }
    
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
        
        if segue.identifier == "goMapView" {
            if let mapVC = segue.destinationViewController as? MapViewController {
                let path = tableView.indexPathForSelectedRow
                var item = items[(path?.row)!]
                
                // 검색된 데이터 처리
//                if searchActive {
//                    for item in items {
//                        if item["addrDoro"] == filtered[path!.row] {
//                            let stN = item["statNm"]
//                            let sLat = item["lat"]
//                            let sLong = item["lng"]
//                            let sAddr = item["addrDoro"]
//                            let sChgerType = item["chgerType"]
//                            let sStat = item["stat"]
//                            let sUseTime = item["useTime"]
//                            
//                            mapVC.latData = Double(sLat!)
//                            mapVC.longData = Double(sLong!)
//                            mapVC.statNmData = stN
//                            mapVC.addrData = sAddr
//                            mapVC.chgerTypeData = sChgerType
//                            mapVC.statData = sStat
//                            
//                            if sUseTime == "시간 이용가능" {
//                                mapVC.useTimeData = "24시간 이용가능"
//                            } else {
//                                mapVC.useTimeData = sUseTime
//                            }
//                        }
//                        
//                    }
//                    
//                // 일반 데이터 처리
//                } else {
//                
//                    mapVC.latData = Double(item["lat"]!)
//                    mapVC.longData = Double(item["lng"]!)
//                    mapVC.statNmData = item["statNm"]
//                    mapVC.addrData = item["addrDoro"]
//                    mapVC.chgerTypeData = item["chgerType"]
//                    mapVC.statData = item["stat"]
//                
//                    if item["useTime"] == "시간 이용가능" {
//                        mapVC.useTimeData = "24시간 이용가능"
//                    } else {
//                        mapVC.useTimeData = item["useTime"]
//                    }
//                }
            }
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


