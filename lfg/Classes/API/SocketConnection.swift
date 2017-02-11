//
//  SocketConnection.swift
//  lfg
//
//  Created by Wim Haanstra on 09/02/2017.
//  Copyright © 2017 Wim Haanstra. All rights reserved.
//

import Foundation
import ActionCableClient

public class SocketConnection {

    static let sharedInstance = SocketConnection()

    private var client = ActionCableClient(url: URL(string: "wss://lfg.pub/cable")!)

	private var connectedChannel: Channel?

    init() {
        log.verbose("Initializing SocketConnection")

        self.client.onConnected = clientConnected
        self.client.onDisconnected = clientDisconnected
        self.client.willConnect = clientWillConnect

        self.client.origin = "https://lfg.pub"
        self.client.connect()
    }

	public func openChannel(channelName: String, subscribed: @escaping (_ channel: Channel) -> Void) {
        let channelIdentifier = ["activity": channelName]

		if self.connectedChannel != nil {
			if let connectedChannelName = self.connectedChannel!.identifier?["activity"] as? String {
				if connectedChannelName == channelName {
					subscribed(self.connectedChannel!)
				}
			} else {
				log.debug("Unsubscribed from previous channel")
				self.connectedChannel!.unsubscribe()
			}
		}

        self.connectedChannel = self.client.create("RequestChannel", identifier: channelIdentifier, autoSubscribe: true, bufferActions: true)

		self.connectedChannel!.onUnsubscribed = {
			log.debug("Unsubscribed from \(channelName)")
		}

		self.connectedChannel!.onSubscribed = {
			log.verbose("Subscribed to \(channelName)")
			subscribed(self.connectedChannel!)
		}
	}

	public func closeChannel() {
		if self.connectedChannel != nil && self.connectedChannel!.isSubscribed {
			self.connectedChannel!.unsubscribe()
		}
		self.connectedChannel = nil
	}

    private func clientWillConnect() {
        log.verbose("Websocket will connect")
    }

    private func clientConnected() {
        log.debug("Websocket connected to \(self.client.url)")
    }

    private func clientDisconnected(error: ConnectionError?) {
        log.debug("Websocket disconnected: \(error)")
    }

}
