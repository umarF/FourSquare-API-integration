//
//  TrendingViewController.swift
//  GrubHound
//
//  Created by Umar Farooque on 16/02/17.
//  Copyright © 2017 ufocorp. All rights reserved.
//

import UIKit
import RealmSwift
import MBProgressHUD

/*
 
 THIS CLASS IS THE RESPONSIBLE FOR HANDLING THE QUICK VIEW LINKS, AND MAKING THE SERVER CALL TO FETCH NEAREST EATING SPOTS DEPENDING ON USER'S LOCATION.
 
 */


class TrendingViewController: UIViewController {
    
    //MARK: OUTLETS
    @IBOutlet weak var trendingTable: UITableView!
    @IBOutlet weak var quickActionView: UIView!
    @IBOutlet weak var quickViewHeightCons: NSLayoutConstraint!
    
    //MARK: VARS
    var dataArray = [FSModel]()
    var refreshControl: UIRefreshControl?
    var discardedArr : Results<DiscardModel>?
    var pointNow: CGPoint = CGPoint(x: 0, y: 0)
    var buttonTextArr = ["All","Drinks","Breakfast","Lunch","Dinner","Coffee","Snacks","Nightlife"]

    //MARK: VIEW LIFECYLCE
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        trendingTable.dataSource = self
        trendingTable.delegate = self
        //add pull to refresh
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(TrendingViewController.loadDataRF), for: .valueChanged)
        trendingTable.addSubview(refreshControl!)
        //register search notif
        NotificationCenter.default.addObserver(self, selector: #selector(TrendingViewController.loadData), name: NSNotification.Name(rawValue: SearchActionNotif), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TrendingViewController.clearArr), name: NSNotification.Name(rawValue: ClearArrNotif), object: nil)
        
        trendingTable.separatorColor = UIColor.darkGray
        //dynamic cell height
        trendingTable.estimatedRowHeight = 95
        trendingTable.rowHeight = UITableViewAutomaticDimension
        //quick action scrollview
        let scrollView = UIScrollView(frame: CGRect(x: quickActionView.frame.origin.x, y: quickActionView.frame.origin.y, width: self.view.frame.width, height: 60))
        var frame : CGRect?
        for i in 0..<buttonTextArr.count {
            
            let button = UIButton(type: .custom)
            if i == 0 {
                
                frame = CGRect(x: 10, y: 28, width: 85, height: 25)
                
            }else{
                
                frame = CGRect(x: CGFloat(i * 120), y: 28, width: 85, height: 25)
            }
            
            button.frame = frame!
            button.titleLabel?.font = UIFont(name: "Helvetica-Bold", size: 14)
            button.layer.cornerRadius = 5
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.white.cgColor
            button.setTitleColor(UIColor.white, for: .normal)
            
            switch i {
            case 0 :
                button.setTitle(buttonTextArr[i], for: .normal)
                
            case 1 :
                button.setTitle(buttonTextArr[i], for: .normal)
                
            case 2 :
                button.setTitle(buttonTextArr[i], for: .normal)
                
            case 3 :
                button.setTitle(buttonTextArr[i], for: .normal)
                
            case 4 :
                button.setTitle(buttonTextArr[i], for: .normal)
                
            case 5 :
                button.setTitle(buttonTextArr[i], for: .normal)
                
            case 6 :
                button.setTitle(buttonTextArr[i], for: .normal)
                
            case 7 :
                button.setTitle(buttonTextArr[i], for: .normal)
                
            default:
                button.setTitle("Button \(i)", for: .normal)
                
            }
            button.tag = i
            button.backgroundColor = UIColor.clear
            button.addTarget(self, action: #selector(TrendingViewController.quickActionCall(sender:)), for: .touchUpInside)
            scrollView.addSubview(button)
            trendingTable.separatorStyle = .none
            
        }
        
        //setup scrollview
        scrollView.contentSize = CGSize(width: 1000, height: scrollView.frame.size.height)
        scrollView.backgroundColor = UIColor.clear
        scrollView.tag = 99
        self.quickActionView.addSubview(scrollView)
        
        //check for condition when location is fetched by api not called
        if appDelegateObj.stringCoord.count != 0 {
            if appDelegateObj.stringCoord[0].characters.count > 1 {
                if dataArray.count == 0 {
                    loadData(notif: nil)
                }
            }
        }
        queryForDiscardedVenues()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if appDelegateObj.forceReload == true {
            
            appDelegateObj.forceReload = false
            loadData(notif: nil)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    //MARK: REALM QUERY
    func queryForDiscardedVenues(){
        
        //query for all reviews of this venue
        let realm = try! Realm()
        discardedArr = realm.objects(DiscardModel.self).sorted(byProperty: "dDateStr")
        print("Realm discarded venues: \(discardedArr)")
        
    }
    
    
    
    func quickActionCall(sender: AnyObject){
        
        if appDelegateObj.searchModeFlag == false {
            
            let scrollView = self.view.viewWithTag(99) as? UIScrollView
            print(sender.tag)
            for i in 0..<buttonTextArr.count {
                
                let button = scrollView?.viewWithTag(i) as? UIButton
                button!.titleLabel?.font = UIFont(name: "Helvetica-Bold", size: 14)
                button!.layer.borderWidth = 1
                
            }
            
            let currentButton = sender as? UIButton
            if currentButton != nil {
                self.clearArr()
                currentButton!.titleLabel?.font = UIFont(name: "HelveticaNeue-CondensedBlack", size: 17)
                currentButton!.layer.borderWidth = 2
                currentButton!.layer.borderColor = UIColor.white.cgColor
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: SearchActionNotif), object: currentButton!.titleLabel?.text ?? "", userInfo: nil)
                
            }

        }else{
            
            //no action when in seach view
            
        }
    }
    
    func clearArr(){
        
        if appDelegateObj.searchModeFlag == true {
            //hide quick view
            self.quickViewHeightCons.constant = 0
            
        }else{
            //show quick view
            self.quickViewHeightCons.constant = 82
        }
        self.view.layoutIfNeeded()
        //reset the buttons
        let scrollView = self.view.viewWithTag(99) as? UIScrollView
        for i in 0..<buttonTextArr.count {
            
            let button = scrollView?.viewWithTag(i) as? UIButton
            button!.titleLabel?.font = UIFont(name: "Helvetica-Regular", size: 15)
            button!.layer.borderWidth = 1
            
        }
        dataArray.removeAll()
        trendingTable.reloadData()
        
    }
    
    
    //MARK: SERVER CALL
    
    func loadDataRF(){
        
        if appDelegateObj.searchModeFlag == false{
            loadData(notif: nil)
        }else{
            //dont refresh in seach mode
        }
    }
    func loadData(notif:Notification?){
        
        MBProgressHUD.showAdded(to: appDelegateObj.window!, animated: false).label.text = "Loading..."
        let serverReqObj = ServerRequest()
        serverReqObj.delegate = self
        serverReqObj.apiType = ServerRequest.API_TYPES_NAME.get_ExploreData
        
        if notif != nil {
            
            let searchText = notif?.object as? String
            if searchText != nil {
                
                if (searchText?.characters.count)! > 0 {
                    //user searchText in api call
                    serverReqObj.generateUrlRequestWithURLPartParameters(["q":searchText!], postParam: nil)
                }else{
                    serverReqObj.generateUrlRequestWithURLPartParameters(nil, postParam: nil)
                    
                }
                
            }else{
                serverReqObj.generateUrlRequestWithURLPartParameters(nil, postParam: nil)
                
            }
        }else{
            
            serverReqObj.generateUrlRequestWithURLPartParameters(nil, postParam: nil)
            
            
        }
        
        
    }
    
    
}
//MARK: SERVER REQUEST DELEGATE

