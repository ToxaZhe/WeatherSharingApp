//
//  ShowWeatherViewController.swift
//  weatherSharingApp
//
//  Created by user on 3/8/18.
//  Copyright © 2018 Toxa. All rights reserved.
//  95515828


import UIKit
import CoreData
import FacebookLogin

protocol ChangeBackgroundGradientProtocol {
    
    func changeBackground(button: UIButton, buttonTag: Int)
}

protocol ErrorHandlingProtocol {
    func handleError(errorCode: Int)
}

protocol LoadWeatherObserversProtocol {
    
    func handleKeyboardNotification(notification: NSNotification)
    func mocSaved(notification: NSNotification)
    func addObservers()
    func removeObservers()
}

protocol LoadWeatherCoreDataProtocol {
    
    func insertCity()
    func saveMOC()
    func fetchCities() -> [City]
    func cityUpdated() -> Bool
    func cityDeleted() -> Bool
   
}

protocol CityWeatherHandlingProtocol {
    
    func getCityWeather(by cityName: String)
    func transformServerData(cityWeather: CityWeather)
}



class LoadWeatherViewController: UIViewController {
    
//    MARK: menu View Outlets
    
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var menuViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var nameAndEmailLabel: UILabel!
    @IBOutlet weak var citiesCollectionView: UICollectionView!
    
    //   MARK: View Outlets
    @IBOutlet var gradientButtons: [UIButton]!
    @IBOutlet weak var stackViewContainerBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchCityTextField: UITextField!
    
    weak var delegate: ApplyNewGradientDelegate?
    private let cityCellIdentifier = "CityCell", textFieldPlaceHolder = "Weather for City", segueIdentifier = "ToShowWeatherForecasVC"
    
    private let day = "d", night = "n"
    
    private var cityWeatherArr = [WeatherForecast]()
    private var cities = [City]()
    
    private var cityName = ""
    private var buttonTag = 0
    
    private let fetchedResultsController = coreDataManager.fetchedResultsController
    private let moc = coreDataManager.persistentContainer.viewContext
    
//    MARK: View load configuration
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewLoad()
        cities = fetchCities()
        
        UIView.insertGradient(in: view, hexStrings: (mainGradientColors.0, mainGradientColors.1))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addObservers()
    }
    
    deinit {
        removeObservers()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier! == segueIdentifier {
            
            let destVC = segue.destination as! ShowWeatherViewController
            destVC.weatherArr = cityWeatherArr
        }
    }
    
    private func configureViewLoad() {
        
        configureLabels()
        configureButtons()
        configureTextField()
    }
    
    private func configureButtons() {
        gradientButtons.sorted(by: {$0.tag < $1.tag }).enumerated().forEach { (arg) in
            let index = arg.0
            let element = arg.1
            guard gradientColors[index] != mainGradientColors else {
                buttonTag = element.tag
                return
            }
            element.imageView?.apply(borderColor: .white, borderWidth: 3, andRadius: nil)
        }
    }
    
    func configureLabels() {
        
        guard let user = fetchedResultsController.fetchedObjects?.first,
        let name = user.name, let email = user.email,
        let hevFont = hevFont,
        let hevBoldFont = hevBoldFont else { return }
        
        nameAndEmailLabel.attributed(strings: [name, "\n\(email)"], colors: [.black, .gray], fonts: [hevBoldFont.withSize(17), hevFont])
    }
    
//    MARK: Controller Actions And Action methods
    
    @IBAction func leftSwipeAction(_ sender: Any) {
        
        moveMenu(alpha: 0, constraintConstant: -view.frame.size.width)
    
    }
    
    @IBAction func rightSwipeAction(_ sender: UISwipeGestureRecognizer) {
        
        moveMenu(alpha: 1, constraintConstant: 0)
    }
    
    func moveMenu(alpha: CGFloat, constraintConstant: CGFloat) {
        menuView.alpha = alpha
        menuViewLeadingConstraint.constant = constraintConstant
        animateView()
    }
    
    @IBAction func tapAction(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    
    
    @IBAction func findAction(_ sender: Any) {
        
        searchWeather()
    }
    
    @IBAction func logOutAction(_ sender: UIButton) {
        logOut()
    }
    
    
    func logOut() {
        
        guard let user = fetchedResultsController.fetchedObjects?.first else { return }
        
        user.status = "not active"
        saveMOC()
        UserDefaults.standard.set(false, forKey: activeUser)
        
        LoginManager().logOut()
        navigationController?.popToRootViewController(animated: true)
    }
}


extension LoadWeatherViewController: ChangeBackgroundGradientProtocol {
    
