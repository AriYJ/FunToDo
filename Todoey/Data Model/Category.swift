//
//  Category.swift
//  Todoey
//
//  Created by Ari Jane on 5/23/20.
//  Copyright © 2020 Ari Jane. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var color: String = "1D9BF6"
    let items = List<Item>() //establishing foward relationship with the Item class, to many
}
