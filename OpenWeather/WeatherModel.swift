//
//  WeatherModel.swift
//  OpenWeather
//
//  Created by Stephen Bassett on 5/19/19.
//  Copyright © 2019 Stephen Bassett. All rights reserved.
//

import Foundation

class WeatherModel: NSObject, Codable {
    
    enum CodingKeys: String, CodingKey {
        case name
        case main
        case wind
        case humidity
        case temp
        case speed //windSpeed = "speed"  // do this when want to use different name than what comes in response
    }
    
    var name = ""
    var temp = 0.0
    var humidity = 0
    var windSpeed = 0.0
    
    func encode(to encoder: Encoder) throws { }
    
    override init() { }
    
    convenience required init(from decoder: Decoder) throws {
        self.init()

        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let main = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .main)
        let wind = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .wind)
        self.name = try container.decode(String.self, forKey: .name)
        
        self.temp = try main.decode(Double.self, forKey: .temp)
        self.humidity = try main.decode(Int.self, forKey: .humidity)
        self.windSpeed = try wind.decode(Double.self, forKey: .speed)
        
    }
}
