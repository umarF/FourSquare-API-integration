//
//  DetailViewController.swift
//  GrubHound
//
//  Created by Umar Farooque on 18/02/17.
//  Copyright © 2017 ufocorp. All rights reserved.
//

import UIKit
import MBProgressHUD
import RealmSwift

/*
 
 THIS CLASS IS USED FOR SHOWING THE DETAILS OF THE SELECTED PLACE AND ALSO FOR DISCARDING THE PLACE AND ADDING CUSTOM REVIEWS
 
 */


class DetailViewController: UIViewController {
    
    
    //MARK: OUTLETS
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var reviewTable: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var reviewHeading: NSLayoutConstraint!
    @IBOutlet weak var reviewBlockView: ShadowView!
    @IBOutlet weak var ratingLabelHeightCons: NSLayoutConstraint!
    @IBOutlet weak var ratingLabelTopCons: NSLayoutConstraint!
    
    //MARK: VARS
    var realmDataArray : Results<ReviewModel>?
    var venue_ID = ""
    var counter = 0
    var timer = Timer()
    var dataArray = [FSModel]()
    var detailObj : FSModel?
    var contactNumber: String! = ""
    var shareURL: String! = ""
    var imageArr = [UIImage]()
    
    
    //MARK: View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        reviewTable.separatorStyle = .none
        NotificationCenter.default.addObserver(self, selector: #selector(DetailViewController.reloadData), name: NSNotification.Name(rawValue: ReloadDetailReviewNotif), object: nil)

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        MBProgressHUD.showAdded(to: self.view, animated: true).label.text = "Loading..."
        loadData(notif: nil)
        MBProgressHUD.showAdded(to: self.imageView, animated: true).label.text = ""
        fetchResults()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    //MARK: Realm Fetch
    func fetchResults(){
        
        //query for all reviews of this venue
        let realm = try! Realm()
        realmDataArray = realm.objects(ReviewModel.self).filter("rID = '\(venue_ID)'").sorted(byProperty: "rDateStr",ascending: false)
        print("Realm Reviews: \(realmDataArray)")
        self.reviewTable.reloadData()
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        imageCache.removeAllObjects()
        timer.invalidate()
    }
    
    deinit {
        
        timer.invalidate()
        
    }
    
    //MARK: Server Call
    func loadData(notif:Notification?){
        
        let serverReqObj = ServerRequest()
        serverReqObj.delegate = self
        serverReqObj.apiType = ServerRequest.API_TYPES_NAME.get_VenueDetails
        serverReqObj.generateUrlRequestWithURLPartParameters(["v_id":venue_ID], postParam: nil)
    }
    
    
    //MARK: BUTTON ACTIONS
    
    @IBAction func callButtonAction(_ sender: Any) {
        
        if detailObj != nil, detailObj!.detailNumber.characters.count > 2 {
            
            let phone = "tel://\(detailObj!.detailNumber)"
            let url = URL(string:phone)
            if url != nil {
                UIApplication.shared.openURL(url!)
            }else{
                //no number
                let alertController: UIAlertController = UIAlertController(title: "Number not found.", message: "", preferredStyle: UIAlertControllerStyle.alert)
                let cancelAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
            }
            
        }else{
            
            //no number
            let alertController: UIAlertController = UIAlertController(title: "Number not found.", message: "", preferredStyle: UIAlertControllerStyle.alert)
            let cancelAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
            
        }
        
    }
    
    
    @IBAction func backButtonAction(_ sender: Any) {
        
        _ = self.navigationController?.popToRootViewController(animated: true)
        
    }
    
    @IBAction func reviewButtonAction(_ sender: Any) {
        
        if detailObj != nil {
            
            if venue_ID.characters.count > 1 {
                appDelegateObj.showRatingAlert(id: venue_ID,name: detailObj!.detailName)
            }else{
                //cant write review
                let alertController: UIAlertController = UIAlertController(title: "Review cannot be posted for this venue.", message: "", preferredStyle: UIAlertControllerStyle.alert)
                let cancelAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
                
            }
            
            
            
        }
    }
    
    @IBAction func shareAction(_ sender: Any) {
        
        if detailObj != nil, (detailObj?.detailShareStr.characters.count)! > 2 {
            
            let textToShare = "\(detailObj!.detailName):\n"
            if let appURL = URL(string: self.detailObj!.detailShareStr) {
                let objectsToShare = [textToShare, appURL] as [Any]
                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                self.present(activityVC, animated: true, completion: nil)
                
                
            }else{
                
                let alertController: UIAlertController = UIAlertController(title: "No share link found.", message: "", preferredStyle: UIAlertControllerStyle.alert)
                let cancelAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
                
            }
            
            
        }
        
        
    }
    
    @IBAction func discardButtonAction(_ sender: Any) {
        
        if detailObj != nil {
            
            let alertController: UIAlertController = UIAlertController(title: "Attention!", message: "You won't be able to view the place once discarded.", preferredStyle: UIAlertControllerStyle.alert)
            let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
            let continueAction: UIAlertAction = UIAlertAction(title: "Proceed", style: UIAlertActionStyle.destructive, handler: { (action) -> Void in
                
                let discard = DiscardModel()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd MMM YYYY HH:mm"
                let dateString = dateFormatter.string(from: Date())
                discard.dDateStr = dateString
                discard.dID = self.venue_ID
                discard.dName = self.detailObj!.detailName
                discard.dAddress = self.detailObj!.detailAddress
                let realm = try! Realm()
                try! realm.write() {
                    realm.add(discard)
                    //done
                    //force reload
                    appDelegateObj.forceReload = true
                    let alertController: UIAlertController = UIAlertController(title: "Discarded.", message: "", preferredStyle: UIAlertControllerStyle.alert)
                    let cancelAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true, completion: nil)
                    
                }
                
            })
            
            alertController.addAction(continueAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
            
        }else{
            
            //wait
            let alertController: UIAlertController = UIAlertController(title: "This venue cannot be discarded.", message: "", preferredStyle: UIAlertControllerStyle.alert)
            let cancelAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
            
            
        }
        
        
    }
    
    
    //MARK: Layout Views
    func setupViews(){
        let serverObj = ServerRequest()
        if detailObj != nil {
            DispatchQueue.main.async(execute: {
                
                self.addressLabel.text = self.detailObj!.detailAddress
                self.navigationItem.title = self.detailObj!.detailName
                self.removeLoader(view: self.view)
                if self.detailObj?.detaingRating == "-" {
                    self.ratingLabelTopCons.constant = 0
                    self.ratingLabelHeightCons.constant = 0
                    
                }else{
                    self.ratingLabelTopCons.constant = 18
                    self.ratingLabelHeightCons.constant = 140
                    self.ratingLabel.text = "\n\(self.detailObj!.detaingRating)/10\n\nBased on \(self.detailObj!.detailReviews) ratings\n\n"
                    if self.detailObj!.detailPricing != "-" {
                        
                        let attrributeDarkColor : [String: UIColor] = [NSForegroundColorAttributeName: UIColor.darkGray]
                        let attrributeLightColor : [String: UIColor] = [NSForegroundColorAttributeName: UIColor.lightGray]

                        
                        switch self.detailObj!.detailPricing {
                        case "₹" :
                            let darkpriceAttrString = NSMutableAttributedString(
                                string: "\n\(self.detailObj!.detaingRating)/10\n\nBased on \(self.detailObj!.detailReviews) ratings\n\n₹",
                                attributes: attrributeDarkColor )
                            let lightpriceAttrString = NSMutableAttributedString(
                                string: "₹₹₹₹",
                                attributes: attrributeLightColor)
                            let combination = NSMutableAttributedString()
                            combination.append(darkpriceAttrString)
                            combination.append(lightpriceAttrString)
                            self.ratingLabel.attributedText = combination

                        case "₹₹" :
                            
                            let darkpriceAttrString = NSMutableAttributedString(
                                string: "\n\(self.detailObj!.detaingRating)/10\n\nBased on \(self.detailObj!.detailReviews) ratings\n\n₹₹",
                                attributes: attrributeDarkColor )
                            let lightpriceAttrString = NSMutableAttributedString(
                                string: "₹₹₹",
                                attributes: attrributeLightColor)
                            let combination = NSMutableAttributedString()
                            combination.append(darkpriceAttrString)
                            combination.append(lightpriceAttrString)
                            self.ratingLabel.attributedText = combination

                        case "₹₹₹" :
                            
                            let darkpriceAttrString = NSMutableAttributedString(
                                string: "\n\(self.detailObj!.detaingRating)/10\n\nBased on \(self.detailObj!.detailReviews) ratings\n\n₹₹₹",
                                attributes: attrributeDarkColor )
                            let lightpriceAttrString = NSMutableAttributedString(
                                string: "₹₹",
                                attributes: attrributeLightColor)
                            let combination = NSMutableAttributedString()
                            combination.append(darkpriceAttrString)
                            combination.append(lightpriceAttrString)
                            self.ratingLabel.attributedText = combination

                            
                        case "₹₹₹₹" :
                            
                            let darkpriceAttrString = NSMutableAttributedString(
                                string: "\n\(self.detailObj!.detaingRating)/10\n\nBased on \(self.detailObj!.detailReviews) ratings\n\n₹₹₹₹",
                                attributes: attrributeDarkColor )
                            let lightpriceAttrString = NSMutableAttributedString(
                                string: "₹",
                                attributes: attrributeLightColor)
                            let combination = NSMutableAttributedString()
                            combination.append(darkpriceAttrString)
                            combination.append(lightpriceAttrString)
                            self.ratingLabel.attributedText = combination

                            
                        case "₹₹₹₹₹" :
                            
                            let darkpriceAttrString = NSMutableAttributedString(
                                string: "\n\(self.detailObj!.detaingRating)/10\n\nBased on \(self.detailObj!.detailReviews) ratings\n\n₹₹₹₹₹",
                                attributes: attrributeDarkColor )
                            let lightpriceAttrString = NSMutableAttributedString(
                                string: ".",
                                attributes: attrributeLightColor)
                            let combination = NSMutableAttributedString()
                            combination.append(darkpriceAttrString)
                            combination.append(lightpriceAttrString)
                            self.ratingLabel.attributedText = combination

                            
                        default:
                         
                            let darkpriceAttrString = NSMutableAttributedString(
                                string: "\n\(self.detailObj!.detaingRating)/10\n\nBased on \(self.detailObj!.detailReviews) ratings\n\n₹",
                                attributes: attrributeDarkColor )
                            let lightpriceAttrString = NSMutableAttributedString(
                                string: "₹₹₹₹",
                                attributes: attrributeLightColor)
                            let combination = NSMutableAttributedString()
                            combination.append(darkpriceAttrString)
                            combination.append(lightpriceAttrString)
                            self.ratingLabel.attributedText = combination
                            

                        }
                        
                    }
                }
                self.view.layoutIfNeeded()
                
                if(self.reviewTable.contentSize.height > self.reviewTable.frame.height){
                    var frame: CGRect = self.reviewTable.frame
                    frame.size.height = self.reviewTable.contentSize.height
                    self.reviewTable.frame = frame
                }
                self.view.layoutIfNeeded()
                
                if self.ratingLabelTopCons.constant == 0 {
                    
                    self.scrollView.contentSize = CGSize(width: self.reviewTable.frame.size.width, height: self.scrollView.contentSize.height + self.reviewTable.frame.size.height )
                    
                }else{
                    self.scrollView.contentSize = CGSize(width: self.reviewTable.frame.size.width, height: self.scrollView.contentSize.height + self.reviewTable.frame.size.height)
                    
                }
                self.view.layoutIfNeeded()
                
                if self.detailObj!.detailImgArr.count > 1 {
                    
                    
                    for imgURLs in self.detailObj!.detailImgArr {
                        
                        if URL(string: imgURLs) != nil {
                            
                            let imageObj = UIImage()
                            if let imageDataPresent = imageCache.object(forKey: imgURLs as AnyObject) as? NSData {
                                let image = UIImage(data: imageDataPresent as Data)
                                if image != nil {
                                    
                                    self.imageArr.append(image!)
                                    DispatchQueue.main.async(execute: {
                                        self.imageView.image = image!
                                        self.removeLoader(view: self.imageView)
                                        self.imageView.backgroundColor = UIColor.clear
                                        
                                    })
                                }
                                
                                
                            }else{
                                
                                serverObj.downloadImagefromURL(stringURL: imgURLs, imageObj:imageObj, completion: { (data, resp, error) in
                                    
                                    if data != nil {
                                        
                                        let detailImage = UIImage(data: data! as Data)
                                        if detailImage != nil {
                                            
                                            imageCache.setObject(data!, forKey: (imgURLs as AnyObject))
                                            self.imageArr.append(detailImage!)
                                            DispatchQueue.main.async(execute: {
                                                if self.imageArr.count == 0 {
                                                    
                                                    self.imageView.image = detailImage!
                                                    self.imageView.backgroundColor = UIColor.clear
                                                    self.removeLoader(view: self.imageView)
                                                    
                                                }
                                            })
                                            
                                        }else{
                                            self.removeLoader(view: self.imageView)
                                            
                                        }
                                        
                                    }else{
                                        self.removeLoader(view: self.imageView)
                                    }
                                })
                                
                            }
                            
                        }else{
                            
                            
                        }
                        
                    }
                    
                    //start after X sec
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
                        
                        self.timer.invalidate()
                        self.timer = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(DetailViewController.cycleImages), userInfo: nil, repeats: true)
                        
                    }
                }else{
                    
                    self.removeLoader(view: self.imageView)
                }
                
                
            })
        }
    }
    
    func cycleImages(){
        MBProgressHUD.hide(for: self.imageView, animated: true)
        self.imageView.backgroundColor = UIColor.clear
        
        let count = self.imageArr.count
        if count != 0 {
            
            
            if counter < count {
                
                UIView.transition(with: imageView,
                                  duration: 0.5,
                                  options: .transitionCrossDissolve,
                                  animations: { self.imageView.image = self.imageArr[self.counter] },
                                  completion: nil)
                counter = counter + 1
            }else{
                
                counter = 0
                UIView.transition(with: imageView,
                                  duration: 0.5,
                                  options: .transitionCrossDissolve,
                                  animations: { self.imageView.image = self.imageArr[self.counter] },
                                  completion: nil)
                
                
            }
            
            
        }
    }
    
    func reloadData(){
        fetchResults()
        setupViews()
    }
    
    func removeLoader(view:UIView){
        
        DispatchQueue.main.async(execute: {
            MBProgressHUD.hide(for: view, animated: true)
        })
        
    }
}

