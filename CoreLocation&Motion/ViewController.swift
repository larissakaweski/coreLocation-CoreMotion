//
//  ViewController.swift
//  CoreLocation&Motion
//
//  Created by Larissa Kaweski Siqueira on 04/11/23.
//

import UIKit
import CoreLocation
import CoreMotion

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet var pedometer: UILabel!
    @IBOutlet var accelerometer: UILabel!
    @IBOutlet var distanceReading: UILabel!
    
    var locationManager: CLLocationManager?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLocationManager()
        setupMotionManager()
        setupActivityManager()
    }
    
    func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        
        view.backgroundColor = .gray
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedAlways {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    startScanning()
                }
            }
        }
        
    }
    
    func startScanning() {
        guard let uuid = UUID(uuidString: "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5") else {
            return
        }
        
        let beaconRegion = CLBeaconIdentityConstraint(uuid: uuid, major: 123, minor: 456)
        let beaconRegionn = CLBeaconRegion(beaconIdentityConstraint: beaconRegion, identifier: "MyBeacon")

        locationManager?.startMonitoring(for: beaconRegionn)
        locationManager?.startRangingBeacons(satisfying: beaconRegion)
    }
    
    func update(distance: CLProximity) {
        UIView.animate(withDuration: 1) {
            switch distance {
            case .far:
                self.view.backgroundColor = UIColor.blue
                self.distanceReading.text = "FAR"

            case .near:
                self.view.backgroundColor = UIColor.orange
                self.distanceReading.text = "NEAR"

            case .immediate:
                self.view.backgroundColor = UIColor.red
                self.distanceReading.text = "RIGHT HERE"
                
            default:
                self.view.backgroundColor = UIColor.gray
                self.distanceReading.text = "UNKNOWN"
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        if let beacon = beacons.first {
            update(distance: beacon.proximity)
        } else {
            update(distance: .unknown)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location update failded, \(error)")
    }
    
    func setupMotionManager() {
        let movementManager = CMMotionManager()
        movementManager.startAccelerometerUpdates()
        movementManager.accelerometerUpdateInterval = 0.5
        
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            if let data = movementManager.accelerometerData {
                self.accelerometer.text = String(data.acceleration.x)
            }
        }
    }
    
    func setupActivityManager() {
        let activityManager = CMMotionActivityManager()
        let pedoMeter = CMPedometer()
        
        if CMMotionActivityManager.isActivityAvailable() {
            activityManager.startActivityUpdates(to: OperationQueue.main) { (data) in
                DispatchQueue.main.async {
                    if let activity = data {
                        if activity.running == true {
                            self.pedometer.text = "Running"
                            print("Running")
                        } else if activity.walking == true {
                            self.pedometer.text = "Walking"
                        } else if activity.automotive == true {
                            self.pedometer.text = "Automotive"
                        }
                    }
                }
            }
        }
        
        if CMPedometer.isStepCountingAvailable() {
            pedoMeter.startUpdates(from: Date()) { (data, error) in
                if error == nil {
                    if let response = data {
                        DispatchQueue.main.async {
                            print("Number of Steps: \(response.numberOfSteps)")
                            self.pedometer.text = "Step Counter: \(response.numberOfSteps)"
                        }
                    }
                }
            }
        }
        
    }
}

