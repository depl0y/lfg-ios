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

public class Language: Object, Mappable {

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
		fatalError("init(value:schema:) has not been implemented")
	}

	public func mapping(map: Map) {
		self.lid <- map["id"]
		self.identifier <- map["identifier"]
		self.title <- map["title"]
	}

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

	private func copy(source: Language, realm: Realm) {
		self.identifier	= source.identifier
		self.title = source.title
	}

	public override var description: String {
		return self.title
	}
}
