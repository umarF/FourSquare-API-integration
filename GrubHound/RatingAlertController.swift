//
//  RatingAlertController.swift
//  GrubHound
//
//  Created by Umar Farooque on 19/02/17.
//  Copyright © 2017 ufocorp. All rights reserved.
//

import UIKit
import RealmSwift

/*
 
 THIS CLASS IS USED HANDLING THE POP UP OF THE REVIEW WHICH APPEARS WHEN EDIT (PENCIL) ICON IS CLICKED IN DETAIL VIEW
 
 */


class RatingAlertController: UIViewController {

    //MARK: VIEW OUTLETS
    @IBOutlet weak var reviewField: FloatLabelTextField!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var popupView: ShadowView!
    @IBOutlet weak var popupCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var starRatingView: SwiftyStarRatingView!
    
    //MARK: VARS
    var venueID = ""
    var venueName = ""
    
    //MARK: VIEW LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        starRatingView.allowsHalfStars = false
        starRatingView.maximumValue = 5
        starRatingView.minimumValue = 1
        starRatingView.value = 1
        starRatingView.addTarget(self, action: #selector(RatingAlertController.starViewCallback), for: .valueChanged)
        reviewField.delegate = self
        reviewField.inputAccessoryView = nil
        reviewField.delegate = self
        popupCenterConstraint.constant = 100
        popupView.alpha = 0.0
        backgroundImageView.alpha = 0.0
        let tapToClosePopupGuesture = UITapGestureRecognizer(target: self, action: #selector(RatingAlertController.removeViewAction))
        tapToClosePopupGuesture.numberOfTapsRequired = 1
        backgroundImageView.addGestureRecognizer(tapToClosePopupGuesture)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.reviewField.becomeFirstResponder()
        popupCenterConstraint.constant = -100
        self.view.setNeedsUpdateConstraints()
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions(), animations: { () -> Void in
            self.view.layoutIfNeeded()
            self.popupView.alpha = 1.0
            self.backgroundImageView.alpha = 0.6
            
        }, completion: nil)
        
        

    }
    
    //MARK: VIEW ACTIONS
    func starViewCallback(_ sender:AnyObject){
        
        starRatingView.value = CGFloat(sender.value) 

    }

    func removeViewAction() {
        
        self.reviewField.resignFirstResponder()
        self.reviewField.text = ""
        starRatingView.value = CGFloat(1)
        popupCenterConstraint.constant = 100
        self.view.setNeedsUpdateConstraints()
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.view.layoutIfNeeded()
            self.popupView.alpha = 0.0
            self.backgroundImageView.alpha = 0.0
        }, completion: { (finished) -> Void in
            if finished {
                self.view.removeFromSuperview()
            }
        })
    }

    
    @IBAction func saveReviewButtonAction(_ sender: AnyObject) {

        let reviewTxt =  reviewField.text
        if reviewTxt != nil {
            
            let spaceCleanedTxt = reviewTxt?.replacingOccurrences(of: " ", with: "")
            if (spaceCleanedTxt?.characters.count)! > 5 {
                //save
                let review = ReviewModel()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd MMM YYYY HH:mm"
                let dateString = dateFormatter.string(from: Date())
                review.rDateStr = dateString
                review.rID = venueID
                review.rText = reviewTxt!
                review.rVenueName = venueName
                review.rStar = String(format: "%.0f", starRatingView.value)
                let realm = try! Realm()
                try! realm.write() {
                    realm.add(review)
                    //notif to reload the view data
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: ReloadDetailReviewNotif), object: nil, userInfo: nil)
                    let alertController: UIAlertController = UIAlertController(title: "Your review is posted.", message: "", preferredStyle: UIAlertControllerStyle.alert)
                    let cancelAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true, completion: nil)
                    removeViewAction()
                }

            }else{
                //alert
                let alertController: UIAlertController = UIAlertController(title: "Review should be at least 5 characters long.", message: "", preferredStyle: UIAlertControllerStyle.alert)
                let cancelAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
                

            }
        }else{
            
            //alert
            let alertController: UIAlertController = UIAlertController(title: "Review cannot be posted at the moment.", message: "", preferredStyle: UIAlertControllerStyle.alert)
            let cancelAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
            

        }
    }
    
    

}

//MARK: TEXT FIELD DELEGATE
extension RatingAlertController:UITextFieldDelegate{
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        
        return true
    }
    
    
    
    
}

