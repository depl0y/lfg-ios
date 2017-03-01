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
	public var source: Int?
	public var destination: Int?

	init(section: Int, source: Int?, destination: Int?) {
		self.section = section
		self.source = source
		self.destination = destination
	}

	public func performChange(collectionView: UICollectionView) {
		if self.source != nil && self.destination == nil {

			let from = IndexPath(item: self.source!, section: section)
			collectionView.deleteItems(at: [ from ])

		} else if self.source == nil && self.destination != nil {

			let to = IndexPath(item: self.destination!, section: section)
			collectionView.insertItems(at: [ to ])

		} else if self.source != nil && self.destination != nil {

			let from = IndexPath(item: self.source!, section: section)
			let to = IndexPath(item: self.destination!, section: section)

			if collectionView.cellForItem(at: from) != nil {
				collectionView.moveItem(at: from, to: to)
			}

		}

	}

}
