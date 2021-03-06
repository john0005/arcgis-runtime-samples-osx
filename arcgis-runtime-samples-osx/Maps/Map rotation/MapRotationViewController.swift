//
// Copyright 2016 Esri.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Cocoa
import ArcGIS

class MapRotationViewController: NSViewController {

    @IBOutlet private weak var mapView:AGSMapView!
    @IBOutlet private weak var slider:NSSlider!
    @IBOutlet private weak var rotationLabel:NSTextField!
    @IBOutlet private weak var compassButton:NSButton!
    
    private var map:AGSMap!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //instantiate map with topographic basemap
        self.map = AGSMap(basemap: AGSBasemap.streetsBasemap())
        
        //assign map to the map view
        self.mapView.map = self.map
        
        //allow rotation by pinching on map view
        self.mapView.allowInteractiveRotation = true
        
        //update the slider value when the user rotates by pinching
        self.mapView.viewpointChangedHandler = { [weak self] () in
            self?.slider.integerValue = Int(self!.mapView.rotation)
            self?.rotationLabel.stringValue = "\(self!.slider.integerValue)\u{00B0}"
            let rotationTransform = CGAffineTransformMakeRotation(CGFloat(self!.mapView.rotation * M_PI/180))
            self?.compassButton.layer?.setAffineTransform(rotationTransform)
        }
        
        //initial viewpoint
        self.map.initialViewpoint = AGSViewpoint(targetExtent: AGSEnvelope(XMin: -13044000, yMin: 3855000, xMax: -13040000, yMax: 3858000, spatialReference: AGSSpatialReference.webMercator()))
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        self.compassButton.wantsLayer = true
        self.compassButton.layer?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        //Position of the imgView
        let frame = self.compassButton.layer!.frame
        
        let xCoord = frame.origin.x + frame.size.width
        let yCoord = frame.origin.y + frame.size.height
        
        let myPoint = CGPointMake(xCoord, yCoord)
        self.compassButton.layer?.position = myPoint
    }
    
    //MARK: - Actions
    
    //rotate the map view based on the value of the slider
    @IBAction private func sliderValueChanged(slider:NSSlider) {
        if let viewpoint = self.mapView.currentViewpointWithType(AGSViewpointType.CenterAndScale) {
            let rotatedViewpoint = AGSViewpoint(center: viewpoint.targetGeometry as! AGSPoint, scale: viewpoint.targetScale, rotation: Double(slider.stringValue)!)
            self.mapView.setViewpoint(rotatedViewpoint)
        }
    }
    
    @IBAction private func compassAction(sender:AnyObject) {
        self.compassButton.layer?.setAffineTransform(CGAffineTransformIdentity)
        self.mapView.setViewpointRotation(0, completion: nil)
    }
}
