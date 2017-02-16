//
//  IconManager.swift
//  lfg
//
//  Created by Wim Haanstra on 15/02/2017.
//  Copyright © 2017 Wim Haanstra. All rights reserved.
//

import UIKit

public class IconManager {

	/// Singleton....
	static let sharedInstance = IconManager()

	private var icons = [String: UIImage]()

	public func get(key: String) -> UIImage? {

		return icons[key]
	}

	public func create(
		key: String,
		iconName: String,
		backgroundColor: UIColor?,
		color: UIColor,
		iconSize: CGFloat,
		imageSize: CGSize) -> UIImage? {

		log.debug("Creating icon for \(key)")

		let img = UIImage.icon(
			icon: iconName,
			backgroundColor: backgroundColor,
			color: color,
			iconSize: iconSize,
			imageSize: imageSize)

		if img != nil {
			self.icons[key] = img
		}

		return img
	}
}