    @IBAction func changeBackgrounAction(_ sender: UIButton) {
        
        switch sender.tag {
        case 1:
            changeBackground(button: sender, buttonTag: sender.tag)
            
        case 2:
            changeBackground(button: sender, buttonTag: sender.tag)
            
        case 3:
            changeBackground(button: sender, buttonTag: sender.tag)
            
        case 4:
            changeBackground(button: sender, buttonTag: sender.tag)
            
        case 5:
            changeBackground(button: sender, buttonTag: sender.tag)
            
        case 6:
            changeBackground(button: sender, buttonTag: sender.tag)
            
        default:
            changeBackground(button: sender, buttonTag: sender.tag)
        }
    }
    
    func changeBackground(button: UIButton, buttonTag: Int) {
        
        saveToDefaults(hexStrings: gradientColors[buttonTag])
        button.pulsate()
        applyNewGradient(index: buttonTag)
        changeSelected(button: button, tag: buttonTag)
    }
    
    private func changeSelected(button btn: UIButton, tag: Int) {
        
        guard let oldGradientBtn = gradientButtons.filter({$0.tag == buttonTag}).first,
            let oldImageView =  oldGradientBtn.imageView,
            let newImageView = btn.imageView else { return }
        
        oldImageView.apply(borderColor: .white, borderWidth: 3, andRadius: nil)
        newImageView.apply(borderColor: .clear, borderWidth: 0, andRadius: nil)
        
        buttonTag = tag
    }
    
    
    private func applyNewGradient(index: Int) {
        
        let colors = (UIColor.init(hexString: gradientColors[index].0).cgColor , UIColor.init(hexString: gradientColors[index].1).cgColor)
        
        let newGradientLayer = CAGradientLayer().createGradientLayer(withColors: colors)
        newGradientLayer.frame = view.frame
        
        delegate?.gradientChanged(changed: true)
        guard let oldGradientLayer = view.layer.sublayers?.first else  { return }
        view.layer.replaceSublayer(oldGradientLayer, with: newGradientLayer)
    }
    
    private func saveToDefaults(hexStrings: (String, String)) {
        
        UserDefaults.standard.set(hexStrings.0, forKey: firstGradientColor)
        UserDefaults.standard.set(hexStrings.1, forKey: secondGradientColor)
        
        mainGradientColors.0 = hexStrings.0
        mainGradientColors.1 = hexStrings.1
    }
    
}

extension LoadWeatherViewController: LoadWeatherObserversProtocol {
    
    func addObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.mocSaved), name: Notification.Name.NSManagedObjectContextDidSave, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func handleKeyboardNotification(notification: NSNotification) {
        
        guard let userInfo = notification.userInfo,
            let keyboardSize = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {return}
        
        var keyboardHeight = keyboardSize.height
        if #available(iOS 11.0, *) {
            let bottomInset = view.safeAreaInsets.bottom
            keyboardHeight -= bottomInset
        }
        
        let isKeyboardShowing = notification.name == .UIKeyboardWillShow
        stackViewContainerBottomConstraint.constant = isKeyboardShowing ? keyboardHeight : 0
        animateView()
    }
    
    private func animateView() {
        
        UIView.animate(withDuration: 0, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }) { (completion) in }
    }
    
    @objc func mocSaved(notification: NSNotification) {
        
        cities = fetchCities()
    }
    
    func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }
}

extension LoadWeatherViewController: CityWeatherHandlingProtocol {
    
    func getCityWeather(by cityName: String) {
        
        WeatherApi.getCityWeatherByName(cityName, onSuccess: {[unowned self] (data) in
            do {
                let decoder = JSONDecoder()
                let weather = try decoder.decode(CityWeather.self, from: data)
                self.transformServerData(cityWeather: weather)
                
            } catch let jsonErr {
                DialogHelper.showAlert(title: "Data Corrupted", message: "error: \(jsonErr.localizedDescription)", controller: self, handleAction: nil)
            }
            
        }) { (errorCode) in self.handleError(errorCode: errorCode) }
    }
    
    func searchWeather() {
        
        guard searchCityTextField.text?.isEmpty == false else {
            DialogHelper.showAlert(title: "No City", message: "Please enter city", controller: self, handleAction: nil)
            return
        }
        
        let cityName = searchCityTextField.text!.replacingOccurrences(of: " ", with: "")
        getCityWeather(by: cityName)
        
        searchCityTextField.text = nil
        searchCityTextField.placeholder = textFieldPlaceHolder
        searchCityTextField.endEditing(true)
    }
    
