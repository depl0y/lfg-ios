//
//  ActivitySorting.swift
//  lfg
//
//  Created by Wim Haanstra on 28/02/2017.
//  Copyright © 2017 Wim Haanstra. All rights reserved.
//

import Foundation

public enum ActivitySorting: Int {
	case popularity = 0
	case alphabetically = 1
	case releaseDate = 2
}

public class ActivitySort {

	public var original = [Activity]()
	public var new = [Activity]()
	public var sortType = ActivitySorting.alphabetically
	public var section = 0
	public var done: ((_ results: [Activity]) -> Void)?

	init(original: [Activity], new: [Activity], sorting: ActivitySorting, section: Int, done: @escaping (_ results: [Activity]) -> Void) {
		self.original = original
		self.new = new
		self.sortType = sorting
		self.section = section
		self.done = done
	}

}
