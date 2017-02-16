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

class ActivityViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

	var activity: Activity!
	var cableChannel: Channel?

	let panel = JKNotificationPanel()

	let tableView = UITableView()
	var statusPanel = StatusPanel()

	var requests = [Request]()

	var filters = [Int: Any]()

	private var moreAvailable: Bool = false
	private var currentPage: Int = 1
	private var isLoading: Bool = false

	private var channelSubscribed = false

	init(activity: Activity) {
		super.init(nibName: nil, bundle: nil)
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

		self.view.addSubview(self.statusPanel)
		self.statusPanel.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets.zero, excludingEdge: .top)
		self.statusPanel.autoSetDimension(.height, toSize: 28)
		self.statusPanel.setTitle(title: "Loading", active: true, animate: false)

		self.view.addSubview(self.tableView)
		self.tableView.backgroundColor = UIColor.clear
		self.tableView.delegate = self
		self.tableView.dataSource = self
		self.tableView.rowHeight = UITableViewAutomaticDimension
		self.tableView.estimatedRowHeight = 100
		self.tableView.separatorStyle = .none
		self.tableView.tableFooterView = UIView()

		self.tableView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0), excludingEdge: .bottom)
		self.tableView.autoPinEdge(.bottom, to: .top, of: self.statusPanel)

		self.setupRealtimeConnection()
		self.configuration()

		let settingsButton = UIBarButtonItem(title: "E", style: .plain, target: self, action: #selector(self.showSettings(sender:)))

		let attributes = [NSFontAttributeName: UIFont.fontAwesome(ofSize: 20)] as [String: Any]
		settingsButton.setTitleTextAttributes(attributes, for: .normal)

		settingsButton.title = String.fontAwesomeIcon(name: .search)

		self.navigationItem.rightBarButtonItem = settingsButton
	}

	override func viewWillAppear(_ animated: Bool) {
		setupRealtimeConnection()
	}

	override func viewWillDisappear(_ animated: Bool) {

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

	private func query(page: Int = 1, perPage: Int = 30) {
		if self.isLoading {
			return
		}

		self.isLoading = true

		log.verbose("Table: \(self.tableView.contentOffset)")
		if page == 1 {
			let p = CGPoint(x: 0, y: -64)
			self.tableView.setContentOffset(p, animated: false)
		}

		self.statusPanel.setTitle(title: "Retrieving requests", active: true)

		let api = API()
		api.query(activity: self.activity, page: page, perPage: perPage, filters: self.filters, completed: { (success, requests) in

			if self.channelSubscribed {
				self.statusPanel.setTitle(title: "Streaming requests realtime", active: true)
			} else {
				self.statusPanel.setTitle(title: "Ready", active: false)
			}

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
		return self.requests.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let request = self.requests[indexPath.row]

		var cell = tableView.dequeueReusableCell(withIdentifier: "request-cell") as? RequestTableViewCell

		if cell == nil {
			cell = RequestTableViewCell(reuseIdentifier: "request-cell")
		}

		cell!.request = request

		return cell!
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let request = self.requests[indexPath.row]

		let vc = RequestViewController(request: request)
		self.navigationController?.pushViewController(vc, animated: true)

		tableView.deselectRow(at: indexPath, animated: true)
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
				self.channelSubscribed = true
				channel.onReceive = { (JSON: Any?, error: Error?) in
					if error != nil {
						log.error("\(error)")
					} else {
						self.parseSocketInfo(JSON: JSON)
					}
				}
				channel.onRejected = {
					self.channelSubscribed = true
					log.error("Channel rejected")
				}
			})
		} else {
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
						self.requests.append(response.request!)
						self.requests.sort()
						self.tableView.reloadSections([0], with: UITableViewRowAnimation.fade)
						self.tableView.endUpdates()
					}
				}
			}
		}
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

	deinit {
		log.verbose("dinit")
		SocketConnection.sharedInstance.closeChannel()
	}
}
