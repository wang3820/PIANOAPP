//
//  SendView.swift
//  InteractivePianoConnect
//
//  Created by Tong Wang on 9/1/21.
//

import SwiftUI

struct SendView: View {
    
    @StateObject var viewRouter:ViewRouter
    @ObservedObject var bleManager:BLEManager
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
                
                HStack(){
                    Button(action: {
                        if bleManager.isConnected{
                        self.bleManager.sendData(send: "red")
                        }
                    }, label: {
                        Text("").padding(.all,10).padding([.leading,.trailing],5).foregroundColor(.white).background(Color.red).cornerRadius(15)
                    })
                    
                    Button(action: {
                        if bleManager.isConnected{
                        self.bleManager.sendData(send: "green")
                        }
                    }, label: {
                        Text("").padding(.all,10).padding([.leading,.trailing],5).foregroundColor(.white).background(Color.green).cornerRadius(15)
                    })
                    
                    Button(action: {
                        if bleManager.isConnected{
                        self.bleManager.sendData(send: "blue")
                        }
                    }, label: {
                        Text("").padding(.all,10).padding([.leading,.trailing],5).foregroundColor(.white).background(Color.blue).cornerRadius(15)
                    })
                    
                    Button(action: {
                        if self.bleManager.isConnected{
                            self.bleManager.sendData(send: "off")}
                    }, label: {
                        Text("").padding(.all,10).padding([.leading,.trailing],5).foregroundColor(.white).background(Color.white).cornerRadius(15)
                    })
                }
                
                
                
                
                Spacer()
                HStack {
                    Button(action: {
                        if bleManager.isConnected {
                            bleManager.sendData(send: "VIS")
                        }
                    }, label: {
                        Text("VIS").padding(.all,10).padding([.leading,.trailing],30).foregroundColor(.white).background(Color.blue).cornerRadius(10)
                    })
                    Button(action: {
                        if bleManager.isConnected {
                            bleManager.sendData(send: "LTP")
                        }
                    }, label: {
                        Text("LTP").padding(.all,10).padding([.leading,.trailing],30).foregroundColor(.white).background(Color.blue).cornerRadius(10)
                    })
                    
                    Button(action: {
                        if bleManager.isConnected {
                            bleManager.sendData(send: "PA")
                        }
                    }, label: {
                        Text("PA").padding(.all,10).padding([.leading,.trailing],30).foregroundColor(.white).background(Color.blue).cornerRadius(10)
                    })
                    
                }
                
                //Spacer()
                List(bleManager.filesOnCard, id:\.self){file in Button(action: {
                    bleManager.selectedFile = file
                    viewRouter.currentView = .ModeSelect         }, label: {
                                    Text(file).foregroundColor(.blue)
                    }).buttonStyle(PlainButtonStyle())
                }.frame(width: 330.0, height: 200.0).background(Color.black)
                
                
                Button(action: {
                    if bleManager.isConnected {
                        bleManager.filesOnCard.removeAll()
                        bleManager.sendData(send: "ListDIR")
                    }
                }, label: {
                    Text("List Directory").padding(.all,10).padding([.leading,.trailing],30).foregroundColor(.white).background(Color.blue).cornerRadius(10)
                })
                
                Spacer()
                Button(action: {
                    viewRouter.currentView = .Connect
                }, label: {
                    Text("Back").padding(.all,10).padding([.leading,.trailing],30).foregroundColor(.white).background(Color.blue).cornerRadius(10)
                })
                
                
            }
        }.onTapGesture {
            self.hideKeyboard()
        }
        
    }
}

struct SendView_Previews: PreviewProvider {
    static var previews: some View {
        SendView(viewRouter:ViewRouter(),bleManager: BLEManager())
    }
}
