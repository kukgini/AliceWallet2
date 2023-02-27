import OSLog
import Foundation
import AriesFramework
import Indy

enum ActionType: Identifiable {
    case credOffer, proofRequest
    var id: Int {
        hashValue
    }
}

extension Data {
    func string() -> String {
        return String(decoding: self, as: UTF8.self)
    }
}

extension AriesAgentFacade: AgentDelegate {
    func onCredentialStateChanged(credentialRecord: CredentialExchangeRecord) {
        if credentialRecord.state == .OfferReceived {
            credentialRecordId = credentialRecord.id
            processCredentialOffer()
        } else if credentialRecord.state == .Done {
            menu = nil
            showSimpleAlert(message: "Credential received")
        }
    }

    func onProofStateChanged(proofRecord: ProofExchangeRecord) {
        if proofRecord.state == .RequestReceived {
            proofRecordId = proofRecord.id
            processVerify()
        } else if proofRecord.state == .Done {
            menu = nil
            showSimpleAlert(message: "Proof done")
        }
    }
}

class AriesAgentFacade : ObservableObject {
    
    var agentConfig: AgentConfig
    var agent: Agent?
    
    @Published var agentProvisioned = false
    @Published var walletOpened = false
    @Published var walletSeed = ""
    @Published var availableNetworls: [URL]? = nil
    @Published var selectedNetwork: URL? = nil
    @Published var agentInitialized = false

    @Published var confirmMessage = ""
    @Published var actionType: ActionType?
    @Published var alertMessage = ""
    @Published var showAlert = false
    @Published var menu: MainMenu?
    
    @Published var credentials: CredentialList = CredentialList()
    
    init() {
        os_log(.info, log: .default, "initialize aries agent facade.")
        self.availableNetworls = AriesAgentFacade.listGenesisTxnURLs()
        let agentProvisioned = UserDefaults.standard.bool(forKey:"agentProvisioned")
        if agentProvisioned {
            self.agentProvisioned = agentProvisioned
            let agentConfigJson = UserDefaults.standard.string(forKey:"agentConfig")!.data(using:.utf8)!
            self.agentConfig = try! JSONDecoder().decode(AgentConfig.self,from:agentConfigJson)
        } else {
            self.agentConfig =  AgentConfig(
                walletId: "AFSDefaultWallet",
                walletKey: "",
                genesisPath: "",
                poolName: "AFSDefaultPool",
                mediatorConnectionsInvite: nil,
                mediatorPickupStrategy: .Implicit,
                label: "SwiftFrameworkAgent",
                autoAcceptConnections: true,
                mediatorPollingInterval: 10,
                mediatorEmptyReturnRetryInterval: 3,
                connectionImageUrl: nil,
                autoAcceptCredential: .always,
                autoAcceptProof: .always,
                useLedgerSerivce: true,
                useLegacyDidSovPrefix: true,
                publicDidSeed: nil,
                agentEndpoints: nil)
        }
    }
    
    static func listGenesisTxnURLs() -> [URL] {
        print("listing genesis txn urls.")
        let networks = Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: "networks")!
        print("networks:")
        for (index, url) in networks.enumerated() {
            let networkName = url.lastPathComponent
            print("\t* [\(index)] \(networkName)")
        }
        return networks
    }
    
    func provision() {
        Task{
            do {
                let seed = walletSeed.padding(toLength: 32, withPad: " ", startingAt: 0)
                let key = try await IndyWallet.generateKey(forConfig:"{\"seed\":\"\(seed)\"}")!
                let genesis = self.selectedNetwork!.absoluteURL.path
                self.agentConfig.walletKey = key
                self.agentConfig.genesisPath = genesis
                
                let agentConfigJson = String(data: try JSONEncoder().encode(agentConfig), encoding: String.Encoding.utf8)
                print("agentConfig=\(String(describing: agentConfigJson))")
                
                agent = Agent(agentConfig: agentConfig, agentDelegate: self)
                
                try await agent!.initialize()
                // TODO save AgentConfig into secure storage with geven password.
                UserDefaults.standard.set(agentConfigJson, forKey: "agentConfig")
                UserDefaults.standard.set(true, forKey: "agentProvisioned")
            } catch {
                if let err = error as NSError? {
                    print("open wallet failed: \(err)")
                    return
                }
            }
        }
        print("Wallet opened!")
        self.walletOpened = true
    }
    
    func start() {
        Task{
            do {
                // TODO get AgentConfig from Secure Storage with given password.

                let agentConfigJson = String(data: try JSONEncoder().encode(agentConfig), encoding: String.Encoding.utf8)
                print("agentConfig=\(String(describing: agentConfigJson))")
                
                agent = Agent(agentConfig: agentConfig, agentDelegate: self)
                
                try await agent!.initialize()
            } catch {
                if let err = error as NSError? {
                    print("open wallet failed: \(err)")
                    return
                }
            }
        }
        print("Wallet opened!")
        self.walletOpened = true
    }
    
    func oobReceiveInvitationFromUrl(_ url: String, config: ReceiveOutOfBandInvitationConfig? = nil) async throws -> (OutOfBandRecord?, ConnectionRecord?) {
        return try await self.agent!.oob.receiveInvitationFromUrl(url, config: config);
    }
    
    public func receiveInvitation(url: String) {
        Task {
            do {
                let (_, connection) = try await agent!.oob.receiveInvitationFromUrl(url)
                self.showSimpleAlert(message: "Connected with \(connection?.theirLabel ?? "unknown agent")")
            } catch {
                print(error)
                self.reportError()
            }
        }
    }

    var credentialRecordId = ""
    var proofRecordId = ""

    func processCredentialOffer() {
        confirmMessage = "Accept credential?"
        triggerAlert(type: .credOffer)
    }

    func processVerify() {
        confirmMessage = "Present proof?"
        triggerAlert(type: .proofRequest)
    }

    func getCredential() {
        menu = .loading

        Task {
            do {
                _ = try await agent!.credentials.acceptOffer(options: AcceptOfferOptions(credentialRecordId: credentialRecordId, autoAcceptCredential: .always))
            } catch {
                menu = nil
                showSimpleAlert(message: "Failed to receive credential")
                print(error)
            }
        }
    }

    func sendProof() {
        menu = .loading

        Task {
            do {
                let retrievedCredentials = try await agent!.proofs.getRequestedCredentialsForProofRequest(proofRecordId: proofRecordId)
                let requestedCredentials = try await agent!.proofService.autoSelectCredentialsForProofRequest(retrievedCredentials: retrievedCredentials)
                _ = try await agent!.proofs.acceptRequest(proofRecordId: proofRecordId, requestedCredentials: requestedCredentials)
            } catch {
                menu = nil
                showSimpleAlert(message: "Failed to present proof")
                print(error)
            }
        }
    }

    func reportError() {
        showSimpleAlert(message: "Invalid invitation url")
    }

    func triggerAlert(type: ActionType) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.actionType = type
        }
    }

    func showSimpleAlert(message: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.alertMessage = message
            self?.showAlert = true
        }
    }
}