    func transformServerData(cityWeather: CityWeather) {
        
        var filteredWeathers = cityWeather.list.enumerated().filter{return $0.0 % 4 == 0}.map{return $0.1}
        cityName = cityWeather.city.name
        cityWeather.list.enumerated().forEach { (index, cityWeather) in
          
            filteredWeathers.enumerated().forEach({ (index, weather) in
            
                var updatedWeather = weather
                
                guard weather.sys.pod == cityWeather.sys.pod,
                    compareDate(Date.init(timeIntervalSince1970: weather.dt), with: Date.init(timeIntervalSince1970: cityWeather.dt), andCondition: .orderedSame) else { return }
                
                let comparedTemps = compareTemperature(in: weather, with: cityWeather)
                updatedWeather.main.temp_min = comparedTemps.0
                updatedWeather.main.temp_max = comparedTemps.1
                
                filteredWeathers[index] = updatedWeather
            })
        }
        updateWeatherModels(from: filteredWeathers)
    }
    
    private func compareDate(_ date1: Date, with date2: Date, andCondition condition: ComparisonResult) -> Bool {
        return Calendar.current.compare(date1, to: date2, toGranularity: .day) == condition
    }
    
    private func findMin(_ newValue: Double, oldValue: Double) -> Bool {
        return newValue < oldValue
    }
    
    private func findMax(_ newValue: Double, oldValue: Double) -> Bool {
        return newValue > oldValue
    }
    
    private func compareTemp(newValue new:Double, with oldValue: Double, comparingClosure: (Double, Double) -> Bool) -> Double {
        
        guard comparingClosure(new,oldValue) else {
            return oldValue
        }
        return new
    }
    
    private func compareTemperature(in weather: CityWeather.WeatherInfo, with newWeather: CityWeather.WeatherInfo) -> (Double, Double) {
        
        var comparingResult: (Double, Double)
        comparingResult.0 = compareTemp(newValue: weather.main.temp_min, with: newWeather.main.temp_min, comparingClosure: findMin(_:oldValue:))
        comparingResult.1 = compareTemp(newValue: weather.main.temp_max, with: newWeather.main.temp_max, comparingClosure: findMax(_:oldValue:))
        
        return comparingResult
    }
    
    func updateWeatherModels(from arr: [CityWeather.WeatherInfo]) {
        cityWeatherArr.removeAll()
        arr.forEach{loadIcon(andAdd : $0)}
    }
    
    func loadIcon(andAdd weather: CityWeather.WeatherInfo) {
        
        WeatherApi.getWeatherIcon(by: weather.weather[0].icon, onSuccess: { [unowned self] (data) in
            
            let weatherForecast = WeatherForecast(context: self.moc)
            
            weatherForecast.createdAt = weather.dt
            weatherForecast.dayTime = weather.sys.pod
            weatherForecast.weatherDescription = weather.weather[0].main
            weatherForecast.minTemp = String(Int(weather.main.temp_min.rounded()))
            weatherForecast.maxTemp = String(Int(weather.main.temp_max.rounded()))
            weatherForecast.weatherImg = data as NSData
            
            self.cityWeatherArr.append(weatherForecast)
            
            guard self.cityWeatherArr.count == 10 else { return }
            
            if !self.cityUpdated() {
                self.insertCity()
            }
            
            DispatchQueue.main.async {
                
                self.citiesCollectionView.reloadData()
                self.performSegue(withIdentifier: self.segueIdentifier, sender: nil)
                }
            }, onError: { (errCode) in
                print(errCode)
        })
    }
    
}


extension LoadWeatherViewController: LoadWeatherCoreDataProtocol {
    
    func insertCity() {
        
        guard let user = fetchedResultsController.fetchedObjects?.first else { return }

        let city = City(context: moc), weatherTempsSet = NSSet.init(array: cityWeatherArr)
    
        city.createdUpdated  = Date() as NSDate
        city.cityName = cityName
        city.addToWeatherForecasts(weatherTempsSet)
        city.user = user
        
        saveMOC()
    }
    
    func cityExists() -> City? {
        
        guard let user = fetchedResultsController.fetchedObjects?.first else { return nil }
        guard let existedCity = user.cities?.filtered(using: NSPredicate(format: "cityName = %@", cityName)).first as? City else { return nil }
        cityWeatherArr = cityWeatherArr.filter{return $0 != existedCity}
        
        return existedCity
    }
    
    func cityDeleted() -> Bool {
        
        guard let cityToDelete = cityExists() else { return false }
        
        fetchedResultsController.fetchedObjects?.first!.removeFromCities(cityToDelete)
        cityWeatherArr.removeAll()
        saveMOC()
        
        return true
    }
    
