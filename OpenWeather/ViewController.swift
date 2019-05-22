//
//  ViewController.swift
//  OpenWeather
//
//  Created by Stephen Bassett on 5/18/19.
//  Copyright © 2019 Stephen Bassett. All rights reserved.
//

import CoreLocation
import UIKit

class ViewController: UIViewController {

    @IBOutlet private var cityNameLabel: UILabel!
    @IBOutlet private var tempLabel: UILabel!
    @IBOutlet private var humidityLabel: UILabel!
    @IBOutlet private var windSpeedLabel: UILabel!
    
    var locationManager = CLLocationManager()
    let networking = Networking.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestLocation()
        
    }


}

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        let latitude = String(location.coordinate.latitude)
        let longitude = String(location.coordinate.longitude)
        print(latitude)
        print(longitude)
        self.networking.getWeatherWithAlamofire(lat: latitude, lon: longitude) { success in
            if success {
                self.cityNameLabel.text = self.networking.name
                self.humidityLabel.text = "\(self.networking.humidity)"
                self.windSpeedLabel.text = "\(self.networking.windSpeed)"
                self.tempLabel.text = "\(self.networking.temp)"
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            self.locationManager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            self.locationManager.requestLocation()
        case .denied, .restricted:
            let alertController = UIAlertController(title: "Location Access Disabled", message: "Weather App needs your location to give a weather forecast. Open your settings to change authorization.", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
                alertController.dismiss(animated: true, completion: nil)
            }
            let openAction = UIAlertAction(title: "Open", style: .default) { action in
                guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            
            alertController.addAction(cancelAction)
            alertController.addAction(openAction)
            
            present(alertController, animated: true, completion: nil)
            break
        @unknown default:
            fatalError()
        }
    }
    
}
