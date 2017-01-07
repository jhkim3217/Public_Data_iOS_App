
import UIKit

class ViewController: UIViewController, NSXMLParserDelegate
{
    
    let key = "XvbbhgxojihU59b%2BzI27UNzRTxEsexjg3suPdRbu%2F5rSpomO7FP7SOjZVpkM7E9JwzLeXf4GY49rLLHE8kgzgQ%3D%3D"
    //인증키
    
    var item:[String:String] = [:]
    var items:[[String:String]] = []
    var currentElement = ""
    
    var isInItem = false

    override func viewDidLoad() 
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let strURL = "http://tourapi.busan.go.kr/openapi/service/CultureInfoService/getFestivalList?ServiceKey=\(key)&board_id=TOUR_FESTIVAL&CATEGORY_CODE1=kpu0403&END_DATE=201409&Data_title=%EC%A0%9C2%ED%9A%8C%20%EB%B6%80%EC%82%B0%EA%B5%AD%EC%A0%9C%EC%BD%94%EB%AF%B8%EB%94%94%ED%8E%98%EC%8A%A4%ED%8B%B0%EB%B2%8C&DELETE_STATUS=N&numOfRows=10&pageSize=10&pageNo=1&startPage=1"
        //웹페이지 안에 key를 집어 넣음
        
        let url = NSURL(string: strURL)!
        //url 객체 선언, url 잘못됬을 수도 있으므로 unrapping해줌
        
        let parser = NSXMLParser(contentsOfURL: url)!
        let parser2 = NSXMLParser(contentsOfURL: url)!
        
        parser.delegate = self
        parser2.delegate = self
        
        if parser.parse()
        {
            print("parsing success")
            print(items)
            if parser2.parse()
            {
                print("---------------------------------------")
                print(items)
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
    func parser2(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String])
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
    
    func parser2(parser: NSXMLParser, foundCharacters string: String)
    {
        if isInItem
        {
            item[currentElement] = string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        }
        
    }
    
    func parser2(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?)
    {
        
        if elementName == "item"
        {
            isInItem = false
            items.append(item)
        }
        
    }
}

