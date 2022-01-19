//
//  Matches.swift
//  snatch
//
//  Created by Nawaf on 4/20/21.
//

import Foundation
import Combine
import SwiftUI

import Alamofire

class ImageLoader: ObservableObject {
    var didChange = PassthroughSubject<Data, Never>()
    var data = Data() {
        didSet {
            didChange.send(data)
        }
    }

    init(urlString:String) {
        guard let url = URL(string: urlString) else { return }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            DispatchQueue.main.async {
                self.data = data
            }
        }
        task.resume()
    }
}

struct ImageView: View {
    @ObservedObject var imageLoader:ImageLoader
    @State var image:UIImage = UIImage()

    init(withURL url:String) {
        imageLoader = ImageLoader(urlString:url)
    }

    var body: some View {
        
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width:100, height:100)
                .onReceive(imageLoader.didChange) { data in
                self.image = UIImage(data: data) ?? UIImage()
        }
    }
}

struct userMatch: Codable, Equatable{

    let id: Int?
    let owner: String
    var challenger: [user?]
    let sport: String
    let teamSize: Int
    let opponentSize: Int
    let time: String
    var taken: Bool
}
struct oppMatch: Codable, Equatable{
    let id: Int
    let owner: user
    var challenger: [user?]
    let sport: String
    let teamSize: Int
    let opponentSize: Int
    let time: String
    var taken: Bool
}
class TokensJson:  Codable, Identifiable{
    var refresh: String
    var access: String
    var user_id: Int
    var username: String
    var first_name: String
    var last_name: String
    var age: Int
    var weight: Int
    var height: String
    var user_picture: String
    var current_match: Match?
}
struct m_location: Codable, Equatable, Hashable {
    var id: Int
    var location_name: String
    var location_address: String
    var location_city: String
    var location_state: String
    var location_image_url: String
    var matches_count: Int
}
struct Match: Codable, Identifiable, Equatable{
    let id: Int
    let owner: user
    var challenger: [user?]
    let sport: String
    let teamSize: Int
    let opponentSize: Int
    let time: String?
    var taken: Bool
    var match_location: m_location
}

struct CreateMatch: Codable{
    let owner: String
    var challenger: [user?]
    let sport: String
    let teamSize: Int
    let opponentSize: Int
    let time: String?
    var taken: Bool
    var match_location: createMatchLocation
}

struct createMatchLocation: Codable {
    var location_name: String
    var location_address: String
    var location_city: String
    var location_state: String
    var timezone: String
}

struct user: Codable, Identifiable, Equatable, Hashable{
    let id: Int
    let username: String
    let first_name: String
    let last_name: String
    let height: String
    let weight: Int
    let age: Int
    let user_picture: String?
}
struct apiResponse {
    let responseCode: Int
}



struct CreateUserErrorResponse: Codable {
    let username : [String]?
    let first_name: [String]?
    let last_name: [String]?
    let height: [String]?
    let weight: [String]?
    let age: [String]?
    let user_picture: [String]?
}



struct dataFromApi {
    var userMatchesData: [TokensJson] = []
    var successCode: Int = 0
}


struct HTTPBinResponse: Decodable {
    let url: String
    
}
struct homeData: Decodable {
    var counts : [String: Int]
    var team_match_count: [Int]
    var popular_locations: [m_location]?
    
}

