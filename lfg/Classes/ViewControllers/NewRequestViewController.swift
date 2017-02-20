//
//  NewRequestViewController.swift
//  lfg
//
//  Created by Wim Haanstra on 19/02/2017.
//  Copyright © 2017 Wim Haanstra. All rights reserved.
//

import UIKit
import Eureka
import RealmSwift

public class NewRequestViewController: FormViewController {

	private var activity: Activity!

	init(activity: Activity) {
		super.init(nibName: nil, bundle: nil)

		self.activity = activity
		self.title = "New request"
	}

	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override public func viewDidLoad() {
		super.viewDidLoad()

		self.view.backgroundColor = UIColor(netHex: 0xf6f7f9)
		self.tableView?.backgroundColor = UIColor.clear

		let settingsButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.cancel(sender:)))
		self.navigationItem.leftBarButtonItem = settingsButton

		// Do any additional setup after loading the view.

		self.createForm()
	}

	private func createForm() {
		let generalSection = Section("Details")

		let lfRow = SegmentedRow<String>("lf_mode") { row in
			row.options = [ "LFG", "LFM" ]
			row.value = "LFG"
		}

		let groupRow = PushRow<ActivityGroup>("group") { row in
			row.title = "Platform"
			row.options = Array(self.activity.groups)

			row.value = self.activity.groups.first
			_ = row.onPresent({ (_, svc) in
				svc.enableDeselection = false
				svc.selectableRowCellUpdate = { cell, row in
					cell.textLabel?.font = UIFont.latoWithSize(size: 14)
				}

			})
			/*
			if let groupId = self.filters[-1] as? Int {
			row.value = self.activity.groups.filter(NSPredicate(format: "lid = %d", groupId)).first
			}
			*/
		}

		let languageRow = PushRow<Language>("language") { row in
			row.title = "Language"

			do {
				let realm = try Realm()
				let languages = realm.objects(Language.self)
				row.options = Array(languages)

				row.value = languages.first
				_ = row.onPresent({ (_, svc) in
					svc.enableDeselection = false
					svc.selectableRowCellUpdate = { cell, row in
						cell.textLabel?.font = UIFont.latoWithSize(size: 14)
					}

				})

				/*
				if let groupId = self.filters[-3] as? Int {
				row.value = languages.filter(NSPredicate(format: "lid = %d", groupId)).first
				}
				*/
			} catch {
				log.error("Could not read from realm")
			}
		}

		let usernameRow = AccountRow("username") { row in
			row.title = "Username"
			row.placeholder = "Xbox live tag/PSN username/etc"
		}

		generalSection.append(lfRow)
		generalSection.append(groupRow)
		generalSection.append(languageRow)
		generalSection.append(usernameRow)

		self.form.append(generalSection)

		self.generateFields()

		let buttonSection = Section("")

		let buttonRow = ButtonRow("submit") { row in
			row.title = "SUBMIT"
			row.onCellSelection({ (_, _) in
				self.submit()
			})
		}

		buttonSection.append(buttonRow)
		self.form.append(buttonSection)

	}

	private func generateFields() {

		activity.fieldGroups.forEach { (fieldGroup) in
			var section = Section(fieldGroup.name)
			self.form.append(section)

			fieldGroup.fields.sorted(byKeyPath: "sortorder").forEach({ (field) in
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
						row.value = Float(field.min)

						row.displayValueFor = {
							return String(Int($0!))
						}
						row.steps = UInt(field.max - field.min)
					}
					section.append(row)
				} else  if field.dataType == .Option {
					let row = PushRow<FieldOption>(field.permalink) { row in
						row.title = field.name
						row.options = Array(field.options.sorted(byKeyPath: "sortorder"))

						_ = row.onPresent({ (_, svc) in
							svc.selectableRowCellUpdate = { cell, row in
								cell.textLabel?.font = UIFont.latoWithSize(size: 14)
							}
							svc.enableDeselection = false
							svc.sectionKeyForValue = { option in
								return option.group != nil ? option.group! : ""
							}
						})

						row.value = row.options.first
					}
					section.append(row)
				} else if field.dataType == .Text {
					let textSection = Section(field.name)

					let row = TextAreaRow(field.permalink) { row in
						row.placeholder = (field.desc != nil) ? field.desc! : field.name
						row.title = field.name
					}
					textSection.append(row)
					self.form.append(textSection)
				} else {
					log.error("Unknown data type for \(activity.permalink):\(field.permalink)")
				}
			})
		}
	}

	func submit() {
		var values = [String: Any]()

		if let row = self.form.rowBy(tag: "lf_mode") as? SegmentedRow<String> {
			values["lfg"] = (row.value != nil && row.value! == "LFG")
		}

		if let row = self.form.rowBy(tag: "language") as? PushRow<Language>, row.value != nil {
			values["language"] = row.value!.lid
		}

		if let row = self.form.rowBy(tag: "username") as? AccountRow, row.value != nil {
			values["username"] = row.value!
		} else {
			log.error("Username is required for submit")
			let alert = UIAlertController(title: "Missing information",
			                              message: "You need to enter a username, so people can find you.",
			                              preferredStyle: .alert)

			alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.destructive, handler: nil))
			self.present(alert, animated: true, completion: nil)
			return
		}

		if let row = self.form.rowBy(tag: "group") as? PushRow<ActivityGroup>, row.value != nil {
			values["group"] = row.value!.lid
		} else {
			let alert = UIAlertController(title: "Missing information",
			                              message: "You need to select a platform you play on.",
			                              preferredStyle: .alert)

			alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.destructive, handler: nil))
			self.present(alert, animated: true, completion: nil)
			return
		}

		form.rows.forEach { (row) in
			if let tag = row.tag {
				if let field = Field.findByPermalink(permalink: tag) {
					if field.dataType
						== .Number {
						if let slideRow = row as? SliderRow, slideRow.value != nil {
							values[tag] = Int(slideRow.value!)
						}
					} else if field.dataType == .Boolean {
						if let switchRow = row as? SwitchRow {
							values[tag] = switchRow.value == nil ? false : switchRow.value!
						}
					} else if field.dataType == .Option {
						if let pushRow = row as? PushRow<FieldOption>, pushRow.value != nil {
							values[tag] = pushRow.value!.lid
						}
					} else if field.dataType == .Text {
						if let textRow = row as? TextAreaRow, textRow.value != nil {
							values[tag] = textRow.value!
						}
					}
				}
			}
		}

		values["activity_id"] = self.activity.lid

		log.debug("\(values)")

		let api = API()
		self.tableView?.layer.opacity = 0.6
		self.tableView?.isUserInteractionEnabled = false
		api.create(activity: self.activity, parameters: values) { (success, uniqueId, message, diff) in
			if success {
				UserDefaults.standard.set(uniqueId, forKey: "request.\(self.activity.permalink)")
				self.dismiss(animated: true, completion: nil)
			} else {
				self.tableView?.layer.opacity = 1
				self.tableView?.isUserInteractionEnabled = true

				if message == "timeout" && diff != nil {
					let alert = UIAlertController(title: "Hold your horses",
					                              message: "You need to wait at least \(diff!) more seconds before you can post again, sorry about that.",
					                              preferredStyle: .alert)

					alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.destructive, handler: nil))
					self.present(alert, animated: true, completion: nil)
				} else if message == "banned" {
					let alert = UIAlertController(title: "Banned",
					                              message: "You are banned from posting to our services.",
						preferredStyle: .alert)

					alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.destructive, handler: nil))
					self.present(alert, animated: true, completion: nil)
				} else {
					let alert = UIAlertController(title: "Unknown error",
					                              message: "An error occurred while posting your information, please try again later",
					                              preferredStyle: .alert)

					alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.destructive, handler: nil))
					self.present(alert, animated: true, completion: nil)
				}
			}
			log.debug("\(success)")
		}
	}

	override public func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@objc private func cancel(sender: Any) {
		self.navigationController?.dismiss(animated: true, completion: {
			//self.completed(self.filters)
		})
	}
}
