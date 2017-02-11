//
//  ValueFinderTransformer.swift
//  lfg
//
//  Created by Wim Haanstra on 11/02/2017.
//  Copyright © 2017 Wim Haanstra. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift

public protocol ValueFinder {
	associatedtype ObjectType

	static func findByValue(value: Any) -> ObjectType?
}

public struct ValueFinderTransformer<T: ValueFinder>: TransformType where T: Mappable {

	public init() { }

	public typealias Object = T
	public typealias JSON = Any

	public func transformFromJSON(_ value: Any?) -> T? {
		if value != nil {
			if let v = T.findByValue(value: value!) as? T {
				return v
			}
		}
		return nil
	}

	public func transformToJSON(_ value: Object?) -> Any? {
		return nil
	}
}