class Api{
    func loadData(completion: @escaping ([Match]) -> (), url: URL) {
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            let matches = try! JSONDecoder().decode([Match].self, from: data!)
            print(matches)
            
            DispatchQueue.main.async {
                completion(matches)
            }
        }.resume()
    }
    

    
    func LHD(completion: @escaping (homeData) -> (), url: URL) {
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            let matches = try! JSONDecoder().decode(homeData.self, from: data!)
            DispatchQueue.main.async {
                completion(matches)
            }
        }.resume()
    }
 
    func loadHomeData(completion: @escaping (homeData) -> ()) {
    
        guard let url = URL(string: "http://opm-backend.herokuapp.com/api/home/") else {return}
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            let hd = try! JSONDecoder().decode(homeData.self, from: data!)
            DispatchQueue.main.async {
                completion(hd)
            }
        }.resume()
    }
    
    
    
    

    func loadData2(completion: @escaping ([TokensJson], apiResponse) ->  (), userData: Dictionary<String, Any>)  {

        var ddd3: dataFromApi?
        let url = URL(string: "https://opm-backend.herokuapp.com/api/token/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: userData, options: [])
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {return}
            do{
            let matchesPost = try! JSONDecoder().decode([TokensJson].self, from: data)
                let info = matchesPost[0]
                let httpResponse = response as? HTTPURLResponse
                var responseCode = apiResponse(responseCode: Int(httpResponse!.statusCode))
            let apiData1 = dataFromApi(userMatchesData: matchesPost, successCode: Int(httpResponse!.statusCode))
            ddd3 = apiData1
            DispatchQueue.main.async {
                completion(matchesPost, responseCode)
//                    return apiData1
                
                }
            } catch let error {
                    print("there was am error")
            }

        }.resume()
    }

    
    
    func withdrawAcceptMatch(_ match: Match, withdraw: Bool, token: Tokens, homeStats: homeStat){
        
        
        
        let url = URL(string: "https://opm-backend.herokuapp.com/api/matches/\(match.id)/")!
        let success = 200...299
        
        var challenger_user_ids: [Int] = []
        if match.challenger.count > 0 {
            for challenger in match.challenger {
                    challenger_user_ids += [challenger!.id]
            }
        }else{
            challenger_user_ids = [token.user_id]
        }
        if withdraw{
            challenger_user_ids = challenger_user_ids.filter {$0 != token.user_id}
        }
        let data = ["challenger":  challenger_user_ids] as[String : Any]
        print(data)

        var responseCode: Int = 0
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token.accessToken)", forHTTPHeaderField: "Authorization")
        print("ACCESS TOKEN:: \(token.accessToken)")
        request.httpBody = try? JSONSerialization.data(withJSONObject: data, options: [])
        let _: Void = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("there was an error \(error.localizedDescription)")
            } else {
                let jsonRes = try? JSONSerialization.jsonObject(with: data!, options: [])
                let httpResponse = response as? HTTPURLResponse
                if withdraw{
                    token.current_match = nil
                }else{
                    token.current_match = match
                }

                responseCode += Int(httpResponse!.statusCode)
                if success.contains(httpResponse!.statusCode) {
                    print("success")
                }else{
                    print("failure")
                }
            }

        }.resume()
        
    }
    
    
    

    
    func createMatch(match_info: CreateMatch, auth_token: String, completion: @escaping (Match?) -> Void ) {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(auth_token)",
            ]
    
        AF.request("https://opm-backend.herokuapp.com/api/matches/create/", method: .post,  parameters: match_info,  encoder: JSONParameterEncoder.default, headers: headers)
            .responseData {response in
                
                switch response.result {
                       case .success( let data):

                           do {
                            if (200...300).contains(response.response!.statusCode){
                                let match = try JSONDecoder().decode(Match.self, from: data)
                                completion(match)
                                print(match)
                            } else{
                                print("error")
                                completion(nil)
                            }
                           }
                           catch {print(error)}

                       case .failure(let error):
                        print (error)
                       }
                
            }
    }
    
    
    
    
    func userCreate(first_name: String, last_name: String, username: String, age: String, weight: String, height: String, password: String, pfp: UIImage, location_state: String, location_city: String,  completion: @escaping (_ error:CreateUserErrorResponse?, _ success: TokensJson?) -> Void )  {
        
        
        let param: [String:Any] = ["username": username,
                                    "first_name": first_name,
                                    "last_name": last_name,
                                    "location_state": "Bloomington",
                                    "location_city": "Indiana",
                                    "height": height,
                                    "weight": weight,
                                    "age": age]
        var image = pfp
        var resultMessage: String = "error"
        let imageData = image.jpegData(compressionQuality: 0.50)
        print(image, imageData!)

        AF.upload(multipartFormData: { (multipartFormData) in
                multipartFormData.append(imageData!, withName: "user_picture", fileName: "pfp.png", mimeType: "image/png")
                for (key, value) in param {
                    multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key)
                }
        }, to: "https://opm-backend.herokuapp.com/api/create_user/")

        .responseData {response in

            switch response.result {
                   case .success( let data):

                       do {
                        if (300...407).contains(response.response!.statusCode){
                            let user = try JSONDecoder().decode(CreateUserErrorResponse.self, from: data)
                            completion(user, nil)
                            print(user)
                        } else{
                            let user = try JSONDecoder().decode(TokensJson.self, from: data)
                            completion(nil, user)
                        }
                       }
                       catch {print(error)}

                   case .failure(let error):
                    print (error)
                   }
        }
    
        }
    
    func sendCreateUserRequest(first_name: String, last_name: String, username: String, age: String, weight: String, height: String, password: String, pfp: UIImage, location_state: String, location_city: String) {
        let url = URL(string: "http://127.0.0.1:8000/api/create_user/")!
        let success = 200...299
        let imageData: Data = pfp.jpegData(compressionQuality: 0.1) ?? Data()
        let imageStr: String = imageData.base64EncodedString()
        let data = ["username": username,
                    "first_name": first_name,
                    "last_name": last_name,
                    "location_state": location_state,
                    "location_city": location_city,
                    "height": height,
                    "weight": Int(weight),
                    "age": Int(age),
                    "user_picture": imageData] as [String : Any]
        
        var responseCode: Int = 0
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: data, options: [])
        let _: Void = URLSession.shared.dataTask(with: request) { data, response, error in
            let httpResponse = response as? HTTPURLResponse
            var responseCode = apiResponse(responseCode: Int(httpResponse!.statusCode))
            if !success.contains(responseCode.responseCode) {
                print("there was an error")
            } else {
                let jsonRes = try? JSONSerialization.jsonObject(with: data!, options: [])
                let httpResponse = response as? HTTPURLResponse
                let access = jsonRes as? [String: Any]
            }

        }.resume()
        
    }
    
    
    
}


