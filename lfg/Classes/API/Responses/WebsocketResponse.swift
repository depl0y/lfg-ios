//
//  WebsocketResponse.swift
//  lfg
//
//  Created by Wim Haanstra on 14/02/2017.
//  Copyright © 2017 Wim Haanstra. All rights reserved.
//

import Foundation
import ObjectMapper

public class WebsocketResponse: Mappable {

	public var remove: Bool = false
	public var request: Request?

	required public init?(map: Map) {
	}

	public func mapping(map: Map) {
		self.remove <- map["remove"]
		self.request <- map["request"]
	}

}
