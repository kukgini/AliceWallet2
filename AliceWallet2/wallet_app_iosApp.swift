//
//  wallet_app_iosApp.swift
//  wallet-app-ios
//

import SwiftUI

@main
struct wallet_app_iosApp: App {
    
    @ObservedObject var agent: AriesAgentFacade = AriesAgentFacade()
    
    var body: some Scene {
        WindowGroup {
            OpenWalletView().environmentObject(agent)
        }
    }
}
