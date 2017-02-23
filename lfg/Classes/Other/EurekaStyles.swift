//
//  EurekaStyles.swift
//  lfg
//
//  Created by Wim Haanstra on 23/02/2017.
//  Copyright © 2017 Wim Haanstra. All rights reserved.
//

import UIKit
import Eureka

public class EurekaStyles {
	public static func setup() {
		let defaultFont = UIFont.latoWithSize(size: 14)
		let defaultBoldFont = UIFont.latoBoldWithSize(size: 14)

		AccountRow.defaultCellUpdate = { cell, row in
			cell.textLabel?.font = defaultFont
			cell.textField.font = defaultBoldFont
		}

		PushRow<ActivityGroup>.defaultCellUpdate = { cell, row in
			cell.textLabel?.font = defaultFont
			cell.detailTextLabel?.font = defaultBoldFont
		}

		PushRow<FieldOption>.defaultCellUpdate = { cell, row in
			cell.textLabel?.font = defaultFont
			cell.detailTextLabel?.font = defaultBoldFont
		}

		PushRow<String>.defaultCellUpdate = { cell, row in
			cell.textLabel?.font = defaultFont
			cell.detailTextLabel?.font = defaultBoldFont
		}

		PushRow<Language>.defaultCellUpdate = { cell, row in
			cell.textLabel?.font = defaultFont
			cell.detailTextLabel?.font = defaultBoldFont
		}

		SliderRow.defaultCellUpdate = { cell, row in
			cell.textLabel?.font = defaultFont
			cell.valueLabel.font = defaultBoldFont
			cell.slider.tintColor = UIColor(netHex: 0x249381)
		}

		SwitchRow.defaultCellUpdate = { cell, row in
			cell.textLabel?.font = defaultFont
		}

		ButtonRow.defaultCellUpdate = { cell, row in
			cell.backgroundColor = UIColor(netHex: 0x249381)
			cell.textLabel?.font = defaultBoldFont
			cell.textLabel?.textColor = UIColor.white
		}

		TextAreaRow.defaultCellUpdate = { cell, row in
			cell.textLabel?.font = defaultFont
			cell.textView.font = defaultBoldFont
			cell.placeholderLabel.font = defaultFont
		}

		SegmentedRow<String>.defaultCellUpdate = { cell, row in
			cell.segmentedControl.setTitleTextAttributes([
				NSFontAttributeName: defaultBoldFont,
				NSForegroundColorAttributeName: UIColor(netHex: 0x249381) ], for: .normal)
			cell.segmentedControl.tintColor = UIColor(netHex: 0x249381)
		}
	}
}
