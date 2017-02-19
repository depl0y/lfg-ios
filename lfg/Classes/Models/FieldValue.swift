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

	public static func resolve(definition: Definition, realm: Realm) -> FieldValue? {

		if let id = definition.lid as? Int {
			let fields = realm.objects(Field.self).filter(NSPredicate(format: "lid = %d", id))

			if let field = fields.first {
				let fieldValue = FieldValue()
				fieldValue.field = ObjectDetacher<Field>.detach(object: field)

				if let number = definition.value as? Int, field.dataType == .Number {
					fieldValue.number = number
					return fieldValue
				} else if let optionId = definition.value as? Int, field.dataType == .Option {
					let options = realm.objects(FieldOption.self).filter(NSPredicate(format: "lid = %d", optionId))

					if let option = options.first {
						fieldValue.option = ObjectDetacher<FieldOption>.detach(object: option)
						return fieldValue
					}
				} else if let bool = definition.value as? Bool, field.dataType == .Boolean {
					fieldValue.bool = bool
					return fieldValue
				}
			} else {
				log.error("Could not find field with ID \(id)")
			}
		}
		return nil
	}

	/*
	public required init?(map: Map) {
		if let lid = map.JSON["id"] as? Int {
			if Field.findByValue(value: lid) == nil {
				return nil
			}
		} else {
			return nil
		}
	}
	*/
	/// This will map JSON to the object
	///
	/// - Parameter map: A JSON map
	/*
	public func mapping(map: Map) {
		self.fieldId <- map["id"]
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
		} else {
			log.error("No Field with id \(self.fieldId)")

		}
	}
	*/

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
