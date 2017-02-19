//
//  NoResultsView.swift
//  lfg
//
//  Created by Wim Haanstra on 17/02/2017.
//  Copyright © 2017 Wim Haanstra. All rights reserved.
//

import UIKit
import PureLayout

public class NoResultsView: UIView, PureLayoutSetup {

	var imageView = UIImageView()
	var titleLabel = UILabel()
	var indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)

	init() {
		super.init(frame: CGRect.zero)
		self.addSubview(imageView)
		self.addSubview(titleLabel)
		self.addSubview(indicator)

		self.setupConstraints()
		self.configureViews()
	}

	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	public func setupConstraints() {
		self.imageView.autoMatch(.width, to: .width, of: self, withMultiplier: 0.6)
		self.imageView.autoMatch(.height, to: .width, of: self, withMultiplier: 0.6)

		self.imageView.autoAlignAxis(.horizontal, toSameAxisOf: self)
		self.imageView.autoAlignAxis(.vertical, toSameAxisOf: self)

		self.titleLabel.autoPinEdge(.left, to: .left, of: self)
		self.titleLabel.autoPinEdge(.right, to: .right, of: self)
		self.titleLabel.autoPinEdge(.top, to: .bottom, of: self.imageView, withOffset: 0)
		self.titleLabel.autoSetDimension(.height, toSize: 22)

		self.indicator.autoPinEdge(.top, to: .bottom, of: self.titleLabel)
		self.indicator.autoAlignAxis(.vertical, toSameAxisOf: self)
		self.indicator.autoSetDimensions(to: CGSize(width: 44, height: 44))
	}

	public func configureViews() {
		self.backgroundColor = UIColor(netHex: 0xC8C8C9)
		self.imageView.image = UIImage(named: "white-logo")

		self.titleLabel.textAlignment = .center
		self.titleLabel.textColor = UIColor.white
		self.titleLabel.font = UIFont.latoBoldWithSize(size: 18)

		self.indicator.hidesWhenStopped = true
	}

	public func setTitle(title: String) {
		self.titleLabel.text = title
	}

	public func setActive(active: Bool) {
		active ? self.indicator.startAnimating() : self.indicator.stopAnimating()
	}
}
