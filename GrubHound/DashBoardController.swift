//
//  DashBoardController.swift
//  GrubHound
//
//  Created by Umar Farooque on 16/02/17.
//  Copyright © 2017 ufocorp. All rights reserved.
//

/*
 
 THIS IS THE MAIN CLASS THAT IS USED AS THE CONTAINER FOR OTHER VIEW CONTAINERS TO LOAD AND ACTS AS THEIR PARENT AND FETCHES THE USER'S LOCATION AS WELL
 
 */


import UIKit
import CoreLocation
import MBProgressHUD

class DashBoardController: UIViewController {

    
    //MARK: VARS
    var customLocationObj = customLocation()
    var currentVCTag = 0
    let locationManager = CLLocationManager()
    
    
    //MARK: OUTLETS
    
    @IBOutlet weak var tabBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var trendingButton: UIButton!
    @IBOutlet weak var ratingButton: UIButton!
    @IBOutlet weak var tabbarView: UIView!
    @IBOutlet weak var tdButton: UIButton!
    @IBOutlet weak var trendingMarker: UIView!
    @IBOutlet weak var ratingMarker: UIView!
    @IBOutlet weak var tdMarker: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var backButtonWidthConstraint: NSLayoutConstraint!
    
    //MARK: VIEW CONTROLLER OBJ
    var trendingViewObj : TrendingViewController?
    var ratingViewObj : RatingViewController?
    var discardViewObj: DiscardedViewController?
    
    
    //MARK:VIEW LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.tintColor = UIColor.white
        NotificationCenter.default.addObserver(self, selector: #selector(DashBoardController.hideNavBar), name: NSNotification.Name(rawValue: HideNavNotif), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(DashBoardController.showNavBar), name: NSNotification.Name(rawValue: ShowNavNotif), object: nil)
        startViewTransition(tag: currentVCTag)
        self.ratingMarker.isHidden = true
        self.tdMarker.isHidden = true
        self.trendingMarker.isHidden = false
        //location
        isAuthorizedtoGetUserLocation()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        }
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.black.cgColor
        self.navigationController?.navigationBar.layer.shadowOpacity = 1
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize.zero
        self.navigationController?.navigationBar.layer.shadowRadius = 3
        
