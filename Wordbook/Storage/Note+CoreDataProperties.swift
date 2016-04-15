//
//  Note+CoreDataProperties.swift
//  Wordbook
//
//  Created by Jerry on 16/4/15.
//  Copyright © 2016年 Jerry Wong. All rights reserved.

import Foundation
import CoreData

extension Note {

    @NSManaged var type: NSNumber?
    @NSManaged var title: String?
    @NSManaged var time: NSDate?
    @NSManaged var definition: String?

}
