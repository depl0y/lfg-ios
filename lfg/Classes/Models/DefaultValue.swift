//
//  Filter.swift
//  lfg
//
//  Created by Wim Haanstra on 26/02/2017.
//  Copyright © 2017 Wim Haanstra. All rights reserved.
//

import Foundation

public class DefaultValues: NSObject, NSCoding {

	public var values = [DefaultValue]()

	public func encode(with aCoder: NSCoder) {
		aCoder.encode(self.values, forKey: "values")
	}

	override init() {
		super.init()
	}

	public required init?(coder aDecoder: NSCoder) {
		if let values = aDecoder.decodeObject(forKey: "values") as? [DefaultValue] {
			self.values = values
		}
	}

	public func storeFilters(key: String) {
		let totalKey = "filters.\(key)"
		self.store(key: totalKey)
	}

	public func storeDefaults(key: String) {
		let totalKey = "defaults.\(key)"
		self.store(key: totalKey)
	}

	public func toDefaults() -> [String: Any] {
		var result = [String: Any]()

		self.values.forEach { (dv) in
			if let value = dv.toDefault() as? (String, Any) {
				result[value.0] = value.1
			}
		}

		return result
	}

	public func toFilters() -> [Int: Any] {
		var result = [Int: Any]()
		self.values.forEach { (dv) in
			if let filter = dv.toFilter() as? (Int, Any) {
				result[filter.0] = filter.1
			}
		}
		return result
	}

	private func store(key: String) {
		let data = NSKeyedArchiver.archivedData(withRootObject: self)
		UserDefaults.standard.set(data, forKey: key)
		UserDefaults.standard.synchronize()
	}

	public static func getFilters(key: String) -> DefaultValues? {
		let totalKey = "filters.\(key)"
		return self.get(key: totalKey)
	}

	public static func getDefaults(key: String) -> DefaultValues? {
		let totalKey = "defaults.\(key)"

		return self.get(key: totalKey)
	}

	private static func get(key: String) -> DefaultValues? {
		if let data = UserDefaults.standard.object(forKey: key) as? Data {
			if let object = NSKeyedUnarchiver.unarchiveObject(with: data) as? DefaultValues {
				return object
			}
		}

		return nil
	}

	public static func fromDefaults(defaults: [String: Any]) -> DefaultValues {
		let result = DefaultValues()

		defaults.forEach { (key, value) in
			let df = DefaultValue(idString: key, value: value)
			if df.value != nil {
				result.values.append(df)
			}
		}

		return result
	}

	public static func fromFilters(filters: [Int: Any]) -> DefaultValues {
		let result = DefaultValues()

		filters.forEach { (key, value) in
			let df = DefaultValue(identifier: key, value: value)
			if df.value != nil {
				result.values.append(df)
			}
		}

		return result
	}

	public static func deleteAllFilters() {
		let valueKeys = UserDefaults.standard.dictionaryRepresentation().keys.filter { (key) -> Bool in
			return key.hasPrefix("filters.")
		}

		valueKeys.forEach {
			log.debug("Key: \($0)")
			UserDefaults.standard.removeObject(forKey: $0)
		}
		UserDefaults.standard.synchronize()
	}

	public static func deleteAllDefaults() {
		let valueKeys = UserDefaults.standard.dictionaryRepresentation().keys.filter { (key) -> Bool in
			return key.hasPrefix("defaults.")
		}

		valueKeys.forEach {
			log.debug("Key: \($0)")
			UserDefaults.standard.removeObject(forKey: $0)
		}
		UserDefaults.standard.synchronize()
	}

}

public class DefaultValue: NSObject, NSCoding {

	var identifier: String = ""
	var stringValue: String?
	var bool: Bool?
	var number: Int?
	var numberArray: [Int]?

	override init() {
		super.init()
	}

	init(idString: String, value: Any) {
		super.init()
		self.identifier = idString
		self.setValue(value: value)
	}

	init(identifier: Int, value: Any) {
		super.init()

		self.identifier = "\(identifier)"
		self.setValue(value: value)
	}

	private func setValue(value: Any) {
		if let v = value as? String {
			self.stringValue = v
		} else if let v = value as? Bool {
			self.bool = v
		} else if let v = value as? Int {
			self.number = v
		} else if let v = value as? [Int] {
			self.numberArray = v
		}
	}

	public func encode(with aCoder: NSCoder) {
		aCoder.encode(self.identifier, forKey: "identifier")

		if stringValue != nil {
			aCoder.encode(stringValue!, forKey: "string")
		}

		if bool != nil {
			aCoder.encode(bool!, forKey: "bool")
		}

		if number != nil {
			aCoder.encode(number!, forKey: "number")
		}

		if numberArray != nil {
			aCoder.encode(numberArray!, forKey: "numberArray")
		}
	}

	required public init?(coder aDecoder: NSCoder) {
		super.init()

		if let identifier = aDecoder.decodeObject(forKey: "identifier") as? String {
			self.identifier = identifier

			if aDecoder.containsValue(forKey: "bool") {
				self.bool = aDecoder.decodeBool(forKey: "bool")
			}

			if let stringValue = aDecoder.decodeObject(forKey: "string") as? String {
				self.stringValue = stringValue
			}

			if aDecoder.containsValue(forKey: "number") {
				self.number = aDecoder.decodeInteger(forKey: "number")
			}

			if let v = aDecoder.decodeObject(forKey: "numberArray") as? [Int] {
				self.numberArray = v
			}
		}
	}

	public var value: Any? {
		if self.stringValue != nil {
			return self.stringValue!
		} else if self.number != nil {
			return self.number!
		} else if self.bool != nil {
			return self.bool!
		} else if self.numberArray != nil {
			return self.numberArray!
		}

		return nil
	}

	public func toFilter() -> (key: Int, value: Any)? {

		if let intId = Int(self.identifier) {
			if self.value != nil {
				return (intId, self.value!)
			}
		}

		return nil
	}

	public func toDefault() -> (key: String, value: Any)? {
		if self.value != nil {
			return (self.identifier, self.value!)
		}
		return nil
	}

	public override var description: String {
		return "\(self.identifier) : \(self.value)"
	}

}
