//
//  ReceiveView.swift
//  InteractivePianoConnect
//
//  Created by Ray on 9/9/21.
//

import SwiftUI

struct ReceiveView: View {
    @StateObject var viewRouter:ViewRouter
    @ObservedObject var bleManager:BLEManager
    var text = [String]()
    
    var body: some View {
        ZStack{
            Color.black.ignoresSafeArea(.all)
            VStack{
                Spacer()
                
                Button(action: {
                    bleManager.startAdvertising()
                }, label: {
                    Text("Start Advertising").padding(.all,10).padding([.leading,.trailing],5).foregroundColor(.white).background(Color.blue).cornerRadius(15)
                })
                
                //VStack{}.padding()
                
                Button(action: {
                    bleManager.stopAdvertising()
                }, label: {
                    Text("Stop Advertising").padding(.all,10).padding([.leading,.trailing],5).foregroundColor(.white).background(Color.blue).cornerRadius(15)
                })
                
                Button(action: {
                    viewRouter.currentView = .Front
                }, label: {
                    Text("Back").padding(.all,10).padding([.leading,.trailing],5).foregroundColor(.white).background(Color.blue).cornerRadius(15)
                })
                
                Spacer()
            }
        }
    }
}

struct ReceiveView_Previews: PreviewProvider {
    static var previews: some View {
        ReceiveView(viewRouter:ViewRouter(),bleManager: BLEManager())
    }
}
