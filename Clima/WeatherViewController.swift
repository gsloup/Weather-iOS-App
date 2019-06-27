//
//  ViewController.swift
//  WeatherApp
//
//  Created by Garrett Sloup on 1/5/2018.
//  Copyright (c) 2018. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire  // to use pods
import SwiftyJSON  // turns Javascript Object Notation and turns it to Swift

class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "bc221e291677569a1cad321c60ad0f6a"  // api key generated from OpenWeatherMap
    

    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()  // object created from the WeatherDataModel Class

    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var degreeSwitch: UISwitch!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()  // requests user location permission
        locationManager.startUpdatingLocation()
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    
    func getWeatherData(url: String, parameters: [String : String]){
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                print("Success! Got the weather data")
                
                let weatherJSON : JSON  = JSON(response.result.value!)
                self.updateWeatherData(json: weatherJSON)  // had to use "self" since inside a closure (in keyword)
                print(weatherJSON)  // test
                
            }
            else {
                print("Error \(String(describing: response.result.error))")
                self.cityLabel.text = "Connection Issues"
            }
        }
    }

    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    func updateWeatherData(json: JSON){
        
        if let tempResult = json["main"]["temp"].double { // finds the weather data in the JSON
        
            weatherDataModel.temperature = Int(tempResult - 273.15) // given in kelvin, have to convert
            
            weatherDataModel.city = json["name"].stringValue
            
            weatherDataModel.condition = json["weather"][0]["id"].intValue
            
            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            
            updateUIWithWeatherData()
            
        }
        else {
            cityLabel.text = "Weather Unavailable"
        }
        
    }

    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    
    func updateUIWithWeatherData() {
        
        cityLabel.text = weatherDataModel.city
        if degreeSwitch.isOn == true {
            temperatureLabel.text = "\(weatherDataModel.temperature)°C"
        }
        else {
            temperatureLabel.text = "\(weatherDataModel.temperature * 9/5 + 32)°F"
        }
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
        
    }
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]  // want the last value since it keeps updating more accurate pts in array
        if location.horizontalAccuracy > 0{ // checks to make sure the data we receive isn't invalid
            locationManager.stopUpdatingLocation() // stops running to save user battery
            locationManager.delegate = nil // stops printing to console after lat and lon is set (time delay otherwise)
            
            print("longitude = \(location.coordinate.longitude), latitude = \(location.coordinate.latitude)")
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            let params : [String : String] = ["lat" : latitude, "lon" : longitude, "appid" : APP_ID]
            
            getWeatherData(url: WEATHER_URL, parameters: params)
        }
    }
    
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavailable"
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    func userEnteredANewCityName(city: String) {
        //print(city)
        let params : [String : String] = ["q" : city, "appid": APP_ID]
        
        getWeatherData(url: WEATHER_URL, parameters: params)
    }

    
    //Write the PrepareForSegue Method here
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "changeCityName"{
            
            let destinationVC = segue.destination as! ChangeCityViewController
            
            destinationVC.delegate = self
        }
    }
    
    
    //Switch between Celcius and Farenheit
    @IBAction func degreeSwitch(_ sender: UISwitch) {
        if sender.isOn == false {
            temperatureLabel.text = "\(weatherDataModel.temperature * 9/5 + 32)°F" // temp in farenheit
        }
        else {
            temperatureLabel.text = "\(weatherDataModel.temperature)°C" // temp in celcius
        }
    }
    
    
}


