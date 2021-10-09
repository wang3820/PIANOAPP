//
//  Helpers.swift
//  InteractivePianoConnect
//
//  Created by Ray on 9/2/21.
//

import Foundation
import UIKit
import SwiftUI
import CoreBluetooth
import UniformTypeIdentifiers
import MidiParser

struct CBUUIDs{

    static let kBLEService_UUID = "6e400001-b5a3-f393-e0a9-e50e24dcca9e"
    static let kBLE_Characteristic_uuid_Tx = "6e400002-b5a3-f393-e0a9-e50e24dcca9e" //UART RX
    static let kBLE_Characteristic_uuid_Rx = "6e400003-b5a3-f393-e0a9-e50e24dcca9e" //UART TX

    static let BLEService_UUID = CBUUID(string: kBLEService_UUID)
    static let BLE_Characteristic_uuid_Tx = CBUUID(string: kBLE_Characteristic_uuid_Tx)//(Property = Write without response)
    static let BLE_Characteristic_uuid_Rx = CBUUID(string: kBLE_Characteristic_uuid_Rx)// (Property = Read/Notify)

}

class ViewRouter: ObservableObject {
    @Published var currentView:Page = .Front
}

enum Page {
    case Front
    case Send
    case Connect
    case Receive
}

struct Peripheral: Identifiable{
    let id: Int
    let name:String
    let rssi:Int
}

struct Doc: FileDocument {
    static var readableContentTypes: [UTType] {
        [.binaryPropertyList,.plainText]
    }
    
    var content:String!
    
    init(content: String) {
        self.content = content
    }
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let string = String(data: data, encoding: .utf8)
                else {
                   throw CocoaError(.fileReadCorruptFile)
                }
        self.content = string
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: content.data(using: .utf8)!)
    }

}

func SaveTextFile(message: String) {
    var path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
    let filename = "notes.txt"
        
    path.appendPathComponent(filename)
        
    print(path.absoluteString)
    
    do{
        try message.write(to: path, atomically: false, encoding: .utf8)
    }
    catch{
        print(error)
    }
}

func getFile(fileUrl: URL) -> [UInt8]? {
    // See if the file exists.
    do {
        // Get the raw data from the file.
        let rawData: Data = try Data(contentsOf: fileUrl)

        // Return the raw data as an array of bytes.
        return [UInt8](rawData)
    } catch {
        // Couldn't read the file.
        return nil
    }
}

func getFileData(fileUrl: URL) -> Data? {
    // See if the file exists.
    do {
        // Get the raw data from the file.
        let rawData: Data = try Data(contentsOf: fileUrl)

        // Return the raw data as an array of bytes.
        return rawData
    } catch {
        // Couldn't read the file.
        return nil
    }
}

func getPatchFamilyFromEnum(num: UInt8) -> String? {
    let intVal = Int(num)
    var patchFamily = ""
    
    switch intVal {
    case 0:  patchFamily = "Piano"
    case 1:  patchFamily = "Chromatic Percussion"
    case 2:  patchFamily = "Organ"
    case 3:  patchFamily = "Guitar"
    case 4:  patchFamily = "Bass"
    case 5:  patchFamily = "Strings"
    case 6:  patchFamily = "Ensemble"
    case 7:  patchFamily = "Brass"
    case 8:  patchFamily = "Reed"
    case 9:  patchFamily = "Pipe"
    case 10: patchFamily = "Synth Lead"
    case 11: patchFamily = "Synth Pad"
    case 12: patchFamily = "Synth Effects"
    case 13: patchFamily = "Ethnic"
    case 14: patchFamily = "Percussive"
    case 15: patchFamily = "Sound Effects"
    default:
        patchFamily = "Wrong"
    }
    
    return patchFamily
}

