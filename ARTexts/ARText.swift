//
//  ARText.swift
//  ARTexts
//
//  Created by James Folk on 9/25/17.
//  Copyright © 2017 James Folk. All rights reserved.
//

import SpriteKit

class ARText
{
    var address:String
    
    init(_ sessionAddress:String)
    {
        self.address = sessionAddress
    }
    
    func list(arText: @escaping (_ succeeded:Bool, _ texts:Array<[String:Any]>) -> ())
    {
        let url = URL(string: "\(self.address)/texts")!
        //create the session object
        let session = URLSession.shared
        
        //now create the URLRequest object using the url object
        var request = URLRequest(url: url)
        request.httpMethod = "GET" //set http method as POST
        //        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let task = session.dataTask(with: request) {
            (data, response, error) in
            // check for any errors
            guard error == nil else {
                arText(false,[])
                print("error calling GET on /texts")
                print(error!)
                return
            }
            // make sure we got data
            guard let responseData = data else {
                arText(false, [])
                print("Error: did not receive data")
                return
            }
            // parse the result as JSON, since that's what the API provides
            do {
                guard let texts = try JSONSerialization.jsonObject(with: responseData, options: [.allowFragments]) as? Array<[String:Any]> else {
                    arText(false, [])
                    return
                }
                arText(true, texts)
            } catch  {
                print("error trying to convert data to JSON")
                return
            }
        }
        task.resume()
    }
    
    //needs a completion string
    func create(_ text:String,
                _ transform: matrix_float4x4,
                _ fontSize:CGFloat,
                _ fontColor:SKColor,
                _ fontName:String,
                arText: @escaping (_ id:String, _ succeeded:Bool) -> ())
    {
        let url = URL(string: "\(self.address)/texts")!
        //create the session object
        let session = URLSession.shared
        
        //now create the URLRequest object using the url object
        var request = URLRequest(url: url)
        request.httpMethod = "POST" //set http method as POST
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        var colorComponents:[CGFloat] = fontColor.cgColor.components!
        let red = colorComponents[0]
        let green = colorComponents[1]
        let blue = colorComponents[2]
        let alpha = colorComponents[3]
        
        var fontColorString:String = red.description
        fontColorString += ","
        fontColorString += green.description
        fontColorString += ","
        fontColorString += blue.description
        fontColorString += ","
        fontColorString += alpha.description
        
        
        var transformString:String = transform.columns.0.x.description
        transformString += ","
        transformString += transform.columns.0.y.description
        transformString += ","
        transformString += transform.columns.0.z.description
        transformString += ","
        transformString += transform.columns.0.w.description
        transformString += ","
        transformString += transform.columns.1.x.description
        transformString += ","
        transformString += transform.columns.1.y.description
        transformString += ","
        transformString += transform.columns.1.z.description
        transformString += ","
        transformString += transform.columns.1.w.description
        transformString += ","
        transformString += transform.columns.2.x.description
        transformString += ","
        transformString += transform.columns.2.y.description
        transformString += ","
        transformString += transform.columns.2.z.description
        transformString += ","
        transformString += transform.columns.2.w.description
        transformString += ","
        transformString += transform.columns.3.x.description
        transformString += ","
        transformString += transform.columns.3.y.description
        transformString += ","
        transformString += transform.columns.3.z.description
        transformString += ","
        transformString += transform.columns.3.w.description
        
        let defaults = UserDefaults.standard
        if let sessionId = defaults.string(forKey: "sessionId")
        {
            let postString = "transform=\(transformString)&text=\(text)&sessionId=\(sessionId)&fontName=\(fontName)&fontSize=\(fontSize.description)&fontColor=\(fontColorString)"
            request.httpBody = postString.data(using: .utf8)
            
            let task = session.dataTask(with: request) {
                (data, response, error) in
                // check for any errors
                guard error == nil else {
                    arText("", false)
                    print("error calling GET on /texts")
                    print(error!)
                    return
                }
                // make sure we got data
                guard let responseData = data else {
                    arText("", false)
                    print("Error: did not receive data")
                    return
                }
                // parse the result as JSON, since that's what the API provides
                do {
                    guard let text = try JSONSerialization.jsonObject(with: responseData, options: [])
                        as? [String: Any] else {
                            arText("", false)
                            print("error trying to convert data to JSON")
                            return
                    }
                    
                    // now we have the todo
                    // let's just print it to prove we can access it
                    //                print("The todo is: " + text.description)
                    
                    // the todo object is a dictionary
                    // so we just access the title using the "title" key
                    // so check for a title and print it if we have one
                    guard let _id = text["_id"] as? String else {
                        print("Could not get todo title from JSON")
                        return
                    }
                    //                print("The textId is: " + _id)
                    
                    arText(_id, true)
                    
                } catch  {
                    arText("", false)
                    print("error trying to convert data to JSON")
                    return
                }
            }
            task.resume()
        }
        else
        {
            arText("", false)
        }
        
    }
    
    func read(_ id:String,
              arText: @escaping (
        _ text:String,
        _ transform: matrix_float4x4,
        _ fontSize:CGFloat,
        _ fontColor:SKColor,
        _ fontName:String, _ succeeded:Bool) -> ())
    {
        let url = URL(string: "\(self.address)/texts" + "/" + id)!
        //create the session object
        let session = URLSession.shared
        
        //now create the URLRequest object using the url object
        var request = URLRequest(url: url)
        request.httpMethod = "GET" //set http method as POST
        
        let task = session.dataTask(with: request) {
            (data, response, error) in
            // check for any errors
            guard error == nil else {
                arText("",
                       matrix_identity_float4x4,
                       32,
                       SKColor(displayP3Red: 1.0,
                               green: 1.0,
                               blue: 1.0,
                               alpha: 1.0),
                       "Courier-Bold",
                       false)
                print("error calling GET on /texts")
                print(error!)
                return
            }
            // make sure we got data
            guard let responseData = data else {
                arText("",
                       matrix_identity_float4x4,
                       32,
                       SKColor(displayP3Red: 1.0,
                               green: 1.0,
                               blue: 1.0,
                               alpha: 1.0),
                       "Courier-Bold",
                       false)
                print("Error: did not receive data")
                return
            }
            // parse the result as JSON, since that's what the API provides
            do {
                guard let _arText = try JSONSerialization.jsonObject(with: responseData, options: [])
                    as? [String: Any] else {
                        arText("",
                               matrix_identity_float4x4,
                               32,
                               SKColor(displayP3Red: 1.0,
                                       green: 1.0,
                                       blue: 1.0,
                                       alpha: 1.0),
                               "Courier-Bold",
                               false)
                        print("error trying to convert data to JSON")
                        return
                }
                // now we have the todo
                // let's just print it to prove we can access it
                //                print("The todo is: " + _arText.description)
                
                let defaults = UserDefaults.standard
                if let sessionId = defaults.string(forKey: "sessionId")
                {
                    guard let _sessionId = _arText["sessionId"] as? String else {
                        arText("",
                               matrix_identity_float4x4,
                               32,
                               SKColor(displayP3Red: 1.0,
                                       green: 1.0,
                                       blue: 1.0,
                                       alpha: 1.0),
                               "Courier-Bold",
                               false)
                        print("Could not get todo title from JSON")
                        return
                    }
                    
                    if(sessionId == _sessionId)
                    {
                        // the todo object is a dictionary
                        // so we just access the title using the "title" key
                        // so check for a title and print it if we have one
                        guard let text = _arText["text"] as? String else {
                            arText("",
                                   matrix_identity_float4x4,
                                   32,
                                   SKColor(displayP3Red: 1.0,
                                           green: 1.0,
                                           blue: 1.0,
                                           alpha: 1.0),
                                   "Courier-Bold",
                                   false)
                            print("Could not get todo title from JSON")
                            return
                        }
                        //                print("The text is: " + text)
                        
                        guard let transform = _arText["transform"] as? String else {
                            arText("",
                                   matrix_identity_float4x4,
                                   32,
                                   SKColor(displayP3Red: 1.0,
                                           green: 1.0,
                                           blue: 1.0,
                                           alpha: 1.0),
                                   "Courier-Bold",
                                   false)
                            print("Could not get todo title from JSON")
                            return
                        }
                        //                print("The transform is: " + transform)
                        let transformComponents = transform.components(separatedBy: ",")
                        
                        let numberFormatter = NumberFormatter()
                        
                        let t = matrix_float4x4(float4(x: (numberFormatter.number(from: transformComponents[0])?.floatValue)!,
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
                        
                        guard let fontSize = _arText["fontSize"] as? CGFloat else {
                            arText("",
                                   matrix_identity_float4x4,
                                   32,
                                   SKColor(displayP3Red: 1.0,
                                           green: 1.0,
                                           blue: 1.0,
                                           alpha: 1.0),
                                   "Courier-Bold",
                                   false)
                            print("Could not get todo title from JSON")
                            return
                        }
                        
                        guard let fontColor = _arText["fontColor"] as? String else {
                            arText("",
                                   matrix_identity_float4x4,
                                   32,
                                   SKColor(displayP3Red: 1.0,
                                           green: 1.0,
                                           blue: 1.0,
                                           alpha: 1.0),
                                   "Courier-Bold",
                                   false)
                            print("Could not get todo title from JSON")
                            return
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
                            arText("",
                                   matrix_identity_float4x4,
                                   32,
                                   SKColor(displayP3Red: 1.0,
                                           green: 1.0,
                                           blue: 1.0,
                                           alpha: 1.0),
                                   "Courier-Bold",
                                   false)
                            print("Could not get todo title from JSON")
                            return
                        }
                        
                        arText(text, t, fontSize, f, fontName, true)
                    }
                    else
                    {
                        arText("",
                               matrix_identity_float4x4,
                               32,
                               SKColor(displayP3Red: 1.0,
                                       green: 1.0,
                                       blue: 1.0,
                                       alpha: 1.0),
                               "Courier-Bold",
                               false)
                    }
                }
                else
                {
                    arText("",
                           matrix_identity_float4x4,
                           32,
                           SKColor(displayP3Red: 1.0,
                                   green: 1.0,
                                   blue: 1.0,
                                   alpha: 1.0),
                           "Courier-Bold",
                           false)
                }
            } catch  {
                arText("",
                       matrix_identity_float4x4,
                       32,
                       SKColor(displayP3Red: 1.0,
                               green: 1.0,
                               blue: 1.0,
                               alpha: 1.0),
                       "Courier-Bold",
                       false)
                print("error trying to convert data to JSON")
                return
            }
        }
        task.resume()
    }
    
    func update(
        _ id:String,
        _ text:String,
        _ transform: matrix_float4x4,
        _ fontSize:CGFloat,
        _ fontColor:SKColor,
        _ fontName:String
        , arText: @escaping (_ succeeded:Bool) -> ())
    {
        let url = URL(string: "\(self.address)/texts" + "/" + id)!
        //create the session object
        let session = URLSession.shared
        
        //now create the URLRequest object using the url object
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        var colorComponents:[CGFloat] = fontColor.cgColor.components!
        let red = colorComponents[0]
        let green = colorComponents[1]
        let blue = colorComponents[2]
        let alpha = colorComponents[3]
        
        var fontColorString:String = red.description
        fontColorString += ","
        fontColorString += green.description
        fontColorString += ","
        fontColorString += blue.description
        fontColorString += ","
        fontColorString += alpha.description
        
        var transformString:String = transform.columns.0.x.description
        transformString += ","
        transformString += transform.columns.0.y.description
        transformString += ","
        transformString += transform.columns.0.z.description
        transformString += ","
        transformString += transform.columns.0.w.description
        transformString += ","
        transformString += transform.columns.1.x.description
        transformString += ","
        transformString += transform.columns.1.y.description
        transformString += ","
        transformString += transform.columns.1.z.description
        transformString += ","
        transformString += transform.columns.1.w.description
        transformString += ","
        transformString += transform.columns.2.x.description
        transformString += ","
        transformString += transform.columns.2.y.description
        transformString += ","
        transformString += transform.columns.2.z.description
        transformString += ","
        transformString += transform.columns.2.w.description
        transformString += ","
        transformString += transform.columns.3.x.description
        transformString += ","
        transformString += transform.columns.3.y.description
        transformString += ","
        transformString += transform.columns.3.z.description
        transformString += ","
        transformString += transform.columns.3.w.description
        
//        let postString = "transform=\(transformString)&text=\(text)"
        let postString = "transform=\(transformString)&text=\(text)&fontName=\(fontName)&fontSize=\(fontSize.description)&fontColor=\(fontColorString)"
        request.httpBody = postString.data(using: .utf8)
        
        let task = session.dataTask(with: request) {
            (data, response, error) in
            // check for any errors
            guard error == nil else {
                arText(false)
                print("error calling GET on /texts")
                print(error!)
                return
            }
            // make sure we got data
            guard let responseData = data else {
                arText(false)
                print("Error: did not receive data")
                return
            }
            // parse the result as JSON, since that's what the API provides
            do {
                guard let text = try JSONSerialization.jsonObject(with: responseData, options: [])
                    as? [String: Any] else {
                        arText(false)
                        print("error trying to convert data to JSON")
                        return
                }
                
                // now we have the todo
                // let's just print it to prove we can access it
                //                print("The todo is: " + text.description)
                
                // the todo object is a dictionary
                // so we just access the title using the "title" key
                // so check for a title and print it if we have one
                guard let _id = text["_id"] as? String else {
                    arText(false)
                    print("Could not get todo title from JSON")
                    return
                }
                //                print("The textId is: " + _id)
                
                guard let Created_date = text["Created_date"] as? String else {
                    arText(false)
                    print("Could not get todo title from JSON")
                    return
                }
                
                //                print("The Created_date is: " + Created_date)
                arText(true)
            } catch  {
                arText(false)
                print("error trying to convert data to JSON")
                return
            }
        }
        task.resume()
    }
    
    func delete(_ id:String, arText: @escaping (_ succeeded:Bool) -> ())
    {
        let url = URL(string: "\(self.address)/texts" + "/" + id)!
        //create the session object
        let session = URLSession.shared
        
        //now create the URLRequest object using the url object
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE" //set http method as POST
        
        let task = session.dataTask(with: request) {
            (data, response, error) in
            // check for any errors
            guard error == nil else {
                arText(false)
                print("error calling GET on /texts")
                print(error!)
                return
            }
            // make sure we got data
            guard let responseData = data else {
                arText(false)
                print("Error: did not receive data")
                return
            }
            // parse the result as JSON, since that's what the API provides
            do {
                guard let text = try JSONSerialization.jsonObject(with: responseData, options: [])
                    as? [String: Any] else {
                        arText(false)
                        print("error trying to convert data to JSON")
                        return
                }
                // now we have the todo
                // let's just print it to prove we can access it
                print("The todo is: " + text.description)
                
                arText(true)
            } catch  {
                arText(false)
                print("error trying to convert data to JSON")
                return
            }
        }
        task.resume()
    }
}
