//
//  alert.swift
//  trans_addr
//
//  Created by L703 on 2016. 11. 16..
//  Copyright © 2016년 dit201212711. All rights reserved.
//

import UIKit

class customAlert : NSObject,UIAlertController{
    
    var title : String!
    
    var massage : String!
    
    init(title : String , massage : String)
    {
        self.title = title
        self.massage = massage
        super.init()
    }

}

