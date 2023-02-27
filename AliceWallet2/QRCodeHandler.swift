//
//  QRCodeHandler.swift
//  wallet-app-ios
//

import SwiftUI
import CodeScanner

class QRCodeHandler {
    
    let agent: AriesAgentFacade
    
    init(agent: AriesAgentFacade) {
        self.agent = agent
    }
    
    public func receiveInvitation(url: String) {
        Task {
            do {
                let (_, connection) = try await agent.oobReceiveInvitationFromUrl(url)
                agent.showSimpleAlert(message: "Connected with \(connection?.theirLabel ?? "unknown agent")")
            } catch {
                print(error)
                agent.reportError()
            }
        }
    }

    @MainActor public func handleResult(_ result: Result<ScanResult, ScanError>) {
        switch result {
        case .success(let result):
            print("Scanned code: [\(result.string)]")
            agent.menu = nil
            receiveInvitation(url: result.string.trimmingCharacters(in: .whitespacesAndNewlines))
        case .failure(let error):
            print("Scanning failed: \(error.localizedDescription)")
        }
    }
}
