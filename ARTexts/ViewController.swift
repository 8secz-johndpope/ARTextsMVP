//
//  ViewController.swift
//  ARTexts
//
//  Created by James Folk on 9/25/17.
//  Copyright © 2017 James Folk. All rights reserved.
//

import UIKit
import SpriteKit
import ARKit
import CoreLocation
import CoreMotion

class ViewController: UIViewController, ARSKViewDelegate {
    
    @IBOutlet var sceneView: ARSKView!
    var locationManager: CLLocationManager!
    
    var currentCLLocation: CLLocation?
    
    let coreMotionManager = CMMotionManager()
    
    var currentAttitude:CMAttitude?
    
    var startAttitude:CMAttitude?
    var startYaw:Double = 0.0
    var startPitch:Double = 0.0
    var startRoll:Double = 0.0
    
    var remoteReady:Bool = false
    var arReady:Bool = false
    var blurView:UIVisualEffectView?
    
    var currentCameraLocation: matrix_float4x4?
    
    public var currentField : UITextField?
    
    public var currentLabel : SKLabelNode? = nil
    public var createNew : Bool = false
    
    public var fontPicker : KWFontPicker = KWFontPicker()
    
    private var panGestureRecognizer: UIPanGestureRecognizer?
    public var slideDirection: Float = 0
    
//    var arSession:ARSession = ARSession("http://localhost:3000")
    var arSession:ARSession = ARSession("https://artexts.herokuapp.com")
    var arText:ARText = ARText("https://artexts.herokuapp.com")
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        guard let velocity = panGestureRecognizer?.velocity(in: self.view) else {return}
        
