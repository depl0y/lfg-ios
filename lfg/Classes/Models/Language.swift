//
//  Language.swift
//  lfg
//
//  Created by Wim Haanstra on 08/02/2017.
//  Copyright © 2017 Wim Haanstra. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper
import Realm

public class Language: Object, Mappable, ValueFinder {

	dynamic var lid: Int = 0
	dynamic var identifier: String = ""
	dynamic var title: String = ""

	public override static func primaryKey() -> String? {
		return "lid"
	}

	required public init?(map: Map) {
		super.init()
	}

	required public init(realm: RLMRealm, schema: RLMObjectSchema) {
		super.init(realm: realm, schema: schema)
	}

	required public init() {
		super.init()
	}

	required public init(value: Any, schema: RLMSchema) {
		super.init(value: value, schema: schema)
	}

	public func mapping(map: Map) {
		self.lid <- map["id"]
		self.identifier <- map["identifier"]
		self.title <- map["title"]
	}

	/// This creates or updates the activity in the database
	/// If the object is IN the database, that instance will be returned
	///
	/// - Parameter realm: The realm to use
	/// - Returns: The added object, if one already exists, that object will be updated and returned
	func createOrUpdate(realm: Realm) -> Language {
		let languages = realm.objects(Language.self).filter("lid = \(self.lid)")

		if languages.count == 0 {
			realm.create(Language.self, value: self, update: true)
			return self
		} else {
			let language = languages.first!
			language.copy(source: self, realm: realm)
			return language
		}
	}

	/// Create a deep copy from an object onto the current object
	///
	/// - Parameters:
	///   - source: The object to copy from
	///   - realm: The realm to use for the copy
	private func copy(source: Language, realm: Realm) {
		self.identifier	= source.identifier
		self.title = source.title
	}

	/// Find an object by the identifying property
	///
	/// - Parameter value: The value of the identifying property
	/// - Returns: The object if any is found, otherwise nil
	public static func findByValue(value: Any) -> Language? {
		if let groupId = value as? Int {
			do {
				let realm = try Realm()
				let groups = realm.objects(Language.self).filter("lid = %d", groupId)
				return groups.first
			} catch {
				log.error("Error occured while fetching REALM")
			}
		}
		return nil
	}

	public override var description: String {
		return self.title
	}
}
