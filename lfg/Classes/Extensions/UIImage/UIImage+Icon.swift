//
//  UIImage+Icon.swift
//  lfg
//
//  Created by Wim Haanstra on 15/02/2017.
//  Copyright © 2017 Wim Haanstra. All rights reserved.
//

import UIKit
import ionicons
import FontAwesome_swift

extension UIImage {

	static func icon(icon: String, backgroundColor: UIColor?, color: UIColor, iconSize: CGFloat, imageSize: CGSize) -> UIImage? {

		var iconImage: UIImage?
		if icon.hasPrefix("ion") {
			iconImage = self.icon(ionIcon: icon, color: color, iconSize: iconSize)
		} else if icon.hasPrefix("fa") {
			iconImage = self.icon(fontAwesomeIcon: icon, color: color, iconSize: iconSize)
		}

		let iconRect = CGRect(x: 0, y: 0, width: iconSize, height: iconSize)
		let imageRect = CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height)

		UIGraphicsBeginImageContext(imageSize)
		let context = UIGraphicsGetCurrentContext()

		if backgroundColor != nil {
			context?.setFillColor(backgroundColor!.cgColor)
			context?.fill(imageRect)
		}

		if iconImage != nil {
			let iconStartPoint = CGPoint(x: imageRect.midX - (iconRect.width / 2), y: imageRect.midY - (iconRect.height / 2))
			iconImage!.draw(at: iconStartPoint)
		}

		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return image
	}

	static func icon(ionIcon: String, color: UIColor, iconSize: CGFloat) -> UIImage? {
		let iconName = self.iconName(ionIcon: ionIcon)

		if iconName == nil {
			return nil
		}

		return IonIcons.image(withIcon: iconName!, iconColor: color, iconSize: iconSize, imageSize: CGSize(width: iconSize, height: iconSize))
	}

	static func icon(fontAwesomeIcon: String, color: UIColor, iconSize: CGFloat) -> UIImage? {

		if fontAwesomeIcon == "fa fa-mature" {
			return UIImage.matureIcon(iconSize: CGSize(width: iconSize, height: iconSize), color: color)
		} else {
			let iconName = self.iconName(fontAwesomeIcon: fontAwesomeIcon)

			if iconName == nil {
				return nil
			}

			return UIImage.fontAwesomeIcon(name: iconName!, textColor: color, size: CGSize(width: iconSize, height: iconSize))
		}
	}

	private static func matureIcon(iconSize: CGSize, color: UIColor) -> UIImage {
		return UIImage.iconWithText(text: "18+", iconSize: iconSize, color: color)
	}

	private static func iconWithText(text: String, iconSize: CGSize, color: UIColor) -> UIImage {
		log.debug("Creating icon with text \(text)")
		let scale = UIScreen.main.scale

		UIGraphicsBeginImageContextWithOptions(iconSize, false, scale)

		var fontSize = iconSize.height - 2
		var font = UIFont.latoBoldWithSize(size: fontSize)
		var textSize = text.heightWithConstrainedWidth(width: 9000, font: font)

		while textSize.width > iconSize.width {
			fontSize -= 2
			font = UIFont.latoBoldWithSize(size: fontSize)
			textSize = text.heightWithConstrainedWidth(width: 9000, font: font)
		}

		let point = CGPoint(x: (iconSize.width / 2) - (textSize.width / 2), y: (iconSize.height / 2) - (textSize.height / 2))

		let rect = CGRect(origin: point, size: textSize.size)

		let textFontAttributes = [
			NSFontAttributeName: font,
			NSForegroundColorAttributeName: color
			] as [String : Any]

		text.draw(in: rect, withAttributes: textFontAttributes)

		let newImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()

		return newImage!
	}

	private static func iconName(ionIcon: String) -> String? {
		if ionIcon == "ion-mic-a" {
			return ion_mic_a
		} else if ionIcon == "ion-xbox" {
			return ion_xbox
		} else if ionIcon == "ion-playstation" {
			return ion_playstation
		} else if ionIcon == "ion-steam" {
			return ion_steam
		} else if ionIcon == "ion-social-windows" {
			return ion_social_windows
		} else if ionIcon == "ion-ios-infinite" {
			return ion_ios_infinite
		} else if ionIcon == "ion-android-mail" {
			return ion_android_mail
		} else {
			return nil
		}
	}

	private static func iconName(fontAwesomeIcon: String) -> FontAwesome? {
		return nil
	}
}
