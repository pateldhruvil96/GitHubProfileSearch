//
//  SelectedUserViewController.swift
//  GitHubSearch
//
//  Created by Dhruvil Patel on 4/20/21.
//  Copyright © 2021 Dhruvil Patel. All rights reserved.
//

import UIKit
import CoreData

class SelectedUserViewController: BaseViewController {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var repoLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var profileLinkLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    var userName = ""
    var followersUrlString = ""
    var Userdata : UserDetail?
    var profileImageURLString = ""
    var currentAPITask: URLSessionDataTask?
    var savedUserDetail: Outcome? //consists of  user id, imageUrl , followers's url
    var index = 0
    var savedIndexArray = [String]()
    var savedImage = UIImage()
    var cameFromSavedVC = Bool()
    var savedData:UserData? //consists of  user details
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.largeTitleDisplayMode = .never
        self.navigationItem.title = userName
        
        let hyperLinkTap = UITapGestureRecognizer(target: self, action: #selector(tapFunction(gesture:)))
        profileLinkLabel.isUserInteractionEnabled = true
        hyperLinkTap.name = "hyperLinkTap"
        profileLinkLabel.addGestureRecognizer(hyperLinkTap)
        
        if cameFromSavedVC{
            nameLabel.text?.append(savedData?.name ?? "Not Provided")
            repoLabel.text?.append(String(savedData?.public_repos ?? 0))
            locationLabel.text?.append(savedData?.location ?? "Not Provided")
            followingLabel.text?.append(String(savedData?.following ?? 0))
            followersLabel.text?.append(String(savedData?.followers ?? 0))
            profileLinkLabel.text?.append(savedData?.html_url ?? "")
            
            //Converting UILabel text to link format
            let attributedString = NSMutableAttributedString(string: profileLinkLabel.text ?? "")
            attributedString.addAttribute(.link, value: savedData?.html_url ?? "", range: NSRange(location: 14, length: savedData?.html_url?.count ?? 0))
            profileLinkLabel.attributedText = attributedString
            
            profileImageView.downloadImage(from: savedData?.avatar_url ?? "", saveAsCache: true)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    func setup(){
        if !cameFromSavedVC{
            savedIndexArray =  UserDefaults.standard.object(forKey: "savedIndexArray") as? [String] ?? []
            if !savedIndexArray.contains(userName){
                navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(addTapped))
            }else{
                navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Saved", style: .plain, target: self, action: nil)
            }
            
            let tapFollowersLabel = UITapGestureRecognizer(target: self, action: #selector(tapFunction(gesture:)))
            followersLabel.isUserInteractionEnabled = true
            followersLabel.addGestureRecognizer(tapFollowersLabel)
            
            callAPI()
        }
    }
    @objc func addTapped(sender: UIBarButtonItem){
        navigationItem.rightBarButtonItem?.title = "Saved"
        savedIndexArray.append(userName)
        UserDefaults.standard.set(savedIndexArray, forKey: "savedIndexArray")
        
        //Saving user information to CoreData
        let userInfo  = UserInfo(context: context)
        userInfo.avatar_url = savedUserDetail?.avatar_url
        userInfo.login = savedUserDetail?.login
        do{
            try context.save()
        }catch{
            print(error)
        }
        
        let userData  = UserData(context: context)
        userData.followers = Int64((Userdata?.followers)!)
        userData.following = Int64((Userdata?.following)!)
        userData.name = Userdata?.name
        userData.location = Userdata?.location
        userData.public_repos = Int64((Userdata?.public_repos)!)
        userData.avatar_url = Userdata?.avatar_url
        userData.html_url = Userdata?.html_url
        do{
            try context.save()
        }catch{
            print(error)
        }
        
        
    }
    @IBAction func tapFunction(gesture: UITapGestureRecognizer) {
        if gesture.name == "hyperLinkTap"{
            hyperlink(link: cameFromSavedVC ? savedData?.html_url ?? "" : Userdata?.html_url ?? "", externalOpen: false)
        }else if(Userdata?.followers != nil && Userdata?.followers != 0){
            let selectedVC = self.storyboard!.instantiateViewController(withIdentifier: "UserDetailsViewController") as! UserDetailsViewController
            selectedVC.link = Userdata?.followers_url ?? ""
            navigationController?.pushViewController(selectedVC, animated: true)
        }
    }
    func callAPI(){
        guard let url = URL(string: "https://api.github.com/users/\(userName)") else {
            return
        }
        self.currentAPITask?.cancel()
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.frame = CGRect.init(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        activityIndicator.startAnimating()
        let tempView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        tempView.backgroundColor = UIColor.white
        view.addSubview(tempView)
        view.addSubview(activityIndicator)
        
        currentAPITask = APIConnection.shared.makeRequest(toURL: url, params: ["": ""], method: .Get) { [weak self] (error, data) in
            activityIndicator.stopAnimating()
            tempView.removeFromSuperview()
            activityIndicator.removeFromSuperview()
            if let err = error {
                print("got error \(err)")
                let alertController = self?.genericRetryAlert(retry:  { (action) in
                    self?.callAPI()
                })
                self?.present(alertController ?? UIAlertController(), animated: true, completion: nil)
                return
            }
            
            guard let responseData = data else {
                let alertController = self?.genericRetryAlert(retry:  { (action) in
                    self?.callAPI()
                })
                self?.present(alertController ?? UIAlertController(), animated: true, completion: nil)
                return
            }
            
            let jsonDecoder = JSONDecoder()
            let responseModel = try? jsonDecoder.decode(UserDetail.self, from: responseData)
            self?.Userdata = responseModel
            self?.nameLabel.text?.append(responseModel?.name ?? "Not Provided")
            self?.repoLabel.text?.append(String(responseModel?.public_repos ?? 0))
            self?.locationLabel.text?.append(responseModel?.location ?? "Not Provided")
            self?.followingLabel.text?.append(String(responseModel?.following ?? 0))
            
            self?.followersLabel.text?.append(String(responseModel?.followers ?? 0))
            if responseModel?.followers != nil && responseModel?.followers != 0{
                self?.followersLabel.text?.append("(Click for more info)")
                
                //Converting UILabel text to link format
                let followersLabelAttributedString = NSMutableAttributedString(string: (self?.followersLabel.text ?? ""))
                followersLabelAttributedString.addAttribute(.link, value: responseModel?.followers_url ?? "", range: NSRange(location: (self?.followersLabel.text?.count ?? 21) - 21, length: 21))
                self?.followersLabel.attributedText = followersLabelAttributedString
            }
            self?.profileLinkLabel.text?.append(responseModel?.html_url ?? "")
            
            //Converting UILabel text to link format
            let attributedString = NSMutableAttributedString(string: self?.profileLinkLabel.text ?? "")
            attributedString.addAttribute(.link, value: responseModel?.html_url ?? "", range: NSRange(location: 14, length: responseModel?.html_url?.count ?? 0))
            self?.profileLinkLabel.attributedText = attributedString
            
            self?.profileImageView.downloadImage(from: self?.profileImageURLString ?? "", saveAsCache: true)
            
        }
    }
    
    
    
}
