//
//  ParserHandle.swift
//  PharmacyWhere
//
//  Created by DIT on 2016. 11. 11..
//  Copyright © 2016년 MinWook. All rights reserved.
//

import UIKit

class ParserHandle : NSObject, NSXMLParserDelegate {
    
    var currentElement = ""
    
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
            print("elementCount = \(elementCount)")
            
        }
    }
}
