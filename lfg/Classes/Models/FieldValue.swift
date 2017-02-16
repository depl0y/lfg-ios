//
//  FieldValue.swift
//  lfg
//
//  Created by Wim Haanstra on 11/02/2017.
//  Copyright © 2017 Wim Haanstra. All rights reserved.
//
import Foundation
import ObjectMapper
import RealmSwift
import Realm

/// This class stores values of a request, together with the field they are for
public class FieldValue: Mappable {

	/// The field for this value
	public var field: Field?

	/// If the datatype is an option, the option will be stored here
	public var option: FieldOption?

	/// If the datatype is a string, stored here
	public var stringValue: String?

	/// If the datatype is an integer, stored here
	public var number: Int?

	/// If the datatype is a boolean, stored here
	public var bool: Bool?

	private var value: Any?

	public required init?(map: Map) {
		if let lid = map.JSON["id"] as? Int {
			if Field.findByValue(value: lid) == nil {
				return nil
			}
		} else {
			return nil
		}
	}

	/// This will map JSON to the object
	///
	/// - Parameter map: A JSON map
	public func mapping(map: Map) {
		self.field <-  (map["id"], ValueFinderTransformer<Field>())
		self.value <- map["value"]

		if self.field != nil {
			self.field = Field(value: self.field!, schema: RLMSchema(objectClasses: [
				Field.self,
				FieldGroup.self,
				Activity.self,
				FieldOption.self,
				ActivityGroup.self
				]))

			if self.value != nil {
				if field!.dataType == .Option {
					if let option = FieldOption.findByValue(value: self.value!) {
						self.option = FieldOption(value: option, schema: RLMSchema(objectClasses: [
							Field.self,
							FieldGroup.self,
							Activity.self,
							FieldOption.self,
							ActivityGroup.self
							]))
					}
				} else if field!.dataType == .Number {
					if let number = self.value as? Int {
						self.number = number
					}
				} else if field!.dataType == .Boolean {
					if let bool = self.value as? Bool {
						self.bool = bool
					}
				}
			}
		}
	}

	public func toString() -> String {
		if field != nil {
			if field!.dataType == .Option && self.option != nil {
				return self.option!.name
			} else if field!.dataType == .Number && self.number != nil {
				return "\(self.number!)"
			} else if field!.dataType == .Boolean {
				if self.bool != nil && self.bool! {
					return "yes"
				} else {
					return "no"
				}
			} else {
				return ""
			}
		} else {
			return ""
		}
	}
}

public func == (lhs: FieldValue, rhs: FieldValue) -> Bool {
	if lhs.field == nil || rhs.field == nil {
		return true
	}

	return lhs.field!.lid == rhs.field!.lid
}