        tabbarView?.layer.shadowColor = UIColor.black.cgColor
        tabbarView?.layer.shadowOpacity = 1
        tabbarView?.layer.shadowOffset = CGSize.zero
        tabbarView?.layer.shadowRadius = 3
        let attributes : [String: AnyObject] = [NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 20)!,NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: BUTTON ACTIONS
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if searchTextField.isFirstResponder{
            searchTextField.resignFirstResponder()
        }
    }
    
    @IBAction func trendingButtonAction(_ sender: Any) {
        
        self.searchView.isHidden = false
        self.navigationItem.title = "GrubHound"
        if self.childViewControllers.last as? TrendingViewController == nil {
            self.view.isUserInteractionEnabled = false
            let currentTag = (sender as? UIButton)?.tag ?? 0
            startViewTransition(tag: currentTag)
        }
    }
    
    
    @IBAction func reviewButtonAction(_ sender: Any) {
        self.closeSearchAction(sender)
        self.searchView.isHidden = true
        self.navigationItem.title = "My Reviews"
        if self.childViewControllers.last as? RatingViewController == nil {
            self.view.isUserInteractionEnabled = false
            let currentTag = (sender as? UIButton)?.tag ?? 0
            startViewTransition(tag: currentTag)
        }
    }
    
    
    @IBAction func tdButtonAction(_ sender: Any) {
        self.closeSearchAction(sender)
        self.searchView.isHidden = true
        self.navigationItem.title = "Discarded"
        if self.childViewControllers.last as? DiscardedViewController == nil {
            self.view.isUserInteractionEnabled = false
            let currentTag = (sender as? UIButton)?.tag ?? 0
            startViewTransition(tag: currentTag)
        }
    }
    
    @IBAction func searchButtonAction(_ sender: Any) {
    
        if searchView.frame.width == 39 {
            appDelegateObj.searchModeFlag = true
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.searchView.frame = CGRect(x: 7, y: self.searchView.frame.origin.y, width: self.view.frame.width -  16 - 7, height: self.searchView.frame.height)
            })
            self.title = ""
            self.backButtonWidthConstraint.constant = 30.0
            self.view.setNeedsUpdateConstraints()
            self.view.layoutIfNeeded()
            searchTextField.becomeFirstResponder()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: ClearArrNotif), object: nil, userInfo: nil)

        }
    }
    
    
    @IBAction func closeSearchAction(_ sender: Any) {
        if self.backButtonWidthConstraint != nil {
            appDelegateObj.searchModeFlag = false
            if self.backButtonWidthConstraint.constant != 0{
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: ClearArrNotif), object: nil, userInfo: nil)
                self.backButtonWidthConstraint.constant = 0.0
                self.view.setNeedsUpdateConstraints()
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    self.navigationItem.title = "GrubHound"
                    self.searchView.frame = CGRect(x: self.view.frame.width - 83 - 16 - 7, y: self.searchView.frame.origin.y, width: 39, height: self.searchView.frame.height)
                    self.view.layoutIfNeeded()
                }) { (finsihed) -> Void in
                    
                }
                searchTextField.resignFirstResponder()
                searchTextField.text = ""
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: SearchActionNotif), object: nil, userInfo: nil)
            }
        }
    }
    
    //MARK: TRANSITION HELPER FUNCTIONS
    func startViewTransition(tag:Int){
        var newController = UIViewController()
        switch tag {
            
        case 0:
            
            if trendingViewObj == nil {
                trendingViewObj = (self.storyboard?.instantiateViewController(withIdentifier: storyBoardID.trendingVC.rawValue) as? TrendingViewController)!
                newController = trendingViewObj!
                
            }else{
                
                newController = trendingViewObj!
            }
            UIView.animate(withDuration: 0.1, animations: {
                self.ratingMarker.isHidden = true
                self.tdMarker.isHidden = true
                self.trendingMarker.isHidden = false
            })
            
        case 1:
            
            self.showNavBar()
            if ratingViewObj == nil {
                ratingViewObj = (self.storyboard?.instantiateViewController(withIdentifier: storyBoardID.ratingVC.rawValue) as? RatingViewController)!
                newController = ratingViewObj!
            }else{
                newController = ratingViewObj!
            }

            UIView.animate(withDuration: 0.1, animations: {
                
                self.ratingMarker.isHidden = false
                self.tdMarker.isHidden = true
                self.trendingMarker.isHidden = true
                
            })
            
            
        case 2:
            
            self.showNavBar()
            if discardViewObj == nil {
                discardViewObj = (self.storyboard?.instantiateViewController(withIdentifier: storyBoardID.discardVC.rawValue) as? DiscardedViewController)!
                newController = discardViewObj!
                
            }else{
                newController = discardViewObj!
            }
            
            UIView.animate(withDuration: 0.1, animations: {
                
                self.ratingMarker.isHidden = true
                self.tdMarker.isHidden = false
                self.trendingMarker.isHidden = true
                
            })

        default:
        
            if discardViewObj == nil {
                discardViewObj = (self.storyboard?.instantiateViewController(withIdentifier: storyBoardID.discardVC.rawValue) as? DiscardedViewController)!
                newController = discardViewObj!
                
            }else{
                
                newController = discardViewObj!
            }
            
            UIView.animate(withDuration: 0.1, animations: {
                
                self.ratingMarker.isHidden = true
                self.tdMarker.isHidden = true
                self.ratingMarker.isHidden = false
                
            })
            
        }
        
        let oldController = self.childViewControllers.last
        if oldController != nil {
            oldController!.willMove(toParentViewController: nil)
            addChildViewController(newController)
            newController.view.frame = self.containerView.frame
            
            transition(from: oldController!, to: newController, duration: 0.1, options: .transitionCrossDissolve, animations:{ () -> Void in
                // nothing needed here
                
            }, completion: { (finished) -> Void in
                
                oldController!.removeFromParentViewController()
                newController.didMove(toParentViewController: self)

            })
        }else{
            
            addChildViewController(newController)
            newController.view.frame = CGRect(x: 0, y: 0, width: self.containerView.frame.size.width, height: self.containerView.frame.size.height)
            self.containerView.addSubview(newController.view)
            newController.didMove(toParentViewController: self)
        }
        self.view.isUserInteractionEnabled = true
    }
    
    func swipeAction(gesture: UISwipeGestureRecognizer)
    {
        switch gesture.direction {
        case UISwipeGestureRecognizerDirection.right:
            setCurrentTag(direction: false)
        case UISwipeGestureRecognizerDirection.left:
            setCurrentTag(direction: true)
        default:
            print("")
        }
        
    }
    
    func setCurrentTag(direction:Bool){
        
        self.view.isUserInteractionEnabled = false
        if direction == true{
            if currentVCTag < 2{
                currentVCTag = currentVCTag + 1
                startViewTransition(tag: currentVCTag)
            }else{
                self.view.isUserInteractionEnabled = true
            }
            
        }else{
            if currentVCTag == 0 {
                self.view.isUserInteractionEnabled = true
            }else{
                currentVCTag = currentVCTag - 1
                startViewTransition(tag: currentVCTag)

            }
        }
    }
    
    func showNavBar(){
        
            view.layoutIfNeeded()
            if appDelegateObj.isTabBarHidden == true {
                if UIApplication.shared.isStatusBarHidden == true {
                    UIApplication.shared.setStatusBarHidden(false, with: UIStatusBarAnimation.none)
                }
                
                appDelegateObj.isTabBarHidden = false
                
                if let navController: UINavigationController = self.navigationController{
                    if navController.isNavigationBarHidden == true {
                        navController.setNavigationBarHidden(false, animated: true)
                    }
                }
                
                self.view.setNeedsUpdateConstraints()
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    self.view.layoutIfNeeded()
                })
            }
        
    }
    
    
    func hideNavBar(){
        
        if appDelegateObj.searchModeFlag == false {
            
            view.layoutIfNeeded()
            if appDelegateObj.isTabBarHidden == false {
                if UIApplication.shared.isStatusBarHidden == false {
                    UIApplication.shared.setStatusBarHidden(true, with: UIStatusBarAnimation.none)
                }
                
                appDelegateObj.isTabBarHidden = true
                
                if let navController: UINavigationController = self.navigationController {
                    if navController.isNavigationBarHidden == false {
                        navController.setNavigationBarHidden(true, animated: true)
                    }
                }
                
                self.view.setNeedsUpdateConstraints()
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    self.view.layoutIfNeeded()
                })
            }
        }
        
        
    }
}


