//
//  Note+CoreDataProperties.swift
//  Wordbook
//
//  Created by Jerry on 16/4/25.
//  Copyright © 2016年 Jerry Wong. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Note {

    @NSManaged var audio: NSData?
    @NSManaged var audioUrl: String?
    @NSManaged var definition: String?
    @NSManaged var enDefinition: String?
    @NSManaged var pronunciation: String?
    @NSManaged var time: NSDate?
    @NSManaged var title: String?
    @NSManaged var type: NSNumber?
    @NSManaged var tag: NSNumber?

}
