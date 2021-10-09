//
//  ContentView.swift
//  InteractivePianoConnect
//
//  Created by Tong Wang on 9/1/21.
//

import SwiftUI

struct FrontPageView: View {
    
    @StateObject var viewRouter:ViewRouter
    @ObservedObject var bleManager:BLEManager
    
    var body: some View {
        ZStack{
            Image("frontPageBackground").resizable().ignoresSafeArea(.all)
            
            VStack{
                Spacer()
                Text("P.I.A.N.O. Connect").fontWeight(.heavy).foregroundColor(.white).font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/).multilineTextAlignment(.center)
                
                Spacer()
                
                Button(action: {
                    viewRouter.currentView = .Connect
                }, label: {
                    Text("Connect").fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/).foregroundColor(.green).padding(.all,10).padding([.leading, .trailing], 30).background(Color.black.opacity(0.5)).cornerRadius(20)
                })
                
                //Spacer()
                
                Button(action: {
                    viewRouter.currentView = .Receive
                }, label: {
                    Text("Receive").fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/).foregroundColor(.green).padding(.all,10).padding([.leading, .trailing], 30).background(Color.black.opacity(0.5)).cornerRadius(20)
                })
                
                
                Spacer()
            }
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        FrontPageView(viewRouter:ViewRouter(), bleManager: BLEManager())
    }
}

