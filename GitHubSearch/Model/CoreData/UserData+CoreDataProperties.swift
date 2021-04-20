//
//  UserData+CoreDataProperties.swift
//  GitHubSearch
//
//  Created by Dhruvil Patel on 4/20/21.
//  Copyright © 2021 Dhruvil Patel. All rights reserved.
//

import Foundation
import CoreData


extension UserData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserData> {
        return NSFetchRequest<UserData>(entityName: "UserData")
    }

    @NSManaged public var name: String?
    @NSManaged public var location: String?
    @NSManaged public var avatar_url: String?
    @NSManaged public var html_url: String?
    @NSManaged public var public_repos: Int64
    @NSManaged public var followers: Int64
    @NSManaged public var following: Int64

}

extension UserData : Identifiable {

}
