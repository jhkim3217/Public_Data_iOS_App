//
//  third_fes_view.swift
//  2_2_to_project
//
//  Created by L703 on 2016. 11. 8..
//  Copyright © 2016년 DIT. All rights reserved.
//

import UIKit

class third_fes_view: UIViewController 
{
    @IBOutlet weak var my_web: UIWebView!
    var str_url = ""
    var save_data_key = ""
    var str_query = ""
    override func viewDidLoad() 
    {
        super.viewDidLoad()
        
        let encode_query = str_query.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        str_url = str_url + encode_query!
        print(str_url)
        let url = NSURL(string: str_url)        
        let request = NSURLRequest(URL: url!)
        my_web.loadRequest(request)
        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() 
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
