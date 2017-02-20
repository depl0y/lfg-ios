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
import SDWebImage

class ActivitiesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PureLayoutSetup {

	let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())

	let refreshControl = UIRefreshControl()

	var activities = [Activity]()
	// var fetchedActivities = [Activity]()

	var sortPopular = false
	var margin: CGFloat = 10
	var columns: CGFloat = 2

	var isLoading = false

	override func viewDidLoad() {
		super.viewDidLoad()

		self.sortPopular = UserDefaults.standard.bool(forKey: "sorting")

		self.view.addSubview(self.collectionView)
		self.collectionView.addSubview(refreshControl)

		self.setupConstraints()
		self.configureViews()

		// self.loadActivities()
		self.loadActivities {
			self.refresh(sender: self)
		}
}

	func setupConstraints() {
		self.collectionView.autoPinEdgesToSuperviewEdges()
	}

	func configureViews() {

		self.view.backgroundColor = UIColor(netHex: 0xf6f7f9)

		self.collectionView.backgroundColor = UIColor.clear
		self.collectionView.dataSource = self
		self.collectionView.delegate = self
		self.collectionView.register(ActivityCell.self, forCellWithReuseIdentifier: "activity-cell")

		guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
		flowLayout.minimumInteritemSpacing = margin
		flowLayout.minimumLineSpacing = margin
		flowLayout.sectionInset = UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)

		refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
		refreshControl.addTarget(self, action: #selector(self.refresh(sender:)), for: UIControlEvents.valueChanged)

		let sortButton = UIBarButtonItem(title: "S", style: .plain, target: self, action: #selector(self.toggleSort(sender:)))
		let attributes = [NSFontAttributeName: UIFont.fontAwesome(ofSize: 16)] as [String: Any]
		sortButton.setTitleTextAttributes(attributes, for: .normal)
		sortButton.title = String.fontAwesomeIcon(name: .sortAmountDesc)

		self.navigationItem.rightBarButtonItem = sortButton

		let deleteButton = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(self.removeItem(sender:)))
		//deleteButton.setTitleTextAttributes(attributes, for: .normal)
		//deleteButton.title = String.fontAwesomeIcon(name: .trash)

		self.navigationItem.leftBarButtonItem = deleteButton

		let image = UIImage(named: "white-logo")
		let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 32))
		imageView.image = image
		imageView.contentMode = UIViewContentMode.scaleAspectFit
		self.navigationItem.titleView = imageView
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	override func viewWillAppear(_ animated: Bool) {
	}

	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.activities.count
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "activity-cell", for: indexPath) as? ActivityCell {
			let activity = self.activities[indexPath.row]
			cell.activity = activity
			return cell

		} else {
			let c = collectionView.dequeueReusableCell(withReuseIdentifier: "activity-cell", for: indexPath)
			return c
		}
	}

	func collectionView(_ collectionView: UICollectionView,
	                    layout collectionViewLayout: UICollectionViewLayout,
	                    sizeForItemAt indexPath: IndexPath) -> CGSize {

		if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
			let marginsAndInsets = flowLayout.sectionInset.left + flowLayout.sectionInset.right + flowLayout.minimumInteritemSpacing * (2 - 1)
			let itemWidth = (collectionView.bounds.size.width - marginsAndInsets) / 2

			let ratio: CGFloat = 1.7180851064
			let itemHeight = (itemWidth / ratio) + 18

			return CGSize(width: itemWidth, height: itemHeight)
		} else {
			return CGSize(width: 100, height: 100)
		}
	}

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let activity = self.activities[indexPath.row]
		let vc = ActivityViewController(activity: activity)
		self.navigationController?.pushViewController(vc, animated: true)
	}

	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		collectionView.collectionViewLayout.invalidateLayout()
	}

	@objc private func refresh(sender: AnyObject) {
		log.verbose("Refreshing activities")

		let api = API()
		UIApplication.shared.isNetworkActivityIndicatorVisible = true

		api.activities { (success) in
			UIApplication.shared.isNetworkActivityIndicatorVisible = false
			if success {
				self.loadActivities {
					self.refreshControl.endRefreshing()
				}
			} else {
				self.refreshControl.endRefreshing()
			}
		}
	}

	@objc private func removeItem(sender: Any) {
		/*
		let previousActivities = Array(self.activities)

		if self.activities.count > 0 {
			self.activities.remove(at: 0)
		}

		self.insertActivities(previousActivities: previousActivities, newActivities: self.activities) { }
		*/
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

		self.insertActivities(previousActivities: self.activities, newActivities: self.activities) { }
	}

	private func sort(activities: [Activity]) -> [Activity] {

		if self.sortPopular {
			return activities.sorted(by: { (lhs, rhs) -> Bool in
				return lhs.popularity > rhs.popularity
			})
		} else {
			return activities.sorted(by: { (lhs, rhs) -> Bool in
				return lhs.name < rhs.name
			})
		}
	}

	private func insertActivities(previousActivities: [Activity], newActivities: [Activity], completed: @escaping () -> Void) {
		var currentOrdering = [Activity: Int]()
		var newOrdering = [Activity: Int]()

		for (index, activity) in previousActivities.enumerated() {
			currentOrdering[activity] = index
		}

		let sortedActivities = self.sort(activities: newActivities)

		for (index, activity) in sortedActivities.enumerated() {
			newOrdering[activity] = index
		}

		var combinedActivities = sortedActivities + previousActivities
		combinedActivities.uniqInPlace()

		if combinedActivities.count > 0 {
			self.collectionView.performBatchUpdates({
				for activity in combinedActivities {
					if currentOrdering[activity] != nil && newOrdering[activity] == nil {
						// REMOVE

						let from = IndexPath(item: currentOrdering[activity]!, section: 0)
						self.collectionView.deleteItems(at: [ from ])

					} else if currentOrdering[activity] == nil && newOrdering[activity] != nil {
						// INSERT

						let to = IndexPath(item: newOrdering[activity]!, section: 0)
						self.collectionView.insertItems(at: [ to ])

					} else if currentOrdering[activity] != nil && newOrdering[activity] != nil {
						// MOVE

						let fromActivity = IndexPath(item: currentOrdering[activity]!, section: 0)
						let toActivity = IndexPath(item: newOrdering[activity]!, section: 0)

						if self.collectionView.cellForItem(at: fromActivity) != nil {
							self.collectionView.moveItem(at: fromActivity, to: toActivity)
						}
					}
				}

				self.activities = sortedActivities
				self.collectionView.reloadData()

			}) { (done) in
				if done {
					completed()
				}
			}
		} else {
			completed()
		}
	}

	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}

	private func loadActivities(completed: @escaping () -> Void) {
		if isLoading {
			return
		}

		log.verbose("Loading activities")

		self.isLoading = true

		do {
			let previousActivities = Array(self.activities)
			let realm = try Realm()
			let fetchedActivities = Array(realm.objects(Activity.self))

			self.insertActivities(previousActivities: previousActivities, newActivities: fetchedActivities, completed: {
				let images = Array(self.activities).map { URL(string: $0.icon) }
				SDWebImagePrefetcher.shared().prefetchURLs(images)
				self.isLoading = false
				completed()
			})
		} catch {
			log.error("Error opening realm")
			completed()
		}
	}
}
