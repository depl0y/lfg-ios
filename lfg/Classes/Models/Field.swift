//
//  Filter.swift
//  lfg
//
//  Created by Wim Haanstra on 08/02/2017.
//  Copyright © 2017 Wim Haanstra. All rights reserved.
//

import Foundation
import RealmSwift
import Realm
import ObjectMapper
import ionicons

public class Field: Object, Mappable, ValueFinder {

	static var enabledIcons = [String: UIImage]()
	static var disabledIcons = [String: UIImage]()

	dynamic var lid: Int = 0

	dynamic var permalink: String = ""
	dynamic var name: String = ""

	dynamic var desc: String?

	dynamic var group: String = ""

	dynamic var icon: String?

	dynamic var dataType: DataType = DataType.Unknown

	dynamic var min: Int = 0
	dynamic var max: Int = 0
	dynamic var step: Int = 1
	dynamic var filterStep: Int = 1

	dynamic var filterable: Bool = false

	dynamic var sortorder: Int = 0

	dynamic var lfg: Bool = false
	dynamic var lfm: Bool = false

	dynamic var valuePrefix: String?
	dynamic var valueSuffix: String?

	dynamic var displayAsCheckboxes: Bool = false
	dynamic var showInList: Bool = false

	dynamic var fieldGroup: FieldGroup?
	dynamic var activity: Activity?

	var options = List<FieldOption>()

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

	public override static func primaryKey() -> String? {
		return "lid"
	}

	override public static func ignoredProperties() -> [String] {
		return ["iconImage", "_iconImage"]
	}

	public func iconImage(enabled: Bool) -> UIImage? {
		if self.icon == nil {
			return nil
		}

		let suffix = (enabled) ? "enabled" : "disabled"
		let backgroundColor = (enabled) ? 0x249381 : 0xd5d5d5

		let iconName = "\(self.icon!)-\(suffix)"

		if let image = IconManager.sharedInstance.get(key: iconName) {
			return image
		} else {
			return IconManager.sharedInstance.create(
				key: iconName,
				iconName: self.icon!,
				backgroundColor: UIColor(netHex: backgroundColor),
				color: UIColor.white,
				iconSize: 60,
				imageSize: CGSize(width: 80, height: 80))
		}
	}

	public func mapping(map: Map) {
		lid <- map["id"]
		name <- map["name"]
		icon <- map["icon"]
		desc <- map["description"]
		permalink <- map["permalink"]
		min <- map["min"]
		max <- map["max"]
		step <- map["step"]
		group <- map["group"]
		filterStep <- map["filter_step"]
		sortorder <- map["sortorder"]
		filterable <- map["filterable"]
		lfg <- map["lfg"]
		lfm <- map["lfm"]
		dataType <- (map["datatype"], DatatypeTransformer())
		valuePrefix <- map["value_prefix"]
		valueSuffix <- map["value_suffix"]
		displayAsCheckboxes <- map["display_as_checkboxes"]
		showInList <- map["show_in_list"]

		options <- (map["options"], ListTransform<FieldOption>())
	}

	public func createOrUpdate(realm: Realm, fieldGroup: FieldGroup) -> Field {
		let predicate = NSPredicate(format: "lid = %d", self.lid)
		let objects = realm.objects(Field.self).filter(predicate)

		self.options.forEach({ (fieldOption) in
			fieldOption.field = self
		})

		if objects.count == 0 {
			self.activity = fieldGroup.activity
			self.fieldGroup = fieldGroup
			fieldGroup.fields.append(self)
			realm.create(Field.self, value: self, update: true)
			return self
		} else {
			let object = objects.first!
			object.copy(source: self, realm: realm)
			return object
		}
	}

	public func copy(source: Field, realm: Realm) {
		self.name = source.name
		self.icon = source.icon
		self.desc = source.desc
		self.permalink = source.permalink
		self.min = source.min
		self.max = source.max
		self.step = source.step
		self.group = source.group
		self.filterable = source.filterable
		self.filterStep = source.filterStep
		self.sortorder = source.sortorder
		self.lfg = source.lfg
		self.lfm = source.lfm
		self.dataType = source.dataType
		self.valuePrefix = source.valuePrefix
		self.valueSuffix = source.valueSuffix
		self.displayAsCheckboxes = source.displayAsCheckboxes
		self.showInList = source.showInList

		let optionIds = Array(source.options).map { $0.lid }
		FieldOption.removeExcept(realm: realm, field: self, options: optionIds)

		let sourceOptions = source.options.map { $0.createOrUpdate(realm: realm, field: self) }

		sourceOptions.forEach { (fieldOption) in
			fieldOption.field = self
			if !self.options.contains(fieldOption) {
				self.options.append(fieldOption)
			}
		}
	}

	public func remove(realm: Realm) {
		_ = Array(self.options).map { $0.remove(realm: realm) }
		realm.delete(self)
	}

	public static func removeExcept(realm: Realm, fieldGroup: FieldGroup, fields: [Int]) {
		let predicate = NSPredicate(format: "fieldGroup = %@ AND NOT (lid in %@)", fieldGroup, fields)
		let objects = realm.objects(Field.self).filter(predicate)
		objects.forEach { (o) in
			o.remove(realm: realm)
		}
	}

	public static func findByValue(value: Any) -> Field? {
		if let vid = value as? Int {
			do {
				let realm = try Realm()
				let groups = realm.objects(Field.self).filter("lid = %d", vid)
				return groups.first
			} catch {
				log.error("Error occured while fetching REALM")
			}
		}
		return nil
	}
}
