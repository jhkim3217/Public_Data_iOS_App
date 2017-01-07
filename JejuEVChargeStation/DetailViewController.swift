//
//  DetailViewController.swift
//  JejuEVChargeStation
//
//  Created by Tae Jong Yoo on 2016. 11. 22..
//  Copyright © 2016년 Tae-Jong Yu. All rights reserved.
//

import UIKit

extension UILabel {
    override open var canBecomeFirstResponder: Bool {
        return true
    }
}

class DetailViewController: UITableViewController {
    
    
    @IBOutlet weak var lblAddr: UICopyableLabel!
    @IBOutlet weak var lblChgerType: UILabel!
    @IBOutlet weak var lblAvailableTime: UILabel!
    @IBOutlet weak var lblStat: UILabel!
    
    let chgerTypes = [
        "nil": "정보 없음",
        "01": "DC차데모",
        "03": "DC차데모+AC상",
        "06": "DC차데모+AC상+콤보"
    ]
    let stats = [
        "nil": "정보 없음",
        "1": "통신이상",
        "2": "충전대기",
        "3": "충전중",
        "4": "운영중지",
        "5": "점검중"
    ]
    
    var selectedForDetail = StationPoint()

    @IBAction func exit(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = selectedForDetail.title
        lblAddr.text = selectedForDetail.subtitle
        lblChgerType.text = chgerTypes[selectedForDetail.chgerType ?? "nil"]
        lblAvailableTime.text = selectedForDetail.useTime
        lblStat.text = stats[selectedForDetail.stat ?? "nil"]
    }
    
    func open(scheme: String) {
        if let url = URL(string: scheme) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:],
                                          completionHandler: {
                                            (success) in
                                            print("Open \(scheme): \(success)")
                })
            } else {
                let success = UIApplication.shared.openURL(url)
                print("Open \(scheme): \(success)")
            }
        }
    }

    @IBAction func launchMap(_ sender: UIBarButtonItem) {
        print("launchMap")
        
        let directionsUrl = "http://maps.apple.com/?saddr=\("Current Location")&daddr=\(selectedForDetail.addr)&dirflg=d".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        open(scheme: directionsUrl!)
    }
}
