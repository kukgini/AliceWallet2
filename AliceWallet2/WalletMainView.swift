import SwiftUI
import CodeScanner

enum MainMenu: Identifiable {
    case qrcode, list, loading
    var id: Int {
        hashValue
    }
}

struct WalletMainView: View {
    
    @EnvironmentObject var agent: AriesAgentFacade
    
    @State var invitation: String = ""
    
    var body: some View {
        ZStack {
            NavigationView {
                VStack {
                    List {
                        Button(action: {
                            agent.menu = .qrcode
                        }) {
                            Text("Connect")
                        }

                        Button(action: {
                            agent.menu = .list
                        }) {
                            Text("Credentials")
                        }
                    }
                    .navigationTitle("Wallet App")
                    .listStyle(.plain)

                    Spacer()

                    HStack {
                        TextField("invitation url", text: $invitation)
                            .textFieldStyle(.roundedBorder)

                        Button("Clear", action: {
                            invitation = ""
                        })
                        .buttonStyle(.bordered)
                        Button("Connect", action: {
                            agent.receiveInvitation(url: invitation)
                        })
                        .buttonStyle(.bordered)
                    }
                    .padding()
                }
            }
            .sheet(item: $agent.menu) { item in
                switch item {
                case .qrcode:
                    Text("Code Scan ...")
                    // CodeScannerView(codeTypes: [.qr], completion: QRCodeHandler().handleResult)
                case .list:
                    CredentialListView()
                case .loading:
                    Text("Processing ...")
                }
            }
            .alert(item: $agent.actionType) { item in
                switch item {
                case .credOffer:
                    return Alert(title: Text("Credential"), message: Text(agent.confirmMessage), primaryButton: .default(Text("OK"), action: {
                        agent.getCredential()
                    }), secondaryButton: .cancel())
                case .proofRequest:
                    return Alert(title: Text("Proof"), message: Text(agent.confirmMessage), primaryButton: .default(Text("OK"), action: {
                        agent.sendProof()
                    }), secondaryButton: .cancel())
                }
            }
            .alert(agent.alertMessage, isPresented: $agent.showAlert) {}
        }
    }
}

struct WalletMainView_Previews: PreviewProvider {
    static var previews: some View {
        WalletMainView()
    }
}
