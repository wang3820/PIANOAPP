//
//  InteractivePianoConnectApp.swift
//  InteractivePianoConnect
//
//  Created by Tong Wang on 9/1/21.
//

import SwiftUI

@main
struct InteractivePianoConnectApp: App {
    var body: some Scene {
        WindowGroup {
            MainView(viewRouter:ViewRouter())
        }
    }
}
