//
//  ARSession.swift
//  ARTexts
//
//  Created by James Folk on 9/25/17.
//  Copyright © 2017 James Folk. All rights reserved.
//

import Foundation

class ARSession
{
    var address:String
    
    init(_ sessionAddress:String)
    {
        self.address = sessionAddress
    }
    
    func list(arSession: @escaping (_ succeeded:Bool, _ sessions:Array<[String:Any]>) -> ())
    {
        let url = URL(string: "\(self.address)/sessions")!
        //create the session object
        let session = URLSession.shared
        
        //now create the URLRequest object using the url object
        var request = URLRequest(url: url)
        request.httpMethod = "GET" //set http method as POST
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let task = session.dataTask(with: request) {
            (data, response, error) in
            // check for any errors
            guard error == nil else {
                arSession(false, [])
                print("error calling GET on /texts")
                print(error!)
                return
            }
            // make sure we got data
            guard let responseData = data else {
                arSession(false, [])
                print("Error: did not receive data")
                return
            }
            // parse the result as JSON, since that's what the API provides
            do {
                guard let sessions = try JSONSerialization.jsonObject(with: responseData, options: [])
                    as? Array<[String:Any]> else {
                        arSession(false, [])
                        print("error trying to convert data to JSON")
                        return
                }
                arSession(true, sessions)
            } catch  {
                print("error trying to convert data to JSON")
                return
            }
        }
        task.resume()
    }
    
    func create(_ latitude:Double, _ longitude:Double, _ altitude:Double, _ horizontalAccuracy:Double, _ verticalAccuracy:Double, _ course:Double, _ speed:Double, _ yaw:Double, _ pitch:Double, _ roll:Double, arSession: @escaping (_ id:String, _ succeeded:Bool) -> ())
    {
        let url = URL(string: "\(self.address)/sessions")!
        //create the session object
        let session = URLSession.shared
        
        //now create the URLRequest object using the url object
        var request = URLRequest(url: url)
        request.httpMethod = "POST" //set http method as POST
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let postString = "latitude=\(latitude)&longitude=\(longitude)&altitude=\(altitude)&horizontalAccuracy=\(horizontalAccuracy)&verticalAccuracy=\(verticalAccuracy)&course=\(course)&speed=\(speed)&yaw=\(yaw)&pitch=\(pitch)&roll=\(roll)"
        request.httpBody = postString.data(using: .utf8)
        
        let task = session.dataTask(with: request) {
            (data, response, error) in
            // check for any errors
            guard error == nil else {
                arSession("", false)
                print("error calling GET on /sessions")
                print(error!)
                return
            }
            // make sure we got data
            guard let responseData = data else {
                arSession("", false)
                print("Error: did not receive data")
                return
            }
            // parse the result as JSON, since that's what the API provides
            do {
                guard let session = try JSONSerialization.jsonObject(with: responseData, options: [])
                    as? [String: Any] else {
                        arSession("", false)
                        print("error trying to convert data to JSON")
                        return
                }
                
                // now we have the todo
                // let's just print it to prove we can access it
                print("The todo is: " + session.description)
                
                // the todo object is a dictionary
                // so we just access the title using the "title" key
                // so check for a title and print it if we have one
                guard let _id = session["_id"] as? String else {
                    print("Could not get todo title from JSON")
                    return
                }
                //                print("The textId is: " + _id)
                
                arSession(_id, true)
                
            } catch  {
                arSession("", false)
                print("error trying to convert data to JSON")
                return
            }
        }
        task.resume()
    }
    
