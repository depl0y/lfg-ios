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
import FontAwesome_swift
import SDWebImage
import SwiftMessages
//import GoogleMobileAds

class ActivitiesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PureLayoutSetup {

	let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
	let refreshControl = UIRefreshControl()
	var noResultsView = NoResultsView()

	var activities = [Activity]()
	var upcomingActivities = [Activity]()
	var favorites = [Activity]()

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

		self.loadActivities {
			self.refresh(sender: self)
		}
	}

	override func viewWillLayoutSubviews() {
		self.collectionView.collectionViewLayout.invalidateLayout()
	}

	func setupConstraints() {
		self.collectionView.autoPinEdgesToSuperviewEdges()
	}

	func configureViews() {

		self.view.backgroundColor = UIColor(netHex: 0xf6f7f9)
		/*
		self.bannerView.adUnitID = "ca-app-pub-5982053360792545/5996299508"
		self.bannerView.rootViewController = self
		self.bannerView.adSize = kGADAdSizeSmartBannerPortrait

		let bannerRequest = GADRequest()
		bannerRequest.testDevices = [ kGADSimulatorID ]

		self.bannerView.load(bannerRequest)
		*/
		self.collectionView.backgroundColor = UIColor.clear
		self.collectionView.dataSource = self
		self.collectionView.delegate = self
		self.collectionView.register(ActivityCell.self, forCellWithReuseIdentifier: "activity-cell")
		self.collectionView.register(FavoriteActivityCell.self, forCellWithReuseIdentifier: "favorite-activity-cell")

		self.collectionView.register(ActivitySectionHeader.self,
		                             forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
		                             withReuseIdentifier: "header-cell")
		self.collectionView.register(UICollectionReusableView.self,
		                             forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
		                             withReuseIdentifier: "other-header")

		self.collectionView.backgroundView = self.noResultsView

		self.noResultsView.setTitle(title: "Loading, please wait")
		self.noResultsView.setActive(active: true)

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

		let settingsButton = UIBarButtonItem(title: "S", style: .plain, target: self, action: #selector(self.openSettings))
		settingsButton.setTitleTextAttributes(attributes, for: .normal)
		settingsButton.title = String.fontAwesomeIcon(name: .cogs)
		self.navigationItem.leftBarButtonItem = settingsButton

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

	func openSettings() {
		let vc = SettingsViewController()
		let nc = UINavigationController(rootViewController: vc)
		nc.modalPresentationStyle = .currentContext
		self.navigationController?.present(nc, animated: true, completion: nil)
	}

	override func viewWillAppear(_ animated: Bool) {
		//self.performReload()
		self.loadActivities {
			log.debug("done")
		}
	}

	override func viewDidAppear(_ animated: Bool) {
	}

	private func showSortingNotification() {
	}

	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		collectionView.collectionViewLayout.invalidateLayout()
		collectionView.reloadData()
	}

	@objc private func refresh(sender: AnyObject) {
		log.verbose("Refreshing activities")

		let api = API()
		UIApplication.shared.isNetworkActivityIndicatorVisible = true

		self.noResultsView.setTitle(title: "Loading, please wait")
		self.noResultsView.setActive(active: true)
		self.isLoading = true

		api.activities { (success) in
			UIApplication.shared.isNetworkActivityIndicatorVisible = false
			self.noResultsView.setActive(active: false)
			self.isLoading = false

			if success {
				self.loadActivities {
					self.refreshControl.endRefreshing()
				}
			} else {
				self.noResultsView.setTitle(title: "Failed loading games")

				self.refreshControl.endRefreshing()
			}
		}
	}

	@objc private func toggleSort(sender: Any) {
		self.sortPopular = !self.sortPopular

		self.showSortingNotification()

		if self.sortPopular {
			self.navigationItem.rightBarButtonItem!.title = String.fontAwesomeIcon(name: .sortAmountAsc)
		} else {
			self.navigationItem.rightBarButtonItem!.title = String.fontAwesomeIcon(name: .sortAmountDesc)
		}

		UserDefaults.standard.set(self.sortPopular, forKey: "sorting")
		UserDefaults.standard.synchronize()

		self.performReload()
	}

	private func performReload() {
		let sorting: ActivitySorting = (self.sortPopular) ? .popularity : .alphabetically

		let sortings = [
			ActivitySort(original: self.favorites, new: self.favorites, sorting: .alphabetically, section: 0, done: { (results) in
				self.favorites = results
			}),
			ActivitySort(original: self.activities, new: self.activities, sorting: sorting, section: 1, done: { (results) in
				self.activities = results
			}),
			ActivitySort(original: self.upcomingActivities, new: self.upcomingActivities, sorting: .releaseDate, section: 2, done: { (results) in
				self.upcomingActivities = results
			})
		]

		self.insert(activitySorting: sortings) { }

	}

	/*
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
	*/

	private func createChangeset(previousActivities: [Activity], newActivities: [Activity], section: Int) -> [IndexPathChange] {

		let currentOrdering = self.createActivityOrderDictionary(activities: previousActivities)
		let newOrdering = self.createActivityOrderDictionary(activities: newActivities)

		var combinedActivities = newActivities + previousActivities
		combinedActivities.uniqInPlace()

		var result = [IndexPathChange]()

		for activity in combinedActivities {
			result.append(IndexPathChange(section: section, source: currentOrdering[activity], destination: newOrdering[activity]))
		}

		return result
	}

	private func insert(activitySorting: [ActivitySort], completed: @escaping () -> Void) {

		var changeset = [IndexPathChange]()

		activitySorting.forEach { (ac) in
			if ac.sortType == .alphabetically {
				ac.new.sortAlphabetically()
			} else if ac.sortType == .releaseDate {
				ac.new.sortReleaseDate()
			} else if ac.sortType == .popularity {
				ac.new.sortPopularity()
			}

			let changes = createChangeset(previousActivities: ac.original, newActivities: ac.new, section: ac.section)
			changeset += changes
		}

		if changeset.count > 0 {
			self.collectionView.performBatchUpdates({
				for change in changeset {
					change.performChange(collectionView: self.collectionView)
				}

				activitySorting.forEach { (ac) in
					if ac.done != nil {
						ac.done!(ac.new)
					}
				}
			}) { (done) in
				if done {
					completed()
				}
			}
		} else {
			completed()
		}
	}

	/*
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
	*/

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
		self.noResultsView.setTitle(title: "Loading games")
		self.noResultsView.setActive(active: true)

		self.isLoading = true
		let sorting: ActivitySorting = (self.sortPopular) ? .popularity : .alphabetically

		let sortings = [
			ActivitySort(original: Array(self.favorites), new: Activity.favorites(), sorting: .alphabetically, section: 0, done: { (results) in
				self.favorites = results
			}),
			ActivitySort(original: Array(self.activities), new: Activity.released(), sorting: sorting, section: 1, done: { (results) in
				self.activities = results
			}),
			ActivitySort(original: Array(self.upcomingActivities), new: Activity.upcoming(), sorting: .releaseDate, section: 2, done: { (results) in
				self.upcomingActivities = results
			})
		]

		self.insert(activitySorting: sortings) {
			var images = [URL]()

			Activity.all().forEach {
				if $0.icon != "" {
					images.append(URL(string: $0.icon)!)
				}
			}

			SDWebImagePrefetcher.shared().prefetchURLs(images)
			self.isLoading = false
			completed()
		}
	}
}

