//
//  main_page.swift
//  trans_addr
//
//  Created by L703 on 2016. 10. 4..
//  Copyright © 2016년 dit201212711. All rights reserved.
//

import UIKit
import MapKit

class main_page: UIViewController,UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource,NSXMLParserDelegate,UISearchBarDelegate {
 
    @IBOutlet weak var navbar: UINavigationItem!

    @IBOutlet weak var addrTable: UITableView!
    
    @IBAction func postSearchPressed(sender: AnyObject) {
        
        set_alert("우편번호")
        
    }
    
    var selectedData : [String:String] = [:] // 테이블 뷰를 클릭했을 때의 데이터F
    
    var noDateView : UIView! // data가 없을때 보여줄 뷰
    
    var data : [[String:String]] = []
    
    var count : Int = 0
    
    var toggle : Bool = true
    
    var totalAddress : [Int:[[String:String]]] = [:] // totalPage > 1 일 때 저장될 주소 목록
    
    var schBar : UISearchBar! // 검색을 위한 서치 바
    
    var totalPage : Int! = 0 // 파싱된 데이터의 총 페이지 수
    
    var startURL : String! // parsing할 주소
    
    // item의 name, color 딕셔너리 초기화
    var address : [String:String] = [:]
    
    // item 딕셔너리를 저장할 배열
    var newAddressListAreaCd:[[String:String]] = []
    
    // 현재의 tag(element)를 저장
    var currentElement = ""
    
    //
    let eCarKey : String = "drjIz4E9SQ8ZhfqBgMsFxNM7j9zlf6z6XUE8%2F0%2BDhwmRABnCFH7sU8tMcx6XlBynih42o%2F%2FA0WWISN7esvLR9w%3D%3D"
    
    // 우편번호 03171 으로 테스트
    var postNum : String = ""
    
    // 검색 타입
    var searchType : String = ""

    var post_field : UITextField!
    
    func parsing()
    {
        if let url = NSURL(string: startURL) {
            if let parser = NSXMLParser(contentsOfURL: url) {
                parser.delegate = self
                
                if parser.parse() {
                    print("parsing succes")
                } else {
                    print("parsing failed")
                }
            }
        } else {
            print("URL error")
        }

    }
    

    
    // tableview를 스크롤 하면 서치바의 키보드 숨김
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
  
                // 키패드 내림
                schBar.resignFirstResponder()
                
