//
//  DiscordInfoView.swift
//  lfg
//
//  Created by Wim Haanstra on 17/02/2017.
//  Copyright © 2017 Wim Haanstra. All rights reserved.
//

import UIKit
import SafariServices

public class DiscordInfoView: UIView, PureLayoutSetup {

	public var iconImage = UIImageView()
	public var activity: Activity
	public var titleLabel = UILabel()

	weak var sender: UIViewController?

	public var actionButton = UIButton(type: .custom)

	init(activity: Activity, sender: UIViewController) {
		self.activity = activity
		self.sender = sender

		super.init(frame: CGRect.zero)

		self.addSubview(self.iconImage)
		self.addSubview(self.titleLabel)
		self.addSubview(self.actionButton)

		self.setupConstraints()
		self.configureViews()
	}

	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	public func setupConstraints() {

		self.iconImage.autoPinEdge(.left, to: .left, of: self, withOffset: 10)
		self.iconImage.autoMatch(.height, to: .height, of: self, withMultiplier: 0.7)
		self.iconImage.autoMatch(.width, to: .height, of: self, withMultiplier: 0.7)
		self.iconImage.autoAlignAxis(.horizontal, toSameAxisOf: self)

		self.titleLabel.autoPinEdge(.right, to: .right, of: self, withOffset: -10)
		self.titleLabel.autoSetDimension(.height, toSize: 16)
		self.titleLabel.autoPinEdge(.left, to: .right, of: self.iconImage, withOffset: 10)
		self.titleLabel.autoAlignAxis(.horizontal, toSameAxisOf: self)

		self.actionButton.autoPinEdgesToSuperviewEdges()
	}

	public func configureViews() {
		self.backgroundColor = UIColor(netHex: 0x738bd7)

		self.iconImage.image = UIImage(named: "discord")

		let text = NSMutableAttributedString()
		text.addWithFont("Join our ", font: UIFont.latoWithSize(size: 14))
		text.addWithFont(activity.name, font: UIFont.latoBoldWithSize(size: 14))
		text.addWithFont(" channel", font: UIFont.latoWithSize(size: 14))

		self.titleLabel.attributedText = text
		self.titleLabel.textColor = UIColor.white

		self.actionButton.addTarget(self, action: #selector(self.clickActionButton), for: UIControlEvents.touchUpInside)

		self.actionButton.setBackgroundImage(UIImage(), for: .normal)
	}

	func clickActionButton() {
		if self.activity.discordInviteCode != nil {
			let url = "https://discord.gg/\(self.activity.discordInviteCode!)"

			let sfc = SFSafariViewController(url: URL(string: url)!)
			sender?.present(sfc, animated: true, completion: nil)
		}
	}

}
