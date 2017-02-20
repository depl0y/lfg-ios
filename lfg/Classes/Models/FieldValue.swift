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
public class FieldValue {

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

	//	private var value: Any?

	//private var fieldId: Int?

	public init() {
	}

	public var shouldShow: Bool {
		if self.field?.dataType == .Number && self.number == self.field?.min {
			return false
		}
		return true
	}

	public static func resolve(definition: Definition, fields: [Field]) -> FieldValue? {
		if let id = definition.lid as? Int {
			if let field = fields.first(where: { return $0.lid == id }) {
				let fieldValue = FieldValue()
				fieldValue.field = ObjectDetacher<Field>.detach(object: field)

				if let number = definition.value as? Int, field.dataType == .Number {
					fieldValue.number = number
					return fieldValue
				} else if let optionId = definition.value as? Int, field.dataType == .Option {
					if let option = field.options.first(where: { return $0.lid == optionId }) {
						fieldValue.option = ObjectDetacher<FieldOption>.detach(object: option)
						return fieldValue
					}
				} else if let bool = definition.value as? Bool, field.dataType == .Boolean {
					fieldValue.bool = bool
					return fieldValue
				}
			} else {
				log.error("Field not found \(id)")
			}
		}
		return nil
	}

	public static func resolve(definition: Definition, activity: Activity) -> FieldValue? {
		let fields = activity.allFields()
		return FieldValue.resolve(definition: definition, fields: fields)
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
