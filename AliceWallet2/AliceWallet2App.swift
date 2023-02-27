//
//  AliceWallet2App.swift
//  AliceWallet2
//
//  Created by soominlee on 2023/02/27.
//

import SwiftUI

@main
struct AliceWallet2App: App {
    @ObservedObject var agent: AriesAgentFacade = AriesAgentFacade()
    var body: some Scene {
        WindowGroup {
            OpenWalletView().environmentObject(agent)
        }
    }
}
