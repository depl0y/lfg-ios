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
	func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGRect {
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
