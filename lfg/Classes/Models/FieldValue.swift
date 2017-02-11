//
//  FieldValue.swift
//  lfg
//
//  Created by Wim Haanstra on 11/02/2017.
//  Copyright © 2017 Wim Haanstra. All rights reserved.
//

import Foundation
import ObjectMapper

public class FieldValue: Mappable {

	public var field: Field!

	public var idType: Any?

	public var option: FieldOption?
	public var value: String?
	public var number: Int?
	public var bool: Bool?

	public required init?(map: Map) {
	}

	public func mapping(map: Map) {
		self.idType <- map["id"]

		if let vid = self.idType as? Int {
			self.field <- (map["id"], ValueFinderTransformer<Field>())
		} else if let vid = self.idType as? String {
			log.debug("\(vid) is string, parse exception")
		}

	}
}
