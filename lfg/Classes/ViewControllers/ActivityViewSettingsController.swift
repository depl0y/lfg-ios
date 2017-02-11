//
//  ActivityViewSettingsController.swift
//  lfg
//
//  Created by Wim Haanstra on 10/02/2017.
//  Copyright © 2017 Wim Haanstra. All rights reserved.
//

import Foundation
import RealmSwift
import Eureka

class ActivityViewSettingsController: FormViewController {

	var activity: Activity!

	init(activity: Activity) {
		super.init(nibName: nil, bundle: nil)
		self.activity = activity
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		self.title = "Filters"

		let settingsButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.close(sender:)))
		self.navigationItem.rightBarButtonItem = settingsButton

		self.generateFilters()

		form +++ Section("Settings")
			<<< SwitchRow("SUBSCRIBE") { row in
				row.title = "Realtime updates"
				}.onChange { row in
					if row.value == true {
						self.enableAlwaysConnected()
					} else {
						self.disableAlwaysConnected()
					}
				}.cellSetup { cell, row in
					row.value = self.activity.subscribe
		}

	}

	private func saveFilterSettings() {

		var dict = [Int: Any]()

		let allFields = activity.allFields()

		allFields.forEach { (field) in
			let row = self.form.rowBy(tag: field.permalink)

			if row != nil {
				if field.dataType == .Boolean {
					if let switchRow = row as? SwitchRow {
						dict[field.lid] = switchRow.value
					}
				} else if field.dataType == .Number {
					if let sliderRow = row as? SliderRow {
						dict[field.lid] = sliderRow.value
					}
				} else if field.dataType == .Option {
					if field.displayAsCheckboxes {
						if let selectRow = row as? MultipleSelectorRow<FieldOption> {
							if selectRow.value != nil {
								dict[field.lid] = selectRow.value!.map { $0.lid }
								log.debug("\(selectRow.value)")
							}
						}
					} else {
						if let pushRow = row as? PushRow<FieldOption> {
							if pushRow.value != nil {
								dict[field.lid] = pushRow.value!
							}
						}
					}
				} else {
					log.error("Unknown data type for \(activity.permalink):\(field.permalink)")
				}
			}
		}

		log.debug("\(dict)")
	}

	private func generateFilters() {

		activity.fieldGroups.forEach { (fieldGroup) in
			let section = Section(fieldGroup.name)
			self.form.append(section)

			fieldGroup.fields.sorted(byKeyPath: "sortorder").forEach({ (field) in
				if field.filterable {

					if field.dataType == .Boolean {
						let row = SwitchRow(field.permalink) { row in
							row.title = field.name
						}
						section.append(row)
					} else if field.dataType == .Number {
						let row = SliderRow(field.permalink) { row in
							row.title = field.name
							row.minimumValue = Float(field.min)
							row.maximumValue = Float(field.max)
							log.debug("Filter step: \(field.filterStep) for \(field.permalink)")
							row.steps = UInt(field.max - field.min)
						}
						section.append(row)
					} else if field.dataType == .Option {
						if field.displayAsCheckboxes {
							let row = MultipleSelectorRow<FieldOption>(field.permalink) { row in
								row.title = field.name
								row.options = Array(field.options.sorted(byKeyPath: "sortorder"))
								row.displayValueFor = { (rowValue: Set<FieldOption>?) in
									return rowValue?.map({ $0.name }).joined(separator: ",")
								}
							}
							section.append(row)
						} else {
							let row = PushRow<FieldOption>(field.permalink) { row in
								row.title = field.name
								row.options = Array(field.options.sorted(byKeyPath: "sortorder"))
							}
							section.append(row)
						}
					} else {
						log.error("Unknown data type for \(activity.permalink):\(field.permalink)")
					}
				}
			})

		}

	}

	private func enableAlwaysConnected() {
		do {
			let realm = try Realm()

			try realm.write {
				self.activity.subscribe = true
				log.verbose("Enabling realtime updates for \(self.activity.permalink)")
			}
		} catch {
			log.error("Could not write tot realm")
		}
	}

	private func disableAlwaysConnected() {
		do {
			let realm = try Realm()

			try realm.write {
				self.activity.subscribe = false
				log.verbose("Disable realtime updates for \(self.activity.permalink)")
			}
		} catch {
			log.error("Could not write tot realm")
		}
	}

	@objc private func close(sender: Any) {
		self.saveFilterSettings()
		self.navigationController?.dismiss(animated: true, completion: nil)
	}
}