extension NSMutableData {
    func appendString(string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}


import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {

    private let locationManager = CLLocationManager()
    @Published var locationStatus: CLAuthorizationStatus?
    @Published var lastLocation: CLLocation?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }

   
    
    var statusString: Bool {
        guard let status = locationStatus else {
            return false
        }
        switch status {
        case .notDetermined: return false
        case .authorizedWhenInUse: return true
        case .authorizedAlways: return true
        case .restricted: return true
        case .denied: return false
        default: return false
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationStatus = status
        print(#function, statusString)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Swift.Error) {
        print(error)
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        lastLocation = location
        print(#function, location)
    }
    
    func getCityState( completionHandler: @escaping (CLPlacemark?)
                        -> Void)  {

        var locationString = ""
        if let lat = lastLocation?.coordinate.latitude, let long = lastLocation?.coordinate.longitude{
        let location = CLLocation(latitude: lat, longitude: long)
        
            let geocoder = CLGeocoder()
            
            // Look up the location and pass it to the completion handler
            geocoder.reverseGeocodeLocation(location,
                        completionHandler: { (placemarks, error) in
                if error == nil {
                    let firstLocation = placemarks?[0]
                    locationString = "\(String(describing: firstLocation?.subAdministrativeArea)) \(String(describing: firstLocation?.administrativeArea))"
                    completionHandler(firstLocation)
                }
                else {
                    locationString = "No Location Found"
                    completionHandler(nil)
                }
            })
    }        
    }
}



extension Dictionary {
    subscript(i: Int) -> (key: Key, value: Value){
        get{
            return self[index(startIndex, offsetBy: i)]
        }
    }
}
