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

		self.setupDefaultFilters()
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
				}.cellSetup { _, row in
					row.value = self.activity.subscribe
			}
			<<< SwitchRow("FAVORITE") { row in
				row.title = "Favorite"
				}.onChange { row in
					if row.value == true {
						self.activity.enableFavorite()
					} else {
						self.activity.disableFavorite()
					}
				}.cellSetup { _, row in
					row.value = self.activity.favorite
		}
	}

	private func setupDefaultFilters() {
		let generalSection = Section("Details")

		let groupRow = PushRow<ActivityGroup>("activity_group") { row in
			row.title = "Platform"
			row.options = Array(self.activity.groups)
			if let groupId = self.filters[-1] as? Int {
				row.value = self.activity.groups.filter(NSPredicate(format: "lid = %d", groupId)).first
			}

			_ = row.onPresent({ (_, svc) in
				svc.selectableRowCellUpdate = { cell, _ in
					cell.textLabel?.font = UIFont.latoWithSize(size: 14)
				}
			})
		}

		let lfgRow = PushRow<String>("lf_mode") { row in
			row.title = "LFG/LFM"
			row.options = [ "LFG", "LFM" ]
			if let mode = self.filters[-2] as? String {
				row.value = mode.uppercased()
			}
			_ = row.onPresent({ (_, svc) in
				svc.selectableRowCellUpdate = { cell, _ in
					cell.textLabel?.font = UIFont.latoWithSize(size: 14)
				}
			})
		}

		let languageRow = PushRow<Language>("language") { row in
			row.title = "Language"

			do {
				let realm = try Realm()
				let languages = realm.objects(Language.self)
				row.options = Array(languages)

				if let groupId = self.filters[-3] as? Int {
					row.value = languages.filter(NSPredicate(format: "lid = %d", groupId)).first
				}

			} catch {
				log.error("Could not write tot realm")
			}
			_ = row.onPresent({ (_, svc) in
				svc.selectableRowCellUpdate = { cell, _ in
					cell.textLabel?.font = UIFont.latoWithSize(size: 14)
				}
			})
		}

		generalSection.append(lfgRow)
		generalSection.append(groupRow)
		generalSection.append(languageRow)

		self.form.append(generalSection)
	}

	private func saveFilterSettings() {
		self.filters = [Int: Any]()

		if let pushRow = self.form.rowBy(tag: "activity_group") as? PushRow<ActivityGroup>, pushRow.value != nil {
			self.filters[-1] = pushRow.value!.lid
		}

		if let pushRow = self.form.rowBy(tag: "lf_mode") as? PushRow<String>, pushRow.value != nil {
			self.filters[-2] = pushRow.value!.lowercased()
		}

		if let pushRow = self.form.rowBy(tag: "language") as? PushRow<Language>, pushRow.value != nil {
			self.filters[-3] = pushRow.value!.lid
		}

		for field in activity.allFields() {
			if let row = self.form.rowBy(tag: field.permalink) {

				switch field.dataType {
				case .Boolean:
					if let switchRow = row as? SwitchRow {
						self.filters[field.lid] = switchRow.value
					}
				case .Number:
					if let sliderRow = row as? SliderRow, sliderRow.value != nil, Int(sliderRow.value!) != field.min {
						self.filters[field.lid] = [ Int(sliderRow.value!), field.max ]
					}
				case .Option:
					if field.displayAsCheckboxes {
						if let selectRow = row as? MultipleSelectorRow<FieldOption>, selectRow.value != nil {
							self.filters[field.lid] = selectRow.value!.map { $0.lid }
						}
					} else {
						if let pushRow = row as? PushRow<FieldOption>, pushRow.value != nil {
							self.filters[field.lid] = pushRow.value!.lid
						}
					}
				default:
					log.error("Unknown datatype for \(activity.permalink):\(field.permalink)")
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

						if let value = self.filters[field.lid] as? Bool {
							row.value = value
						}

						section.append(row)
					} else if field.dataType == .Number {
						let row = SliderRow(field.permalink) { row in
							row.title = field.name
							row.minimumValue = Float(field.min)
							row.maximumValue = Float(field.max)
							log.debug("Filter step: \(field.filterStep) for \(field.permalink)")
							row.steps = UInt(field.max - field.min)
							row.value = row.minimumValue
							row.displayValueFor = {
								return "> \(Int($0!))"
							}

							if let value = self.filters[field.lid] as? [Int] {
								row.value = Float(value[0])
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

							_ = row.onPresent({ (_, svc) in
								svc.selectableRowCellUpdate = { cell, row in
									cell.textLabel?.font = UIFont.latoWithSize(size: 14)
								}
								svc.sectionKeyForValue = { option in
									return option.group != nil ? option.group! : ""
								}
							})
						}
						section.append(row)

					} else {
						log.error("Unknown data type for \(activity.permalink):\(field.permalink)")
					}
				}
			})

		}
	}

	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
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
