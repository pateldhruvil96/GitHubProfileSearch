//
//  Model.swift
//  GitHubSearch
//
//  Created by Dhruvil Patel on 4/20/21.
//  Copyright © 2021 Dhruvil Patel. All rights reserved.
//

import Foundation
struct Result:Codable {
    let total_count:Int?
    let incomplete_results:Bool?
    var items : [Outcome]?
}
struct Outcome:Codable{
    let login : String?
    let avatar_url : String?
    let followers_url : String?
}
struct UserDetail:Codable {
    let html_url : String?
    let avatar_url : String?
    let followers_url : String?
    let name : String?
    let location : String?
    let followers : Int?
    let following : Int?
    let public_repos : Int?
}
