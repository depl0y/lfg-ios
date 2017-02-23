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
import SafariServices

class ActivityViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, PureLayoutSetup {

	var activity: Activity!
	var cableChannel: Channel?
	var client: ActionCableClient!
	var requests = [Request]()
	var filters = [Int: Any]()
	var moreAvailable: Bool = false
	var currentPage: Int = 1
	var isLoading: Bool = false

	var statusPanelHeightConstraint: NSLayoutConstraint!

	let tableView = UITableView()

	var discordInfoView: DiscordInfoView!
	var statusPanel = StatusPanel()
	var addButton = UIButton(type: .custom)
	var noResultsView = NoResultsView()

	var upButton = UIButton(type: .custom)
	var upButtonIsHidden = true

	init(activity: Activity) {
		super.init(nibName: nil, bundle: nil)

		self.client = ActionCableClient(url: URL(string: "wss://lfg.pub/cable")!)
		self.discordInfoView = DiscordInfoView(activity: activity, sender: self)
		self.activity = activity
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

		self.view.addSubview(self.upButton)

		self.setupConstraints()
		self.configureViews()

		if activity.lastConfigUpdate != nil && activity.lastConfigUpdate! > Date().addingTimeInterval(-300) {
			self.query()
		} else {
			self.configuration()
		}

		NotificationCenter.default.addObserver(
			self,
			selector: #selector(self.applicationDidBecomeActive),
			name: NSNotification.Name.UIApplicationDidBecomeActive,
			object: nil)
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(self.applicationWillEnterForeground),
			name: NSNotification.Name.UIApplicationWillEnterForeground,
			object: nil)
	}

	func setupConstraints() {
		self.statusPanel.autoPinEdge(.bottom, to: .top, of: self.addButton)
		self.statusPanel.autoPinEdge(.left, to: .left, of: self.view)
		self.statusPanel.autoPinEdge(.right, to: .right, of: self.view)
		self.statusPanelHeightConstraint = self.statusPanel.autoSetDimension(.height, toSize: 36)

		self.addButton.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets.zero, excludingEdge: .top)
		self.addButton.autoSetDimension(.height, toSize: 44)

		self.tableView.autoPinEdge(.top, to: .top, of: self.view)
		self.tableView.autoPinEdge(.left, to: .left, of: self.view)
		self.tableView.autoPinEdge(.right, to: .right, of: self.view)
		self.tableView.autoPinEdge(.bottom, to: .top, of: self.addButton)

		self.upButton.autoPinEdge(.bottom, to: .bottom, of: self.tableView, withOffset: -10)
		self.upButton.autoPinEdge(.right, to: .right, of: self.tableView, withOffset: -10)
		self.upButton.autoSetDimensions(to: CGSize(width: 44, height: 44))

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

		self.upButton.backgroundColor = UIColor(netHex: 0x4F4F4F)
		self.upButton.layer.cornerRadius = 5
		self.upButton.isHidden = true

		let upButtonTitle = NSMutableAttributedString()
		upButtonTitle.addWithFont(String.fontAwesomeIcon(name: .chevronUp), font: UIFont.fontAwesome(ofSize: 20), color: UIColor.white)
		self.upButton.setAttributedTitle(upButtonTitle, for: .normal)
		self.upButton.addTarget(self, action: #selector(self.scrollToTop), for: .touchUpInside)
	}

	func applicationDidBecomeActive() {
		self.viewWillAppear(false)
		self.query()
	}

	func applicationWillEnterForeground() {
	}

	func scrollToTop() {
		let top = NSIndexPath(row: Foundation.NSNotFound, section: 0)
		self.tableView.scrollToRow(at: top as IndexPath, at: .top, animated: true)
	}

	override func viewWillAppear(_ animated: Bool) {
		if let bg = self.tableView.backgroundView {
			bg.setNeedsLayout()
			bg.layoutIfNeeded()
		}
		self.setButton()

		if self.activity.subscribe {
			self.connectClient()
		} else {
			if self.client.isConnected && self.cableChannel != nil && self.cableChannel!.isSubscribed {
				self.cableChannel!.unsubscribe()
				self.disconnectClient()
			}
		}
	}

	override func viewWillDisappear(_ animated: Bool) {
		if self.navigationController?.viewControllers.index(of: self) == nil {
			self.disconnectClient()
		}

		super.viewWillDisappear(animated)
	}

	private func configuration() {
		let api = API()
		self.statusPanel.setTitle(title: "Downloading configuration", active: true)
		api.configuration(activity: self.activity) { (success) in
			if success {
				self.query()
			}
		}
	}

	private func setButton() {

		let buttonTitle = NSMutableAttributedString()

		let key = "request.\(self.activity.permalink)"
		if (UserDefaults.standard.object(forKey: key) as? String) != nil {
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

		if page == 1 {
			let top = NSIndexPath(row: Foundation.NSNotFound, section: 0)
			self.tableView.scrollToRow(at: top as IndexPath, at: .top, animated: false)
		}

		self.statusPanel.setTitle(title: "Retrieving requests", active: true)

		let api = API()

		UIApplication.shared.isNetworkActivityIndicatorVisible = true
		api.query(activity: self.activity, page: page, perPage: perPage, filters: self.filters, completed: { (success, requests) in

			if self.cableChannel != nil && self.cableChannel!.isSubscribed {
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
				self.tableView.reloadData()
			}

		})
	}

	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		let currentOffset = scrollView.contentOffset.y
		let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height

		if !self.isLoading && self.moreAvailable {
			if maximumOffset - currentOffset <= (scrollView.frame.size.height / 2) {
				self.currentPage += 1
				self.query(page: self.currentPage)
			}
		}

		if currentOffset > scrollView.bounds.size.height && self.upButtonIsHidden {
			self.upButtonIsHidden = false
			self.upButton.isHidden = false
			self.upButton.layer.opacity = 0

			UIView.animate(withDuration: 0.4, animations: {
				self.upButton.layer.opacity = 0.7
			})
		} else if currentOffset < scrollView.bounds.size.height && !self.upButtonIsHidden {
			self.upButtonIsHidden = true
			UIView.animate(withDuration: 0.4, animations: {
				self.upButton.layer.opacity = 0
			}, completion: { (done) in
				if done {
					self.upButton.isHidden = true
				}
			})
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}

	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}

	func removeRequest(request: Request) {
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
		let nc = UINavigationController(rootViewController: vc)
		nc.modalPresentationStyle = .currentContext

		self.present(nc, animated: true) {
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
			let nc = UINavigationController(rootViewController: vc)
			nc.modalPresentationStyle = .currentContext
			self.navigationController?.present(nc, animated: true, completion: nil)
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
		UIApplication.shared.isNetworkActivityIndicatorVisible = false
	}
}

