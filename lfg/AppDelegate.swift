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

let log = SwiftyBeaver.self

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

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

        let navigationController = UINavigationController(rootViewController: ActivitiesViewController())

        self.window = UIWindow()
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()

        _ = SocketConnection.sharedInstance

        do {
            let realm = try Realm()
            log.verbose("\(realm.configuration.fileURL!)")
        } catch {
            log.error("Error opening REALM")
        }
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
}
