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

	public static func latoWithSize(size: CGFloat) -> UIFont {
		let lato = UIFont(name: "Lato-Regular", size: size)
		return lato!
	}

	public static func latoBoldWithSize(size: CGFloat) -> UIFont {
		return UIFont(name: "Lato-Bold", size: size)!
	}
}
