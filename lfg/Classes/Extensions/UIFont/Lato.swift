//
//  UIFont+Lato.swift
//  lfg
//
//  Created by Wim Haanstra on 16/02/2017.
//  Copyright © 2017 Wim Haanstra. All rights reserved.
//

import Foundation
import UIKit

extension UIFont {

	/// Static function return an UIFont with the Lato font loaded
	///
	/// - Parameter size: The size of the font
	/// - Returns: An instantiated UIFont for Lato regular
	public static func latoWithSize(size: CGFloat) -> UIFont {
		let lato = UIFont(name: "Lato-Regular", size: size)
		return lato!
	}

	/// Static function return an UIFont with the Lato font loaded
	///
	/// - Parameter size: The size of the font
	/// - Returns: An instantiated UIFont for Lato bold
	public static func latoBoldWithSize(size: CGFloat) -> UIFont {
		return UIFont(name: "Lato-Bold", size: size)!
	}
}
