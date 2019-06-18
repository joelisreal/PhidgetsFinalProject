//
//  ViewController.swift
//  2ADCMotorPhidget
//
//  Created by Joel Igberase on 2019-05-24.
//  Copyright © 2019 Joel Igberase. All rights reserved.
//

import UIKit
import Phidget22Swift
import WebKit
import AVKit
import Vision

class ViewController: UIViewController {
    
    var voltVert = VoltageRatioInput()
    var voltHor = VoltageRatioInput()
    var button = DigitalInput()
    var motor0 = DCMotor()
    var motor1 = DCMotor()
    var objectDetected : Bool = false
    var leftSpeed : Double = 0.0
    var rightSpeed : Double = 0.0
    var chooseDir : Bool = false
    @IBOutlet var webCam: WKWebView!
    var myURL = URL(string: "http://192.168.99.1:81/?action=stream")

    var sensor = DistanceSensor()
    var autoSensor : Int = 1
    
    func attach_handler(sender: Phidget) {
        do {
            let hubPort = try sender.getHubPort()
            let channel = try sender.getChannel()
            
            print(hubPort)
            print(channel)
            
            if hubPort == 0 {
                if channel == 0 {
                    print("Vertical Axis attached")
                } else if channel == 1 {
                    print("Horizontal Axis attached")
                }
                print("Thumbstick attached")
            } else if hubPort == 1 {
                print("Motor0 attached")
            } else if hubPort == 2 {
                print("Motor1 attached")
            }
            else if hubPort == 3 {
                print("Sensor attached")
              //  try sensor.setDataInterval(100)
                //try sensor.setDistanceChangeTrigger(25)
            }
        } catch let err as PhidgetError{
            print("Phidget Error111 " + err.description)
        } catch {
            //catch other errors here
        }
        
    }
    
    
    func voltageChange(sender: VoltageRatioInput, voltageRatio: Double) {
        do {
            print("hor  \(try voltHor.getVoltageRatio())")
            print("ver  \(try voltVert.getVoltageRatio())")
            print(objectDetected)
            try motor1.setTargetVelocity(leftSpeed) //motor1 is LEFT side
            try motor0.setTargetVelocity(rightSpeed) //motor2 is RIGHT side

            if objectDetected == true {
                chooseDir = Bool.random()
                
                if chooseDir == true {
                    leftSpeed = -1
                    rightSpeed = 1
                } else if chooseDir == false {
                    leftSpeed = 1
                    rightSpeed = -1
                }
            } else if objectDetected == false {
                //SET MOTOR SPEEDS
                if autoSensor == 1 {
                    //DETERMINE MOTOR SPEEDS
                    leftSpeed = (try voltVert.getVoltageRatio()) + (try voltHor.getVoltageRatio())
                    rightSpeed = (try voltVert.getVoltageRatio()) - (try voltHor.getVoltageRatio())
                    
                    // MAKE SURE SPEEDS ARE NOT > or < 1/-1
                    if leftSpeed > 1 {
                        leftSpeed = 1
                    }
                    else if leftSpeed < -1 {
                        leftSpeed = -1
                    }
                
                    if rightSpeed > 1 {
                        rightSpeed = 1
                    }
                    else if rightSpeed < -1 {
                        rightSpeed = -1
                    }
                }
                if autoSensor == -1 {
                    leftSpeed = 1
                    rightSpeed = 1
                }

            }

            
            
            
        } catch let err as PhidgetError{
            print("Phidget Error112 " + err.description)
        } catch {
            //catch other errors here
        }
    }
    
    
    
