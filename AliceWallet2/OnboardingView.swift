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
        
        VStack(alignment:.center) {
            VStack(alignment:.center) {
                Text("Verifiable Data Registries").font(.title)
                List (self.agent.availableNetworks!, id: \.self, selection: $agent.selectedNetwork) { url in
                    VerifiableRegistryCell(url: url)
                }
                .background(Color.blue)
                .frame(maxHeight: 200)
            }.background(Color.yellow)
            
            VStack(alignment:.center) {
                Text("Wallet").font(.title)
                Image(systemName:"lock")
                TextField("Enter your PIN", text:$agent.walletSeed)
                    .frame(width:200)
                    .multilineTextAlignment(.center)
                Button(action: {self.agent.provisionAndStart()}) {
                    Text("Create Wallet")
                }
            }
            .background(Color.green)
        }
        .background(Color.red)
    }
}

struct VerifiableRegistryCell: View {
    let url: URL
    
    var body: some View {
        HStack {
            Image(systemName:"lock")
            Text(url.deletingPathExtension().lastPathComponent)
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
