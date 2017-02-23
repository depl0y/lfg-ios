//
//  OAuthInfo.swift
//  lfg
//
//  Created by Wim Haanstra on 20/02/2017.
//  Copyright © 2017 Wim Haanstra. All rights reserved.
//

import Foundation

public class OAuthInfoStore {

	static let sharedInstance = OAuthInfoStore()

	public var providers = [
		GoogleOAuthInfo()
	]

}

public class OAuthInfo {
	public var icon: String {
		return ""
	}

	public var name: String {
		return ""
	}

	public var clientId: String {
		return ""
	}

	public var urlScheme: String {
		return ""
	}
}

public class GoogleOAuthInfo: OAuthInfo {

	public override var name: String {
		return "Google"
	}

	public override var icon: String {
		return "google"
	}

	public override var clientId: String {
		return "290176971013-ehac1mfmoesq234ctan71dhfofbv9psf.apps.googleusercontent.com"
	}

	public override var urlScheme: String {
		return "com.googleusercontent.apps.290176971013-ehac1mfmoesq234ctan71dhfofbv9psf"
	}

}
