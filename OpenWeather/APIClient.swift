//
//  APIClient.swift
//  OpenWeather
//
//  Created by Stephen Bassett on 5/18/19.
//  Copyright © 2019 Stephen Bassett. All rights reserved.
//

import Foundation

class APIClient {
    
    static let shared = APIClient()
    
    let apiKey = ""
    let baseURL = "https://api.openweathermap.org/data/2.5/weather"
    
    func getWeatherDataURL(lat: String, lon: String) -> String {
        return "\(self.baseURL)?lat=\(lat)&lon=\(lon)&APPID=\(self.apiKey)"
    }
    
}