extension TrendingViewController: ServerRequestDelegate{
    
    
    
    func requestFinishedWithResult(_ responseDictionary: [String : Any], apiCallType: Int, response: URLResponse) {
        
        let resultDict = (responseDictionary["response"] as? CustomDict) ?? ["":""]
        if resultDict["groups"]  != nil {
            
            let resultArray = resultDict["groups"] as! [Any]
            let resultGroup = resultArray[0] as? CustomDict ?? ["":""]
            let resultItems = resultGroup["items"] as? [CustomDict] ?? [["":""]]
            if resultItems.count >  0 {
                
                self.dataArray.removeAll()
                for items in resultItems {
                    
                    let resultVenue = items["venue"] as? CustomDict ?? ["":""]
                    let fsData = FSModel(data: resultVenue)
                    if discardedArr !=  nil {
                        var skipFlag = false
                        for element in discardedArr! {
                            if element.dID == fsData.elementID {
                                skipFlag = true
                            }
                        }
                        
                        if skipFlag == false {
                            self.dataArray.append(fsData)
                        }
                        
                    }else{
                        self.dataArray.append(fsData)
                    }
                }
                
                DispatchQueue.main.async(execute: {
                    MBProgressHUD.hide(for: appDelegateObj.window!, animated: true)
                    self.trendingTable.reloadData()
                    if self.refreshControl?.isRefreshing == true {
                        
                        self.refreshControl?.endRefreshing()
                    }
                    
                    
                })
            }
            
        }
        
        
        
    }
    
