//
//  SecondViewController.swift
//  BeSafe
//
//  Created by Shivang SIngh on 7/7/19.
//  Copyright © 2019 Shivang Singh. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
import CoreLocation

class SecondViewController: UIViewController {
 
    @IBOutlet weak var s: UILabel!
    
    @IBAction func button(_ sender: Any) {
        
        s.text = "Hello World!!!!!!!!!"

    }
    
    private var gradientColors = [UIColor.green, UIColor.red]
    private var gradientStartPoints = [0.75, 1.0] as? [NSNumber]
    private var heatmapLayer: GMUHeatmapTileLayer!
    @IBOutlet var mapView: GMSMapView!
    
    override func loadView() {
        let camera = GMSCameraPosition.camera(withLatitude: kCameraLatitude,
                                              longitude: kCameraLongitude, zoom: 3)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        self.view = mapView

    }

    override func viewDidLoad() {
        heatmapLayer = GMUHeatmapTileLayer()
        heatmapLayer.radius = 300
        heatmapLayer.opacity = 1.0

        addHeatmap()
        // Create the gradient.
        heatmapLayer.gradient = GMUGradient(colors: gradientColors,
                                            startPoints: gradientStartPoints!,
                                            colorMapSize: 1000)
        heatmapLayer.map = mapView
        
    }
    
    
    func addHeatmap()  {
        NSLog("THIS METHOD")
        
        var list = [GMUWeightedLatLng]()
        do {
            // Get the data: latitude/longitude positions of police stations.
            NSLog("HERE 2 !!!")
            
            
            let path: String = "/police_stations.json"
            let file = try ! Bundle.main.url(forResource: "Data", withExtension: "json")
            let data = Data(file.utf8)

            NSLog(file)
            
            if data != nil {
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions.allowFragments)
                    
                    NSLog("JSON")
                    
                    if let object = json as? [[String: Any]] {
                        for item in object {
                            let lat = item["latitude"]
                            let lng = item["longitude"]
                            let coords = GMUWeightedLatLng(coordinate: CLLocationCoordinate2DMake(lat as! CLLocationDegrees, lng as! CLLocationDegrees), intensity: 1.0)
                            list.append(coords)
                        }
                    }
                    
                }
                catch {
                    //Handle error
                    
                    NSLog("YETTTTTT!!!!!")

                }
            }else{
                NSLog("FILE NOT CORRECT")

            }
        // Add the latlngs to the heatmap layer.
        heatmapLayer.weightedData = list
      }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
