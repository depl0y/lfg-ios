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
	var upcomingActivities = [Activity]()
	// var fetchedActivities = [Activity]()

	var sortPopular = false
	var margin: CGFloat = 10
	var columns: CGFloat = 2

	var isLoading = false

	public var selectionChanged: ((_ activity: Activity) -> Void)?

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

	override func viewWillLayoutSubviews() {
		log.debug("Will layout")
		self.collectionView.collectionViewLayout.invalidateLayout()
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
		self.collectionView.register(ActivitySectionHeader.self,
		                             forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
		                             withReuseIdentifier: "header-cell")
		self.collectionView.register(UICollectionReusableView.self,
		                             forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
		                             withReuseIdentifier: "other-header")

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
		return 2
	}

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if section == 0 {
			return self.activities.count
		} else {
			return self.upcomingActivities.count
		}
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "activity-cell", for: indexPath) as? ActivityCell {
			if indexPath.section == 0 {
				let activity = self.activities[indexPath.row]
				cell.activity = activity
			} else {
				let activity = self.upcomingActivities[indexPath.row]
				cell.activity = activity
			}

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

		let activity = (indexPath.section == 0) ? self.activities[indexPath.row] : self.upcomingActivities[indexPath.row]

		if self.selectionChanged != nil {
			self.selectionChanged!(activity)
		} else {
			let vc = ActivityViewController(activity: activity)
			self.navigationController?.pushViewController(vc, animated: true)
		}
	}

	func collectionView(_ collectionView: UICollectionView,
	                    viewForSupplementaryElementOfKind kind: String,
	                    at indexPath: IndexPath) -> UICollectionReusableView {

		log.debug("Creating header")
		if kind == UICollectionElementKindSectionHeader && indexPath.section == 1 {
			if let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader,
			                                                                withReuseIdentifier: "header-cell",
			                                                                for: indexPath) as? ActivitySectionHeader {
				header.setTitle(title: "UPCOMING RELEASES")
				return header
			} else {
				return UICollectionReusableView()
			}
		} else {
			return UICollectionReusableView()
		}
	}

	func collectionView(_ collectionView: UICollectionView,
	                    layout collectionViewLayout: UICollectionViewLayout,
	                    referenceSizeForHeaderInSection section: Int) -> CGSize {
		if section == 1 {
			return CGSize(width:collectionView.frame.size.width, height:30.0)
		} else {
			return CGSize.zero
		}
	}

	func collectionView(_ collectionView: UICollectionView, shouldUpdateFocusIn context: UICollectionViewFocusUpdateContext) -> Bool {
		return true
	}

	/*
	func collectionView(collectionView: UICollectionView,
	layout collectionViewLayout: UICollectionViewLayout,
	referenceSizeForHeaderInSection section: Int) -> CGSize {
	return CGSize(width: 300, height: 30)
	}
	*/

	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		collectionView.collectionViewLayout.invalidateLayout()
		collectionView.reloadData()
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

		self.insertActivities(
			previousActivities: self.activities,
			newActivities: self.activities,
			upcomingActivities: self.upcomingActivities,
			newUpcomingActivities: self.upcomingActivities) { }

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

	private func sortByReleaseDate(activities: [Activity]) -> [Activity] {
		return activities.sorted(by: { (lhs, rhs) -> Bool in
			if lhs.releaseDate == nil && rhs.releaseDate == nil {
				return lhs.name < rhs.name
			} else {
				return lhs.releaseDate! < rhs.releaseDate!
			}
		})
	}

	private func createChangeset(previousActivities: [Activity], newActivities: [Activity], section: Int) -> [IndexPathChange] {

		let currentOrdering = self.createActivityOrderDictionary(activities: previousActivities)
		let newOrdering = self.createActivityOrderDictionary(activities: newActivities)

		var combinedActivities = newActivities + previousActivities
		combinedActivities.uniqInPlace()

		var result = [IndexPathChange]()

		for activity in combinedActivities {
			result.append(IndexPathChange(section: section, from: currentOrdering[activity], to: newOrdering[activity]))
		}

		return result

	}

	private func insertActivities(previousActivities: [Activity],
	                              newActivities: [Activity],
	                              upcomingActivities: [Activity],
	                              newUpcomingActivities: [Activity],
	                              completed: @escaping () -> Void) {

		let sortedNewActivities = self.sort(activities: newActivities)
		var changeSet = createChangeset(previousActivities: previousActivities, newActivities: sortedNewActivities, section: 0)

		let sortedNewUpcomingActivities = self.sortByReleaseDate(activities: newUpcomingActivities)
		let upcomingChanges = createChangeset(previousActivities: upcomingActivities, newActivities: sortedNewUpcomingActivities, section: 1)

		changeSet += upcomingChanges

		if changeSet.count > 0 {
			self.collectionView.performBatchUpdates({

				for change in changeSet {
					change.performChange(collectionView: self.collectionView)
				}

				self.activities = sortedNewActivities
				self.upcomingActivities = sortedNewUpcomingActivities

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

	private func createActivityOrderDictionary(activities: [Activity]) -> [Activity: Int] {
		var result = [Activity: Int]()

		for (index, activity) in activities.enumerated() {
			result[activity] = index
		}

		return result
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

		let previousActivities = Array(self.activities)
		let fetchedActivities = Activity.released()

		let previousUpcoming = Array(self.upcomingActivities)
		let fetchedUpcoming = Activity.upcoming()

		self.insertActivities(previousActivities: previousActivities,
		                      newActivities: fetchedActivities,
		                      upcomingActivities: previousUpcoming,
		                      newUpcomingActivities: fetchedUpcoming,
		                      completed: {

								let images = Array(Activity.all()).map { URL(string: $0.icon) }
								SDWebImagePrefetcher.shared().prefetchURLs(images)
								self.isLoading = false
								completed()
		})
	}
}
