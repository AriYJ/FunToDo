//
//  Item.swift
//  Todoey
//
//  Created by Ari Jane on 5/23/20.
//  Copyright © 2020 Ari Jane. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date?
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items") //reverse relationship, to one
}
