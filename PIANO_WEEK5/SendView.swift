//
//  SendView.swift
//  InteractivePianoConnect
//
//  Created by Tong Wang on 9/1/21.
//

import SwiftUI

struct SendView: View {
    
    @StateObject var viewRouter:ViewRouter
    @State private var text:String = ""
    
    let placeHolderMessage:String = "Please input text..."
    
    var body: some View {
        ZStack {
            Image("sendPageBackground").resizable().ignoresSafeArea(.all)
            
            
            VStack{
                Spacer()
                
                HStack{
                    Spacer()
                    
                    TextField(placeHolderMessage, text: $text).foregroundColor(.white).font(.title2).padding([.top, .bottom],10).background(Color.gray).multilineTextAlignment(.center)
                    
                    Spacer()
                    
                    Button(action: {
                        //To Do
                        if self.text != "" {
                            //print(self.text)
                            self.text = ""
                            self.hideKeyboard()
                            
                        }
                    }, label: {
                        Image(systemName: "arrow.up.circle.fill").foregroundColor(.blue).font(.system(size: 40))
                    })
                    
                    
                    Spacer()
                }
                
                
                Spacer()
                
                Button(action: {
                    viewRouter.currentView = .Front
                }, label: {
                    Text("Back").padding(.all,10).padding([.leading,.trailing],30).foregroundColor(.white).background(Color.blue).cornerRadius(10).padding(.bottom, 150)
                })
                
                
            }
        }.onTapGesture {
            self.hideKeyboard()
        }
        
    }
}

struct SendView_Previews: PreviewProvider {
    static var previews: some View {
        SendView(viewRouter:ViewRouter())
    }
}
