//
//  FieldValue.swift
//  lfg
//
//  Created by Wim Haanstra on 11/02/2017.
//  Copyright © 2017 Wim Haanstra. All rights reserved.
//
import Foundation
import ObjectMapper

/// This class stores values of a request, together with the field they are for
public class FieldValue: Mappable {

	/// The field for this value
	public var field: Field!

	/// Variable used for determening the type of value stored
	public var idType: Any?

	/// If the datatype is an option, the option will be stored here
	public var option: FieldOption?

	/// If the datatype is a string, stored here
	public var stringValue: String?

	/// If the datatype is an integer, stored here
	public var number: Int?

	/// If the datatype is a boolean, stored here
	public var bool: Bool?

	public required init?(map: Map) {
	}

	/// This will map JSON to the object
	///
	/// - Parameter map: A JSON map
	public func mapping(map: Map) {
		self.idType <- map["id"]

		if self.idType as? Int != nil {
			self.field <- (map["id"], ValueFinderTransformer<Field>())
		} else if self.idType as? String != nil {
			//log.debug("\(vid) is string, parse exception")
		}

	}
}
