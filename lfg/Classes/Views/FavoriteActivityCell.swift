//
//  ActivityCell.swift
//  lfg
//
//  Created by Wim Haanstra on 16/02/2017.
//  Copyright © 2017 Wim Haanstra. All rights reserved.
//

import UIKit
import SDWebImage
import PureLayout

public class FavoriteActivityCell: UICollectionViewCell, PureLayoutSetup {

	private var titleLabel = UILabel()

	override init(frame: CGRect) {
		super.init(frame: frame)

		self.addSubview(self.titleLabel)

		self.setupConstraints()
		self.configureViews()
	}

	public func setupConstraints() {
		self.titleLabel.autoSetDimension(.height, toSize: 22)
		self.titleLabel.autoMatch(.width, to: .width, of: self)
		self.titleLabel.autoAlignAxis(.horizontal, toSameAxisOf: self)
	}

	public func configureViews() {
		self.backgroundColor = UIColor.clear
		self.clipsToBounds = false

		self.titleLabel.backgroundColor = UIColor.clear
		self.titleLabel.textColor = UIColor(netHex: 0x7897A3)
		self.titleLabel.font = UIFont.latoBoldWithSize(size: 22)
	}

	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	public var activity: Activity? {
		didSet {
			if self.activity != nil {
				self.titleLabel.text = self.activity!.name.uppercased()
			}
		}
	}
}