    func requestFinishedWithResultArray(_ responseArray: Array<Any>, apiCallType: Int, response: URLResponse) {
        
        DispatchQueue.main.async(execute: {
            MBProgressHUD.hide(for: appDelegateObj.window!, animated: true)
            
            if self.refreshControl?.isRefreshing == true {
                
                self.refreshControl?.endRefreshing()
            }
            
            
        })
        
    }
    
    func requestFinishedWithResponse(_ response: URLResponse, message: String, apiCallType: Int) {
        
        DispatchQueue.main.async(execute: {
            MBProgressHUD.hide(for: appDelegateObj.window!, animated: true)
            
            if self.refreshControl?.isRefreshing == true {
                
                self.refreshControl?.endRefreshing()
            }
            
            
        })
        
    }
    
    func requestFailedWithError(_ error: Error, apiCallType: Int, response: URLResponse?) {
        
        DispatchQueue.main.async(execute: {
            MBProgressHUD.hide(for: appDelegateObj.window!, animated: true)
            
            if self.refreshControl?.isRefreshing == true {
                
                self.refreshControl?.endRefreshing()
            }
            
            if error == CustomError.locationNotFound {
                
                //alert user to do so
                let alertController: UIAlertController = UIAlertController(title: "Kindly allow app to use location in order to function.\nGo to settings -> Privacy -> Location Services -> GrubHound", message: "", preferredStyle: UIAlertControllerStyle.alert)
                let cancelAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)

            }
            
        })
        
    }
    
}


//MARK: TABLE VIEW DELEGATE
extension TrendingViewController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: TrendingViewCell = trendingTable.dequeueReusableCell(withIdentifier: storyBoardID.trendingCell.rawValue) as! TrendingViewCell
        cell = cell.configureCell(dataModel: dataArray[indexPath.row])
        if URL(string: dataArray[indexPath.row].placeIcons) != nil {
            
            let imageObj = UIImage()
            if let imageDataPresent = imageCache.object(forKey: dataArray[indexPath.row].placeIcons as AnyObject) as? NSData {
                let image = UIImage(data: imageDataPresent as Data)
                if image != nil {
                    
                    DispatchQueue.main.async(execute: {
                        cell.iconView.image = image!
                        
                    })
                }
                
                
            }else{
                let serverObj = ServerRequest()
                serverObj.downloadImagefromURL(stringURL: dataArray[indexPath.row].placeIcons, imageObj:imageObj, completion: { (data, resp, error) in
                    
                    if data != nil {
                        
                        let detailImage = UIImage(data: data! as Data)
                        if detailImage != nil {
                            
                            if indexPath.row >= self.dataArray.count {
                                return
                            }else{
                                
                                if self.dataArray.count == 0 {
                                    return
                                }else{
                                    
                                    imageCache.setObject(data!, forKey: (self.dataArray[indexPath.row].placeIcons as AnyObject))
                                    DispatchQueue.main.async(execute: {
                                        
                                        cell.iconView.image = detailImage!
                                    })
                                    
                                }
                            }
                            
                            
                        }
                        
                    }
                })
                
            }
            
            
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if dataArray.count == 0 {
            
            MBProgressHUD.hide(for: appDelegateObj.window!, animated: true)
            return 0
            
        }else{
            MBProgressHUD.hide(for: appDelegateObj.window!, animated: true)
            
            return dataArray.count
            
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //push the detailView
        if appDelegateObj.isTabBarHidden == true {
            
            //show nav notif
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: ShowNavNotif), object: nil)
            
        }

        let detailViewObj = self.storyboard?.instantiateViewController(withIdentifier: storyBoardID.detailVC.rawValue) as! DetailViewController
        detailViewObj.venue_ID = dataArray[indexPath.row].elementID
        self.navigationController?.pushViewController(detailViewObj, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        pointNow = scrollView.contentOffset
    }

    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.bounds.size.height) {
            // Don't animate
        }
        else if scrollView.contentOffset.y < pointNow.y {
            //Upwards Scrolling
            if appDelegateObj.isTabBarHidden == true {
                
                //show nav notif
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: ShowNavNotif), object: nil)

            }
        }
        else if scrollView.contentOffset.y > pointNow.y && scrollView.contentSize.height >= scrollView.bounds.size.height {
            //Downwards Scrolling
            if appDelegateObj.isTabBarHidden == false  && scrollView.contentOffset.y >= 0 && self.pointNow.y >= 0{
                
                //hide notif
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: HideNavNotif), object: nil)
            }
        }
    }
}
