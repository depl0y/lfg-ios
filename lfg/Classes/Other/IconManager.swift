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

	/// Tries to load a previously generated icon
	///
	/// - Parameter key: The key associated with the icon
	/// - Returns: An image if the icon is cached
	public func get(key: String) -> UIImage? {
		return icons[key]
	}

	/// Create an icon
	///
	/// - Parameters:
	///   - key: The cache key for the icon
	///   - iconName: The icon name, used for resolving using FontAwesome or Ion Icons
	///   - backgroundColor: The background color of the icon, transparent if nil
	///   - color: The color of the icon itself
	///   - iconSize: The size of the icon
	///   - imageSize: The size of the total image
	/// - Returns: An image, with the size imageSize and the icon centered in it.
	public func create(
		key: String,
		iconName: String,
		backgroundColor: UIColor?,
		color: UIColor,
		iconSize: CGFloat,
		imageSize: CGSize) -> UIImage? {

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
