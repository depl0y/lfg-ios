//
//  AppDelegate.swift
//  lfg
//
//  Created by Wim Haanstra on 08/02/2017.
//  Copyright © 2017 Wim Haanstra. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyBeaver
import Eureka
// import GoogleMobileAds

let log = SwiftyBeaver.self

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UINavigationControllerDelegate {

	var window: UIWindow?
	static var anonymize: Bool = false

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.

		// Setup logging to console
		let console = ConsoleDestination()

		console.levelString.verbose = "💜 VERBOSE"
		console.levelString.debug = "💚 DEBUG  "
		console.levelString.info = "💙 INFO   "
		console.levelString.warning = "💛 WARNING"
		console.levelString.error = "⛔️ ERROR  "

		console.format = "$DHH:mm:ss$d $L [$N:$l] $M"
		log.addDestination(console)

		// GADMobileAds.configure(withApplicationID: "ca-app-pub-5982053360792545~3042833103")

		self.window = UIWindow()

		if UIDevice.current.userInterfaceIdiom == .pad {
			self.window?.rootViewController = BaseiPadController()
		} else {
			let navigationController = UINavigationController(rootViewController: ActivitiesViewController())
			navigationController.delegate = self
			self.window?.rootViewController = navigationController
		}

		self.window?.makeKeyAndVisible()

		do {
			let config = Realm.Configuration(
				schemaVersion: 4,
				migrationBlock: { _, oldSchemaVersion in
					if oldSchemaVersion < 1 { }
				}
			)

			Realm.Configuration.defaultConfiguration = config
			let realm = try Realm()
			log.verbose("\(realm.configuration.fileURL!)")
		} catch {
			log.error("Error opening REALM")
		}

		UINavigationBar.appearance().barTintColor = UIColor(netHex: 0x249381)
		UINavigationBar.appearance().tintColor = UIColor.white
		UINavigationBar.appearance().isTranslucent = false

		UINavigationBar.appearance().titleTextAttributes = [
			NSForegroundColorAttributeName: UIColor.white,
			NSFontAttributeName: UIFont.latoBoldWithSize(size: 15)
		]

		UIBarButtonItem.appearance().setTitleTextAttributes([
			NSForegroundColorAttributeName: UIColor.white,
			NSFontAttributeName: UIFont.latoBoldWithSize(size: 15)
		], for: .normal)

		UIApplication.shared.statusBarStyle = .lightContent
		EurekaStyles.setup()

		return true
	}

	func applicationWillResignActive(_ application: UIApplication) {
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
	}

	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}

	func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
		viewController.edgesForExtendedLayout = []
	}
}
