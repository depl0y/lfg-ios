//
//  RequestTableViewCell.swift
//  lfg
//
//  Created by Wim Haanstra on 14/02/2017.
//  Copyright © 2017 Wim Haanstra. All rights reserved.
//

import UIKit
import PureLayout
import DateToolsSwift

class RequestTableViewCell: UITableViewCell, PureLayoutSetup {

	private var cellPadding: CGFloat = 12

	private var modeLabel = UILabel()
	private var timestampLabel = UILabel()
	private var titleLabel = UILabel()
	private var messageLabel = UILabel()

	private var keyValuesView = KeyValuesStack()

	public var playerLabel = UILabel()
	public var groupLabel = UILabel()
	public var booleansView = UIStackView()

	public var playerSeparator = TitleSeparator()

	public var separatorView = UIView()

	private var timestampTimer: Timer?

	public var messageButtonClicked: ((_ request: Request) -> Void)?

	init(reuseIdentifier: String) {
		super.init(style: .default, reuseIdentifier: reuseIdentifier)

		self.addSubview(self.modeLabel)
		self.addSubview(self.timestampLabel)
		self.addSubview(self.titleLabel)
		self.addSubview(self.messageLabel)
		self.addSubview(self.keyValuesView)

		self.addSubview(self.playerSeparator)
		self.addSubview(self.playerLabel)
		self.addSubview(self.groupLabel)
		self.addSubview(self.booleansView)
		self.addSubview(self.separatorView)

		self.setupConstraints()
		self.configureViews()
	}

