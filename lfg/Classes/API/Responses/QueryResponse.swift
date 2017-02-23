//
//  QueryResponse.swift
//  lfg
//
//  Created by Wim Haanstra on 11/02/2017.
//  Copyright © 2017 Wim Haanstra. All rights reserved.
//

import Foundation
import ObjectMapper

public class QueryResponse: Mappable {

	public var totalHits: Int = 0
	public var perPage: Int  = 0
	public var currentPage: Int = 0

	public var dateFilterCounts = [String: Int]()

	public var requests = [Request]()

	public required init?(map: Map) {
	}

	public func mapping(map: Map) {

		self.totalHits <- map["total_hits"]
		self.perPage <- map["per_page"]
		self.currentPage <- map["current_page"]
		self.dateFilterCounts <- map["date_filter_counts"]

		self.requests <- map["requests"]
	}
}

/*
"total_hits": 4735,
"per_page": "10",
"current_page": "1",
"date_filter_counts": {
"0": 2447,
"1": 0,
"2": 0,
"3": 0,
"4": 0
},
"requests": [
*/
