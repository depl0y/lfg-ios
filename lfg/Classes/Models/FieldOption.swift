//
//  FilterOption.swift
//  lfg
//
//  Created by Wim Haanstra on 08/02/2017.
//  Copyright © 2017 Wim Haanstra. All rights reserved.
//

import Foundation
import RealmSwift
import Realm
import ObjectMapper

public class FieldOption: Object, Mappable, ValueFinder {

	dynamic var lid: Int = 0
	dynamic var permalink: String = ""
	dynamic var name: String = ""
	dynamic var group: String?

	dynamic var lfg: Bool = true
	dynamic var lfm: Bool = true

	dynamic var sortorder: Int = 0

	dynamic var field: Field?

	public override static func primaryKey() -> String? {
		return "lid"
	}

	public required init?(map: Map) {
		super.init()
	}

	public required init() {
		super.init()
	}

	public required init(value: Any, schema: RLMSchema) {
		super.init(value: value, schema: schema)
	}

	public required init(realm: RLMRealm, schema: RLMObjectSchema) {
		super.init(realm: realm, schema: schema)
	}

	public func mapping(map: Map) {
		name <- map["name"]
		lid <- map["id"]
		permalink <- map["permalink"]
		group <- map["group"]
		lfg <- map["lfg"]
		lfm <- map["lfm"]
		sortorder <- map["sortorder"]
	}

	public func createOrUpdate(realm: Realm, field: Field) -> FieldOption {
		let predicate = NSPredicate(format: "lid = %d", self.lid)
		let objects = realm.objects(FieldOption.self).filter(predicate)

		if objects.count == 0 {
			self.field = field
			field.options.append(self)
			realm.create(FieldOption.self, value: self, update: true)
			return self
		} else {
			let object = objects.first!
			object.copy(source: self, realm: realm)
			return object
		}
	}

	/// Do a cascading delete of this object
	///
	/// - Parameter realm: The realm to use for the delete
	public func remove(realm: Realm) {
		realm.delete(self)
	}

	/// Create a deep copy from an object onto the current object
	///
	/// - Parameters:
	///   - source: The object to copy from
	///   - realm: The realm to use for the copy
	private func copy(source: FieldOption, realm: Realm) {
		self.name = source.name
		self.permalink = source.permalink
		self.lfg = source.lfg
		self.lfm = source.lfm
		self.sortorder = source.sortorder
		self.group = source.group
	}

	/// Removes objects that are no longer present
	///
	/// - Parameters:
	///   - realm: The realm to use
	///   - field: The field connected to this object
	///   - activities: Identifiers still available
	public static func removeExcept(realm: Realm, field: Field, options: [Int]) {
		let predicate = NSPredicate(format: "field = %@ AND NOT (lid in %@)", field, options)
		let objects = realm.objects(FieldOption.self).filter(predicate)

		objects.forEach { (o) in
			o.remove(realm: realm)
		}
	}

	public override var description: String {
		if self.group != nil {
			return "\(self.group!) - \(self.name)"
		} else {
			return self.name
		}
	}

	public static func findByValue(value: Any) -> FieldOption? {
		if let vid = value as? Int {
			do {
				let realm = try Realm()
				let groups = realm.objects(FieldOption.self).filter("lid = %d", vid)
				return groups.first
			} catch {
				log.error("Error occured while fetching REALM")
			}
		}
		return nil
	}
}
