import Foundation
import SwiftUI

struct OnboardingView: View {

    @EnvironmentObject var agent: AriesAgentFacade
    
    var body: some View {
        
        VStack(alignment:.center) {
            VStack(alignment:.center) {
            Text("Verifiable Data Registries").font(.title)
                if agent.isProvisioned {
                    VerifiableRegistryCell(url:agent.selectedNetwork!).background(Color.blue).frame(height:200)
                } else {
                    List (self.agent.availableNetworks!, id: \.self, selection: $agent.selectedNetwork) { url in
                        VerifiableRegistryCell(url: url)
                    }.background(Color.blue).frame(maxHeight: 200)
                }
            }.background(Color.yellow)
            
            VStack(alignment:.center) {
                Text("Wallet").font(.title)
                Image(systemName:"lock")
                TextField("Enter your PIN", text:$agent.walletSeed)
                    .frame(width:200)
                    .multilineTextAlignment(.center)
                if agent.isProvisioned {
                    Button(action: {self.agent.start()}) {
                        Text("Open Wallet")
                    }

                } else {
                    Button(action: {self.agent.provisionAndStart()}) {
                        Text("Create Wallet")
                    }
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
