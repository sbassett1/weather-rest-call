//
//  Networking.swift
//  OpenWeather
//
//  Created by Stephen Bassett on 5/18/19.
//  Copyright © 2019 Stephen Bassett. All rights reserved.
//

import Alamofire
import Foundation
import SwiftyJSON

class Networking {
    
    static let shared = Networking()
    
    var humidity = 0
    var temp = 0.0
    var windSpeed = 0.0
    var name = ""
    
    func getWeatherWithAlamofire(lat: String, lon: String, completion: @escaping (Bool) -> ()) {
        guard let url = URL(string: APIClient.shared.getWeatherDataURL(lat: lat, lon: lon)) else {
            print("could not form url")
            return
        }
        
        let headers: HTTPHeaders = [
            "Accept": "application/json; charset=utf-8"
        ]
        let parameters: Parameters = [:]
        
        AF.request(url,
                   method: .get,
                   parameters: parameters,
                   encoding: URLEncoding.default,
                   headers: headers).responseJSON { [weak self] res in
                    guard let strongSelf = self,
                        let data = res.data else {
                            completion(false)
                            return
                    }
                    
                    DispatchQueue.main.async {
                        completion(strongSelf.parseJSONWithCodable(data: data))
                    }
                    /*
                    switch res.result {
                    case .failure(let error):
                        print(error)
                        completion(false)
                    case .success(let jsonData):
                        DispatchQueue.main.async {
                            completion(strongSelf.parseJSONWithSwifty(data: jsonData as! [String: Any]))
//                            completion(strongSelf.parseJSONManually(data: jsonData as! [String: Any]))
                        }
                    }
                     */
        }
        
        
//        AF.request(url).responseJSON { res in
//            switch res.result {
//            case .failure(let error):
//                print(error)
//            case .success(let jsonData):
//                print(jsonData)
//            }
//        }
    }
    
    func parseJSONWithCodable(data: Data) -> Bool {
        do {
            let weatherObject = try JSONDecoder().decode(WeatherModel.self, from: data)
            
            self.humidity = weatherObject.humidity
            self.windSpeed = weatherObject.windSpeed
            self.temp = weatherObject.temp.kelvinToFarenheit.rounded(toPlaces: 1)
            self.name = weatherObject.name
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return true
    }
    
    func parseJSONWithSwifty(data: [String: Any]) -> Bool {
        
        let jsonData = JSON(data)
        
        if let humidity = jsonData["main"]["humidity"].int {
            self.humidity = humidity
        }
        
        if let temp = jsonData["main"]["temp"].double {
            self.temp = temp.kelvinToFarenheit.rounded(toPlaces: 1)
        }
        
        if let windSpeed = jsonData["wind"]["speed"].double {
            self.windSpeed = windSpeed
        }
        
        if let name = jsonData["name"].string {
            self.name = name
        }
        
        return true
    }
    
    func parseJSONManually(data: [String: Any]) -> Bool {
        
        guard let main = data["main"] as? [String: Any],
            let wind = data["wind"] as? [String: Any],
            let name = data["name"] as? String else { return false }
        
        if let humidity = main["humidity"] as? Int {
            self.humidity = humidity
        }
        
        if let temp = main["temp"] as? Double {
            self.temp = temp.kelvinToFarenheit.rounded(toPlaces: 1)
        }
        
        if let windSpeed = wind["speed"] as? Double {
            self.windSpeed = windSpeed
        }
        
        self.name = name
        
        return true
    }
    
    func getWeatherWithURLSession(lat: String, lon: String) {
        
        guard var urlComponents = URLComponents(string: APIClient.shared.baseURL) else { return }
        
        urlComponents.query = "lat=\(lat)&lon=\(lon)&APPID=\(APIClient.shared.apiKey)"
        guard let url = urlComponents.url else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: request) { data, res, error in
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let data = data else { return }
            
            do {
                guard let weatherData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                    print("there was an error converting data into JSON")
                    return
                }
                print(weatherData)
            } catch {
                print("error converting data into JSON")
            }
            
        }
        task.resume()
    }
    
    
    /*
     * this way is simple but doesnt allow to set headers, body, httpMethod, etc
     *
     
     guard let weatherURL = URL(string: APIClient.shared.getWeatherDataURL(lat: lat, lon: lon)) else { return }
     
     URLSession.shared.dataTask(with: weatherURL) { data, res, error in
         ...
     }.resume()
     
     *
     *
     */
}


extension Double {
    
    var kelvinToFarenheit: Double {
        return (self - 273.15) * 9 / 5 + 32
    }
    
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
}
