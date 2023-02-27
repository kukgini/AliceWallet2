//
//  OpenWalletView.swift
//  wallet-app-ios
//

import SwiftUI

struct OpenWalletView: View {

    @EnvironmentObject var agent: AriesAgentFacade
    
    var body: some View {
        VStack {
            if agent.walletOpened {
                WalletMainView().environmentObject(agent)
            } else {
                NavigationStack {
                    Image(systemName:"lock")
                    TextField("Enter your PIN", text:$agent.walletSeed).padding()
                    Button(action: {
                        if agent.agentProvisioned {
                            self.agent.start()
                        } else {
                            self.agent.provision()
                        }}) {
                        if agent.agentProvisioned {
                            Text("Open Wallet")
                        } else {
                            Text("Create Wallet")
                        }
                    }
                    .navigationTitle("Wallet")
                }
                if !agent.agentProvisioned {
                    NavigationStack {
                        List(self.agent.availableNetworls!, id: \.self, selection: $agent.selectedNetwork) { url in
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
