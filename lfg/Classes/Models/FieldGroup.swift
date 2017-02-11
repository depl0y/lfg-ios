//
//  FilterGroup.swift
//  lfg
//
//  Created by Wim Haanstra on 08/02/2017.
//  Copyright © 2017 Wim Haanstra. All rights reserved.
//

import Foundation
import RealmSwift
import Realm
import ObjectMapper

public class FieldGroup: Object, Mappable {

	dynamic var name: String = ""
	dynamic var activity: Activity?

	var fields = List<Field>()

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
		name <- map["name"]
		fields <- (map["objects"], ListTransform<Field>())
	}

	public func createOrUpdate(realm: Realm, activity: Activity) -> FieldGroup {
		let predicate = NSPredicate(format: "name = %@ AND activity = %@", self.name, activity)
		let objects = realm.objects(FieldGroup.self).filter(predicate)

		if objects.count == 0 {
			self.activity = activity

			self.fields.forEach({ (field) in
				field.activity = activity
				field.fieldGroup = self
			})

			activity.fieldGroups.append(self)

			realm.add(self)
			return self
		} else {
			let object = objects.first!
			object.copy(source: self, realm: realm)
			return object

		}
	}

	public func remove(realm: Realm) {
		_ = Array(self.fields).map { $0.remove(realm: realm) }
		realm.delete(self)
	}

	private func copy(source: FieldGroup, realm: Realm) {
		self.name = source.name
		let fieldIds = Array(source.fields).map { $0.lid }

		Field.removeExcept(realm: realm, fieldGroup: self, fields: fieldIds)
		let sourceFields = source.fields.map { $0.createOrUpdate(realm: realm, fieldGroup: self) }

		sourceFields.forEach { (field) in
			if !self.fields.contains(field) {
				self.fields.append(field)
			}
		}
	}

	public static func removeExcept(realm: Realm, activity: Activity, names: [String]) {
		let predicate = NSPredicate(format: "activity = %@ AND NOT (name in %@)", activity, names)
		let objects = realm.objects(FieldGroup.self).filter(predicate)

		log.verbose("Found \(objects.count) objects for removal")

		objects.forEach { (o) in
			o.remove(realm: realm)
		}

	}
}
