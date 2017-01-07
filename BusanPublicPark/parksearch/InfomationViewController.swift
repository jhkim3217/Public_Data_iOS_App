//
//  InfomationViewController.swift
//  parksearch
//
//  Created by Psyke on 2016. 10. 27..
//  Copyright © 2016년 Psyke. All rights reserved.
//

import UIKit
import MapKit

class InfomationViewController: UITableViewController,MKMapViewDelegate{
    
    @IBOutlet weak var InfomationMap: MKMapView!
    
    //이전 페이지에서 보낸 값을 받을 변수
    var parkName:String?
    var chargeInfo:String?
    var runDate:String?
    var weekdayStartTime:String?
    var tel:String?
    var Road:String?
    var coordinate:CLLocationCoordinate2D?
    
    //테이블의 타이틀 값 출력을 위한 변수.
    var infomationTitle:[String] = ["도로명주소","요금정보","운영요일","평일 운영시간","전화번호"]
    
   override func viewDidLoad() {
        super.viewDidLoad()
    
        //현제 페이지이의 타이틀명을 주차장 명으로 변경한다.
        title = parkName
    
        print(coordinate!)
    
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate!
        annotation.title = parkName
        annotation.subtitle = Road
    
        let span = MKCoordinateSpanMake(0.004, 0.004)
        let region = MKCoordinateRegionMake(coordinate!, span)
    
        InfomationMap.setRegion(region, animated: true)
    
        InfomationMap.addAnnotation(annotation)
    
        InfomationMap.delegate = self
    
        InfomationMap.selectedAnnotations.append(annotation)
    
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return infomationTitle.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //주차장 상세정보를 출력하기 위한 변수
        let parkInfomation = [Road,chargeInfo,runDate,weekdayStartTime,tel]
        
        // Configure the cell...
        let cell = tableView.dequeueReusableCellWithIdentifier("custom", forIndexPath: indexPath)
        
        //주차장 상세정보를 테이블에 출력한다.
        cell.textLabel?.text =  infomationTitle[indexPath.row]
        cell.detailTextLabel?.text = parkInfomation[indexPath.row]
        
        return cell
    }

}
