//
//  Request.swift
//  lfg
//
//  Created by Wim Haanstra on 11/02/2017.
//  Copyright © 2017 Wim Haanstra. All rights reserved.
//

import Foundation
import ObjectMapper

public class Request: Mappable {

	public var activityGroup: ActivityGroup?

	public var isPlanned: Bool = false
	public var lfg: Bool = false
	public var title: String = ""
	public var timeStamp: Date!
	public var username: String = ""
	public var activityGroupMessageLink: String?
	public var fieldValues = [FieldValue]()

	public var activity: Activity?

	public required init?(map: Map) {

	}

	public func mapping(map: Map) {
		self.title <- map["title"]

		self.activityGroup <- (map["activity_group.id"], ValueFinderTransformer<ActivityGroup>())
		self.lfg <- map["lfg"]
		self.isPlanned <- map["is_planned"]
		self.activityGroupMessageLink <- map["activity_group_link"]
		self.fieldValues <- map["definitions"] //, ValueFinderTransformer<FieldValue>())

		self.timeStamp <- (map["timestamp"], DateTransformer(format: "yyyy-MM-dd'T'HH:mm:ss.SSSz"))
	}
}