//MARK: Server Request Delegate
extension DetailViewController: ServerRequestDelegate{
    
    
    func requestFinishedWithResult(_ responseDictionary: [String : Any], apiCallType: Int, response: URLResponse) {
        
        let resultDict = ((responseDictionary["response"] as? [String:Any])?["venue"] as! [String : Any])
        detailObj = FSModel(withDetailDict: resultDict)
        setupViews()
    }
    
    func requestFinishedWithResultArray(_ responseArray: Array<Any>, apiCallType: Int, response: URLResponse) {
        
        self.removeLoader(view: self.imageView)
        self.removeLoader(view: self.view)
    }
    
    func requestFinishedWithResponse(_ response: URLResponse, message: String, apiCallType: Int) {
        
        self.removeLoader(view: self.imageView)
        self.removeLoader(view: self.view)
    }
    
    
    func requestFailedWithError(_ error: Error, apiCallType: Int, response: URLResponse?) {
        
        self.removeLoader(view: self.imageView)
        self.removeLoader(view: self.view)
    }
    
    
}

//MARK: Table View Delegate

extension DetailViewController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: ReviewCell = reviewTable.dequeueReusableCell(withIdentifier: storyBoardID.reviewCell.rawValue) as! ReviewCell
        cell = cell.configureCell(dataModel: realmDataArray![indexPath.row])
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if realmDataArray == nil {
            
            reviewHeading.constant = 0
            self.reviewBlockView.isHidden = true
            self.view.layoutIfNeeded()
            return 0
            
        }else{
            
            if realmDataArray!.count == 0 {
                reviewHeading.constant = 0
                self.reviewBlockView.isHidden = true
                self.view.layoutIfNeeded()
                return 0
                
            }else{
                reviewHeading.constant = 42
                self.reviewBlockView.isHidden = false
                self.view.layoutIfNeeded()
                return realmDataArray!.count
            }
            
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
    }
    
    
}