    func cityUpdated() -> Bool {
        
        guard let cityToUpdate = cityExists() else { return false }
        guard let user = fetchedResultsController.fetchedObjects?.first else { return false }
        
        cityToUpdate.weatherForecasts?.forEach({ (weatherForecast) in
            guard let forecast = weatherForecast as? WeatherForecast else { return }
            cityToUpdate.removeFromWeatherForecasts(forecast)
        })
      
        let weatherTempsSet = NSSet.init(array: cityWeatherArr)
        cityToUpdate.addToWeatherForecasts(weatherTempsSet)
        cityToUpdate.user = user
        cityToUpdate.createdUpdated = NSDate()
        
        saveMOC()
        
        return true
    }
   
    
    func saveMOC() {
        
        do {
            try coreDataManager.saveMOC()
        } catch { print(error.localizedDescription)}
    }
    
    func fetchCities() -> [City] {
        
        let emptyCities = [City]()
        guard let cities = fetchedResultsController.fetchedObjects?.first?.cities?.sortedArray(using: City.defaultCitySortDescriptors) as? [City] else {
            
            return emptyCities
        }
        return cities
    }
}

extension LoadWeatherViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        guard textField.text != nil else { return false }
        
        searchWeather()
        return true
    }
    
    func configureTextField() {
        
        searchCityTextField.autocapitalizationType = .words
        searchCityTextField.attributedPlaceholder = NSAttributedString(string: textFieldPlaceHolder, attributes: [NSAttributedStringKey.foregroundColor: UIColor.white.withAlphaComponent(0.3)])
        
        let placeholdeLabel = searchCityTextField.value(forKey: "_placeholderLabel") as! UILabel
        placeholdeLabel.adjustsFontSizeToFitWidth = true
        placeholdeLabel.textAlignment = .center
        
    }
}


extension LoadWeatherViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cities.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cityCellIdentifier, for: indexPath) as! CityInfoCollectionViewCell
        
        guard let cityLastLetter = cities[indexPath.row].cityName?.last,
            let cityWithoutLastLetter = cities[indexPath.row].cityName?.dropLast(),
            let hevFont = hevFont else { return cell }
        cell.cityNameLabel.attributed(strings: [String(cityWithoutLastLetter), String("\n\(cityLastLetter)")], colors: nil, fonts: [hevFont, hevFont])
        
        
        guard let date = DateFormatter().convertToString(dates: [cities[indexPath.row].createdUpdated! as Date]).first else { return cell }
        cell.savedDateLabel.text = date
        
        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let height = collectionView.frame.size.width * 130/327
        
        return CGSize.init(width: height, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        collectionView.deselectItem(at: indexPath, animated: true)
        
        cityWeatherArr.removeAll()
        cityWeatherArr = cities[indexPath.row].weatherForecasts?.sortedArray(using: WeatherForecast.defaultWeatherSortDescriptors) as! [WeatherForecast]
        
        moveMenu(alpha: 0, constraintConstant: -view.frame.size.width)
        performSegue(withIdentifier: segueIdentifier, sender: nil)
    }
}

extension LoadWeatherViewController: ErrorHandlingProtocol {
    
    func handleError(errorCode: Int) {
        
        switch errorCode {
        case 404:
            
            DialogHelper.showAlert(title: "Not Found", message: "Can't find entered city", controller: self, handleAction: nil)
            
        case 400:
            //            MARK: In completionHandler we can send error details to support
            DialogHelper.showAlert(title: "Bad Request", message: "Please contact our support service", controller: self, handleAction: nil)
            
        case 500, 503, 502, 504, -1011:
            
            DialogHelper.showAlert(title: "Server error", message: "Please contact our support service", controller: self, handleAction: nil)
            
        case -1009, -1005:
            
            DialogHelper.showAlert(title: "No Connection", message: "Please check your internrt connection", controller: self, handleAction: nil)
            
        case -1015, -1016, -1017:
            
            DialogHelper.showAlert(title: "Data Corrupted", message: "Can't parse response", controller: self, handleAction: nil)
            
        case -1001:
            
            DialogHelper.showAlert(title: "Timed Out", message: "Request timed out", controller: self, handleAction: nil)
            
        case -1008, 1004, 1005:
            
            DialogHelper.showAlert(title: "Connection problem", message: "Cannot connect to host", controller: self, handleAction: nil)
            
        default:
            
            DialogHelper.showAlert(title: "Unknown Error", message: "Please contact us", controller: self, handleAction: nil)
        }
    }
}

