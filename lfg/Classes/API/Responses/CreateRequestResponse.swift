//
//  CreateRequestResponse.swift
//  lfg
//
//  Created by Wim Haanstra on 20/02/2017.
//  Copyright © 2017 Wim Haanstra. All rights reserved.
//

import Foundation
import ObjectMapper

public class CreateRequestResponse: Mappable {

	public var lid: String = ""
	public var loggedIn: Bool = false
	public var message: String = ""
	public var diff: Int = 0

	public required init?(map: Map) {
	}

	public func mapping(map: Map) {
		self.lid <- map["id"]
		self.loggedIn <- map["logged_in"]
	}
}
