//
//  SettingsViewController.swift
//  lfg
//
//  Created by Wim Haanstra on 24/02/2017.
//  Copyright © 2017 Wim Haanstra. All rights reserved.
//

import UIKit
import Eureka

public class SettingsViewController: FormViewController {

	public init() {
		super.init(nibName: nil, bundle: nil)
	}

	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
	}

	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	public override func viewDidLoad() {
		super.viewDidLoad()

		let settingsButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(self.close(sender:)))
		self.navigationItem.rightBarButtonItem = settingsButton

		form +++ Section("VISIT US")
			<<< ButtonRow("LFG_PUB") { row in
				row.title = "Visit our site"
				}.cellUpdate { cell, _ in
					cell.backgroundColor = UIColor.white
					cell.textLabel?.textColor = UIColor.black
					cell.textLabel?.textAlignment = .left
				}.onCellSelection { _, _ in
					let url = URL(string: "https://lfg.pub")!
					if UIApplication.shared.canOpenURL(url) {
						UIApplication.shared.openURL(url)
					}
			}

			<<< ButtonRow("FACEBOOK") { row in
				row.title = "Visit us on Facebook"
				}.cellUpdate { cell, _ in
					cell.backgroundColor = UIColor.white
					cell.textLabel?.textColor = UIColor.black
					cell.textLabel?.textAlignment = .left
				}.onCellSelection { _, _ in
					// FBID 1118952534893929
					let url = URL(string: "fb://profile/1118952534893929")!
					if UIApplication.shared.canOpenURL(url) {
						UIApplication.shared.openURL(url)
					} else {
						UIApplication.shared.openURL(URL(string: "https://facebook.com/lfgpub")!)
					}
		}

		form +++ Section("CLEANING UP")
			<<< ButtonRow("CLEAN_DEFAULTS") { row in
				row.title = "Clean all defaults"
				}.cellUpdate { cell, _ in
					cell.backgroundColor = UIColor.white
					cell.textLabel?.textColor = UIColor.black
					cell.textLabel?.textAlignment = .left
			}

			<<< ButtonRow("CLEAN_FILTERS") { row in
				row.title = "Clean all filters"
				}.cellUpdate { cell, _ in
					cell.backgroundColor = UIColor.white
					cell.textLabel?.textColor = UIColor.black
					cell.textLabel?.textAlignment = .left
				}.onCellSelection { _, _ in
					DefaultValues.deleteAllFilters()

					self.displayMessage(title: "Done", message: "All your defined filters are removed.")
			}
			
			<<< ButtonRow("CLEAN_CACHE") { row in
				row.title = "Clean cache"
				}.cellUpdate { cell, _ in
					cell.backgroundColor = UIColor.white
					cell.textLabel?.textColor = UIColor.black
					cell.textLabel?.textAlignment = .left
		}

		form +++ Section("DEBUGGING")
			<<< SwitchRow("ANONYMIZE") { row in
				row.title = "Anonymize requests"
				row.value = AppDelegate.anonymize
				}.onChange { row in
					if let value = row.value {
						AppDelegate.anonymize = value
					}
		}

	}

	private func displayMessage(title: String, message: String) {
		let alert = UIAlertController(title: title,
		                              message: message,
			preferredStyle: .alert)

		alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.destructive, handler: nil))
		self.present(alert, animated: true, completion: nil)

	}

	@objc private func close(sender: Any) {
		self.navigationController?.dismiss(animated: true, completion: {
			//self.completed(self.filters)
		})
	}

}
