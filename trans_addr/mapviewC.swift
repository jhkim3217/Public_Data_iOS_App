//
//  mapviewC.swift
//  trans_addr
//
//  Created by L703 on 2016. 11. 29..
//  Copyright © 2016년 dit201212711. All rights reserved.
//

import UIKit
import MapKit

class mapviewC: UIViewController,MKMapViewDelegate {

    @IBOutlet weak var myMapView: MKMapView!
    
    var addr : [String:String] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "검색 위치"

        // Geocoding 객체 생성
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(addr["lnmAdres"]!, completionHandler: { placemarks, error in
            
            if error != nil {
                print(error)
                return
            }
            
            
            if let placemarks = placemarks {
                // Get the first placemark
                let placemark = placemarks[0]
                
                // Add annotation
                
                let annotation = MKPointAnnotation()
                
                annotation.title = "우편번호: " + self.addr["zipNo"]!
                annotation.subtitle = "도로명 주소: " + self.addr["lnmAdres"]!
                
                if let location = placemark.location {
                    
                    annotation.coordinate = location.coordinate
                    
                    let region = MKCoordinateRegionMakeWithDistance(location.coordinate, 100.0, 100.0)
                    
                    
                    self.myMapView.setRegion(region, animated: true)
                    
                    self.myMapView.addAnnotation(annotation)
                
                    self.mapView(self.myMapView,viewForAnnotation:annotation)
                    
                    self.myMapView.selectAnnotation(annotation, animated: true)
                }
                
                
            }
            
            
            
        })
        
        // Do any additional setup after loading the view.
    }

    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
    
        let identifier = "address"
        
        var annoView = myMapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView
 
        annoView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        
        annoView!.canShowCallout = true
        annoView!.pinTintColor = UIColor.greenColor()
            
        let btn = UIButton(type: .DetailDisclosure)
            
        btn.setImage(UIImage(named: "restart.png"), forState: .Normal)
            
        annoView!.rightCalloutAccessoryView = btn

        return annoView
    }

    
    


    override func didReceiveMemoryWarning() {
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
