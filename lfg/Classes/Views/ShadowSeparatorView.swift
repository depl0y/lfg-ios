//
//  ShadowSeparatorView.swift
//  lfg
//
//  Created by Wim Haanstra on 28/02/2017.
//  Copyright © 2017 Wim Haanstra. All rights reserved.
//

import UIKit

public class ShadowSeparatorView: UIView {

	override init(frame: CGRect) {
		super.init(frame: frame)
		self.backgroundColor = UIColor(netHex: 0xD8D8D8)
	}

	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	public override func draw(_ rect: CGRect) {
		if let context = UIGraphicsGetCurrentContext() {
			context.saveGState()

			let offset = CGSize(width: 0, height: 0)
			context.setShadow(offset: offset, blur: 3, color: UIColor.black.cgColor)

			let path = CGMutablePath()
			path.move(to: CGPoint(x: 0, y: 0))
			path.addRect(CGRect(x: 0, y: 0, width: rect.size.width, height: 1))

			context.addPath(path)
			UIColor(netHex: 0xD8D8D8).setFill()

			context.drawPath(using: CGPathDrawingMode.fill)
			context.restoreGState()
		}
	}
}
