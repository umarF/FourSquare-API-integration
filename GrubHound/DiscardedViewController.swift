//
//  DiscardedViewController.swift
//  GrubHound
//
//  Created by Umar Farooque on 16/02/17.
//  Copyright © 2017 ufocorp. All rights reserved.
//

import UIKit
import RealmSwift

/*
 
 THIS CLASS IS USED FOR SHOWING ALL THE DISCARDED PLACES THAT ARE STORED LOCALLY AND NOT SHOWN IN THE TRENDING VIEW 
 
 */


class DiscardedViewController: UIViewController {

    //MARK: OUTLETS
    @IBOutlet weak var emptyListLabel: UILabel!
    @IBOutlet weak var discardedTable: UITableView!
    
    //MARK: VARS
    var dataArray : Results<DiscardModel>?

    //MARK:VIEW LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //dynamic cell height
        discardedTable.estimatedRowHeight = 95
        discardedTable.rowHeight = UITableViewAutomaticDimension
        discardedTable.separatorStyle = .none
        emptyListLabel.isHidden = true
        //hide navbar notif

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchResults()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: REALM QUERY
    func fetchResults(){
        
        //query for all reviews of this venue
        let realm = try! Realm()
        dataArray = realm.objects(DiscardModel.self).sorted(byProperty: "dDateStr",ascending: false)
        if dataArray != nil {
            if dataArray!.count > 0 {
                
                emptyListLabel.isHidden = true
                
            }else{
                
                emptyListLabel.isHidden = false
                
            }
        }else{
            
            emptyListLabel.isHidden = true
            
        }
        self.discardedTable.reloadData()
        
    }
    
    @IBAction func deleteButtonAction(_ sender: Any) {
        
        let alertController: UIAlertController = UIAlertController(title: "Remove from discard list ?", message: "", preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction: UIAlertAction = UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler: nil)
        alertController.addAction(cancelAction)
        let continueAction = UIAlertAction(title: "Yes", style: .destructive) { (action) in
            
            if self.dataArray != nil {
                //get the indexPath from button touch
                if sender is UIButton {
                    let applyBtn: UIButton = sender as! UIButton
                    let buttonOrigin: CGPoint = applyBtn.frame.origin
                    let pointInTableView: CGPoint = self.discardedTable.convert(buttonOrigin, from: applyBtn.superview?.superview)
                    let currentIndex = self.discardedTable.indexPathForRow(at: pointInTableView)!
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

//MARK:TABLE VIEW DELEGATE
extension DiscardedViewController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: DiscardViewCell = discardedTable.dequeueReusableCell(withIdentifier: storyBoardID.discardCell.rawValue) as! DiscardViewCell
        cell = cell.configureCell(dataModel: dataArray![indexPath.row])
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if dataArray == nil {
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
