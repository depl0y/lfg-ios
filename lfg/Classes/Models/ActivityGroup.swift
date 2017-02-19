//
//  ActivityGroup.swift
//  lfg
//
//  Created by Wim Haanstra on 08/02/2017.
//  Copyright © 2017 Wim Haanstra. All rights reserved.
//

import Foundation
import RealmSwift
import Realm
import ObjectMapper

public class ActivityGroup: Object, Mappable, ValueFinder {

	dynamic var lid: Int =  0
	dynamic var name: String = ""
	dynamic var icon: String = ""

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
		lid <- map["id"]
		name <- map["name"]
		icon <- map["icon"]
	}

	public override static func primaryKey() -> String? {
		return "lid"
	}

	public override var description: String {
		return self.name
	}

	/// This creates or updates the activity in the database
	/// If the object is IN the database, that instance will be returned
	///
	/// - Parameter realm: The realm to use
	/// - Returns: The added object, if one already exists, that object will be updated and returned
	func createOrUpdate(realm: Realm) -> ActivityGroup {
		let groups = realm.objects(ActivityGroup.self).filter("lid = \(self.lid)")

		if groups.count == 0 {
			realm.add(self)
			return self
		} else {
			let activity = groups.first!
			activity.copy(source: self, realm: realm)
			return activity
		}
	}

	/// Create a deep copy from an object onto the current object
	///
	/// - Parameters:
	///   - source: The object to copy from
	///   - realm: The realm to use for the copy
	private func copy(source: ActivityGroup, realm: Realm) {
		self.name = source.name
		self.icon = source.icon
	}

	/// Find an object by the identifying property
	///
	/// - Parameter value: The value of the identifying property
	/// - Returns: The object if any is found, otherwise nil
	public static func findByValue(value: Any) -> ActivityGroup? {
		if let groupId = value as? Int {
			do {
				let realm = try Realm()
				let groups = realm.objects(ActivityGroup.self).filter("lid = %d", groupId)
				return groups.first
			} catch {
				log.error("Error occured while fetching REALM")
			}
		}
		return nil
	}
}
