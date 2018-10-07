//
//  Location Handler.swift
//  DemoLocation
//
//  Created by iOS Developer on 07/10/18.
//  Copyright © 2018 TechTreeIT. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

struct globalValues {
    /// Last Location
    static var userLastLocation : CLLocation?
}

//MARK:-  BG Location Manager
class BGLocationManager : NSObject {
    /// Location Manager - Used to get location
    let locationManager = CLLocationManager()
    
    // Shared instance of class
    @objc static let shared = BGLocationManager()
}

//MARK: Location Delegates
extension BGLocationManager: CLLocationManagerDelegate {
    //MARK: Start Location Manager
    func startLocationManager() {
        self.locationManager.requestAlwaysAuthorization()
        //self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied: return
            case .authorizedAlways, .authorizedWhenInUse:
                print("Application To Start Monitoring Location In Background/Terminated State")
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.allowsBackgroundLocationUpdates = true
                locationManager.pausesLocationUpdatesAutomatically = false
                locationManager.activityType = .otherNavigation
                locationManager.distanceFilter = kCLDistanceFilterNone
                locationManager.startUpdatingLocation()
            }
        }
    }
    
    //MARK: Location Manager
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // create a New Region with current fetched location
        let location = locations.last
        globalValues.userLastLocation = location
        print("Location is updated here with significant delegate")
        //Make region and again the same cycle continues.
        self.createRegion(location: globalValues.userLastLocation!)
    }
}

//MARK: BG location Region Handler
extension BGLocationManager
{
    //MARK: Create A Region
    func createRegion(location:CLLocation) {        
        // Make sure the app is authorized.
        if CLLocationManager.authorizationStatus() == .authorizedAlways {
            if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
                let coordinate = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
                let regionRadius = 1.0
                
                let region = CLCircularRegion(center: CLLocationCoordinate2D(
                    latitude: coordinate.latitude,
                    longitude: coordinate.longitude),
                                              radius: regionRadius,
                                              identifier: "aabb")
                
                region.notifyOnExit = true
                region.notifyOnEntry = true
                
                //Send your fetched location to server
                print("Update Location To Backend Services")
                print("Location Coordinates \(coordinate.latitude) Longutude \(coordinate.longitude)")
                
                //Stop your location manager for updating location and start regionMonitoring
                self.locationManager.stopUpdatingLocation()
                print(CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self))
                self.locationManager.startMonitoring(for: region)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        if state == .inside {
            print("I am in that Region")
        } else if state == .outside {
            print("I am out of that Region")
        } else {
            print("Undefined")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print(error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if let region = region as? CLCircularRegion {
            let identifier = region.identifier
            print("FOUND: " + identifier)
        }    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("User did Exit Defined Region")
        /// Stop Monitoring for old region as user entered in New Region Bounds
        self.locationManager.stopMonitoring(for: region)
        
        /// Start Updating Location Again
        locationManager.startUpdatingLocation()
    }
}
