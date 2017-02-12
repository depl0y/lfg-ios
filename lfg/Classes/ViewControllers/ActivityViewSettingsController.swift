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
	var filters = [Int: Any]()

	var completed: ((_ filters: [Int: Any]) -> Void)!

	init(activity: Activity, filters: [Int: Any], completed: @escaping (_ filters: [Int: Any]) -> Void) {
		super.init(nibName: nil, bundle: nil)
		self.activity = activity

		self.filters = filters
		self.completed = completed
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		self.title = "Filters"

		let settingsButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.close(sender:)))
		self.navigationItem.rightBarButtonItem = settingsButton

		let generalSection = Section("General")

		let groupRow = PushRow<ActivityGroup>("activity_group") { row in
			row.title = "Platform"
			row.options = Array(self.activity.groups)
			if let groupId = self.filters[-1] as? Int {
				row.value = self.activity.groups.filter(NSPredicate(format: "lid = %d", groupId)).first
			}
		}

		let lfgRow = PushRow<String>("lf_mode") { row in
			row.title = "LFG/LFM"
			row.options = [ "LFG", "LFM" ]
			if let mode = self.filters[-2] as? String {
				row.value = mode
			}
		}

		generalSection.append(groupRow)
		generalSection.append(lfgRow)

		self.form.append(generalSection)

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

		self.filters = [Int: Any]()

		if let pushRow = self.form.rowBy(tag: "activity_group") as? PushRow<ActivityGroup> {
			if pushRow.value != nil {
				self.filters[-1] = pushRow.value!.lid
			}
		}

		if let pushRow = self.form.rowBy(tag: "lf_mode") as? PushRow<String> {
			if pushRow.value != nil {
				self.filters[-2] = pushRow.value!
			}
		}

		let allFields = activity.allFields()

		allFields.forEach { (field) in
			let row = self.form.rowBy(tag: field.permalink)

			if row != nil {
				if field.dataType == .Boolean,
					let switchRow = row as? SwitchRow {

					self.filters[field.lid] = switchRow.value

				} else if field.dataType == .Number,
					let sliderRow = row as? SliderRow {

					if sliderRow.value != nil {
						let value = Int(sliderRow.value!)
						if value != field.min {
							self.filters[field.lid] = value
						}
					}

				} else if field.dataType == .Option && field.displayAsCheckboxes,
					let selectRow = row as? MultipleSelectorRow<FieldOption> {

					if selectRow.value != nil {
						self.filters[field.lid] = selectRow.value!.map { $0.lid }
						log.debug("\(selectRow.value)")
					}

				} else if field.dataType == .Option && !field.displayAsCheckboxes,
					let pushRow = row as? PushRow<FieldOption> {

					if pushRow.value != nil {
						self.filters[field.lid] = pushRow.value!.lid
					}

				} else {
					log.error("Unknown data type for \(activity.permalink):\(field.permalink)")
				}
			}
		}

		log.debug("\(self.filters)")
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

							if let value = self.filters[field.lid] as? Int {
								row.value = Float(value)
							}
						}
						section.append(row)
					} else if field.dataType == .Option && field.displayAsCheckboxes {
						let row = MultipleSelectorRow<FieldOption>(field.permalink) { row in
							row.title = field.name
							row.options = Array(field.options.sorted(byKeyPath: "sortorder"))
							row.displayValueFor = { (rowValue: Set<FieldOption>?) in
								return rowValue?.map({ $0.name }).joined(separator: ",")
							}
						}
						section.append(row)
					} else  if field.dataType == .Option && !field.displayAsCheckboxes {
						let row = PushRow<FieldOption>(field.permalink) { row in
							row.title = field.name
							row.options = Array(field.options.sorted(byKeyPath: "sortorder"))

							if let optionId = self.filters[field.lid] as? Int {
								row.value = field.options.filter(NSPredicate(format: "lid = %d", optionId)).first
							}
						}
						section.append(row)

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
		self.navigationController?.dismiss(animated: true, completion: {
			self.completed(self.filters)
		})
	}
}
