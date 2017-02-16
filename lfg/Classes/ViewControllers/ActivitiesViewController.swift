//
//  ViewController.swift
//  lfg
//
//  Created by Wim Haanstra on 08/02/2017.
//  Copyright © 2017 Wim Haanstra. All rights reserved.
//

import UIKit
import PureLayout
import RealmSwift
//import FontAwesome
import FontAwesome_swift

class ActivitiesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

	let tableView = UITableView()
	let refreshControl = UIRefreshControl()

	var activities = [Activity]()
	var sortPopular = false

	override func viewDidLoad() {
		super.viewDidLoad()

		self.sortPopular = UserDefaults.standard.bool(forKey: "sorting")

		self.loadActivities()

		self.view.addSubview(self.tableView)
		self.tableView.dataSource = self
		self.tableView.delegate = self
		self.tableView.autoPinEdgesToSuperviewEdges()

		refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
		refreshControl.addTarget(self, action: #selector(self.refresh(sender:)), for: UIControlEvents.valueChanged)
		self.tableView.addSubview(refreshControl)

		let sortButton = UIBarButtonItem(title: "S", style: .plain, target: self, action: #selector(self.toggleSort(sender:)))
		let attributes = [NSFontAttributeName: UIFont.fontAwesome(ofSize: 20)] as [String: Any]
		sortButton.setTitleTextAttributes(attributes, for: .normal)

		sortButton.title = String.fontAwesomeIcon(name: .sortAmountDesc)

		self.navigationItem.rightBarButtonItem = sortButton
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	override func viewWillAppear(_ animated: Bool) {
		refresh(sender: self)
	}

	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.activities.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		var cell = tableView.dequeueReusableCell(withIdentifier: "activity-cell")

		if cell == nil {
			cell = UITableViewCell(style: .subtitle, reuseIdentifier: "activity-cell")
		}

		let activity = self.activities[indexPath.row]
		cell!.textLabel?.text = activity.name
		cell!.textLabel?.font = UIFont.latoWithSize(size: 16)

		return cell!
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let activity = self.activities[indexPath.row]
		let vc = ActivityViewController(activity: activity)
		self.navigationController?.pushViewController(vc, animated: true)
	}

	@objc private func refresh(sender: AnyObject) {
		let api = API()
		api.activities { (success) in
			if success {
				self.loadActivities()
			}
			self.refreshControl.endRefreshing()
		}
	}

	@objc private func toggleSort(sender: Any) {
		self.sortPopular = !self.sortPopular

		if self.sortPopular {
			self.navigationItem.rightBarButtonItem!.title = String.fontAwesomeIcon(name: .sortAmountAsc)
		} else {
			self.navigationItem.rightBarButtonItem!.title = String.fontAwesomeIcon(name: .sortAmountDesc)
		}

		UserDefaults.standard.set(self.sortPopular, forKey: "sorting")
		UserDefaults.standard.synchronize()

		self.sortActivities()
	}

	private func sortActivities() {
		if self.sortPopular {
			self.activities.sort(by: { (lhs, rhs) -> Bool in
				return lhs.popularity > rhs.popularity
			})
		} else {
			self.activities.sort(by: { (lhs, rhs) -> Bool in
				return lhs.name < rhs.name
			})
		}
		self.tableView.reloadData()
	}

	private func loadActivities() {
		do {
			let realm = try Realm()
			self.activities = Array(realm.objects(Activity.self))
			self.sortActivities()
		} catch {
			log.error("Error opening realm")
		}
	}
}