// Websocket connection
extension ActivityViewController {

	func connectClient() {
		if !self.client.isConnected {
			self.client.origin = "https://lfg.pub"
			self.client.onConnected = onWebsocketConnected
			self.client.willConnect = onWebsocketWillConnect
			self.client.onDisconnected = onWebsocketDisconnected
			self.client.connect()
		} else {
			log.debug("Websocket already connected")
			self.onWebsocketConnected()
		}
	}

	func disconnectClient() {
		log.debug("Disconnecting websocket")
		if self.cableChannel != nil && self.cableChannel!.isSubscribed {
			self.cableChannel!.unsubscribe()
		}

		if self.client.isConnected {
			self.client.disconnect()
		}
	}

	func openChannel() {
		if !self.client.isConnected {
			log.debug("Websocket is not connected")
			return
		}

		if self.cableChannel != nil && self.cableChannel!.isSubscribed {
			log.debug("Channel already connected")
			return
		}

		log.debug("Opening channel \(self.activity.permalink)")
		self.cableChannel = self.client.create("RequestChannel",
		                                       identifier: [ "activity" : activity.permalink ],
		                                       autoSubscribe: false,
		                                       bufferActions: false)

		UIApplication.shared.isNetworkActivityIndicatorVisible = true

		self.cableChannel?.onReceive = { (JSON: Any?, error: Error?) in
			if error != nil {
				log.error("\(error)")
			} else {
				self.parseSocketInfo(JSON: JSON)
			}
		}

		self.cableChannel?.onSubscribed = {
			log.debug("Subscribed to \(self.activity.permalink)")
		}

		self.cableChannel?.onUnsubscribed = {
			log.debug("Unsubscribed to \(self.activity.permalink)")
		}

		self.cableChannel?.onRejected = {
			UIApplication.shared.isNetworkActivityIndicatorVisible = false
			log.error("Channel rejected")
		}

		self.cableChannel?.subscribe()
	}

	func onWebsocketWillConnect() {
	}

	func onWebsocketConnected() {
		log.debug("Websocket Client connected")
		self.openChannel()
	}

	func onWebsocketDisconnected(error: ConnectionError?) {
		log.debug("Websocket Client disconnected")
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
}

// Extension containing UITableViewDatasource / UITableViewDelegate
extension ActivityViewController {

	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 56
	}

	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		if self.activity.discordChannel != nil && self.activity.discordInviteCode != nil {
			return self.discordInfoView
		} else {
			return nil
		}
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

		if request.activityGroupMessageLink != nil {
			cell!.messageButtonClicked = { (request: Request) in

				if let url = URL(string: request.activityGroupMessageLink!.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!) {

					log.debug("Opening url: \(url)")
					let sfc = SFSafariViewController(url: url)
					self.present(sfc, animated: true, completion: nil)
				} else {
					log.error("URL invalid: \(request.activityGroupMessageLink!)")
				}
			}
		} else {
			cell!.messageButtonClicked = nil
		}

		return cell!
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		//let request = self.requests[indexPath.row]

		//let vc = RequestViewController(request: request)
		//self.navigationController?.pushViewController(vc, animated: true)

		tableView.deselectRow(at: indexPath, animated: false)
	}
}
