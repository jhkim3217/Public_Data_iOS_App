//
//  ViewController.swift
//  Famous Resturant Parsing
//
//  Created by 김종현 on 2016. 9. 24..
//  Copyright © 2016년 김종현. All rights reserved.
//

import UIKit

class ViewController: UIViewController, NSXMLParserDelegate {
    
    var item:[String:String] = [:]
    var items = NSMutableArray()
    var currentElement = ""
    var elementCount = 0
    var itemCount = 0
    
    //let key = "aT2qqrDmCzPVVXR6EFs6I50LZTIvvDrlvDKekAv9ltv9dbO%2F8i8JBz2wsrkpr9yrPEODkcXYzAqAEX1m%2Fl4nHQ%3D%3D"
    let eCarKey = "aT2qqrDmCzPVVXR6EFs6I50LZTIvvDrlvDKekAv9ltv9dbO%2F8i8JBz2wsrkpr9yrPEODkcXYzAqAEX1m%2Fl4nHQ%3D%3D"
    
    func getFileName(fileName:String) -> String {
        let docsDir = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let docPath = docsDir[0] as NSString
        let fullName = docPath.stringByAppendingPathComponent(fileName)
        return fullName
     }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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

        items = NSMutableArray(contentsOfFile: getFileName("items.plist"))!
        itemCount = items.count
        
        // Do any additional setup after loading the view, typically from a nib.
        //let strURL = "http://opendata.busan.go.kr/openapi/service/CultureFestival/getCultureFestivalInfoList?ServiceKey=\(key)&numOfRows=32"
        
        //let strDetailURL = "http://opendata.busan.go.kr/openapi/service/CultureFestival/getCultureFestivalInfoDetail?ServiceKey=\(key)"
        
        let strURL = "http://open.ev.or.kr:8080/openapi/services/rest/EvChargerService?serviceKey=\(eCarKey)"
        
        print(strURL)
        
        if let url = NSURL(string: strURL) {
            if let parser = NSXMLParser(contentsOfURL: url) {
                parser.delegate = self
                
                if parser.parse() {
                    print("parsing succed")
                    print(items)
                    //print("totalCount = \(item["totalCount"])")
                    let totalCount = Int(items["totalCount"]!)
                    if !(itemCount == totalCount){
                        getItems()
                    }
                    
                    

                } else {
                    print("parsing failed")
                }
            }
        } else {
            print("URL error")
        }
        
//        let url = NSURL(string: strURL)
//        
//        let parser = NSXMLParser(contentsOfURL: url!)
//        
//        if parser!.parse() {
//            print("parsing succeed")
//            print(items)
//        } else {
//            print("paring failing")
//        }
        
    }
    
    func getItems(){
        for count in 1...itemCount {
            myParse(count)
        }
    }
    
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
        
//        print("totalCount = \(item["totalCount"])")
        
//        elementCount = elementCount+1
//        print("elementCount = \(elementCount)")
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            items.append(item)
            elementCount = elementCount+1
            print("elementCount = \(elementCount)")

        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

