//
//  TitleSeparator.swift
//  lfg
//
//  Created by Wim Haanstra on 16/02/2017.
//  Copyright © 2017 Wim Haanstra. All rights reserved.
//

import UIKit
import PureLayout

public class TitleSeparator: UIView {

	private var textWidth: CGFloat = 0
	private var textLineOffset: CGFloat = 4

	public var titleLabel = UILabel()
	public var lineWidth: CGFloat = 2
	public var color = UIColor(netHex: 0xC8C8C9) {
		didSet {
			self.titleLabel.textColor = self.color
			self.setNeedsDisplay()
		}
	}

	public init() {
		super.init(frame: CGRect.zero)
		self.backgroundColor = UIColor.clear
		self.addSubview(titleLabel)
		self.titleLabel.autoPinEdgesToSuperviewEdges()
		self.titleLabel.textColor = color
		self.titleLabel.font = UIFont.latoBoldWithSize(size: 14)
	}

	public func setTitle(title: String) {
		self.titleLabel.text = title
		self.setNeedsDisplay()

		let textSize = title.calculateSize(width: self.frame.size.width, font: self.titleLabel.font)
		self.textWidth = textSize.width
	}

	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	public override func draw(_ rect: CGRect) {
		let y = self.titleLabel.frame.origin.y + self.titleLabel.frame.height - lineWidth

		let path = UIBezierPath()
		path.move(to: CGPoint(x: self.titleLabel.frame.origin.x + textWidth + textLineOffset, y: y))
		path.addLine(to: CGPoint(x: rect.maxX, y: y))
		path.close()

		color.setStroke()
		path.lineWidth = self.lineWidth
		path.stroke()

	}
}