	func setupConstraints() {
		self.modeLabel.autoPinEdge(.top, to: .top, of: self, withOffset: cellPadding)
		self.modeLabel.autoPinEdge(.left, to: .left, of: self, withOffset: cellPadding)
		self.modeLabel.autoSetDimensions(to: CGSize(width: 50, height: 30))

		self.timestampLabel.autoPinEdge(.top, to: .top, of: self, withOffset: cellPadding + 1)
		self.timestampLabel.autoPinEdge(.right, to: .right, of: self, withOffset: cellPadding * -1)
		self.timestampLabel.autoPinEdge(.left, to: .right, of: self.modeLabel, withOffset: 10)
		self.timestampLabel.autoSetDimension(.height, toSize: 30)

		self.titleLabel.autoPinEdge(.left, to: .left, of: self, withOffset: cellPadding)
		self.titleLabel.autoPinEdge(.right, to: .right, of: self, withOffset: cellPadding * -1)
		self.titleLabel.autoPinEdge(.top, to: .bottom, of: self.modeLabel, withOffset: 4)
		self.titleLabel.autoSetDimension(.height, toSize: 20)

		self.messageLabel.autoPinEdge(.left, to: .left, of: self, withOffset: cellPadding)
		self.messageLabel.autoPinEdge(.right, to: .right, of: self, withOffset: cellPadding * -1)
		self.messageLabel.autoPinEdge(.top, to: .bottom, of: self.titleLabel, withOffset: 2)

		self.keyValuesView.autoPinEdge(.left, to: .left, of: self, withOffset: cellPadding)
		self.keyValuesView.autoPinEdge(.right, to: .right, of: self, withOffset: cellPadding * -1)
		self.keyValuesView.autoPinEdge(.top, to: .bottom, of: self.messageLabel, withOffset: 10)

		self.playerSeparator.autoPinEdge(.left, to: .left, of: self, withOffset: cellPadding)
		self.playerSeparator.autoPinEdge(.right, to: .right, of: self, withOffset: cellPadding * -1)
		self.playerSeparator.autoPinEdge(.top, to: .bottom, of: self.keyValuesView, withOffset: 14)
		self.playerSeparator.autoSetDimension(.height, toSize: 14)

		self.playerLabel.autoPinEdge(.left, to: .left, of: self, withOffset: cellPadding)
		self.playerLabel.autoPinEdge(.right, to: .right, of: self, withOffset: cellPadding * -1)
		self.playerLabel.autoPinEdge(.top, to: .bottom, of: self.playerSeparator, withOffset: 16)
		self.playerLabel.autoSetDimension(.height, toSize: 16)

		self.groupLabel.autoPinEdge(.left, to: .left, of: self, withOffset: cellPadding)
		self.groupLabel.autoPinEdge(.top, to: .bottom, of: self.playerLabel, withOffset: 18)
		self.groupLabel.autoMatch(.width, to: .width, of: self, withMultiplier: 0.5)
		self.groupLabel.autoSetDimension(.height, toSize: 20)
		self.groupLabel.autoPinEdge(.bottom, to: .bottom, of: self, withOffset: (cellPadding + 8) * -1)

		//		self.booleansView.autoPinEdge(.left, to: .right, of: self.groupLabel, withOffset: 2)
		self.booleansView.autoPinEdge(.right, to: .right, of: self, withOffset: cellPadding * -1)
		self.booleansView.autoPinEdge(.top, to: .bottom, of: self.playerLabel, withOffset: 10)

		self.separatorView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets.zero, excludingEdge: .top)
		self.separatorView.autoSetDimension(.height, toSize: 2)
		self.separatorView.backgroundColor = UIColor(netHex: 0xe9e9e9)
	}

	func configureViews() {
		// LFG #33bfc9, LFM #d7c26e
		self.backgroundColor = UIColor.clear

		// Timestamp: 0x0c425e
		self.modeLabel.textAlignment = .center
		self.modeLabel.textColor = UIColor.white
		self.modeLabel.font = UIFont.latoBoldWithSize(size: 16)

		self.timestampLabel.textColor = UIColor(netHex: 0x0c425e)
		self.timestampLabel.font = UIFont.latoBoldWithSize(size: 14)

		self.titleLabel.font = UIFont.latoWithSize(size: 18)

		self.messageLabel.font = UIFont.latoWithSize(size: 14)
		self.messageLabel.numberOfLines = 0
		self.messageLabel.textColor = UIColor(netHex: 0x757575)

		self.groupLabel.font = UIFont.latoBoldWithSize(size: 18)
		self.groupLabel.textColor = UIColor(netHex: 0x757575)

		self.playerLabel.textColor = UIColor(netHex: 0x249381)
		self.playerLabel.font = UIFont(name: "Menlo-Bold", size: 14)

		self.playerSeparator.setTitle(title: "PLAYER")

		self.booleansView.alignment = .trailing
		self.booleansView.spacing = 6

		self.timestampTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(self.updateTimestamp), userInfo: nil, repeats: true)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func awakeFromNib() {
		super.awakeFromNib()
		// Initialization code
	}

	public var request: Request! {
		didSet {
			self.modeLabel.backgroundColor = (self.request.lfg) ? UIColor(netHex: 0x33bfc9) : UIColor(netHex: 0xd7c26e)
			self.modeLabel.text = (self.request.lfg) ? "LFG" : "LFM"
			self.timestampLabel.text = "\(self.request.timeStamp.timeAgo()) ago" //"\(self.request.timeStamp.timeAgoSinceNow) \(self.request.lid)"
			self.titleLabel.text = request.title.uppercased()
			self.messageLabel.text = request.message

			if request.activityGroup != nil {
				self.groupLabel.text = request.activityGroup?.name.uppercased()
			}

			self.playerLabel.text = request.username

			self.keyValuesView.clear()

			if request.language != nil {
				self.keyValuesView.addRow(key: "Language", value: request.language!.title)
			}

			let listValues = request.listValues

			listValues.forEach { (fieldValue) in
				if fieldValue.field != nil {
					self.keyValuesView.addRow(key: fieldValue.field!.name, value: fieldValue.toString())
				}
			}

			self.booleansView.subviews.forEach { $0.removeFromSuperview() }

			for boolValue in request.boolValues.filter({ $0.bool != nil }) {
				if let image = boolValue.field?.iconImage(enabled: boolValue.bool!) {
					let imageView = UIImageView(image: image)
					imageView.contentMode = UIViewContentMode.scaleAspectFit
					self.booleansView.addArrangedSubview(imageView)
					imageView.autoSetDimensions(to: CGSize(width: 36, height: 36))
				}
			}

			if request.activityGroupMessageLink != nil {
				let key = "ion-android-mail-enabled"

				var image = IconManager.sharedInstance.get(key: key)
				if image == nil {
					image = IconManager.sharedInstance.create(
						key: key,
						iconName: "ion-android-mail",
						backgroundColor: UIColor(netHex: 0x249381),
						color: UIColor.white,
						iconSize: 60,
						imageSize: CGSize(width: 80, height: 80))
				}

				let sendMessageButton = UIButton(type: .custom)
				sendMessageButton.setImage(image!, for: .normal)

				self.booleansView.addArrangedSubview(sendMessageButton)
				sendMessageButton.autoSetDimensions(to: CGSize(width: 36, height: 36))
				sendMessageButton.addTarget(self, action: #selector(self.messageClicked), for: UIControlEvents.touchUpInside)
			}

			self.setNeedsLayout()
		}
	}

	@objc private func updateTimestamp() {
		self.timestampLabel.text = self.request.timeStamp.timeAgo() //"\(self.request.timeStamp.timeAgoSinceNow) \(self.request.lid)"
	}

	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
	}

	func messageClicked() {
		log.verbose("Message clicked")
		if self.messageButtonClicked != nil {
			self.messageButtonClicked!(self.request)
		}
	}

	deinit {
		if self.timestampTimer != nil {
			self.timestampTimer!.invalidate()
			self.timestampTimer = nil
		}
	}

}