func midiReduction(fileUrl: URL) -> Data{
    let midi = MidiData()
    let data:Data = getFileData(fileUrl: fileUrl)!
    
    midi.load(data: data)
    
    var trackId = 0;
    
    for track in midi.noteTracks {
        print("Track Number: \(trackId)")
        print(track.trackName)
        if (track.patch != nil) {
            print("PatchFamily: "+getPatchFamilyFromEnum(num: (track.patch?.family.rawValue)!)!)
            print("Channel Number: \(Int(track.patch!.channel))\n")
            if (track.patch!.channel == 9) {
                midi.remove(track: track)
            }
            
            if (getPatchFamilyFromEnum(num: (track.patch?.family.rawValue)!)! == "Sound Effects") {
                midi.remove(track: track)
            }
        }
        else {
            midi.remove(track: track)
        }
        trackId += 1
    }

    
    var path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
    let filename = fileUrl.lastPathComponent + ".smidi"
        
    path.appendPathComponent(filename)
    
    try! midi.writeData(to: path)
    
    return midi.createData()!
}

class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate, CBPeripheralManagerDelegate {
    
    var myCentral:CBCentralManager!
    var myPeripheralManager:CBPeripheralManager!
    var myPeripheral:CBPeripheral!
    var myService:CBMutableService!
    var rxCharacteristic:CBCharacteristic!
    var txCharacteristic:CBCharacteristic!
    
    @Published var isSwitchedOn:Bool = false
    @Published var isConnected:Bool = false
    @Published var trueDisconnection = false
    @Published var peripherals = [Peripheral]()
    @Published var cbperipherals = [CBPeripheral]()
    @Published var names = [String]()
    @Published var connectedName:String!
    @Published var receivedValue:String!
    @Published var previouslyConnected:CBPeripheral! = nil;
    
    override init(){
        super.init()
        
        myCentral = CBCentralManager(delegate: self, queue: nil)
        myCentral.delegate = self
        myPeripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            isSwitchedOn = true
        }
        else {
            isSwitchedOn = false
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        var peripheralName: String!
        
        if let name = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            peripheralName = name
        }
        else {
                peripheralName = "Unknown"
            }
               
