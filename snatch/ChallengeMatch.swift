//
//  ChallengeMatch.swift
//  snatch
//
//  Created by Nawaf on 6/14/21.
//

import SwiftUI
import Kingfisher
struct ChallengeMatch: View {
    var match: Match
    @State var hidden = true
    @ObservedObject var token: Tokens
    @ObservedObject var homeStats: homeStat
    @State var withdraw = false
    @State var playerSheetShown = false
    @State var showWithdrawAlert = false
    @State var withdrawLoading = false
    func forTrailingZero(temp: Double) -> String {
        var tempVar = String(format: "%g", temp)
        return tempVar
    }
    
    func withdrawAcceptMatch(_ match: Match, withdraw: Bool){
        
        
        
        let url = URL(string: "https://opm-backend.herokuapp.com/api/matches/\(match.id)/")!
        let success = 200...299
        
        var challenger_user_ids: [Int] = []
        if match.challenger.count > 0 {
            for challenger in match.challenger {
                challenger_user_ids += [challenger!.id]
            }
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
        request.httpBody = try? JSONSerialization.data(withJSONObject: data, options: [])
        let _: Void = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("there was an error \(error.localizedDescription)")
            } else {
                let jsonRes = try? JSONSerialization.jsonObject(with: data!, options: [])
                let httpResponse = response as? HTTPURLResponse
                homeStats.challengeMatch = nil
                responseCode += Int(httpResponse!.statusCode)
                if success.contains(httpResponse!.statusCode) {
                    print("success")
                }else{
                    print("failure")
                }
            }

        }.resume()
    }
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US")
            formatter.dateFormat = "h:mm a"
            formatter.amSymbol = "AM"
            formatter.pmSymbol = "PM"
            return formatter
        }()

    
    
    func matchDateInfo(time: String) -> Date? {
        let sepByColon = time.components(separatedBy: ":")
        var hour = Int(sepByColon[0])!
        let min_daytime = sepByColon[1].components(separatedBy: " ")
        let min = Int(min_daytime[0])!
        let daytime = min_daytime[1]
        if daytime == "PM"{
            hour += 12
        }
        let matchDate = Calendar.current.date(bySettingHour: hour, minute: min, second: 0, of: Date())!
        return matchDate
    }
    @State var hours: Int?
    @State var minutes: Int?
    @State var seconds: Int?
    @State var matchDate2: Date?
    @State var actDate : Date?
    var body: some View {
        
        GeometryReader {geo in
            
            ZStack{
            VStack{
                ScrollView{
            ZStack{
            VStack(alignment: .leading){
                Text("Your upcoming")
                    .font(.title.bold())
                HStack{
                    Text("Match in ")
                
//                   timer
                if actDate != nil {
                    if Date() !=  actDate!{
                        Text("\(hours ?? 0):\(minutes ?? 0):\(seconds ?? 0)")
                        .foregroundColor(.red)
                    } else {
                        Text("Now")
                            .foregroundColor(.red)
                    }
                }
                }
                
                    

            }
            .padding(.leading)
            .frame(width: geo.size.width, alignment: .leading)
                ZStack{
                    RemoteImage(url: match.owner.user_picture!)

                        .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .cornerRadius(20)
            }
                .padding(.trailing)
                .frame(width: geo.size.width, alignment: .trailing)
            }
            .padding(.top, geo.size.height * 0.08)
            .padding(.bottom, geo.size.height * 0.05)
            .font(.title2.bold())

            
            
            
                HStack{
                    RemoteImage(url: match.match_location.location_image_url)
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geo.size.width * 0.45, height: geo.size.width * 0.5)
                        .clipped()
                        .cornerRadius(30)
                        .padding(.trailing, 5)
                    ZStack{
                        RoundedRectangle(cornerRadius: 30)
                            .fill(
                                    LinearGradient(gradient: Gradient(colors: [.orange, .red]), startPoint: .top, endPoint: .bottom)
                                )
                            .frame(width: geo.size.width * 0.45, height: geo.size.width * 0.5)
                        Text("🏀 1v1\nBasketball")
                            .font(.system(size: 20, weight: .medium, design: .default))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.leading)
                    }
                    
                }
                .padding(.bottom, 10)
                .frame(width: geo.size.width, alignment: .center)
                
                
                ZStack{
                    VStack(alignment: .leading){
                        Text("Location:\n\(match.match_location.location_name)")
                            .frame(width: geo.size.width * 0.75, alignment: .leading)
                            .font(.system(size: 20, weight: .medium, design: .default))
                            .multilineTextAlignment(.leading)
                            .foregroundColor(.white)
                        Text(match.match_location.location_address)
                            .frame(width: geo.size.width * 0.75, alignment: .leading)
                            .foregroundColor(.white.opacity(0.6))
                            .font(.system(size: 16, weight: .medium, design: .default))
                    }
                    .frame(width: geo.size.width * 0.85)
                    .padding(.leading)
                    .padding(.trailing)
                    .padding(.top, 25)
                    .padding(.bottom, 25)
                    .background(Color(hex: 0x0099ff))
                    .cornerRadius(30)
                }
                .padding(.bottom, 10)
                
                HStack{
                    ZStack{
                        RoundedRectangle(cornerRadius: 30)
                            .frame(width: geo.size.width * 0.5, height: geo.size.width * 0.3)
                        Text("Time \n\(match.time!)")
                            .font(.system(size: 20, weight: .medium, design: .default))
                            .frame(width: 180)
                            .multilineTextAlignment(.leading)
                            .foregroundColor(.black)
                    }
                    .padding(.trailing, 5)
                    ZStack{
                        RoundedRectangle(cornerRadius: 30)
                            .fill(Color.red)
                            .frame(width: geo.size.width * 0.4, height: geo.size.width * 0.3)
                        VStack{
                        Text("\(match.challenger.count + 1)/\(match.teamSize + 1)\nPlayers")
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .medium, design: .default))
                            .multilineTextAlignment(.leading)
                        
                        }
                    }
                    .onTapGesture {
                        playerSheetShown = true
                    }
                    
                }
                .padding(.bottom, 10)

                
                HStack{
                    ZStack{
                        RoundedRectangle(cornerRadius: 30)
                            .fill(Color(hex: 0xE90303))
                            .frame(width: geo.size.width * 0.35, height: geo.size.width * 0.3)
                        Text("Withdraw")
                            .font(.system(size: 20, weight: .medium, design: .default))
                            .multilineTextAlignment(.center)
                    }
                    
                    .padding(.trailing, 5)
                    .onTapGesture {
                        showWithdrawAlert = true
                    }
                    ZStack{
                        RoundedRectangle(cornerRadius: 30)
                            .fill(Color(hex: 0x00C65B))
                            .frame(width: geo.size.width * 0.55, height: geo.size.width * 0.3)
                        Text("Invite\nFriends")
                            .font(.system(size: 20, weight: .medium, design: .default))
                            .frame(width: 140)
                            .multilineTextAlignment(.center)
                    }
                    
                }
                
                
                .padding(.bottom)
            
            }
        }
            .alert(isPresented: $showWithdrawAlert) {
                return  Alert(title: Text("Withdraw Match"), message: Text("Are you sure you want to withdraw from this match?"), primaryButton: .destructive(Text("Yes")) {
                    withdrawLoading = true
                    Api().withdrawAcceptMatch(match, withdraw: true, token: token, homeStats: homeStats)
                }, secondaryButton: .cancel())
                    
                    }
            
            
            
            .overlay(
                    RoundedRectangle(cornerRadius: 0)
                        .fill(Color.black)
                        .opacity(playerSheetShown ? 0.6: 0)
                        .onTapGesture {
                            if playerSheetShown {
                                playerSheetShown = false
                            }
                        }

            )
            
            BottomSheetView(isOpen: $playerSheetShown, maxHeight: geo.size.height * 0.7){
                let players = [match.owner] + match.challenger

                Text("Players (\(match.challenger.count + 1)/\(match.teamSize + 1))")
                    .foregroundColor(.black)
                    .font(.system(size: 20, weight: .medium, design: .default))
                    .padding(.bottom)
                ScrollView{

                    LazyVStack{
                ForEach(players, id: \.self){ player in



                    HStack{
                    RemoteImage(url: player!.user_picture!)
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 96, height:96)
                        .clipped()
                        .cornerRadius(30)

                        Text("\(player!.first_name) \(player!.last_name)- \(player!.age) yrs \n 6'1 ft - \(player!.weight) lbs")
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                            .padding(.leading, 10)
                        .frame(width: geo.size.width * 0.5, alignment: .leading)
                    }
                    .frame(width: geo.size.width, alignment: .center)


                }
                }
                }




            }

        
        }

    }
        .onAppear {
            actDate = matchDateInfo(time: match.time!)
            let diffComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: Date(), to: actDate!)
            hours = diffComponents.hour
            minutes = diffComponents.minute
            seconds = diffComponents.second
        }
        .onReceive(timer) { input in

            let diffComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: Date(), to: actDate!)
            hours = diffComponents.hour
            minutes = diffComponents.minute
            seconds = diffComponents.second
        }
        .foregroundColor(.white)
        .background(Color(hex: 0x023049))
        .edgesIgnoringSafeArea(.all)
    }
}

//struct ChallengeMatch_Previews: PreviewProvider {
//    static var previews: some View {
//        var user1 = user(id: 1, username: "nwef", first_name: "Nawaf", last_name: "Aloufi", height: "7'1", weight: 120, age: 18, user_picture: "https://nba.nbcsports.com/wp-content/uploads/sites/12/2021/06/GettyImages-1233226298-e1622733402729.jpg?w=1024")
//        var users: [user] = [user1]
//        var match = Match(id: 2, owner: user1, challenger: users, sport: "Basketball", teamSize: 1, opponentSize: 1, time: "6:30pm", taken: false, match_location: m_location(id: 2, location_name: "Twin Lakes Recreation Center", location_address: "2522 E May Bloat Rd", location_city: "San Francisco", location_state: "California", location_image_url: "https://ritchiecenter.du.edu/images/2020/9/17/stapleton_pavilion_basketball_night.jpg", matches_count: 5))
//        var token = Tokens()
//        ChallengeMatch(match: match, token: Tokens(), homeStats: homeStat())
//    }
//}
