//
//  Parsing.swift
//  trans_addr
//
//  Created by L703 on 2016. 11. 9..
//  Copyright © 2016년 dit201212711. All rights reserved.
//

import UIKit

class Parsing : NSObject,NSXMLParserDelegate {
    
    
    let parsingURL: String!

    var newAddressListAreaCd : [[String:String]] = []
    
    var address : [String:String] = [:]
    
    var currentElement : String = ""
    
    var pageNo : Int = 0
    
//    var dataA: NSMutableData = NSMutableData(capacity: 0)!
    
    init(url : String, pageNo : Int)
    {
        self.parsingURL = url
        self.pageNo = pageNo
        super.init()


        //NSURLConnection(request: NSURLRequest(URL: NSURL(string: self.parsingURL)!), delegate: self)!
        
        
        let session: NSURLSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        
        let dataT =  session.dataTaskWithRequest(NSURLRequest(URL: NSURL(string: self.parsingURL)!)) { (dataA, resp, errorA) -> Void in
          
            
            let parser = NSXMLParser(data: dataA!)
            parser.delegate = self
            parser.parse()
        }
        
        dataT.resume()
        
    }
    
//    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
//        print("2222222")
//
//        self.dataA.appendData(data)
//    }
//
//    
//    func connectionDidFinishDownloading(connection: NSURLConnection, destinationURL: NSURL) {
//        let parser = NSXMLParser(data: self.dataA)
//        parser.delegate = self
//        parser.parse()
//
//    }

    
    
    
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
        
        NSNotificationCenter.defaultCenter().postNotificationName("ParsedData", object: self, userInfo: [ "\(pageNo)" : newAddressListAreaCd] )
    }
    
}

