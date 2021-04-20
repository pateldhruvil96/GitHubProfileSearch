//
//  UserDetailsViewController.swift
//  GitHubSearch
//
//  Created by Dhruvil Patel on 4/20/21.
//  Copyright © 2021 Dhruvil Patel. All rights reserved.
//

import UIKit

class UserDetailsViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var results = [Outcome]() //consists of  user id, imageUrl , followers's url
    var link = ""
    var lastPageNumberLoaded: Int = -1
    var currentAPITask: URLSessionDataTask?
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        
    }
    deinit {
        results.removeAll()
    }
    func setup(){
        self.navigationItem.largeTitleDisplayMode = .never
        self.navigationItem.title = "Followers"
        
        callAPI(isUserScrolled: false)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        let nibCustomTableViewCell = UINib(nibName: "CustomTableViewCell", bundle: nil)
        tableView.register(nibCustomTableViewCell, forCellReuseIdentifier: "CustomTableViewCell")
    }
    func callAPI(isUserScrolled:Bool){
        self.currentAPITask?.cancel()
        guard let url = URL(string: link) else {
            return
        }
        lastPageNumberLoaded = isUserScrolled ? lastPageNumberLoaded + 1 : 1
        currentAPITask  = APIConnection.shared.makeRequest(toURL: url, params: ["page": "\(lastPageNumberLoaded)"], method: .Get) { [weak self] (error, data) in
            if let err = error {
                //Show error
                print("got error \(err)")
                let alertController = self?.genericRetryAlert(retry:  { (action) in
                    self?.callAPI(isUserScrolled: isUserScrolled)
                })
                self?.present(alertController ?? UIAlertController(), animated: true, completion: nil)
                return
            }
            
            guard let responseData = data else {
                let alertController = self?.genericRetryAlert(retry:  { (action) in
                    self?.callAPI(isUserScrolled: isUserScrolled)
                })
                self?.present(alertController ?? UIAlertController(), animated: true, completion: nil)
                return
            }
            
            let jsonDecoder = JSONDecoder()
            let responseModel = try? jsonDecoder.decode([Outcome].self, from: responseData)
            if let resp = responseModel {
                if isUserScrolled{
                    self?.tableView.tableFooterView  = nil
                    self?.results.append(contentsOf: resp)
                }else{
                    self?.results = resp
                }
                self?.tableView.reloadData()
                
            }
            
        }
    }
}
extension UserDetailsViewController:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIDevice.current.userInterfaceIdiom == .pad ? IPADTABLECELLHEIGHT : IPHONETABLECELLHEIGHT
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomTableViewCell", for: indexPath) as! CustomTableViewCell
        cell.userNameLabel.text = results[indexPath.row].login
        cell.configureWith(urlString: results[indexPath.row].avatar_url!, saveAsCache: false)
        cell.rightImageArrow.isHidden = true
        return cell
    }
}
extension UserDetailsViewController:UIScrollViewDelegate{
    //Pagination:
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let bottomEdge = scrollView.contentOffset.y + scrollView.frame.height
        if bottomEdge >= scrollView.contentSize.height{//We reached bottom
            self.tableView.tableFooterView = createSpinnerFooter()
            callAPI(isUserScrolled: true)
        }
        
    }
}

