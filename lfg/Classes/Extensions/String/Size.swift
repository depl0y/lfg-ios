//
//  String+Size.swift
//  lfg
//
//  Created by Wim Haanstra on 16/02/2017.
//  Copyright © 2017 Wim Haanstra. All rights reserved.
//

import Foundation
import UIKit

extension String {
	/// Calculates the size of the box for a string, constrained to a certain width
	///
	/// - Parameters:
	///   - width: The width constrain
	///   - font: The font to use to calculate the size
	/// - Returns: A box, describing the width and height of the string
	func calculateSize(width: CGFloat, font: UIFont) -> CGRect {
		let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
		let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)

		return boundingBox
	}

	init?(htmlEncodedString: String) {
		let encodedData = htmlEncodedString.data(using: String.Encoding.utf8)!
		let attributedOptions = [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType]

		guard let attributedString = try? NSAttributedString(data: encodedData, options: attributedOptions, documentAttributes: nil) else {
			return nil
		}
		self.init(attributedString.string)
	}
}

extension NSMutableAttributedString {

	/// Add text with a certain font to an attributed string
	///
	/// - Parameters:
	///   - text: The text to add
	///   - font: The font to use for the text that is appended
	public func addWithFont(_ text: String, font: UIFont) {
		let attrs: [String: AnyObject] = [NSFontAttributeName: font]
		let boldString = NSMutableAttributedString(string:"\(text)", attributes:attrs)
		self.append(boldString)
	}

	/// Add text with a certain font to an attributed string
	///
	/// - Parameters:
	///   - text: The text to add
	///   - font: The font to use for the text that is appended
	public func addWithFont(_ text: String, font: UIFont, color: UIColor) {
		let attrs: [String: AnyObject] = [NSFontAttributeName: font, NSForegroundColorAttributeName: color]
		let boldString = NSMutableAttributedString(string:"\(text)", attributes:attrs)
		self.append(boldString)
	}
}
