//
//  DateTransformer.swift
//  lfg
//
//  Created by Wim Haanstra on 09/02/2017.
//  Copyright © 2017 Wim Haanstra. All rights reserved.
//

import Foundation
import ObjectMapper

public class DateTransformer: TransformType {

	var dateFormat = ""

	public typealias Object = Date
	public typealias JSON = String

	public func transformFromJSON(_ value: Any?) -> Date? {
		if let v = value as? String {
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = self.dateFormat

			return dateFormatter.date(from: v)
		}
		return nil
	}

	public func transformToJSON(_ value: Date?) -> String? {
		return nil
	}

	public init(format: String) {
		self.dateFormat = format
	}
}
