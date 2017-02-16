//
//  StatusPanel.swift
//  lfg
//
//  Created by Wim Haanstra on 16/02/2017.
//  Copyright © 2017 Wim Haanstra. All rights reserved.
//

import UIKit
import PureLayout

public class StatusPanel: UIView {

	private var titleLabel = UILabel()
	private var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
	private var indicatorDimensions = [NSLayoutConstraint]()

	public init() {
		super.init(frame: CGRect.zero)

		self.backgroundColor = UIColor(netHex: 0x249381)

		self.addSubview(self.activityIndicator)
		self.activityIndicator.hidesWhenStopped = true

		self.activityIndicator.autoPinEdge(.top, to: .top, of: self, withOffset: 4)
		self.activityIndicator.autoPinEdge(.left, to: .left, of: self, withOffset: 4)
		self.indicatorDimensions = self.activityIndicator.autoSetDimensions(to: CGSize(width: 22, height: 22))

		self.addSubview(self.titleLabel)
		self.titleLabel.font = UIFont.latoWithSize(size: 14)
		self.titleLabel.textColor = UIColor.white
		self.titleLabel.autoPinEdge(.top, to: .top, of: self, withOffset: 0)
		self.titleLabel.autoPinEdge(.bottom, to: .bottom, of: self, withOffset: 0)
		self.titleLabel.autoPinEdge(.left, to: .right, of: self.activityIndicator, withOffset: 6)
		self.titleLabel.autoPinEdge(.right, to: .right, of: self, withOffset: -6)
	}

	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	public func setTitle(title: String, active: Bool, animate: Bool = true) {

		let animationTime: TimeInterval = animate ? 0.4 : 0

		if active {
			self.activityIndicator.startAnimating()

			for constraint in self.indicatorDimensions {
				constraint.constant = 22
			}

			UIView.animate(withDuration: animationTime, animations: {
				//				self.layer.opacity = 1
				self.layoutIfNeeded()
			})
		} else {
			self.activityIndicator.stopAnimating()

			for constraint in self.indicatorDimensions {
				constraint.constant = 0
			}

			UIView.animate(withDuration: animationTime, animations: {
				//				self.layer.opacity = 0.7
				self.layoutIfNeeded()
			})
		}
		self.titleLabel.text = title
	}

}
