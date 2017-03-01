//
//  ActivitySectionHeader.swift
//  lfg
//
//  Created by Wim Haanstra on 21/02/2017.
//  Copyright © 2017 Wim Haanstra. All rights reserved.
//

import Foundation
import UIKit

public class ActivitySectionHeader: UICollectionReusableView {

	private var textWidth: CGFloat = 0
	private var textLineOffset: CGFloat = 4

	public var titleLabel = UILabel()
	public let padding: CGFloat = 10
	public var lineWidth: CGFloat = 2
	public var color = UIColor(netHex: 0x249381) {
		didSet {
			self.titleLabel.textColor = self.color
			self.setNeedsDisplay()
		}
	}

	override init(frame: CGRect) {
		super.init(frame: frame)

		self.backgroundColor = UIColor.clear
		self.addSubview(titleLabel)

		self.titleLabel.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: self.padding, bottom: 0, right: self.padding * -1),
		                                             excludingEdge: .top)
		self.titleLabel.autoSetDimension(.height, toSize: 20)

		self.titleLabel.textColor = color
		self.titleLabel.font = UIFont.latoBoldWithSize(size: 20)
	}

	public init() {
		super.init(frame: CGRect.zero)

		self.backgroundColor = UIColor.clear
		self.addSubview(titleLabel)

		self.titleLabel.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: self.padding, bottom: 0, right: self.padding * -1),
		                                             excludingEdge: .top)

		self.titleLabel.autoSetDimension(.height, toSize: 20)

		self.titleLabel.textColor = color
		self.titleLabel.font = UIFont.latoBoldWithSize(size: 20)
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
		path.addLine(to: CGPoint(x: rect.maxX - self.padding, y: y))
		path.close()

		color.setStroke()
		path.lineWidth = self.lineWidth
		path.stroke()
	}

}
