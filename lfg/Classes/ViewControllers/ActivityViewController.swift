//
//  ActivityViewController.swift
//  lfg
//
//  Created by Wim Haanstra on 09/02/2017.
//  Copyright © 2017 Wim Haanstra. All rights reserved.
//

import UIKit
import ActionCableClient
import RealmSwift
import JKNotificationPanel
import PureLayout

class ActivityViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, PureLayoutSetup {

	var activity: Activity!
	var cableChannel: Channel?
	var noRequests = UILabel()

	let panel = JKNotificationPanel()

	let tableView = UITableView()
	var discordInfoView: DiscordInfoView!
	var statusPanel = StatusPanel()
	var addButton = UIButton(type: .custom)
	var noResultsView = NoResultsView()
	var requests = [Request]()

	var filters = [Int: Any]()

	var statusPanelHeightConstraint: NSLayoutConstraint!

	private var moreAvailable: Bool = false
	private var currentPage: Int = 1
	private var isLoading: Bool = false

	private var channelSubscribed = false

	init(activity: Activity) {
		super.init(nibName: nil, bundle: nil)

		self.discordInfoView = DiscordInfoView(activity: activity, sender: self)
		self.activity = activity
		self.panel.timeUntilDismiss = 5
		self.title = activity.name

	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		self.view.backgroundColor = UIColor(netHex: 0xf6f7f9)

		self.view.addSubview(self.tableView)
		self.view.addSubview(self.addButton)
		self.view.addSubview(self.statusPanel)

		if self.activity.discordChannel != nil && self.activity.discordInviteCode != nil {
			self.tableView.tableHeaderView = self.discordInfoView
		}

		self.setupConstraints()
		self.configureViews()

		self.setupRealtimeConnection()

		if activity.lastConfigUpdate != nil && activity.lastConfigUpdate! > Date().addingTimeInterval(-300) {
			self.query()
			self.refreshFilters()
		} else {
			self.configuration()
		}
	}

	func setupConstraints() {
		self.statusPanel.autoPinEdge(.bottom, to: .top, of: self.addButton)
		self.statusPanel.autoPinEdge(.left, to: .left, of: self.view)
		self.statusPanel.autoPinEdge(.right, to: .right, of: self.view)
		self.statusPanelHeightConstraint = self.statusPanel.autoSetDimension(.height, toSize: 36)

		if self.activity.discordChannel != nil && self.activity.discordInviteCode != nil {
			self.discordInfoView.autoPinEdge(.top, to: .top, of: self.tableView)
			self.discordInfoView.autoPinEdge(.left, to: .left, of: self.tableView)
			self.discordInfoView.autoMatch(.width, to: .width, of: self.tableView)
			if self.activity.discordChannel != nil && self.activity.discordInviteCode != nil {
				self.discordInfoView.autoSetDimension(.height, toSize: 56)
			} else {
				self.discordInfoView.autoSetDimension(.height, toSize: 0)
			}
		}

		self.addButton.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets.zero, excludingEdge: .top)
		self.addButton.autoSetDimension(.height, toSize: 44)

