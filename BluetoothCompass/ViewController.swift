//
//  ViewController.swift
//  BluetoothCompass
//
//  Created by Luke Bousfield on 3/10/18.
//  Copyright © 2018 Luke Bousfield. All rights reserved.
//

import UIKit;
import Starscream;
import CoreLocation;

class ViewController: UIViewController, CLLocationManagerDelegate, WebSocketDelegate {
    
    func websocketDidConnect(socket: WebSocketClient) {
        print("Websocket connected.")
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("Websocket disconnected.")
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print("Recieved message: \(text)")
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("Recieved data: \(data)")
    }
    
    
    let serverLocation : String = "ws://192.168.0.108:8080"
    
    var isLocationAuthed = false
    
    var locationManager : CLLocationManager!
    
    var socket : WebSocket? = nil
    
    @IBOutlet weak var angleIndicator: UILabel!
    
    @IBAction func scan(_ sender: Any) {
        print("Connecting to server.")
        socket = WebSocket(url: URL(string: serverLocation)!)
        socket!.delegate = self
        socket!.connect()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager!.requestWhenInUseAuthorization()
        locationManager!.startUpdatingHeading()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func send(num : Int) {
        
        if let s = socket {
            s.write(string: "\(num)")
        }
        
    }
    
    func locationManager(_ manager : CLLocationManager, didUpdateHeading newHeading : CLHeading) {
        print("New heading: \(newHeading.trueHeading)")
        let trueHeading : Int = Int(newHeading.trueHeading.rounded())
        angleIndicator.text = "Angle: \(trueHeading)˚"
        var toSend : Int = 0
        var shouldSend : Bool = true
        if (trueHeading < 270 && trueHeading > 90) {
            print("Can't reach direction.")
            shouldSend = false
        } else if (trueHeading >= 270) {
            toSend = -1 * (360 - trueHeading)
        } else if (trueHeading <= 90) {
            toSend = trueHeading
        } else {
            print("Something went very wrong.")
        }
        
        if (shouldSend) {
            send(num: toSend)
        }
        
    }

}

