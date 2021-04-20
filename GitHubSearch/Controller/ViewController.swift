//
//  ViewController.swift
//  GitHubSearch
//
//  Created by Dhruvil Patel on 4/20/21.
//  Copyright © 2021 Dhruvil Patel. All rights reserved.
//

import UIKit

class ViewController: BaseViewController, UISearchBarDelegate {
    let seachController  = UISearchController()
    var currentAPITask: URLSessionDataTask?
    var results = [Outcome]() //consists of  user id, imageUrl , followers's url
    var lastText = ""
    var lastPageNumberLoaded: Int = -1
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    func setup(){
        //If wanted to delete data from CoreData & UserDefaults uncomment below code
              // deleteAllRecords(entityName: "UserInfo")
               // deleteAllRecords(entityName: "UserData")
             //   resetDefaults()
        title = "GitHub Search"
        seachController.searchBar.delegate = self
        navigationItem.searchController = seachController
        seachController.obscuresBackgroundDuringPresentation = false;
        
        
        let nibCustomTableViewCell = UINib(nibName: "CustomTableViewCell", bundle: nil)
        tableView.register(nibCustomTableViewCell, forCellReuseIdentifier: "CustomTableViewCell")
        
        tableView.dataSource = self
        tableView.delegate = self
        
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if Reachability.isConnectedToNetwork(){
            lastText = searchText
            self.currentAPITask?.cancel()
            callAPI(isUserScrolled: false)
        }else{
            alert(title: "Oops", message: "Not connected with internet")
        }
        
    }
    func callAPI(isUserScrolled:Bool){
        guard let url = URL(string: BASEURL) else {
            return
        }
        if lastText.isEmpty{
            self.currentAPITask?.cancel()
            self.results.removeAll()
            self.tableView.reloadData()
            lastPageNumberLoaded = -1
        }else{
            lastPageNumberLoaded = isUserScrolled ? lastPageNumberLoaded + 1 : 1
            
            self.currentAPITask = APIConnection.shared.makeRequest(toURL: url, params: ["q": lastText, "sort": "followers","page":"\(lastPageNumberLoaded)"], method: .Get) { [weak self] (error, data) in
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
                let responseModel = try? jsonDecoder.decode(Result.self, from: responseData)
                if let resp = responseModel {
                    if let items = resp.items {
                        if isUserScrolled{
                            self?.tableView.tableFooterView  = nil
                            self?.results.append(contentsOf: items)
                        }else{
                            self?.results = items
                        }
                        self?.tableView.reloadData()
                    }
                }
            }
        }
    }
    
}
extension ViewController:UIScrollViewDelegate{
    //Pagination:
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let bottomEdge = scrollView.contentOffset.y + scrollView.frame.height
        if bottomEdge >= scrollView.contentSize.height{//We reached bottom
            if !lastText.isEmpty{
                self.tableView.tableFooterView = createSpinnerFooter()
                callAPI(isUserScrolled: true)
            }
        }
    }
}
extension ViewController:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedVC = self.storyboard!.instantiateViewController(withIdentifier: "SelectedUserViewController") as! SelectedUserViewController
        selectedVC.savedUserDetail = results[indexPath.row]
        selectedVC.userName = results[indexPath.row].login ?? "Not Provided"
        selectedVC.followersUrlString = results[indexPath.row].followers_url ?? ""
        selectedVC.profileImageURLString = results[indexPath.row].avatar_url ?? ""
        selectedVC.index = indexPath.row
        
        navigationController?.pushViewController(selectedVC, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIDevice.current.userInterfaceIdiom == .pad ? IPADTABLECELLHEIGHT : IPHONETABLECELLHEIGHT
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomTableViewCell", for: indexPath) as! CustomTableViewCell
        cell.userNameLabel.text = results[indexPath.row].login
        cell.configureWith(urlString: results[indexPath.row].avatar_url!, saveAsCache: true)
        return cell
    }
}


