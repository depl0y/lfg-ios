//
//  DataTypes.swift
//  lfg
//
//  Created by Wim Haanstra on 09/02/2017.
//  Copyright © 2017 Wim Haanstra. All rights reserved.
//

import Foundation

@objc public enum DataType: Int {
	case Unknown = 0
	case Number = 1
	case Option = 2
	case Boolean = 3

	static func fromString(name: String) -> DataType {
		if name == "number" {
			return .Number
		} else if name == "option" {
			return .Option
		} else if name == "boolean" {
			return .Boolean
		}
		return .Unknown
	}
}