                self.addrTable.reloadData()
    
    }
    
    // UISearchBar delegate methods
    //  SearchBar에 Text 입력이 시작되면...
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {

        searchBar.showsCancelButton = true
        
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {

        searchBar.showsCancelButton = false
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        
        searchBar.text = ""
        searchBar.showsCancelButton = false
        self.addrTable.reloadData()
        searchBar.resignFirstResponder()

        
    }

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
       
        self.addrTable.reloadData()
        
    }
    
        
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "selecttable" {
            if let detailVC = segue.destinationViewController as? mapviewC {
                
                let path = addrTable.indexPathForSelectedRow
                
                // Data 넘기기
                detailVC.addr = newAddressListAreaCd[(path?.row)!]
                
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.performSegueWithIdentifier("selecttable", sender: self)
        
    }
    
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        data.removeAll()
        
        // Search Text에서 Clear button(x)를 눌렀을때 runtime 오류 처리
        if searchText != "" {
            
            for k in 0..<newAddressListAreaCd.count
            {
                if (newAddressListAreaCd[k]["rnAdres"]!.containsString(searchText) || newAddressListAreaCd[k]["lnmAdres"]!.containsString(searchText))
                {
                    // 검색이 된다
                    
                    data.append(newAddressListAreaCd[k])
                    
                }
            }
            
            if data.count <= 0
            {
                let errAlert = UIAlertController(title: "검색된 데이터 없음", message: "", preferredStyle: .Alert)
                
                errAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (UIAlertAction) -> Void in
                    
                    self.schBar.text = ""
                    
                }))
                
                presentViewController(errAlert, animated: true, completion: nil)

            }
            
            self.addrTable.reloadData()
        }
        else
        {
            self.addrTable.reloadData()
        }
        
    }
   
    
    // 우편번호를 입력받는 얼트 메시지 출력
    func set_alert(title : String)
    {
        
        let aoc = UIAlertController(title: title, message: nil, preferredStyle: .Alert)
            
        aoc.addTextFieldWithConfigurationHandler { (txtPost : UITextField) -> Void in
                
                self.post_field = txtPost
            
                self.post_field?.attributedPlaceholder = NSAttributedString(string: "신우편번호 5자리를 입력하세요.", attributes: [NSForegroundColorAttributeName: UIColor.lightGrayColor()])
 
                self.post_field?.clearButtonMode = UITextFieldViewMode.Always
            
                self.post_field?.keyboardType = UIKeyboardType.NumberPad
            }
            
        aoc.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (UIAlertAction) -> Void in
            
            self.searchType = "post"
            
            self.postNum = self.post_field.text!
            
            self.startURL = "http://openapi.epost.go.kr/postal/retrieveNewAdressAreaCdService/retrieveNewAdressAreaCdService/getNewAddressListAreaCd?ServiceKey=\(self.eCarKey)&searchSe=" + self.searchType + "&srchwrd=" + self.postNum + "&countPerPage=50"

            self.parsing()
            
            
            
        }))
       
        
        aoc.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (UIAlertAction) -> Void in
            
            
        }))
        
        presentViewController(aoc, animated: true, completion: nil)
    }
    
    func msg_alert(title : String , msg : String)
    {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .ActionSheet)
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (UIAlertAction) -> Void in
            
        }))
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func noDataViewCreate()
    {
        let cg1 : CGRect = UIScreen.mainScreen().bounds // 폭과 높이
        
        self.noDateView = UIView(frame: CGRect(x: 10, y: 10, width: cg1.size.width-30, height: cg1.size.height-50))
        
        self.noDateView = NSBundle.mainBundle().loadNibNamed("noDataView", owner: self, options: nil).first as! UIView
        
        self.view.addSubview(self.noDateView)
        
        self.noDateView.hidden = true
    }
    
    func mTableViewCreate()
    {
        
        let cg1 : CGRect = UIScreen.mainScreen().bounds // 폭과 높이
        
        
        schBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: cg1.size.width-30, height: 50))
        
        schBar.delegate = self
        
        schBar.placeholder = "우편번호/지번/도로명"
        
        addrTable.registerNib(UINib(nibName: "Cell", bundle: nil), forCellReuseIdentifier: "Cell")
        
        addrTable.rowHeight = 100 // 커스텀으로 만들었기 때문에 제대로 데이터를 보여주려면 height 조절이 필요하다.
        
        self.addrTable.tableHeaderView = schBar
 
    }
    
    
    
    // 화면 가로 모드로 전환하는거 막기
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(getFromParsing), name: "ParsedData", object: nil)
        
        // NSNotificationCenter.defaultCenter().addObserver(self, selector: "getFromParsing:", name: "ParsedData", object: nil)

        
        
        mTableViewCreate() // 검색 테이블을 위한 테이블 뷰 생성 함수 Call
        
        noDataViewCreate() 
        
        set_alert("우편번호")
        
        // Do any additional setup after loading the view.
    }

    
    func getFromParsing(notifi : NSNotification)
    {
        count = count + 1
        
        for j in 1..<totalPage
        {
            if let data = notifi.userInfo![String(j+1)] as? [[String:String]]
            {
                totalAddress[j] = data
            }
        }
        
        if(count == totalPage)
        {
            count = 0
            
            for i in 1..<totalPage
            {
                if(totalAddress[i] != nil)
                {
                    newAddressListAreaCd.appendContentsOf(totalAddress[i]!)
                }
            }
            
            let alert1 = UIAlertController(title: "검색 성공", message: "OK후 화면을 드래그 해주세요.", preferredStyle: .Alert)
            
            alert1.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (UIAlertAction) -> Void in
                
            }))
            
            presentViewController(alert1, animated: true, completion: nil)
            
            
            addrTable.reloadData()
            
        }
        
        // 예시 : newAddressListAreaCd.appendContentsOf(notifi.userInfo!["2"])
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if data.count > 0
        {
                return data.count
        }
        else
        {
                return newAddressListAreaCd.count
        }
        
    }
    
    

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let myCell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! TableViewCell
        
        if data.count > 0
        {
            myCell.ZipNo.text = "우편번호: " + data[indexPath.row]["zipNo"]!
            
            myCell.LnmAdres.text = "지번주소: " + data[indexPath.row]["rnAdres"]!
            
            myCell.RnAdres.text = "도로명주소: " + data[indexPath.row]["lnmAdres"]!
            
            let imageView : UIImageView
            
            imageView  = UIImageView(frame:CGRectMake(0,0,20,20))
            
            imageView.image = UIImage(named:"placeholder.png")
            
            myCell.accessoryView = imageView
      
            return myCell
        }
        else
        {
            myCell.ZipNo.text = "우편번호: " + newAddressListAreaCd[indexPath.row]["zipNo"]!
            
            myCell.LnmAdres.text = "지번주소: " + newAddressListAreaCd[indexPath.row]["rnAdres"]!
            
            myCell.RnAdres.text = "도로명주소: " + newAddressListAreaCd[indexPath.row]["lnmAdres"]!
            
            let imageView : UIImageView
            
            imageView  = UIImageView(frame:CGRectMake(0,0,20,20))
            
            imageView.image = UIImage(named:"placeholder.png")
            
            myCell.accessoryView = imageView
            
            return myCell
            
        }
        
        
    }
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        currentElement = elementName
        //print("currentElement = \(currentElement)")
        
        if elementName == "NewAddressListResponse" {
            newAddressListAreaCd = []
        } else if elementName == "newAddressListAreaCd" {
            address = [:]
        }
    }
    
    //
    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        
       // let data = string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        switch(currentElement)
        {
        case "zipNo" :
                address[currentElement] = string
            break
        case "lnmAdres" :
                address[currentElement] = string
            break
        case "rnAdres" :
                address[currentElement] = string
            break
        case "totalPage" :
                totalPage = Int(string)
                break
        default:
            break
        }
    }
    
    
    
    // 파싱을 끝낼 부분 판단
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "newAddressListAreaCd" {
            
            newAddressListAreaCd.append(address)
            
        }
    }
    
    // 파싱이 완전히 끝나면
    
    func parserDidEndDocument(parser: NSXMLParser) {

        if let item : [String:String] = address
        {
            if item.count <= 0
            {
                let alert1 = UIAlertController(title: "잘못된 우편번호 입니다.", message: "다시 한번 확인해주세요.", preferredStyle: .Alert)
                
                alert1.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (UIAlertAction) -> Void in
                    
                }))
                
                presentViewController(alert1, animated: true, completion: nil)
    
                noDateView.hidden = false
            
            }
            else
            {
                totalAddress[count] = newAddressListAreaCd
                
                count = count + 1
                
                address = [:]
                
                noDateView.hidden = true
                
            }
        }
        
        if(totalPage > 1)
        {
            for i in 0..<totalPage {

                startURL = "http://openapi.epost.go.kr/postal/retrieveNewAdressAreaCdService/retrieveNewAdressAreaCdService/getNewAddressListAreaCd?ServiceKey=" + self.eCarKey + "&searchSe=" + self.searchType + "&srchwrd=" + self.postNum + "&countPerPage=50&currentPage=" + String(i+1)
                
                Parsing(url: startURL,pageNo: i+1)
            }
        }
        
        addrTable.reloadData()
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
