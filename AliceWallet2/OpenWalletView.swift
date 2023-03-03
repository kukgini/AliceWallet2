import SwiftUI

struct OpenWalletView: View {

    @EnvironmentObject var agent: AriesAgentFacade
    
    var body: some View {
        VStack {
            NavigationStack {
                Image(systemName:"lock")
                TextField("Enter your PIN", text:$agent.walletSeed).padding()
                Button(action: {self.agent.start()}) {
                    if agent.isProvisioned {
                        Text("Open Wallet")
                    }
                }
                .navigationTitle("Wallet")
            }
        }
    }
}

struct OpenWalletView_Previews: PreviewProvider {
    static var previews: some View {
        OpenWalletView()
    }
}