        let newPeripheral = Peripheral(id: peripherals.count, name: peripheralName, rssi: RSSI.intValue)
        //print(newPeripheral)
        if newPeripheral.name != "Unknown" {
            if !names.contains(newPeripheral.name) {
                peripherals.append(newPeripheral)
                cbperipherals.append(peripheral)
                names.append(newPeripheral.name)
            }
            
        }
        
    }
    
    func startScanning() {
        myCentral.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
        
    }
    
    func stopScanning() {
        myCentral.stopScan()
    }
    
    func connect(peripheral:CBPeripheral) {
        myPeripheral = peripheral
        myPeripheral.delegate = self
        myCentral.connect(peripheral, options: nil)
        self.previouslyConnected = peripheral
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        self.isConnected = true
        myPeripheral.discoverServices(nil)
        stopScanning()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let peripheralServices = peripheral.services {
            for service in peripheralServices {
                //print(service.uuid)
                //print(service.uuid.uuidString)
                
                self.myPeripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        if let serviceCharacteristics = service.characteristics {
            for characteristic in serviceCharacteristics {
                //print(characteristic)

                if characteristic.uuid.isEqual(CBUUIDs.BLE_Characteristic_uuid_Rx) {
                    rxCharacteristic = characteristic
                    myPeripheral.setNotifyValue(true, for: characteristic)
                    myPeripheral.readValue(for: characteristic)
                    print("RX Characteristic: \(rxCharacteristic.uuid)")
                }
                
                if characteristic.uuid.isEqual(CBUUIDs.BLE_Characteristic_uuid_Tx) {
                    txCharacteristic = characteristic
                    print("TX Characteristic: \(txCharacteristic.uuid)")
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic.uuid == rxCharacteristic.uuid {
            if let readData = characteristic.value{
                let ASCIIstring = NSString(data: readData, encoding: String.Encoding.utf8.rawValue)
                self.receivedValue = ASCIIstring as String?
                //print(self.receivedValue!)
                
            }
        }
    }
    
    func sendData(send data: String) {
        print(data)

        let sentData = ((data+"\r") as NSString).data(using: String.Encoding.utf8.rawValue)
        
        myPeripheral.writeValue(sentData!, for: txCharacteristic, type: CBCharacteristicWriteType.withResponse)
    }
    
    func sendData(send data: UInt8) {
        
        let sendData = Data([data])
        
        myPeripheral.writeValue(sendData, for: txCharacteristic, type: CBCharacteristicWriteType.withResponse)
    }
    
    func sendData(send data: [UInt8]) {
        
        let sendData = Data(data)
        
        myPeripheral.writeValue(sendData, for: txCharacteristic, type: CBCharacteristicWriteType.withResponse)
    }
    
    func sendBytes(send data: [UInt8], number bytes: Int) {
        var transferedSize = 0
        
        var idx = 0;
        let icr = bytes > 185 ? 185 : bytes
        
        repeat {
            sendData(send: Array(data[idx..<idx+icr]))
            transferedSize += bytes
            idx += icr
        }while(idx+icr<data.count)
        
        let lastDataSend = Array(data[idx..<data.count])
        sendData(send: lastDataSend)
        transferedSize += lastDataSend.count
        
//        var transferCompleted = false
//        var lastChunck = false
//        var front = 0
//        var back  = bytes
//        var dataSend:[UInt8]!
//        let length = data.count
//
//
//        if (data.count <= bytes) {
//            sendData(send: data)
//            return
//        }
//
//        while (!transferCompleted) {
//            if (!lastChunck) {
//                dataSend = Array(data[front..<back])
//
//                if back + bytes > length {
//                    lastChunck = true
//                }
//                else {
//                    front += bytes
//                    back  += bytes
//                }
//            }
//            else {
//                dataSend = Array(data[back..<length])
//                transferCompleted = true
//            }
//            sendData(send: dataSend!)
//            transferedSize += dataSend.count
//
//            print("Bytes sent: \(dataSend.count)")
//            //print(String(decoding: dataSend, as: UTF8.self));
//
//        }
        print("Total bytes send: \(transferedSize)")
        print("Total size of file: \(data.count)")
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic.uuid == txCharacteristic.uuid {
            if error != nil {
                print("Written Unsuccessful")
                print(error!)
            }
            else {
                //print("Written Successful")
            }
        }
    }
    
    func disconnect(){
        self.myCentral.cancelPeripheralConnection(self.myPeripheral)
        self.trueDisconnection = true
        self.previouslyConnected = nil
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if (self.trueDisconnection) {
            self.isConnected = false
        }
        else {
            self.isConnected = false
            startScanning()
            connect(peripheral: self.previouslyConnected!)
        }
    }
    
    // Peripheral Setup
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
    }

    let peripheralServiceID = CBUUID(string:"00001011-0000-1100-1000-00123456789A")
    let peripheralCharacteristicID = CBUUID(string:"00001012-0000-1100-1000-00123456789A")
    
    func addServicesAndCharacteristics(){
        myService = CBMutableService(type: peripheralServiceID, primary: true)
        let data = "Welovepianos!"
        let myCharacteristic = CBMutableCharacteristic(type: peripheralCharacteristicID, properties: [.read], value: data.data(using: .utf8), permissions: [.readable])
        let rx = CBMutableCharacteristic(type: CBUUIDs.BLE_Characteristic_uuid_Rx, properties: [.notify,.read
        ], value: nil, permissions: [.writeable,.readable])
        let tx = CBMutableCharacteristic(type: CBUUIDs.BLE_Characteristic_uuid_Tx, properties: [.notify,.write
        ], value: nil, permissions: [.writeable,.readable])
        myService.characteristics = [myCharacteristic, rx, tx]
        myPeripheralManager.add(myService)
    }
    
    func startAdvertising(){
        if myService == nil {
            addServicesAndCharacteristics()
        }
        
        myPeripheralManager.startAdvertising([CBAdvertisementDataLocalNameKey:"InteractivePianoConnect", CBAdvertisementDataServiceUUIDsKey: [peripheralServiceID]])
    }
    
    func stopAdvertising(){
        myPeripheralManager.stopAdvertising()
    }
}
