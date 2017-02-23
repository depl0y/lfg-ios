//
//  KeyValueView.swift
//  lfg
//
//  Created by Wim Haanstra on 22/02/2017.
//  Copyright © 2017 Wim Haanstra. All rights reserved.
//

import UIKit
import PureLayout

class KeyValuesStack: UIStackView {

	private var rows = [KeyValueView]()

	init() {
		super.init(frame: CGRect.zero)
		self.axis = UILayoutConstraintAxis.vertical
		self.spacing = 4
	}

	required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func addRow(key: String, value: String, height: CGFloat = 20) {
		let row = KeyValueView(key: key, value: value)
		self.addArrangedSubview(row)

		//row.autoSetDimension(.height, toSize: height)
		row.autoMatch(.width, to: .width, of: self)
		self.rows.append(row)
	}

	func clear() {

		self.rows.forEach {
			$0.removeFromSuperview()
		}
		self.rows.removeAll()
	}
}

class KeyValueView: UIView, PureLayoutSetup {

	private var keyLabel = UILabel()
	private var valueLabel = UILabel()

	init(key: String, value: String) {
		super.init(frame: CGRect.zero)

		self.addSubview(self.keyLabel)
		self.addSubview(self.valueLabel)

		self.key = key
		self.value = value

		self.setupConstraints()
		self.configureViews()
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func setupConstraints() {
		let margin: CGFloat = 0
		let insets = UIEdgeInsets(top: 0, left: margin, bottom: 0, right: margin * -1)

		self.keyLabel.autoPinEdgesToSuperviewEdges(with: insets, excludingEdge: .right)
		self.keyLabel.autoMatch(.width, to: .width, of: self, withMultiplier: 0.4)

		self.valueLabel.autoPinEdge(.top, to: .top, of: self)
		self.valueLabel.autoPinEdge(.bottom, to: .bottom, of: self)
		self.valueLabel.autoPinEdge(.left, to: .right, of: self.keyLabel)
		self.valueLabel.autoPinEdge(.right, to: .right, of: self)
	}

	func configureViews() {
		self.valueLabel.textColor = UIColor.black
		self.valueLabel.font = UIFont.latoBoldWithSize(size: 14)

		self.keyLabel.textColor = UIColor(netHex: 0x757575)
		self.keyLabel.font = UIFont.latoWithSize(size: 14)
	}

	public var key: String? {
		get {
			return self.keyLabel.text
		}
		set {
			self.keyLabel.text = newValue
		}
	}

	public var value: String? {
		get {
			return self.valueLabel.text
		}
		set {
			self.valueLabel.text = newValue
		}
	}

}
