/* Copyright (c) 2016 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */



import GoogleMaps
import UIKit
import CoreLocation

//import CSVImporter
/// Point of Interest Item which implements the GMUClusterItem protocol.
class POIItem: NSObject, GMUClusterItem {
    var position: CLLocationCoordinate2D
    var name: String!

    init(position: CLLocationCoordinate2D, name: String) {
        self.position = position
        self.name = name
    }
}

let kClusterItemCount = 1000
let kCameraLatitude = 30.3928327
let kCameraLongitude = -97.747193600000003

class ViewController: UIViewController, GMUClusterManagerDelegate, GMSMapViewDelegate {

    private var mapView: GMSMapView!
    private var clusterManager: GMUClusterManager!
    private var someProtocol = [String : [String : String]]()
    
    override func loadView() {
        let camera = GMSCameraPosition.camera(withLatitude: kCameraLatitude,
                                              longitude: kCameraLongitude, zoom: 10)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        self.view = mapView
        
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up the cluster manager with default icon generator and renderer.
        let iconGenerator = GMUDefaultClusterIconGenerator()
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let renderer = GMUDefaultClusterRenderer(mapView: mapView, clusterIconGenerator: iconGenerator)
        clusterManager = GMUClusterManager(map: mapView, algorithm: algorithm, renderer: renderer)
        
        generateClusterItems()
        
        // Generate and add random items to the cluster manager.

        // Call cluster() after items have been added to perform the clustering and rendering on map.
        clusterManager.cluster()

        // Register self to listen to both GMUClusterManagerDelegate and GMSMapViewDelegate events.
        clusterManager.setDelegate(self, mapDelegate: self)
    }

    // MARK: - GMUClusterManagerDelegate

    func clusterManager(_ clusterManager: GMUClusterManager, didTap cluster: GMUCluster) -> Bool {
        let newCamera = GMSCameraPosition.camera(withTarget: cluster.position,
                                                 zoom: mapView.camera.zoom + 1)
        let update = GMSCameraUpdate.setCamera(newCamera)
        mapView.moveCamera(update)
        return false
    }

    // MARK: - GMUMapViewDelegate

    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        if let poiItem = marker.userData as? POIItem {
            marker.title = someProtocol[poiItem.name]?["Crime"]
            marker.snippet = someProtocol[poiItem.name]?["Time"]
            NSLog("Did tap marker for cluster item \(poiItem.name)")
        } else {
            NSLog("Did tap a normal marker")
        }
        return false
    }
    
    
    
    private func generateClusterItems(){
        
        do {
            let path: String = "crime.csv"
            let file = try! String(contentsOfFile: path)
            let text: [String] = file.components(separatedBy: "\n")
            
            for str in text{
                
                var s : Array<Substring> = str.split(separator: ",")
                
                print(s)
                if (s.count > 13){
                    
                    //someProtocol[String(s[1])]
                    
                    var values = [String : String]()
                    values["ID"] = String(s[0])
                    values["Crime"] = String(s[4])
                    values["Time"] = String(s[5])
                    values["Address"] = String(s[6])
                    values["Latitude"] = String(s[s.count-2])
                    values["Longitude"] = String(s[s.count-1])

                    someProtocol[String(s[0])] = values
                    //values[""] =
                    print(s[s.count-2])
                    print(s[s.count-1])
                    var lat : Double = (s[s.count-2] as NSString).doubleValue
                    var lng : Double = (s[s.count-1] as NSString).doubleValue
                    let item = POIItem(position: CLLocationCoordinate2DMake(lat, lng), name: String(s[0]))
                    clusterManager.add(item)
                    
                }
            }
            
        }
    }

    // MARK: - Private

    /// Randomly generates cluster items within some extent of the camera and adds them to the
    /// cluster manager.
    private func generateTestClusterItems() {
        let extent = 0.2
        for index in 1...kClusterItemCount {
            let lat = kCameraLatitude + extent * randomScale()
            let lng = kCameraLongitude + extent * randomScale()
            let name = "Item \(index)"
            let item = POIItem(position: CLLocationCoordinate2DMake(lat, lng), name: name)
            clusterManager.add(item)
        }
    }

    /// Returns a random value between -1.0 and 1.0.
    private func randomScale() -> Double {
        return Double(arc4random()) / Double(UINT32_MAX) * 2.0 - 1.0
    }
}

