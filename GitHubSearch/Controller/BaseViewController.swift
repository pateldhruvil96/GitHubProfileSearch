//
//  BaseViewController.swift
//  GitHubSearch
//
//  Created by Dhruvil Patel on 4/20/21.
//  Copyright © 2021 Dhruvil Patel. All rights reserved.
//

import UIKit
import CoreData
import SafariServices
import SystemConfiguration

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    func genericRetryAlert(retry: ((UIAlertAction) -> Void)? = nil,cancel: ((UIAlertAction) -> Void)? = nil) -> UIAlertController {
        return self.twoButtonAlert(title: "Error",
                                   message: "Some internal error occured. Please retry",
                                   left: cancel,
                                   leftTitle: "Cancel",
                                   right: retry,
                                   rightTitle: "Retry")
    }
    func resetDefaults() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
    }
    func deleteAllRecords(entityName:String) {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print ("There was an error")
        }
    }
    func twoButtonAlert(title: String? = nil,
                        message: String? = nil,
                        left: ((UIAlertAction) -> Void)? = nil,
                        leftStyle: UIAlertAction.Style = .cancel,
                        leftTitle: String? = nil,
                        right: ((UIAlertAction) -> Void)? = nil,
                        rightStyle: UIAlertAction.Style = .default,
                        rightTitle: String? = nil) -> UIAlertController {
        
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: leftTitle, style: leftStyle, handler: left))
        controller.addAction(UIAlertAction(title: rightTitle, style: rightStyle, handler: right))
        
        return controller
    }
    func createSpinnerFooter()->UIView{
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 100))
        let spinner = UIActivityIndicatorView()
        spinner.center  = footerView.center
        footerView.addSubview(spinner)
        spinner.startAnimating()
        return footerView
    }
    func alert(title:String,message:String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction =  UIAlertAction(title: "Ok", style: .default) { (action) in
            self.tabBarController?.selectedIndex = 0
        }
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion:nil)
    }
    func hyperlink(link:String,externalOpen:Bool){
        if let url = URL(string: link) {
            if externalOpen{
                UIApplication.shared.open(url)
            }else{
                let config = SFSafariViewController.Configuration()
                config.entersReaderIfAvailable = true
                
                let vc = SFSafariViewController(url: url, configuration: config)
                present(vc, animated: true)
            }
        }
    }
}
let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
    
    func downloadImage(from imgURL: String,saveAsCache:Bool) -> URLSessionDataTask? {
        
        guard let url = URL(string: imgURL) else { return nil }
        
        // set initial image to nil so it doesn't use the image from a reused cell
        image = nil
        
        // check if the image is already in the cache
        if let imageToCache = imageCache.object(forKey: imgURL as NSString) {
            print("Image from cache")
            self.image = imageToCache
            return nil
        }
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.frame = CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        activityIndicator.startAnimating()
        if self.image == nil{
            self.addSubview(activityIndicator)
        }
        // download the image asynchronously
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let err = error {
                print(err)
                return
            }
            
            DispatchQueue.main.async {
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
                // create UIImage
                let imageToCache = UIImage(data: data!)
                print("Downloaded  picture ")
                // add image to cache
                if saveAsCache{
                imageCache.setObject(imageToCache!, forKey: imgURL as NSString)
                }
                self.image = imageToCache
            }
        }
        task.resume()
        return task
    }
}
public class Reachability {

    class func isConnectedToNetwork() -> Bool {

        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)

        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }

        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }

        // Working for Cellular and WIFI
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)

        return ret

    }
}
