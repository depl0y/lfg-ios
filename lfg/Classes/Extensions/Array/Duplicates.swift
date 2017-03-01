//
//  Array+Duplicates.swift
//  lfg
//
//  Created by Wim Haanstra on 18/02/2017.
//  Copyright © 2017 Wim Haanstra. All rights reserved.
//

import Foundation

extension Array where Element: Equatable {

	/// Remove duplicates from an array
	///
	/// - Returns: The array, removing all duplicate objects
	public func uniq() -> [Element] {
		var arrayCopy = self
		arrayCopy.uniqInPlace()
		return arrayCopy
	}

	/// In place removing of duplicates from this array
	mutating public func uniqInPlace() {
		var seen = [Element]()
		var index = 0
		for element in self {
			if seen.contains(element) {
				remove(at: index)
			} else {
				seen.append(element)
				index += 1
			}
		}
	}
}

extension Array where Element: Activity {

	mutating public func sortAlphabetically() {
		self.sort { (lhs: Activity, rhs: Activity) -> Bool in
			return lhs.name < rhs.name
		}
	}

	mutating public func sortPopularity() {
		self.sort { (lhs: Activity, rhs: Activity) -> Bool in
			return lhs.popularity > rhs.popularity
		}
	}

	mutating public func sortReleaseDate() {
		self.sort { (lhs: Activity, rhs: Activity) -> Bool in
			if lhs.releaseDate != nil && rhs.releaseDate != nil {
				return lhs.releaseDate! < rhs.releaseDate!
			} else {
				return lhs.name < rhs.name
			}
		}
	}
}