extension ActivitiesViewController {
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 3
	}

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

		if self.activities.count == 0 {
			self.collectionView.backgroundView?.isHidden = false

			if self.isLoading {
				self.noResultsView.setTitle(title: "Loading, please wait")
				self.noResultsView.setActive(active: true)
			} else {
				self.noResultsView.setTitle(title: "No requests found")
			}

			self.noResultsView.setActive(active: self.isLoading)

		} else {
			self.collectionView.backgroundView?.isHidden = true
		}

		if section == 0 {
			return self.favorites.count
		} else if section == 1 {
			return self.activities.count
		} else {
			return self.upcomingActivities.count
		}
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if indexPath.section == 0 {
			if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "favorite-activity-cell", for: indexPath) as? FavoriteActivityCell {
				let activity = self.favorites[indexPath.row]
				cell.activity = activity
				return cell
			}
		} else {
			if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "activity-cell", for: indexPath) as? ActivityCell {
				if indexPath.section == 1 {
					let activity = self.activities[indexPath.row]
					cell.activity = activity
				} else {
					let activity = self.upcomingActivities[indexPath.row]
					cell.activity = activity
				}
				return cell
			}
		}
		let c = collectionView.dequeueReusableCell(withReuseIdentifier: "activity-cell", for: indexPath)
		return c
	}

	func collectionView(_ collectionView: UICollectionView,
	                    layout collectionViewLayout: UICollectionViewLayout,
	                    sizeForItemAt indexPath: IndexPath) -> CGSize {

		if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
			if indexPath.section == 0 {
				let marginsAndInsets = flowLayout.sectionInset.left + flowLayout.sectionInset.right // + flowLayout.minimumInteritemSpacing * (2 - 1)
				let itemWidth = (collectionView.bounds.size.width - marginsAndInsets)
				return CGSize(width: itemWidth, height: 32)
			} else {
				let marginsAndInsets = flowLayout.sectionInset.left + flowLayout.sectionInset.right + flowLayout.minimumInteritemSpacing * (2 - 1)
				let itemWidth = (collectionView.bounds.size.width - marginsAndInsets) / 2

				let ratio: CGFloat = 1.7180851064
				let itemHeight = (itemWidth / ratio) + 18
				return CGSize(width: itemWidth, height: itemHeight)
			}
		} else {
			return CGSize(width: 100, height: 100)
		}

	}

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

		var activity: Activity?

		if indexPath.section == 0 {
			activity = self.favorites[indexPath.row]
		} else if indexPath.section == 1 {
			activity = self.activities[indexPath.row]
		} else if indexPath.section == 2 {
			activity = self.upcomingActivities[indexPath.row]
		}

		if activity != nil {
			if self.selectionChanged != nil {
				self.selectionChanged!(activity!)
			} else {
				let vc = ActivityViewController(activity: activity!)
				self.navigationController?.pushViewController(vc, animated: true)
			}
		}

	}

	func collectionView(_ collectionView: UICollectionView,
	                    viewForSupplementaryElementOfKind kind: String,
	                    at indexPath: IndexPath) -> UICollectionReusableView {

		log.debug("Creating header")

		var headerText: String? = nil
		if kind == UICollectionElementKindSectionHeader {
			if indexPath.section == 0 {
				headerText = "FAVORITES"
			} else if indexPath.section == 1 {
				headerText = "ALL GAMES"
			} else if indexPath.section == 2 {
				headerText = "UPCOMING RELEASES"
			}

			if headerText != nil {
				if let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader,
				                                                                withReuseIdentifier: "header-cell",
				                                                                for: indexPath) as? ActivitySectionHeader {
					header.setTitle(title: headerText!)
					return header
				}
			}
		}
		return UICollectionReusableView()
	}

	func collectionView(_ collectionView: UICollectionView,
	                    layout collectionViewLayout: UICollectionViewLayout,
	                    referenceSizeForHeaderInSection section: Int) -> CGSize {

		if (section == 0 && self.favorites.count == 0) || (section == 2 && self.upcomingActivities.count == 0) {
			return CGSize(width: 0.1, height: 0.1)
		}

		return CGSize(width:collectionView.frame.size.width, height:28)
	}

	func collectionView(_ collectionView: UICollectionView, shouldUpdateFocusIn context: UICollectionViewFocusUpdateContext) -> Bool {
		return true
	}
}