//MARK: LOCATION CALLBACKS
extension DashBoardController:CLLocationManagerDelegate {

    func isAuthorizedtoGetUserLocation() {
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse     {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
       
        if status == .authorizedWhenInUse {
            print("User allowed us to access location")
            //do whatever init activities here.
            locationManager.startUpdatingLocation()
        }else if status == .denied || status == .restricted {
            
            //alert user to do so
            let alertController: UIAlertController = UIAlertController(title: "Kindly allow app to use location in order to function.\nGo to settings -> Privacy -> Location Services -> GrubHound", message: "", preferredStyle: UIAlertControllerStyle.alert)
            let cancelAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
        if locations.last != nil {
            customLocationObj = customLocation(lat: locations.last!.coordinate.latitude, long: locations.last!.coordinate.longitude, locationObj: locations.last!)
             appDelegateObj.stringCoord = customLocationObj.returnStringFormat(location: customLocationObj.locationObj!)
            //call api
            if appDelegateObj.stringCoord[0].characters.count > 1 {
                //location found
                //call api
                if self.childViewControllers.first as? TrendingViewController != nil {
                    let childVC = self.childViewControllers.first as! TrendingViewController
                    childVC.loadData(notif: nil)
                    locationManager.stopUpdatingLocation()
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Did location updates is called but failed getting location \(error)")
    }
    
}

//MARK: TEXT FIELD DELEGATE
extension DashBoardController: UITextFieldDelegate{
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        //fire notif with search keyword 
        var searchText = textField.text
        if searchText != nil {
            
            if (searchText?.characters.count)! > 2 {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: SearchActionNotif), object: searchText, userInfo: nil)

            }else{
                
                //prompt user for proper keyword
                let alertController: UIAlertController = UIAlertController(title: "Please enter proper keyword", message: "", preferredStyle: UIAlertControllerStyle.alert)
                let cancelAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
        return true
    }
}
    