        if(velocity.y > 0)
        {
            self.slideDirection = 1
        }
        else if(velocity.y < 0)
        {
            self.slideDirection = -1
        }
        else
        {
            self.slideDirection = 0
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        
        
        
        
//        arText.delete("5a25754906f0ee00237342ab", arText: {(success:Bool) in
//            if(success)
//            {
//                print("removed the text")
//            }
//            else
//            {
//                print("could not remove the text")
//            }
//        })
        
        
        
        
        
        
        
        
        
        let blur = UIBlurEffect(style: .regular)
        self.blurView = UIVisualEffectView(effect: blur)
        self.blurView?.frame = self.view.bounds
        self.blurView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        self.view.addSubview(self.blurView!)
        
//        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
//        swipeUp.direction = .up
//        self.view.addGestureRecognizer(swipeUp)
//
//        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
//        swipeDown.direction = .down
//        self.view.addGestureRecognizer(swipeDown)
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleGesture))
        self.view.addGestureRecognizer(panGestureRecognizer!)
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and node count
        sceneView.showsFPS = true
        sceneView.showsNodeCount = true
        
        // Load the SKScene from 'Scene.sks'
        if let scene = SKScene(fileNamed: "Scene") {
            sceneView.presentScene(scene)
        }
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        
        //https://github.com/mcritz/iosfonts/blob/master/data/iosfonts.json
        let filePath = Bundle.main.path(forResource: "iosfonts", ofType:"json")
        let data = NSData(contentsOfFile:filePath!)
        
        if let urlContent = data {
            do {
                let jsonResult = try JSONSerialization.jsonObject(with: urlContent as Data, options: JSONSerialization.ReadingOptions.mutableContainers)
                
                var fontList : [String] = []
                let dict = jsonResult as? NSDictionary
                let fonts = dict!["fonts"] as? NSArray
                for font in fonts!
                {
                    if let font = font as? NSDictionary
                    {
                        let family_name = font["family_name"] as! String
                        fontList.append(family_name)
                    }
                }
                
                fontPicker.fontList = fontList
                fontPicker.minFontSize = 8
                fontPicker.maxFontSize = 72
                fontPicker.colorVariants = KWFontPickerColorVariants.variants666
                fontPicker.grayVariants = 16
                
                fontPicker.setChangeHandler((() -> Void)!{
                    DispatchQueue.main.async {
                        guard let label = self.currentLabel else { return }
                        label.fontName = self.fontPicker.selectedFontName()
                        label.fontSize = self.fontPicker.selectedFontSize()
                        label.fontColor = self.fontPicker.selectedColor()
                    }
                })
                
                self.sceneView.addSubview(fontPicker)
                
                fontPicker.isHidden = true
                
            }
            catch
            {
                print("JSON serialization failed")
            }
        }
        else
        {
            print("ERROR FOUND HERE")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        // Create a session configuration
//        let configuration = ARWorldTrackingConfiguration()
//
//        // Run the view's session
//        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    func endEditing(_ label: SKLabelNode)
    {
        if createNew
        {
            if label.text != ""
            {
                if let dictParams: NSMutableDictionary = label.userData
                {
                    if let textAnchor:ARAnchorText = dictParams.object(forKey: "textAnchor") as? ARAnchorText
                    {
                        //MARK: Create the label from the scene
                        let transform:matrix_float4x4 = textAnchor.transform
                        
                        arText.create(label.text!, transform, label.fontSize, label.fontColor!, label.fontName!, arText: {(id:String, success:Bool) in
                        
                            DispatchQueue.main.async {
                                if(success)
                                {
                                    textAnchor.userData = ["textID" : id]
                                    
                                    print("ADDED a new artext to the scene")
                                }
                                else
                                {
                                    print("Did not add a new artext to the scene, but tried")
                                }
                            }
                        })
                    }
                }
            }
        }
        else
        {
            if label.text == ""
            {
                deleteLabel(label)
            }
            else
            {
                //MARK: Update the label from the scene
                if let dictParams: NSMutableDictionary = label.userData
                {
                    if let textAnchor:ARAnchorText = dictParams.object(forKey: "textAnchor") as? ARAnchorText
                    {
                        if let textAnchor_dictParams: NSMutableDictionary = textAnchor.userData
                        {
                            if let textId:String = textAnchor_dictParams.object(forKey: "textID") as? String
                            {
                                let transform:matrix_float4x4 = textAnchor.transform
                                let text:String = label.text!
                                let fontName:String = label.fontName!
                                let fontSize:CGFloat = label.fontSize
                                let fontColor:SKColor = label.fontColor!
                                
                                arText.update(textId, text, transform, fontSize, fontColor, fontName, arText: {(success:Bool) in
//                                arText.update(textId, text, transform, arText: {(success:Bool) in
                                
                                    DispatchQueue.main.async {
                                        if(success)
                                        {
                                            print("UPDATED the artext")
                                        }
                                        else
                                        {
                                            print("Did not update the artext, but tried")
                                        }
                                    }
                                })
                            }
                        }
                    }
                }
            }
        }
        
        fontPicker.isHidden = true
    }
    
    func deleteLabel(_ label: SKLabelNode)
    {
        guard let cancelButton = label.childNode(withName: "cancelButton") else {return}
        cancelButton.isHidden = true
        label.isHidden = true
        
        cancelButton.removeFromParent()
        label.removeFromParent()
        
        //MARK: Delete the label from the scene
        if let dictParams: NSMutableDictionary = label.userData
        {
            if let textAnchor:ARAnchorText = dictParams.object(forKey: "textAnchor") as? ARAnchorText
            {
                if let textAnchor_dictParams: NSMutableDictionary = textAnchor.userData
                {
                    if let textId:String = textAnchor_dictParams.object(forKey: "textID") as? String
                    {
                        arText.delete(textId, arText: {(success:Bool) in
                            
                            DispatchQueue.main.async {
                                if(success)
                                {
                                    print("DELETED the artext")
                                }
                                else
                                {
                                    print("Did not delete the artext, but tried")
                                }
                            }
                        })

                    }
                }
            }
        }
    }
    
    func loadLabel(_ text: String, _ textAnchor: ARAnchorText, _ fontName: String, _ fontColor: SKColor, _ fontSize:CGFloat)
    {
        let label = SKLabelNode(fontNamed: fontName)
        label.text = text
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.name = "label"
        label.userData = ["textAnchor" : textAnchor]
        label.color = fontColor
        label.fontSize = fontSize
        
        let cancelButton = SKSpriteNode(imageNamed: "Cancel")
        cancelButton.position = CGPoint(x: 0, y: label.frame.size.height + (label.frame.size.height * 0.5))
        cancelButton.name = "cancelButton"
        let size = CGSize(width: cancelButton.size.width * 0.025, height: cancelButton.size.height * 0.025)
        cancelButton.scale(to: size)
        label.addChild(cancelButton)
        
        
        cancelButton.isHidden = true
        fontPicker.isHidden = true
        createNew = false
        
        fontPicker.selectColor(label.color, animated: true)
        fontPicker.selectFontName(label.fontName, animated: true)
        fontPicker.selectFontSize(label.fontSize, animated: true)
        
        currentLabel = label
        
        
        
        currentLabel?.fontName = self.fontPicker.selectedFontName()
        currentLabel?.fontSize = self.fontPicker.selectedFontSize()
        currentLabel?.fontColor = self.fontPicker.selectedColor()
        
        
    }
    
    func createLabel(_ text: String, _ textAnchor: ARAnchorText)
    {
        let label = SKLabelNode(fontNamed: "Courier-Bold")
        label.text = text
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.name = "label"
        label.userData = ["textAnchor" : textAnchor]
        label.color = SKColor(displayP3Red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        label.fontSize = 32
        
        let cancelButton = SKSpriteNode(imageNamed: "Cancel")
        cancelButton.position = CGPoint(x: 0, y: label.frame.size.height + (label.frame.size.height * 0.5))
        cancelButton.name = "cancelButton"
        let size = CGSize(width: cancelButton.size.width * 0.025, height: cancelButton.size.height * 0.025)
        cancelButton.scale(to: size)
        label.addChild(cancelButton)
        
        cancelButton.isHidden = false
        fontPicker.isHidden = false
        createNew = true
        
        fontPicker.selectColor(label.color, animated: false)
        fontPicker.selectFontName(label.fontName, animated: false)
        fontPicker.selectFontSize(label.fontSize, animated: false)
        
        currentLabel = label
        
    }
    
    func view(_ view: ARSKView, nodeFor anchor: ARAnchor) -> SKNode?
    {
        
        
        // Create and configure a node for the anchor added to the view's session.
        
        
        
        let previousLabel = currentLabel
//        guard let textAnchor = anchor as? ARAnchorText else {return nil}
        
        
//        let textAnchor:ARAnchorText = anchor as! ARAnchorText
        
        guard let textAnchor = try anchor
            as? ARAnchorText else {
                
                print("error trying to convert anchor")
                return nil
        }
        
        if let textAnchor_dictParams: NSMutableDictionary = textAnchor.userData
        {
            if let textID:String = textAnchor_dictParams.object(forKey: "textID") as? String
            {
                if let fontName:String = textAnchor_dictParams.object(forKey: "fontName") as? String
                {
                    if let fontColor:SKColor = textAnchor_dictParams.object(forKey: "fontColor") as? SKColor
                    {
                        if let fontSize:CGFloat = textAnchor_dictParams.object(forKey: "fontSize") as? CGFloat
                        {
                            self.loadLabel(textAnchor.text, textAnchor, fontName, fontColor, CGFloat(fontSize))
                        }
                    }
                }
            }
        }
        else
        {
            self.createLabel(textAnchor.text, textAnchor)
            
            self.handleKeyboard(textAnchor.text)
            
            if nil != previousLabel
            {
                if previousLabel?.text == ""
                {
                    deleteLabel(previousLabel!)
                }
                else
                {
                    guard let cancelButton = previousLabel?.childNode(withName: "cancelButton") else {return currentLabel}
                    cancelButton.isHidden = true
                    self.endEditing(previousLabel!)
                }
            }
        }
        
        
        
        return currentLabel;
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        
        switch camera.trackingState {
        case .notAvailable:
            self.arReady = false
            self.blurView!.isHidden = false
        case .limited:
            self.blurView!.isHidden = false
            self.arReady = false
        case .normal:
            self.arReady = true
            self.blurView!.isHidden = true
        }
    }
    
//    func session(_ session: ARSession, didFailWithError error: Error) {
//        // Present an error message to the user
//
//    }
//
//    func sessionWasInterrupted(_ session: ARSession) {
//        // Inform the user that the session has been interrupted, for example, by presenting an overlay
//
//    }
//
//    func sessionInterruptionEnded(_ session: ARSession) {
//        // Reset tracking and/or remove existing anchors if consistent tracking is required
//
//    }
    
    func startRemoteARSession()
    {
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
        sceneView.session.delegate = self
        
        guard let cl = self.currentCLLocation else { return }
        
        let latitude:Double = cl.coordinate.latitude
        let longitude:Double = cl.coordinate.longitude
        let altitude:Double = cl.altitude
        let horizontalAccuracy:Double = cl.horizontalAccuracy
        let verticalAccuracy:Double = cl.verticalAccuracy
        let course:Double = cl.course
        let speed:Double = cl.speed
        
        let defaults = UserDefaults.standard
        
        if let sessionId = defaults.string(forKey: "sessionId")
        {
            arSession.read(sessionId, arSession: {(latitude:Double, longitude:Double, altitude:Double, horizontalAccuracy:Double, verticalAccuracy:Double, course:Double, speed:Double, yaw:Double, pitch:Double, roll:Double, success:Bool) in
                
                self.remoteReady = true
                
                self.startYaw = yaw
                self.startPitch = pitch
                self.startRoll = roll
                
                self.arText.list(arText: {(success:Bool, texts:Array<[String:Any]>) in
                    for _arText in texts
                    {
                        guard let text = _arText["text"] as? String else {
                            continue
                        }
                        
                        guard let t = _arText["transform"] as? String else {
                            continue
                        }
                        
                        guard let _id = _arText["_id"] as? String else {
                            continue
                        }
                        
                        guard let _sessionId = _arText["sessionId"] as? String else {
                            continue
                        }
                        
                        if(_sessionId != sessionId)
                        {
                            continue
                        }
                        
                        let transformComponents = t.components(separatedBy: ",")
                        
                        let numberFormatter = NumberFormatter()
                        
                        let transform = matrix_float4x4(float4(x: (numberFormatter.number(from: transformComponents[0])?.floatValue)!,
                                                               y: (numberFormatter.number(from: transformComponents[1])?.floatValue)!,
                                                               z: (numberFormatter.number(from: transformComponents[2])?.floatValue)!,
                                                               w: (numberFormatter.number(from: transformComponents[3])?.floatValue)!),
                                                        float4(x: (numberFormatter.number(from: transformComponents[4])?.floatValue)!,
                                                               y: (numberFormatter.number(from: transformComponents[5])?.floatValue)!,
                                                               z: (numberFormatter.number(from: transformComponents[6])?.floatValue)!,
                                                               w: (numberFormatter.number(from: transformComponents[7])?.floatValue)!),
                                                        float4(x: (numberFormatter.number(from: transformComponents[8])?.floatValue)!,
                                                               y: (numberFormatter.number(from: transformComponents[9])?.floatValue)!,
                                                               z: (numberFormatter.number(from: transformComponents[10])?.floatValue)!,
                                                               w: (numberFormatter.number(from: transformComponents[11])?.floatValue)!),
                                                        float4(x: (numberFormatter.number(from: transformComponents[12])?.floatValue)!,
                                                               y: (numberFormatter.number(from: transformComponents[13])?.floatValue)!,
                                                               z: (numberFormatter.number(from: transformComponents[14])?.floatValue)!,
                                                               w: (numberFormatter.number(from: transformComponents[15])?.floatValue)!))
                        
                        print("\(text) : \(transform)")
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        guard let fontSize = _arText["fontSize"] as? CGFloat else {
                            continue
                        }
                        
                        guard let fontColor = _arText["fontColor"] as? String else {
                            continue
                        }
                        
                        let fontColorComponents = fontColor.components(separatedBy: ",")
                        
                        let red = CGFloat((numberFormatter.number(from: fontColorComponents[0])?.floatValue)!)
                        let green = CGFloat((numberFormatter.number(from: fontColorComponents[1])?.floatValue)!)
                        let blue = CGFloat((numberFormatter.number(from: fontColorComponents[2])?.floatValue)!)
                        let alpha = CGFloat((numberFormatter.number(from: fontColorComponents[3])?.floatValue)!)
                        
                        let f = SKColor(displayP3Red: red,
                                        green: green,
                                        blue: blue,
                                        alpha: alpha)
                        
                        guard let fontName = _arText["fontName"] as? String else {
                            continue
                        }
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        DispatchQueue.main.async {
                            guard let scene = self.sceneView.scene as? Scene else {
                                return
                            }
                            scene.loadText(transform, _id, fontName, f, fontSize, text)
                            
                        }
                    }
                })
                
            })
        }
        else
        {
            arSession.create(latitude, longitude, altitude, horizontalAccuracy, verticalAccuracy, course, speed, self.startYaw, self.startPitch, self.startRoll, arSession: {(id:String, success:Bool) in
                
                defaults.setValue(id, forKey: "sessionId")
                defaults.synchronize()
                
                self.remoteReady = true
                
            })
        }
    }
    
    func handleKeyboard(_ text:String)
    {
        if(self.currentField != nil)
        {
            self.currentField?.removeFromSuperview()
            self.currentField?.resignFirstResponder()
            self.currentField = nil
        }
        
        if(self.currentField == nil)
        {
            self.currentField = UITextField(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
            self.currentField?.delegate = self
            self.currentField?.isHidden = true
            self.view?.addSubview(self.currentField!)
        }
        self.currentField?.text = text
        self.currentField?.becomeFirstResponder()
    }
}

extension ViewController:CLLocationManagerDelegate
{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        var startCMSession:Bool = false
        if(currentCLLocation == nil)
        {
            startCMSession = true
        }
        
        currentCLLocation = locations[0]
        if(currentCLLocation == nil)
        {
            return
        }
        
        if(startCMSession)
        {
            if coreMotionManager.isDeviceMotionAvailable {
                
                coreMotionManager.startDeviceMotionUpdates(to: .main) {
                    [weak self] (data: CMDeviceMotion?, error: Error?) in
                    
                    guard let data = data else { return }
                    guard let vc = self else { return }
                    
                    vc.currentAttitude = data.attitude
                    
                    DispatchQueue.main.async {
                        if (vc.startAttitude == nil)
                        {
                            vc.startAttitude = data.attitude
                            
                            vc.startRoll = (vc.startAttitude?.roll)!
                            vc.startYaw = (vc.startAttitude?.yaw)!
                            vc.startPitch = (vc.startAttitude?.pitch)!
                            
                            vc.startRemoteARSession()
                        }
                    }
                }
            }
        }
    }
}

extension ViewController:ARSessionDelegate
{
    func session(_ session: ARSession,
                 didUpdate frame: ARFrame)
    {
        currentCameraLocation = frame.camera.transform
    }
    
    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        
    }
}

extension ViewController: UITextFieldDelegate
{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let newString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
        
        guard let label = currentLabel else { return true }
        label.text = newString
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        DispatchQueue.main.async {
            guard let cancelButton = self.currentLabel?.childNode(withName: "cancelButton") else {return}
            cancelButton.isHidden = true
            
            self.view.endEditing(true)
            self.endEditing(self.currentLabel!)
            
//            self.currentLabel = nil
        }
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        print("end editing")
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        DispatchQueue.main.async {
            textField.selectAll(nil)
            
        }
    }
}
