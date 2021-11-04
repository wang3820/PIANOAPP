//
//  MainView.swift
//  InteractivePianoConnect
//
//  Created by Tong Wang on 9/1/21.
//

import SwiftUI
import CoreBluetooth

extension View {
    func hideKeyboard() {
        let resign = #selector(UIResponder.resignFirstResponder)
        UIApplication.shared.sendAction(resign, to: nil, from: nil, for: nil)
    }
}

struct MainView: View {
    
    @StateObject var viewRouter:ViewRouter
    @StateObject var bleManager = BLEManager()
    
    var body: some View {
        switch viewRouter.currentView {
        case .Front:
            FrontPageView(viewRouter: viewRouter, bleManager: bleManager)
        case .Send:
            SendView(viewRouter: viewRouter, bleManager: bleManager)
        case .Connect:
            ConnectView(viewRouter: viewRouter,bleManager: bleManager)
        case .Receive:
            ReceiveView(viewRouter: viewRouter,bleManager: bleManager)
        case .ModeSelect:
            ModeSelectView(viewRouter: viewRouter,bleManager: bleManager)
        case .FileTransfer:
            FileTransferPopUpView(viewRouter: viewRouter,bleManager: bleManager)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(viewRouter:ViewRouter())
    }
}
