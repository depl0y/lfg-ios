//
//  Language.swift
//  lfg
//
//  Created by Wim Haanstra on 08/02/2017.
//  Copyright © 2017 Wim Haanstra. All rights reserved.
//

import Foundation
import RealmSwift

public class Language: Object {

	dynamic var lid: Int = 0
	dynamic var identifier: String = ""
	dynamic var title: String = ""

	public override static func primaryKey() -> String? {
		return "lid"
	}
}
