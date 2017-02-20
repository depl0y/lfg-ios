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

class FieldValueRow {
	public var fieldValue: FieldValue?
	public var fieldNameLabel = UILabel()
	public var fieldValueLabel = UILabel()

	init(fieldValue: FieldValue) {
		self.fieldValue = fieldValue

		if self.fieldValue != nil && self.fieldValue!.field != nil {
			self.fieldNameLabel.text = self.fieldValue!.field!.name
			self.fieldValueLabel.text = self.fieldValue!.toString()
		}
	}

	init(fieldName: String, text: String) {
		self.fieldNameLabel.text = fieldName
		self.fieldValueLabel.text = text
	}

	func addViews(view: UIView, topView: UIView?, topOffset: CGFloat = 2) {
		view.addSubview(self.fieldNameLabel)
		view.addSubview(self.fieldValueLabel)

		self.fieldNameLabel.font = UIFont.latoWithSize(size: 14)
		self.fieldValueLabel.font = UIFont.latoWithSize(size: 14)

		self.fieldNameLabel.textColor = UIColor(netHex: 0x757575)

		self.fieldNameLabel.autoPinEdge(.left, to: .left, of: view)
		self.fieldNameLabel.autoMatch(.width, to: .width, of: view, withMultiplier: 0.35)
		self.fieldNameLabel.autoSetDimension(.height, toSize: 20)

		self.fieldValueLabel.autoPinEdge(.right, to: .right, of: view)
		self.fieldValueLabel.autoPinEdge(.left, to: .right, of: self.fieldNameLabel)
		self.fieldValueLabel.autoMatch(.height, to: .height, of: self.fieldNameLabel)

		if topView == nil {
			self.fieldNameLabel.autoPinEdge(.top, to: .top, of: view, withOffset: topOffset)
			self.fieldValueLabel.autoPinEdge(.top, to: .top, of: view, withOffset: topOffset)
		} else {
			self.fieldNameLabel.autoPinEdge(.top, to: .bottom, of: topView!, withOffset: topOffset)
			self.fieldValueLabel.autoPinEdge(.top, to: .bottom, of: topView!, withOffset: topOffset)
		}
	}
}

class RequestTableViewCell: UITableViewCell, PureLayoutSetup {

	private var cellPadding: CGFloat = 12

	private var modeLabel = UILabel()
	private var timestampLabel = UILabel()
	private var titleLabel = UILabel()
	private var messageLabel = UILabel()

	private var fieldValuesView = UIView()

	private var fieldValueRows = [FieldValueRow]()
	private var boolImages = [UIView]()

	public var playerLabel = UILabel()
	public var groupLabel = UILabel()
	public var booleansView = UIView()

	public var playerSeparator = TitleSeparator()

	public var separatorView = UIView()

	private var timestampTimer: Timer?

	init(reuseIdentifier: String) {
		super.init(style: .default, reuseIdentifier: reuseIdentifier)

		self.addSubview(self.modeLabel)
		self.addSubview(self.timestampLabel)
		self.addSubview(self.titleLabel)
		self.addSubview(self.messageLabel)
		self.addSubview(self.fieldValuesView)
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

		self.fieldValuesView.autoPinEdge(.left, to: .left, of: self, withOffset: cellPadding)
		self.fieldValuesView.autoPinEdge(.right, to: .right, of: self, withOffset: cellPadding * -1)
		self.fieldValuesView.autoPinEdge(.top, to: .bottom, of: self.messageLabel, withOffset: 6)

		self.playerSeparator.autoPinEdge(.left, to: .left, of: self, withOffset: cellPadding)
		self.playerSeparator.autoPinEdge(.right, to: .right, of: self, withOffset: cellPadding * -1)
		self.playerSeparator.autoPinEdge(.top, to: .bottom, of: self.fieldValuesView, withOffset: 6)
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

		self.booleansView.autoPinEdge(.left, to: .right, of: self.groupLabel, withOffset: 2)
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

			self.fieldValuesView.subviews.forEach { (v) in
				v.removeFromSuperview()
			}
			self.fieldValueRows.removeAll()

			self.boolImages.forEach { (imageView) in
				imageView.removeFromSuperview()
			}
			self.boolImages.removeAll()

			self.modeLabel.backgroundColor = (self.request.lfg) ? UIColor(netHex: 0x33bfc9) : UIColor(netHex: 0xd7c26e)
			self.modeLabel.text = (self.request.lfg) ? "LFG" : "LFM"
			self.timestampLabel.text = "\(self.request.timeStamp.timeAgo()) ago" //"\(self.request.timeStamp.timeAgoSinceNow) \(self.request.lid)"
			self.titleLabel.text = request.title.uppercased()
			self.messageLabel.text = request.message

			if request.activityGroup != nil {
				self.groupLabel.text = request.activityGroup?.name.uppercased()
			}

			self.playerLabel.text = request.username

			var previousView: UIView? = nil

			if request.language != nil {
				let topOffset: CGFloat = 6
				let row = FieldValueRow(fieldName: "Language", text: request.language!.title)
				row.addViews(view: self.fieldValuesView, topView: previousView, topOffset: topOffset)
				previousView = row.fieldNameLabel
				self.fieldValueRows.append(row)
			}

			let listValues = request.listValues

			listValues.forEach { (fieldValue) in
				let topOffset: CGFloat = (previousView == nil) ? 6 : 2

				let row = FieldValueRow(fieldValue: fieldValue)
				row.addViews(view: self.fieldValuesView, topView: previousView, topOffset: topOffset)
				previousView = row.fieldNameLabel
				self.fieldValueRows.append(row)
			}

			if previousView != nil {
				previousView!.autoPinEdge(.bottom, to: .bottom, of: self.fieldValuesView, withOffset: -6)
			}

			previousView = nil

			for boolValue in request.boolValues.reversed() {
				if boolValue.bool != nil {
					let image = boolValue.field?.iconImage(enabled: boolValue.bool!)

					if image != nil {
						let imageView = UIImageView(image: image!)
						self.booleansView.addSubview(imageView)

						imageView.autoSetDimensions(to: CGSize(width: 36, height: 36))
						imageView.autoPinEdge(.top, to: .top, of: self.booleansView)

						if previousView == nil {
							imageView.autoPinEdge(.right, to: .right, of: self.booleansView)
						} else {
							imageView.autoPinEdge(.right, to: .left, of: previousView!, withOffset: -4)
						}

						if request.boolValues.last! == boolValue {
							imageView.autoPinEdge(.bottom, to: .bottom, of: self.booleansView)
						}
						self.boolImages.append(imageView)

						previousView = imageView
					}
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

				self.booleansView.addSubview(sendMessageButton)

				sendMessageButton.autoSetDimensions(to: CGSize(width: 36, height: 36))
				sendMessageButton.autoPinEdge(.top, to: .top, of: self.booleansView)

				if previousView == nil {
					sendMessageButton.autoPinEdge(.right, to: .right, of: self.booleansView)
				} else {
					sendMessageButton.autoPinEdge(.right, to: .left, of: previousView!, withOffset: -4)
				}
				self.boolImages.append(sendMessageButton)
				sendMessageButton.addTarget(self, action: #selector(self.messageClicked), for: UIControlEvents.touchUpInside)
				previousView = imageView
			}

			if previousView == nil {
			}
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
	}

	deinit {
		if self.timestampTimer != nil {
			self.timestampTimer!.invalidate()
			self.timestampTimer = nil
		}
	}

}
