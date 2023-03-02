//
//  OnboardingView.swift
//  AliceWallet2
//
//  Created by soominlee on 2023/03/02.
//

import Foundation
import SwiftUI

struct OnboardingView: View {

    @EnvironmentObject var agent: AriesAgentFacade
    
    var body: some View {
        VStack {
            NavigationStack {
                Image(systemName:"lock")
                TextField("Enter your PIN", text:$agent.walletSeed).padding()
                Button(action: {self.agent.provisionAndStart()}) {
                    Text("Create Wallet")
                }
                .navigationTitle("Wallet")
            }
            NavigationStack {
                List(self.agent.availableNetworks!, id: \.self, selection: $agent.selectedNetwork) { url in
                    let name = url.deletingPathExtension().lastPathComponent
                    Text("\(name)")
                }
                .navigationTitle("Networks")
            }
            NavigationStack {}
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
