//
//  OpenWalletView.swift
//  wallet-app-ios
//

import SwiftUI

struct OpenWalletView: View {

    @EnvironmentObject var agent: AriesAgentFacade
    
    var body: some View {
        VStack {
            if agent.isReady {
                WalletMainView().environmentObject(agent)
            } else {
                NavigationStack {
                    Image(systemName:"lock")
                    TextField("Enter your PIN", text:$agent.walletSeed).padding()
                    Button(action: {
                        if agent.isProvisioned {
                            self.agent.start()
                        } else {
                            self.agent.provisionAndStart()
                        }}) {
                        if agent.isProvisioned {
                            Text("Open Wallet")
                        } else {
                            Text("Create Wallet")
                        }
                    }
                    .navigationTitle("Wallet")
                }
                if !agent.isProvisioned {
                    NavigationStack {
                        List(self.agent.availableNetworks!, id: \.self, selection: $agent.selectedNetwork) { url in
                            let name = url.deletingPathExtension().lastPathComponent
                            Text("\(name)")
                        }
                        .navigationTitle("Networks")
                    }
                }
            }
        }
    }
}

struct OpenWalletView_Previews: PreviewProvider {
    static var previews: some View {
        OpenWalletView()
    }
}