		self.tableView.autoPinEdge(.top, to: .top, of: self.view)
		self.tableView.autoPinEdge(.left, to: .left, of: self.view)
		self.tableView.autoPinEdge(.right, to: .right, of: self.view)
		self.tableView.autoPinEdge(.bottom, to: .top, of: self.addButton)

	}

	func configureViews() {
		self.statusPanel.setTitle(title: "Loading", active: true, animate: false)
		//self.statusPanel.layer.opacity = 0.7

		self.tableView.backgroundColor = UIColor.clear
		self.tableView.delegate = self
		self.tableView.dataSource = self
		self.tableView.rowHeight = UITableViewAutomaticDimension
		self.tableView.estimatedRowHeight = 100
		self.tableView.separatorStyle = .none
		self.tableView.tableFooterView = UIView()

		self.tableView.backgroundView = self.noResultsView

		self.addButton.backgroundColor = UIColor(netHex: 0x249381)
		self.addButton.setTitleColor(UIColor.white, for: .normal)

		let buttonTitle = NSMutableAttributedString()
		buttonTitle.addWithFont("Add request", font: UIFont.latoBoldWithSize(size: 14), color: UIColor.white)
		self.addButton.setAttributedTitle(buttonTitle, for: .normal)
		self.addButton.addTarget(self, action: #selector(self.addRequestButton), for: UIControlEvents.touchUpInside)

		let settingsButton = UIBarButtonItem(title: "E", style: .plain, target: self, action: #selector(self.showSettings(sender:)))

		let attributes = [NSFontAttributeName: UIFont.fontAwesome(ofSize: 20)] as [String: Any]
		settingsButton.setTitleTextAttributes(attributes, for: .normal)
		settingsButton.title = String.fontAwesomeIcon(name: .search)

		self.navigationItem.rightBarButtonItem = settingsButton
		self.edgesForExtendedLayout = []
	}

	override func viewWillAppear(_ animated: Bool) {
		setupRealtimeConnection()

		if let bg = self.tableView.backgroundView {
			bg.setNeedsLayout()
			bg.layoutIfNeeded()
		}

		self.setButton()
	}

	override func viewWillDisappear(_ animated: Bool) {
		if self.navigationController?.viewControllers.index(of: self) == nil {
			if self.channelSubscribed {
				SocketConnection.sharedInstance.closeChannel()
				self.channelSubscribed = false
			}
		}

		super.viewWillDisappear(animated)
	}

	private func configuration() {
		let api = API()
		self.statusPanel.setTitle(title: "Downloading configuration", active: true)
		api.configuration(activity: self.activity) { (success) in
			if success {
				self.refreshFilters()
				self.query()
			}
		}
	}

	private func setButton() {

		let buttonTitle = NSMutableAttributedString()

		let key = "request.\(self.activity.permalink)"
		if let uniqueId = UserDefaults.standard.object(forKey: key) as? String {
			buttonTitle.addWithFont("Remove request", font: UIFont.latoBoldWithSize(size: 14), color: UIColor.white)
			self.addButton.backgroundColor = UIColor(netHex: 0xD9534F)
		} else {
			buttonTitle.addWithFont("Add request", font: UIFont.latoBoldWithSize(size: 14), color: UIColor.white)
			self.addButton.backgroundColor = UIColor(netHex: 0x249381)
		}
		self.addButton.setAttributedTitle(buttonTitle, for: .normal)

	}

	private func query(page: Int = 1, perPage: Int = 30) {
		if self.isLoading {
			return
		}

		self.isLoading = true

		self.showStatus()

		self.noResultsView.setTitle(title: "Loading, please wait")
		self.noResultsView.setActive(active: true)

		log.verbose("Table: \(self.tableView.contentOffset)")
		if page == 1 {
			let p = CGPoint(x: 0, y: 0)
			self.tableView.setContentOffset(p, animated: false)
		}

		self.statusPanel.setTitle(title: "Retrieving requests", active: true)

		let api = API()

		UIApplication.shared.isNetworkActivityIndicatorVisible = true
		api.query(activity: self.activity, page: page, perPage: perPage, filters: self.filters, completed: { (success, requests) in

			if self.channelSubscribed {
				self.statusPanel.setTitle(title: "Streaming requests realtime", active: true)
			} else {
				UIApplication.shared.isNetworkActivityIndicatorVisible = false
				self.statusPanel.setTitle(title: "Ready", active: false)
			}

			self.hideStatus()
			self.isLoading = false

			if success && requests != nil {
				if page == 1 {
					self.requests = requests!
				} else {
					self.requests.append(contentsOf: requests!)
				}
				self.requests.sort()
				self.moreAvailable = requests!.count == perPage

				if self.moreAvailable {
					log.debug("More requests available")
				} else {
					log.debug("No more requests available")
				}

				self.tableView.reloadData()
			}

		})
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		if self.requests.count == 0 {
			tableView.backgroundView?.isHidden = false

			if self.isLoading {
				self.noResultsView.setTitle(title: "Loading, please wait")
				self.noResultsView.setActive(active: true)
			} else {
				self.noResultsView.setTitle(title: "No requests found")
			}

			self.noResultsView.setActive(active: self.isLoading)

		} else {
			tableView.backgroundView?.isHidden = true
		}

		return self.requests.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let request = self.requests[indexPath.row]

		var cell = tableView.dequeueReusableCell(withIdentifier: "request-cell") as? RequestTableViewCell

		if cell == nil {
			cell = RequestTableViewCell(reuseIdentifier: "request-cell")
		}

		cell!.selectionStyle = .none
		cell!.request = request

		return cell!
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		//let request = self.requests[indexPath.row]

		//let vc = RequestViewController(request: request)
		//self.navigationController?.pushViewController(vc, animated: true)

		tableView.deselectRow(at: indexPath, animated: false)
	}

	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		if !self.isLoading && self.moreAvailable {
			let currentOffset = scrollView.contentOffset.y
			let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height

			if maximumOffset - currentOffset <= (scrollView.frame.size.height / 2) {
				self.currentPage += 1
				self.query(page: self.currentPage)
			}
		}
	}

	func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {

	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	private func refreshFilters() {

	}

	private func setupRealtimeConnection() {
		if activity.subscribe {
			SocketConnection.sharedInstance.openChannel(channelName: self.activity.permalink, subscribed: { (channel) in
				UIApplication.shared.isNetworkActivityIndicatorVisible = true

				self.channelSubscribed = true
				channel.onReceive = { (JSON: Any?, error: Error?) in
					if error != nil {
						log.error("\(error)")
					} else {
						self.parseSocketInfo(JSON: JSON)
					}
				}
				channel.onRejected = {
					UIApplication.shared.isNetworkActivityIndicatorVisible = false

					self.channelSubscribed = true
					log.error("Channel rejected")
				}
			})
		} else {
			UIApplication.shared.isNetworkActivityIndicatorVisible = false

			SocketConnection.sharedInstance.closeChannel()
			self.channelSubscribed = false
		}
	}

	public func parseSocketInfo(JSON: Any?) {
		if JSON == nil {
			return
		}

		if let dict = JSON as? [String: Any] {
			if let response = WebsocketResponse(JSON: dict) {
				if response.request != nil {
					if response.remove {
						self.removeRequest(request: response.request!)
					} else {
						self.tableView.beginUpdates()
						let request = response.request!
						request.activity = self.activity
						self.requests.append(request)
						self.requests.sort()
						self.tableView.reloadSections([0], with: UITableViewRowAnimation.fade)
						self.tableView.endUpdates()
					}
				}
			}
		}
	}

	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}

	private func removeRequest(request: Request) {
		self.tableView.beginUpdates()

		self.requests = self.requests.filter { (r) -> Bool in
			return r.lid != request.lid
		}

		self.tableView.reloadSections([0], with: UITableViewRowAnimation.fade)

		self.tableView.endUpdates()
	}

	@objc private func showSettings(sender: Any) {
		let vc = ActivityViewSettingsController(activity: self.activity, filters: self.filters) { (filters) in
			self.filters = filters
			self.query()
		}
		let nav = UINavigationController(rootViewController: vc)
		self.present(nav, animated: true) {
		}
	}

	private func showStatus() {
		UIView.animate(withDuration: 0.2, animations: {
			self.statusPanel.activityIndicator.isHidden = false
			self.statusPanel.activityIndicator.startAnimating()

			self.statusPanelHeightConstraint.constant = 36
			self.view.layoutIfNeeded()
		})
	}

	@objc private func addRequestButton() {

		let key = "request.\(self.activity.permalink)"
		if let uniqueId = UserDefaults.standard.object(forKey: key) as? String {
			let api = API()
			api.remove(activity: self.activity, uniqueId: uniqueId, completed: { (success) in
				if success {
					UserDefaults.standard.removeObject(forKey: key)
				}
				self.setButton()
			})
		} else {
			let vc = NewRequestViewController(activity: self.activity)
			//self.navigationController?.pushViewController(vc, animated: true)
			let nc = UINavigationController(rootViewController: vc)
			self.present(nc, animated: true, completion: nil)
		}

	}

	private func hideStatus() {

		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
			self.statusPanelHeightConstraint.constant = 0
			self.statusPanel.activityIndicator.stopAnimating()
			self.statusPanel.activityIndicator.isHidden = true

			UIView.animate(withDuration: 0.2, animations: {
				self.view.layoutIfNeeded()
			})
		}
	}

	deinit {
		SocketConnection.sharedInstance.closeChannel()
		UIApplication.shared.isNetworkActivityIndicatorVisible = false
	}
}
