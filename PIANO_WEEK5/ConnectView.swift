//
//  ConnectView.swift
//  InteractivePianoConnect
//
//  Created by Ray on 9/2/21.
//

import SwiftUI

struct ConnectView: View {
    @StateObject var viewRouter:ViewRouter
    @State private var text:String = ""
    @State var isScanning = false
    @State var fileName = ""
    @State var openFile = false
    @State var r = 0.0
    @State var g = 0.0
    @State var b = 0.0
    @State var rChanged = false
    @State var gChanged = false
    @State var bChanged = false
    @State var showPopUp = false
    
    @ObservedObject var bleManager:BLEManager
    @State var sendSize = 16
    
    let placeHolderMessage:String = "Please input text..."
    

    var body: some View {
        ZStack{
            Color.black.ignoresSafeArea(.all)
            VStack{
                Spacer()
                
                Text("Bluetooth Devices").foregroundColor(.white).font(.title)
                List(bleManager.peripherals){peripheral in Button(action: {
                    self.bleManager.connectedName=peripheral.name
                    if !bleManager.isConnected{
                        self.isScanning.toggle()
                    }
                    self.bleManager.stopScanning()
                    var idx:Int? = nil
                    idx = bleManager.names.firstIndex(of: peripheral.name)
                    bleManager.connect(peripheral: bleManager.cbperipherals[idx!])
                }, label: {
                    
                    HStack{
                        Text(peripheral.name).foregroundColor(.blue)
                        if bleManager.isConnected && bleManager.connectedName == peripheral.name {
                            Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                        }
                    }
                })
                    
                }.background(Color.black
                )
                Spacer()
                
                VStack{
                    
                    HStack{
                        Spacer()
                        
                        TextField(placeHolderMessage, text: $text).foregroundColor(.white).font(.title2).padding([.top, .bottom],10).background(Color.gray).multilineTextAlignment(.center)
                        
                        Spacer()
                        
                        Button(action: {
                            //To Do
                            
                            if self.text != "" {
                                bleManager.sendData(send: self.text)
                                self.text = ""
                                self.hideKeyboard()
                                
                            }
                            
                        }, label: {
                            Image(systemName: "arrow.up.circle.fill").foregroundColor(.blue).font(.system(size: 40))
                        })
                        
                        
                        Spacer()
                    }.padding(.bottom,20)
                    
                    VStack{
                        Text(self.fileName).fontWeight(.bold)
                        
                        Button(action: {
                            SaveTextFile(message: "Configure")
                            self.openFile.toggle()
                        }, label: {
                            Text("Import File")
                        })
                    }.fileImporter(isPresented: $openFile, allowedContentTypes: [.text,.binaryPropertyList,.audio]){(res) in
                        do{
                            let fileUrl = try res.get()
                            //print(fileUrl)
                            self.fileName = fileUrl.lastPathComponent
                            
                            let rawDataArray = getFile(fileUrl: fileUrl)
//                            midiReduction(fileUrl: fileUrl)
                            
                            if bleManager.isConnected {
                                bleManager.sendData(send: "File Transfer")
                                bleManager.sendData(send: self.fileName)
                                //bleManager.sendBytes(send: [UInt8](midiReduction(fileUrl: fileUrl)), number: 185)
                                
                                bleManager.sendBytes(send: rawDataArray!, number: 128)
                                bleManager.sendData(send: "EOF")
                                
                            }
                            
//                            viewRouter.currentView = .FileTransfer
//                            
//                            if bleManager.isTransfering {
//                                viewRouter.currentView = .FileTransfer
//                            }
                        }
                        catch{
                            print("Error Reading File")
                            print(error.localizedDescription)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        isScanning.toggle()
                        //print(isScanning)
                        if !isScanning {
                            self.bleManager.stopScanning()
                        }
                        else {
                            self.bleManager.startScanning()
                        }
                    }, label: {
                        if isScanning{
                            Text("Stop Scanning").padding(.all,10).padding([.leading,.trailing],5).foregroundColor(.white).background(Color.blue).cornerRadius(15)
                        }
                        else{
                            Text("Start Scanning").padding(.all,10).padding([.leading,.trailing],5).foregroundColor(.white).background(Color.blue).cornerRadius(15)
                        }
                    })
                    
                    Button(action: {
                        viewRouter.currentView = .Send
                    }, label: {
                        Text("Send").fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/).foregroundColor(.green).padding(.all,10).padding([.leading, .trailing], 30).background(Color.black.opacity(0.5)).cornerRadius(20)
                    })
                    
                    Slider(
                        value: $r,
                        in: 0...20,
                        onEditingChanged: { editing in
                                        rChanged = editing
                            if bleManager.isConnected{
                                self.bleManager.sendData(send: "Color_Changed")
                                //usleep(1000000)
                                self.bleManager.sendData(send: "red")
                                //usleep(1000000)
                                self.bleManager.sendData(send: String(Int(r)))
                            }
                        }
                    ).accentColor(.red)
                    
                    Slider(
                        value: $g,
                        in: 0...20,
                        onEditingChanged: { editing in
                                        gChanged = editing
                            if bleManager.isConnected{
                                self.bleManager.sendData(send: "Color_Changed")
                                //usleep(1000000)
                                self.bleManager.sendData(send: "green")
                                //usleep(1000000)
                                self.bleManager.sendData(send: String(Int(g)))
                            }
                        }
                    ).accentColor(.green)
                    
                    Slider(
                        value: $b,
                        in: 0...20,
                        onEditingChanged: { editing in
                                        bChanged = editing
                            if bleManager.isConnected{
                                self.bleManager.sendData(send: "Color_Changed")
                                //usleep(1000000)
                                self.bleManager.sendData(send: "blue")
                                //usleep(1000000)
                                self.bleManager.sendData(send: String(Int(b)))
                            }
                        }
                    ).accentColor(.blue)
                    
                    
                    
                    if bleManager.isSwitchedOn {
                        Text("Bluetooth is ON").foregroundColor(.green).padding(.bottom, 20)
                    }
                    else {
                        Text("Bluetooth is OFF").foregroundColor(.red).padding(.bottom, 20)
                    }
                    
                    if bleManager.isConnected{
                        Button(action: {
                            self.bleManager.disconnect()
                        }, label: {
                            Text("Disconnect").padding(.all,10).padding([.leading,.trailing],5).foregroundColor(.black).background(Color.red).cornerRadius(15)
                        })
                    }
                    
//                    Button(action: {
//                        viewRouter.currentView = .Front
//                    }, label: {
//                        Text("Back").padding(.all,10).padding([.leading,.trailing],5).foregroundColor(.white).background(Color.blue).cornerRadius(15)
//                    })
                    
                }.padding(.bottom, 20).padding(.top, 50).onTapGesture {
                    self.hideKeyboard()
                }
                
            }
        }
    }
}

struct ConnectView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectView(viewRouter:ViewRouter(),bleManager: BLEManager())
    }
}
