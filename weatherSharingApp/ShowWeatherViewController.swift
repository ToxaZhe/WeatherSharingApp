//
//  ShowweatherViewController.swift
//  weatherSharingApp
//
//  Created by user on 3/12/18.
//  Copyright © 2018 Toxa. All rights reserved.
//

import UIKit
import CoreData
import FacebookShare

class ShowWeatherViewController: UIViewController {
    
    @IBOutlet weak var weatherCollectionView: UICollectionView!
    @IBOutlet weak var cityLabel: UILabel!
    
    private let weatherCellIdentifier = "WeatherCell"
    private let night = "n"
    private let dayTime = "day"
    private let nightTime = "night"
    
    internal var weatherArr: [WeatherForecast]!
    private var dayWeatherArray = [WeatherForecast]()
    private var nightWeatherArray = [WeatherForecast]()
    
    private var dayTimes = [String]()
    private var nightDatesStrings = [String]()
    private var dayDatesStrings = [String]()
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        convertDatesToStrings(from: weatherArr)
        transform(weatherArray: weatherArr)
        
        UIView.insertGradient(in: view, hexStrings: (mainGradientColors.0, mainGradientColors.1))
        
        guard let cityName = weatherArr[0].city?.cityName else { return }
        cityNameforLabel(cityName)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        shakeCell()
    }
    
    func cityNameforLabel(_ name: String) {
        
        guard let hevFont = hevFont else {return}
        cityLabel.attributed(strings: ["city -", "\n\(name)"], colors: nil, fonts: [hevFont, hevFont])
    }
    
    func convertDatesToStrings(from array: [WeatherForecast]) {
        
        array.forEach { (weather) in
            guard weather.dayTime != night else {
                let date = Date.init(timeIntervalSince1970: weather.createdAt)
                nightDatesStrings.append(DateFormatter.convertDateInString(date: date))
                return
            }
            
            let date = Date.init(timeIntervalSince1970: weather.createdAt)
            dayDatesStrings.append(DateFormatter.convertDateInString(date: date))
        }
    }

    func shakeCell() {
        
        let indexPath = IndexPath.init(row: 0, section: 0)
        let cell = weatherCollectionView.cellForItem(at: indexPath) as! WeatherCollectionViewCell
        let values = [ -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]

        cell.cardView.shake(animationValues: values, duration: 0.6)
    }
    
    func transform(weatherArray array: [WeatherForecast]) {
        
        let dayForecasts = array.filter{$0.dayTime != night}
        let nightForecasts = array.filter{$0.dayTime == night}
        
        dayWeatherArray = dayForecasts
        nightWeatherArray = nightForecasts
        
        guard array.first?.dayTime == night  else {
            dayWeatherArray.forEach{_ in dayTimes.append(dayTime)}
            return
        }
        nightWeatherArray.forEach{_ in dayTimes.append(nightTime)}
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func shareCardToFacebook(_ sender: UIButton) {

        postWeatherToFacebook()
    }
    
    func postWeatherToFacebook() {
        
        guard let cell = weatherCollectionView.visibleCells.first as? WeatherCollectionViewCell else { return }
        
        let image = Photo(image: UIImage(view: cell.cardView), userGenerated: true)
        let content = PhotoShareContent(photos: [image])
        
        do {
            try ShareDialog.show(from: self, content: content)
        } catch {
            DialogHelper.showAlert(title: "Sharing Error", message: "error: \(error.localizedDescription)", controller: self, handleAction: nil)
        }
    }
}

extension ShowWeatherViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dayWeatherArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: weatherCellIdentifier, for: indexPath) as! WeatherCollectionViewCell
        
        switch dayTimes[indexPath.row] {
            
        case nightTime:
            
            cell.cardBackgroundView.backgroundColor = .black
            UILabel.applyLabelsColors([(cell.weatherDescriptionLbl, .white), (cell.minMaxTempLbl, .white)])
            return prepare(cell: cell, for: indexPath, weatherArray: nightWeatherArray, stringDates: nightDatesStrings, dayTimes: dayTimes)
        default:
            
            cell.cardBackgroundView.backgroundColor = .white
            UILabel.applyLabelsColors([(cell.weatherDescriptionLbl, .black), (cell.minMaxTempLbl, .black)])
            return prepare(cell: cell, for: indexPath, weatherArray: dayWeatherArray, stringDates: dayDatesStrings, dayTimes: dayTimes)
        }
      
    }
    
    func prepare(cell: WeatherCollectionViewCell, for indexPath: IndexPath, weatherArray: [WeatherForecast], stringDates: [String], dayTimes: [String]) ->  WeatherCollectionViewCell {
        
        cell.dayTimeLabel.text = dayTimes[indexPath.row]
        cell.weatherDescriptionLbl.text = weatherArray[indexPath.row].weatherDescription
        cell.minMaxTempLbl.text = weatherArray[indexPath.row].minTemp! + "/" + weatherArray[indexPath.row].maxTemp!
       
        guard let image = UIImage.init(data: weatherArray[indexPath.row].weatherImg! as Data),
        let weekDay = stringDates[indexPath.row].components(separatedBy: " ").first,
        let date =  stringDates[indexPath.row].components(separatedBy: " ").last,
        let hevFont = hevFont else { return cell }
        
        cell.dateLbl.attributed(strings: [weekDay, date], colors: nil, fonts: [hevFont, hevFont])
        cell.weatherImageView.image = image
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.frame.size.width
        let height = collectionView.frame.size.height
        
        return CGSize.init(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! WeatherCollectionViewCell
        dayTimes[indexPath.row] = cell.dayTimeLabel.text == dayTime ? nightTime : dayTime
        
        let transitionOptions: UIViewAnimationOptions = [.transitionFlipFromLeft, .curveEaseInOut]
        UIView.transition(with: cell.cardBackgroundView, duration: 0.3, options: transitionOptions, animations: {
            
            cell.cardBackgroundView.alpha = 0
            collectionView.reloadItems(at: [indexPath])
            
        }, completion: { (true) in
            
            cell.cardBackgroundView.alpha = 1
        })
    }
}

