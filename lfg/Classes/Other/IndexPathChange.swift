//
//  IndexPathChange.swift
//  lfg
//
//  Created by Wim Haanstra on 21/02/2017.
//  Copyright © 2017 Wim Haanstra. All rights reserved.
//

import Foundation
import UIKit

public class IndexPathChange {

	public var section: Int
	public var from: Int?
	public var to: Int?

	init(section: Int, from: Int?, to: Int?) {
		self.section = section
		self.from = from
		self.to = to
	}

	public func performChange(collectionView: UICollectionView) {
		if self.from != nil && self.to == nil {

			let from = IndexPath(item: self.from!, section: section)
			collectionView.deleteItems(at: [ from ])

		} else if self.from == nil && self.to != nil {

			let to = IndexPath(item: self.to!, section: section)
			collectionView.insertItems(at: [ to ])

		} else if self.from != nil && self.to != nil {

			let from = IndexPath(item: self.from!, section: section)
			let to = IndexPath(item: self.to!, section: section)

			if collectionView.cellForItem(at: from) != nil {
				collectionView.moveItem(at: from, to: to)
			}

		}

	}

}
