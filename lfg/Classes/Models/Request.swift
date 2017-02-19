//
//  Request.swift
//  lfg
//
//  Created by Wim Haanstra on 11/02/2017.
//  Copyright © 2017 Wim Haanstra. All rights reserved.
//

import Foundation
import ObjectMapper
import Realm
import RealmSwift

public class Definition: Mappable {

	dynamic var lid: Any = -1
	dynamic var value: Any = 0

	public func mapping(map: Map) {
		self.lid <- map["id"]
		self.value <- map["value"]
	}

	public required init?(map: Map) {
	}
}

public class Request: Mappable, Equatable, Hashable, Comparable {
	/// Returns a Boolean value indicating whether the value of the first
	/// argument is less than that of the second argument.
	///
	/// This function is the only requirement of the `Comparable` protocol. The
	/// remainder of the relational operator functions are implemented by the
	/// standard library for any type that conforms to `Comparable`.
	///
	/// - Parameters:
	///   - lhs: A value to compare.
	///   - rhs: Another value to compare.
	public static func < (lhs: Request, rhs: Request) -> Bool {
		return lhs.timeStamp > rhs.timeStamp
	}

	public var activityGroup: ActivityGroup?

	public var lid: String = ""

	public var isPlanned: Bool = false
	public var lfg: Bool = false
	public var title: String = ""
	public var timeStamp: Date!
	public var username: String = ""
	public var activityGroupMessageLink: String?
	public var fieldValues = [FieldValue]()

	public var definitions = [Definition]()

	public var message: String = ""

	public var activity: Activity?

	public var remove: Bool = false

	public required init?(map: Map) {
	}

	public var listValues: [FieldValue] {
		var result = self.fieldValues.filter({ (fieldValue) -> Bool in
			return fieldValue.field != nil &&
				fieldValue.field!.showInList &&
				fieldValue.field!.permalink != "message" && !(fieldValue.field!.dataType == .Boolean && fieldValue.field!.icon != nil)
		})

		result = result.sorted { (lhs, rhs) -> Bool in
			return lhs.field!.sortorder < rhs.field!.sortorder
		}

		return result
	}

	public var boolValues: [FieldValue] {
		var result = self.fieldValues.filter({ (fieldValue) -> Bool in
			return fieldValue.field != nil && fieldValue.field!.dataType == .Boolean && fieldValue.field!.icon != nil
		})

		result = result.sorted { (lhs, rhs) -> Bool in
			return lhs.field!.sortorder < rhs.field!.sortorder
		}

		return result

	}

	public func mapping(map: Map) {
		self.lid <- map["id"]
		self.title <- map["title"]

		self.message <- map["message"]

		let decoded = String(htmlEncodedString: self.message)
		if decoded != nil {
			self.message = decoded!
		}

		self.activityGroup <- (map["activity_group.id"], ValueFinderTransformer<ActivityGroup>())

		if self.activityGroup != nil {
			self.activityGroup = ObjectDetacher<ActivityGroup>.detach(object: self.activityGroup!)
		}

		self.username <- map["username"]
		self.lfg <- map["lfg"]
		self.isPlanned <- map["is_planned"]
		self.activityGroupMessageLink <- map["activity_group_link"]
		self.definitions <- map["definitions"]

		self.timeStamp <- (map["timestamp"], DateTransformer(format: "yyyy-MM-dd'T'HH:mm:ss.SSSz"))
		self.findFieldValues()

	}

	private func findFieldValues() {
		do {
			let realm = try Realm()
			self.definitions.forEach({ (definition) in
				if let fieldValue = FieldValue.resolve(definition: definition, realm: realm) {
					self.fieldValues.append(fieldValue)
				}
			})
		} catch {
			log.error("Some error occured")
		}
	}

	public var hashValue: Int {
		return self.lid.hashValue
	}
}

public func == (lhs: Request, rhs: Request) -> Bool {
	return lhs.lid == rhs.lid
}
