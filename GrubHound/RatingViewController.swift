//
//  RatingViewController.swift
//  GrubHound
//
//  Created by Umar Farooque on 16/02/17.
//  Copyright © 2017 ufocorp. All rights reserved.
//

import UIKit
import RealmSwift

/*
 
 THIS CLASS IS USED FOR SHOWING ALL THE REVIEWS THAT ARE STORED LOCALLY
 
 */


class RatingViewController: UIViewController {

    //MARK: OUTLETS
    @IBOutlet weak var emptyListLabel: UILabel!
    @IBOutlet weak var ratingsTable: UITableView!
    
    //MARK: VARS
    var dataArray : Results<ReviewModel>?

    //MARK: VIEW LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //dynamic cell height
        ratingsTable.estimatedRowHeight = 95
        ratingsTable.rowHeight = UITableViewAutomaticDimension
        ratingsTable.separatorStyle = .none
        emptyListLabel.isHidden = true

    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        fetchResults()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: FETCH REALM DATA
    func fetchResults(){
        //query for all reviews of this venue
        let realm = try! Realm()
        dataArray = realm.objects(ReviewModel.self).sorted(byProperty: "rDateStr",ascending: false)
        if dataArray != nil {
            if dataArray!.count > 0 {
                
                emptyListLabel.isHidden = true
                
            }else{
                
                emptyListLabel.isHidden = false

            }
        }else{
            
            emptyListLabel.isHidden = true

        }
        self.ratingsTable.reloadData()

    }
    
    @IBAction func deleteButtonAction(_ sender: Any) {
        
        let alertController: UIAlertController = UIAlertController(title: "Delete rating ?", message: "", preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction: UIAlertAction = UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler: nil)
        alertController.addAction(cancelAction)
        let continueAction = UIAlertAction(title: "Yes", style: .destructive) { (action) in
            if self.dataArray != nil {
                //get the indexPath from button touch
                if sender is UIButton {
                    let applyBtn: UIButton = sender as! UIButton
                    let buttonOrigin: CGPoint = applyBtn.frame.origin
                    let pointInTableView: CGPoint = self.ratingsTable.convert(buttonOrigin, from: applyBtn.superview?.superview)
                    let currentIndex = self.ratingsTable.indexPathForRow(at: pointInTableView)!
                    let currentObj = self.dataArray![currentIndex.row]
                    let realm = try! Realm()
                    try! realm.write {
                        realm.delete(currentObj)
                        self.fetchResults()
                        appDelegateObj.forceReload = true
                        let alertController: UIAlertController = UIAlertController(title: "Removed", message: "", preferredStyle: UIAlertControllerStyle.alert)
                        let cancelAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
                        alertController.addAction(cancelAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
                
            }
        }
        alertController.addAction(continueAction)
        self.present(alertController, animated: true, completion: nil)
        
    }
    
}

//MARK: TABLE VIEW DELEGATES
extension RatingViewController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = ratingsTable.dequeueReusableCell(withIdentifier: storyBoardID.ratingCell.rawValue)
        cell?.selectionStyle = UITableViewCellSelectionStyle.none
        let venueStar = cell?.viewWithTag(10) as? SwiftyStarRatingView
        let venueName = cell?.viewWithTag(1) as? UILabel
        let venueReview = cell?.viewWithTag(2) as? UILabel
        let venueReviewDate = cell?.viewWithTag(3) as? UILabel
        
        if dataArray != nil {
            venueName?.text = dataArray![indexPath.row].rVenueName
            venueReview?.text = dataArray![indexPath.row].rText
            venueReviewDate?.text = dataArray![indexPath.row].rDateStr
            venueStar?.allowsHalfStars = false
            venueStar?.maximumValue = 5
            venueStar?.minimumValue = 1
            venueStar?.value = CGFloat((dataArray![indexPath.row].rStar as NSString).floatValue)
            
        }
        return cell!
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if dataArray ==  nil {
            return 0
            
        }else{
            
            if dataArray!.count == 0 {
                return 0
                
            }else{
                return dataArray!.count
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
       
        
    }
}