    func read(_ id:String, arSession: @escaping (_ latitude:Double, _ longitude:Double, _ altitude:Double, _ horizontalAccuracy:Double, _ verticalAccuracy:Double, _ course:Double, _ speed:Double, _ yaw:Double, _ pitch:Double, _ roll:Double, _ succeeded:Bool) -> ())
    {
        let url = URL(string: "\(self.address)/sessions" + "/" + id)!
        //create the session object
        let session = URLSession.shared
        
        //now create the URLRequest object using the url object
        var request = URLRequest(url: url)
        request.httpMethod = "GET" //set http method as POST
        
        let task = session.dataTask(with: request) {
            (data, response, error) in
            // check for any errors
            guard error == nil else {
                arSession(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false)
                print("error calling GET on /sessions")
                print(error!)
                return
            }
            // make sure we got data
            guard let responseData = data else {
                arSession(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false)
                print("Error: did not receive data")
                return
            }
            
            // parse the result as JSON, since that's what the API provides
            do {
                guard let _arSession = try JSONSerialization.jsonObject(with: responseData, options: [])
                    as? [String: Any] else {
                        arSession(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false)
                        print("error trying to convert data to JSON")
                        return
                }
                
                
                // now we have the todo
                // let's just print it to prove we can access it
                print("The todo is: " + _arSession.description)
                
                // the todo object is a dictionary
                // so we just access the title using the "title" key
                // so check for a title and print it if we have one
                guard let latitude = _arSession["latitude"] as? Double else {
                    arSession(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false)
                    print("Could not get todo title from JSON")
                    return
                }
                
                guard let longitude = _arSession["longitude"] as? Double else {
                    arSession(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false)
                    print("Could not get todo title from JSON")
                    return
                }
                
                guard let altitude = _arSession["altitude"] as? Double else {
                    arSession(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false)
                    print("Could not get todo title from JSON")
                    return
                }
                
                guard let horizontalAccuracy = _arSession["horizontalAccuracy"] as? Double else {
                    arSession(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false)
                    print("Could not get todo title from JSON")
                    return
                }
                
                guard let verticalAccuracy = _arSession["verticalAccuracy"] as? Double else {
                    arSession(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false)
                    print("Could not get todo title from JSON")
                    return
                }
                
                guard let course = _arSession["course"] as? Double else {
                    arSession(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false)
                    print("Could not get todo title from JSON")
                    return
                }
                
                guard let speed = _arSession["speed"] as? Double else {
                    arSession(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false)
                    print("Could not get todo title from JSON")
                    return
                }
                
                guard let yaw = _arSession["yaw"] as? Double else {
                    arSession(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false)
                    print("Could not get todo title from JSON")
                    return
                }
                
                guard let pitch = _arSession["pitch"] as? Double else {
                    arSession(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false)
                    print("Could not get todo title from JSON")
                    return
                }
                
                guard let roll = _arSession["roll"] as? Double else {
                    arSession(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false)
                    print("Could not get todo title from JSON")
                    return
                }
                
                //                guard let timestamp = _arSession["timestamp"] as? Date else {
                //                    arSession(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Date(), false)
                //                    print("Could not get todo title from JSON")
                //                    return
                //                }
                
                //                let numberFormatter = NumberFormatter()
                
                /*
                 _ latitude:Double, _ longitude:Double, _ altitude:Double, _ horizontalAccuracy:Double, _ verticalAccuracy:Double, _ course:Double, _ speed:Double, _ timestamp:Date
                 */
                
                arSession(latitude,
                          longitude,
                          altitude,
                          horizontalAccuracy,
                          verticalAccuracy,
                          course,
                          speed,
                          yaw,
                          pitch,
                          roll,
                          true)
            } catch  {
                arSession(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false)
                print("error trying to convert data to JSON")
                return
            }
        }
        task.resume()
    }
    
    func update(_ id:String, _ latitude:Double, _ longitude:Double, _ altitude:Double, _ horizontalAccuracy:Double, _ verticalAccuracy:Double, _ course:Double, _ speed:Double, _ yaw:Double, _ pitch:Double, _ roll:Double, arSession: @escaping (_ succeeded:Bool) -> ())
    {
        let url = URL(string: "\(self.address)/sessions" + "/" + id)!
        //create the session object
        let session = URLSession.shared
        
        //now create the URLRequest object using the url object
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let postString = "latitude=\(latitude)&longitude=\(longitude)&altitude=\(altitude)&horizontalAccuracy=\(horizontalAccuracy)&verticalAccuracy=\(verticalAccuracy)&course=\(course)&speed=\(speed)&yaw=\(yaw)&pitch=\(pitch)&roll=\(roll)"
        request.httpBody = postString.data(using: .utf8)
        
        let task = session.dataTask(with: request) {
            (data, response, error) in
            // check for any errors
            guard error == nil else {
                arSession(false)
                print("error calling GET on /texts")
                print(error!)
                return
            }
            // make sure we got data
            guard let responseData = data else {
                arSession(false)
                print("Error: did not receive data")
                return
            }
            // parse the result as JSON, since that's what the API provides
            do {
                guard let text = try JSONSerialization.jsonObject(with: responseData, options: [])
                    as? [String: Any] else {
                        arSession(false)
                        print("error trying to convert data to JSON")
                        return
                }
                
                // now we have the todo
                // let's just print it to prove we can access it
                //                print("The todo is: " + text.description)
                
                // the todo object is a dictionary
                // so we just access the title using the "title" key
                // so check for a title and print it if we have one
                guard (text["_id"] as? String) != nil else {
                    arSession(false)
                    print("Could not get todo title from JSON")
                    return
                }
                //                print("The textId is: " + _id)
                
                guard (text["Created_date"] as? String) != nil else {
                    arSession(false)
                    print("Could not get todo title from JSON")
                    return
                }
                
                //                print("The Created_date is: " + Created_date)
                arSession(true)
            } catch  {
                arSession(false)
                print("error trying to convert data to JSON")
                return
            }
        }
        task.resume()
    }
    
    func delete(_ id:String, arSession: @escaping (_ succeeded:Bool) -> ())
    {
        let url = URL(string: "\(self.address)/sessions" + "/" + id)!
        //create the session object
        let session = URLSession.shared
        
        //now create the URLRequest object using the url object
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE" //set http method as POST
        
        let task = session.dataTask(with: request) {
            (data, response, error) in
            // check for any errors
            guard error == nil else {
                arSession(false)
                print("error calling GET on /texts")
                print(error!)
                return
            }
            // make sure we got data
            guard let responseData = data else {
                arSession(false)
                print("Error: did not receive data")
                return
            }
            // parse the result as JSON, since that's what the API provides
            do {
                guard let text = try JSONSerialization.jsonObject(with: responseData, options: [])
                    as? [String: Any] else {
                        arSession(false)
                        print("error trying to convert data to JSON")
                        return
                }
                // now we have the todo
                // let's just print it to prove we can access it
                print("The todo is: " + text.description)
                
                arSession(true)
            } catch  {
                arSession(false)
                print("error trying to convert data to JSON")
                return
            }
        }
        task.resume()
    }
}