    func distanceChange(sender: DistanceSensor, distance: UInt32) {
        do {
            print(distance)
            if try sensor.getDistance() < 4000 {
                objectDetected = true
            } else {
                objectDetected = false
            }
            
            
        } catch let err as PhidgetError{
            print("Phidget Error114 " + err.description)
        } catch {
            //catch other errors here
        }
    }
    func stateChange_handler(sender: DigitalInput, state: Bool){
        do {
            if state == true {
                autoSensor *= -1
                
            }

            
            
        } catch let err as PhidgetError{
            print("Phidget Error115 " + err.description)
        } catch {
            //catch other errors here
        }
        
    }
    
    
    required init(coder aDecoder: NSCoder) {
        self.webCam = WKWebView(frame: CGRect(x: 0, y: 0, width: 314, height: 636))
        super.init(coder: aDecoder)!
    }
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //here is where the camera is set up
//        let captureSession = AVCaptureSession()
//
//        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
//
//        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
//        captureSession.addInput(input)
//
//        captureSession.startRunning()
//
//        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
//        view.layer.addSublayer(previewLayer)
//        previewLayer.frame = view.frame
        let myRequest = URLRequest(url: myURL!)
        webCam.load(myRequest)
     //   let dataOutput = webCam.load(myRequest)
      //  let request = VNCoreMLRequest(model: <#T##VNCoreMLModel#>, completionHandler: <#T##VNRequestCompletionHandler?##VNRequestCompletionHandler?##(VNRequest, Error?) -> Void#>)
      //  VNImageRequestHandler(cgImage: <#T##CGImage#>, options: [:]).perform(<#T##requests: [VNRequest]##[VNRequest]#>)
        
        do {
            try Net.addServer(serverName: "phidgetsbc", address: "192.168.99.1", port: 5661, password: "", flags: 0)
            //enable server discovery
            try Net.enableServerDiscovery(serverType: .deviceRemote)
//            view.addSubview(webCam)
//            webCam.translatesAutoresizingMaskIntoConstraints = false
//            let views = ["webCam" : webCam]
//            let h = NSLayoutConstraint.constraints(withVisualFormat: "H:|[webView]|", options: [], metrics: nil , views: views)
//            let w = NSLayoutConstraint.constraints(withVisualFormat: "V:|[webView]|", options: [], metrics: nil, views: views)
//            view.addConstraints(h)  //This is where I was going wrong
//            view.addConstraints(w)  //This is where I was going wrong
            


            //address objects
            try voltVert.setDeviceSerialNumber(528025)
            try voltVert.setHubPort(0)
            try voltVert.setChannel(0)
            try voltVert.setIsHubPortDevice(false)
            
            try voltHor.setDeviceSerialNumber(528025)
            try voltHor.setHubPort(0)
            try voltHor.setChannel(1)
            try voltHor.setIsHubPortDevice(false)
            
            try button.setDeviceSerialNumber(528025)
            try button.setHubPort(0)
            try button.setIsHubPortDevice(false)
            
            try motor0.setDeviceSerialNumber(514814)
            try motor0.setHubPort(1)
            try motor0.setIsHubPortDevice(false)
            
            try motor1.setDeviceSerialNumber(514814)
            try motor1.setHubPort(2)
            try motor1.setIsHubPortDevice(false)
            
            try sensor.setDeviceSerialNumber(514814)
            try sensor.setHubPort(3)
            try sensor.setIsHubPortDevice(false)
            
            
            //attach handler
            let _ = voltVert.attach.addHandler(attach_handler)
            let _ = voltHor.attach.addHandler(attach_handler)
            let _ = button.attach.addHandler(attach_handler)
            let _ = sensor.attach.addHandler(attach_handler)
            let _ = motor0.attach.addHandler(attach_handler)
            let _ = motor1.attach.addHandler(attach_handler)
            
            //add state change handlers
            let _ = voltVert.voltageRatioChange.addHandler(voltageChange)
            let _ = voltHor.voltageRatioChange.addHandler(voltageChange)
            let _ = button.stateChange.addHandler(stateChange_handler)
            let _ = sensor.distanceChange.addHandler(distanceChange)
            
            
            //open objects
            try voltVert.open(timeout: 8000)
              print(2)
            try voltHor.open(timeout: 8100)
            try button.open(timeout: 8200)
            try motor0.open(timeout: 4300)
            try motor1.open(timeout: 4400)
            try sensor.open(timeout: 4500)
            
            
            
            // try motor0.setAcceleration(50)
        } catch let err as PhidgetError{
            print("Phidget Error116 " + err.description)
        } catch{
            //catch other errors here
        }
        
    }
    
}










