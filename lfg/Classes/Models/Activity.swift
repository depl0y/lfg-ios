//
//  Activity.swift
//  lfg
//
//  Created by Wim Haanstra on 08/02/2017.
//  Copyright © 2017 Wim Haanstra. All rights reserved.
//

import Foundation
import RealmSwift
import Realm
import ObjectMapper

public class Activity: Object, Mappable, ValueFinder {

	dynamic var lid: Int = 0
	dynamic var name: String = ""
	dynamic var permalink: String = ""
	dynamic var icon: String = ""
	dynamic var banner: String = ""
	dynamic var background: String = ""
	dynamic var popularity: Float = 0
	dynamic var configUrl: String = ""
	dynamic var releaseDate: Date?
	dynamic var url: String = ""

	dynamic var lastConfigUpdate: Date?

	dynamic var subscribe: Bool = true

	dynamic var discordChannel: String?
	dynamic var discordInviteCode: String?
	dynamic var discordServer: String?

	var groups = List<ActivityGroup>()
	let fieldGroups = List<FieldGroup>()

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
		return "permalink"
	}

	public func mapping(map: Map) {
		lid <- map["id"]
		name <- map["name"]
		permalink <- map["permalink"]
		icon <- map["icon"]
		banner <- map["banner"]
		background <- map["background"]
		popularity <- map["popularity"]
		configUrl <- map["config_url"]
		releaseDate <- (map["release_date"], DateTransformer(format: "yyyy-MM-dd'T'HH:mm:ss.SSSz"))
		url <- map["url"]
		groups <- (map["groups"], ListTransform<ActivityGroup>())

		discordServer <- map["discord_info.server_id"]
		discordChannel <- map["discord_info.channel_name"]
		discordInviteCode <- map["discord_info.invite_code"]
	}

	/// This creates or updates the activity in the database
	/// If the object is IN the database, that instance will be returned
	///
	/// - Parameter realm: The realm to use
	/// - Returns: The added object, if one already exists, that object will be updated and returned
	func createOrUpdate(realm: Realm) -> Activity {
		let activities = realm.objects(Activity.self).filter("permalink = '\(self.permalink)'")

		if activities.count == 0 {
			realm.create(Activity.self, value: self, update: true)
			return self
		} else {
			let activity = activities.first!
			activity.copy(source: self, realm: realm)
			return activity
		}
	}

	/// Do a cascading delete of this object
	///
	/// - Parameter realm: The realm to use for the delete
	func remove(realm: Realm) {
		_ = Array(self.fieldGroups).map { $0.remove(realm: realm) }
		realm.delete(self)
	}

	func allFields() -> [Field] {
		return Array(self.fieldGroups).flatMap { Array($0.fields) }
	}

	/// Create a deep copy from an object onto the current object
	///
	/// - Parameters:
	///   - source: The object to copy from
	///   - realm: The realm to use for the copy
	private func copy(source: Activity, realm: Realm) {
		self.name = source.name

		if self.icon != source.icon {
			self.icon = source.icon
		}

		self.lid = source.lid
		self.banner = source.banner
		self.background = source.background
		self.popularity = source.popularity
		self.configUrl = source.configUrl
		self.releaseDate = source.releaseDate
		self.url = source.url
		self.discordServer = source.discordServer
		self.discordChannel = source.discordChannel
		self.discordInviteCode = source.discordInviteCode

		source.groups.forEach({ (activityGroup) in
			let ag = activityGroup.createOrUpdate(realm: realm)

			if !self.groups.contains(ag) {
				self.groups.append(ag)
			}
		})
	}

	/// Removes objects that are no longer present
	///
	/// - Parameters:
	///   - realm: The realm to use
	///   - activities: Identifiers still available
	public static func removeExcept(realm: Realm, activities: [String]) {
		let predicate = NSPredicate(format: "NOT (permalink in %@)", activities)
		let objects = realm.objects(Activity.self).filter(predicate)

		objects.forEach { (o) in
			o.remove(realm: realm)
		}
	}

	/// Find an object by the identifying property
	///
	/// - Parameter value: The value of the identifying property
	/// - Returns: The object if any is found, otherwise nil
	public static func findByValue(value: Any) -> Activity? {
		if let vid = value as? String {
			do {
				let realm = try Realm()
				let groups = realm.objects(Activity.self).filter(NSPredicate(format: "permalink = %@", vid))
				return groups.first
			} catch {
				log.error("Error occured while fetching REALM")
			}
		}
		return nil
	}

	public static func released() -> [Activity] {
		do {
			let realm = try Realm()
			let t = realm.objects(Activity.self).filter(NSPredicate(format: "releaseDate == nil"))
			return Array(t)
		} catch {
			return []
		}
	}

	public static func upcoming() -> [Activity] {
		do {
			let realm = try Realm()
			let t = realm.objects(Activity.self).filter(NSPredicate(format: "releaseDate != nil")).sorted(byKeyPath: "releaseDate")
			return Array(t)
		} catch {
			return []
		}
	}

	public static func all() -> [Activity] {
		do {
			let realm = try Realm()
			let t = realm.objects(Activity.self)
			return Array(t)
		} catch {
			return []
		}
	}
}
