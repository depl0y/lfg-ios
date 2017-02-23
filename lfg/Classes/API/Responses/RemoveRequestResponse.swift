//
//  RemoveRequestResponse.swift
//  lfg
//
//  Created by Wim Haanstra on 20/02/2017.
//  Copyright © 2017 Wim Haanstra. All rights reserved.
//

import Foundation
import ObjectMapper

public class RemoveRequestResponse: Mappable {
	public var status: String = ""

	public required init?(map: Map) {
	}

	public func mapping(map: Map) {

		self.status <- map["status"]
	}
}
