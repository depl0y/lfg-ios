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
		fatalError("init(value:schema:) has not been implemented")
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

	private func copy(source: ActivityGroup, realm: Realm) {
		self.name = source.name
		self.icon = source.icon
	}

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
