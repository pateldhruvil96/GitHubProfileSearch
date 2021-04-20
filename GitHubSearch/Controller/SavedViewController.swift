//
//  SavedViewController.swift
//  GitHubSearch
//
//  Created by Dhruvil Patel on 4/20/21.
//  Copyright © 2021 Dhruvil Patel. All rights reserved.
//

import UIKit
import CoreData

class SavedViewController: BaseViewController {
    var saveData = [UserDetail]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var userInfoOutcome = [UserInfo]() //consists of  user id , followers's url fetched from CoreData
    var userDataOutcome = [UserData]()  //consists of  user details fetched from CoreData
    
    @IBOutlet weak var tableView: UITableView!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        do{
            userInfoOutcome = try context.fetch(UserInfo.fetchRequest())
            tableView.reloadData()
        }catch{
            print(error)
        }
        
        do{
            userDataOutcome = try context.fetch(UserData.fetchRequest())
            tableView.reloadData()
        }catch{
            print(error)
        }
        if(userInfoOutcome.isEmpty){
            alert(title: "Oops", message: "No saved profile found.Try saving some and come back")
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    func setup(){
        let nibCustomTableViewCell = UINib(nibName: "CustomTableViewCell", bundle: nil)
        tableView.register(nibCustomTableViewCell, forCellReuseIdentifier: "CustomTableViewCell")
        
        tableView.dataSource = self
        tableView.delegate = self
    }
}
extension SavedViewController:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedVC = self.storyboard!.instantiateViewController(withIdentifier: "SelectedUserViewController") as! SelectedUserViewController
        selectedVC.savedData = userDataOutcome[indexPath.row]
        selectedVC.cameFromSavedVC = true
        navigationController?.pushViewController(selectedVC, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIDevice.current.userInterfaceIdiom == .pad ? IPADTABLECELLHEIGHT : IPHONETABLECELLHEIGHT
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userInfoOutcome.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomTableViewCell", for: indexPath) as! CustomTableViewCell
        cell.userNameLabel.text = userInfoOutcome[indexPath.row].login
        cell.configureWith(urlString: userInfoOutcome[indexPath.row].avatar_url!, saveAsCache: true)
        return cell
    }
}

