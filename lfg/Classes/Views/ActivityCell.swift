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

public class ActivityCell: UICollectionViewCell, PureLayoutSetup {

	private var imageView = UIImageView()
	private var titleLabel = UILabel()

	override init(frame: CGRect) {
		super.init(frame: frame)

		self.addSubview(self.titleLabel)
		self.addSubview(self.imageView)

		self.setupConstraints()
		self.configureViews()
	}

	public func setupConstraints() {
		self.titleLabel.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), excludingEdge: .top)
		self.titleLabel.autoSetDimension(.height, toSize: 15)

		self.imageView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), excludingEdge: .bottom)
		self.imageView.autoPinEdge(.bottom, to: .top, of: self.titleLabel, withOffset: -2)
	}

	public func configureViews() {
		self.backgroundColor = UIColor.clear

		self.titleLabel.backgroundColor = UIColor.clear
		self.titleLabel.textColor = UIColor(netHex: 0x7897A3)
		self.titleLabel.font = UIFont.latoBoldWithSize(size: 14)
	}

	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	public var activity: Activity? {
		didSet {
			if self.activity != nil {
				self.imageView.sd_setImage(with: URL(string: self.activity!.icon))
				self.titleLabel.text = self.activity!.name.uppercased()
			}
		}
	}

}
