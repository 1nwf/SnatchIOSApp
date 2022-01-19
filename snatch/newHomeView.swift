//
//  newHomeView.swift
//  snatch
//
//  Created by Nawaf on 6/26/21.
//

import SwiftUI
import Kingfisher
import MapKit
import CoreLocation
struct matchLocation: Encodable, Decodable{
    var location_name: String
    var location_address: String
    var location_city: String
    var location_state: String
}

struct newHomeView: View {
    @ObservedObject var homeStats : homeStat
    @ObservedObject var token: Tokens
    @State var browseSports = ["🏀 Basketball": 0, "⚽️ Soccer": 0, "🏈 Football": 0, "🏐 Volleyball": 0, "🏓 Tennis": 0]
    let locations = (0..<10).map({ _ in "Twin Lakes Recreation Center"})
    let teams = (1...13).map({ "\($0)v\($0)" })
    @State var filter_color = Color(hex: 0xEDEDED)
    @State private var selectedItem: String?
    @State var showingSheet = false
    
    @State var sport_filtered: String = "All"
    @State var team_filtered: String = "All"
    @State var location_filtered: m_location?
    
    @State var popular_locs: [m_location]?
    @Environment(\.presentationMode) var presentationMode
    
    var sportOptions = ["basketball", "football", "volleyball", "tennis", "frisbee"]
    @State private var selectedSportIndex = 0
    @State var sportName: String = ""
    @State var teamSizeNumber: Int = 1
    @State var place: Place?

    
    @State var time = Date()
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    
    let formatter = DateFormatter()
    
    var timeFormat: DateFormatter {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("EEEE, MMM d")
        return formatter
    }
    
    func timeString(date: Date) -> String {
         let time = timeFormat.string(from: date)
         return time
    }
        
    let filterColor = Color.green.opacity(0.8)
    
    @State var showModal = false
    
    @State var currentLocation: String = "....."
    @State var city: String = ""
    @State var state : String = ""
    
    @EnvironmentObject var location: LocationManager
    
    var body: some View {
        NavigationView {
        GeometryReader {geo in
            ZStack{
            ScrollView{
            VStack{
                VStack{
                HStack{
                Image(systemName: "location")
                    .frame(width: 9, height: 9)
                    .foregroundColor(Color.white)
                Text("\(city), \(state)")
                    .font(.system(size: 13))
                    .foregroundColor(.white)
                }
                
                HStack{
                    VStack(alignment: .leading){
                        Group{
                            Text("Today's")
                            Text("Matches")
                        }
                        .font(Font.title2.bold())
                        .foregroundColor(.white)
                    }
                    .padding(.leading)
                        Spacer()
                    
                    RemoteImage(url: token.user_picture)
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .cornerRadius(12)
                        .offset(x: -geo.size.width * 0.03)
                }
                .frame(width: geo.size.width)
                }
                .padding(.bottom)
                
                Text("Popular Locations")
                    .foregroundColor(.white)
                    .frame(width: geo.size.width * 0.9, alignment: .leading)

                if popular_locs != nil{
                    
                    
                    ScrollView(.horizontal, showsIndicators: false){
                        HStack{
                            if popular_locs != nil{
                            ForEach(popular_locs!.indices, id: \.self) { index in
                                
                                let location = popular_locs![index]
                                NavigationLink(destination: NewMatchView(selectedSport: sport_filtered, selectedTeam: team_filtered, selectedLocation: location, homeStats: homeStats, token: token, city: $city, state: $state) ){
                                VStack{
                                    ZStack{
                                        RemoteImage(url: location.location_image_url)
                                            .cornerRadius(25)
                                            .frame(width: 133, height: 164)
                                        Group{
                                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                                            .fill(Color.red)
                                            .frame(width: 30, height: 30)
                                            Text("\(location.matches_count)")
                                            .foregroundColor(.white)
                                            .font(.system(size: 13))
                                        }
                                        .offset(x: -40, y: -50)
                                    }.frame(width:133, height: 164)
                                    
                                    Text(location.location_name)
                                        .frame(width: 120, height: 30, alignment: .topLeading)
                                        .foregroundColor(.white)
                                        .font(.system(size: 12))
                                }
                                .frame(height: 200)
                                .padding(.trailing, 9)
                            }
                            }
                        }
                        
                        }
                    }
                    .padding(.leading, geo.size.width * 0.06)
                } else {
                   
                    Text("No Locations Available")
                                  .foregroundColor(.white)
                                  .frame(width : geo.size.width * 0.9, height: geo.size.width * 0.25)
                                  .background(Color.red)
                                  .cornerRadius(23)
                                  .padding(.top)
      
                    
                }
                    
                Text("Sports")
                    .foregroundColor(.white)
                    .frame(width: geo.size.width * 0.9, alignment: .leading)
                    ScrollView(.horizontal, showsIndicators: false){
                        HStack{

                            ForEach(browseSports.sorted(by: >), id: \.key) { key, value in
                                
                                NavigationLink(destination: NewMatchView(selectedSport: key, selectedTeam: team_filtered, selectedLocation: location_filtered, homeStats: homeStats, token: token, city: $city, state: $state) ){
                                    
                                let space_ind = key.firstIndex(of: " ")!
                                let name2 = key.index(after: space_ind)
                                let sport_name = key[name2...]
                                let icon_ind = key.index(before: space_ind)
                                let icon = key[...icon_ind]
                                
                                    VStack{
                                        VStack{
                                            Text(icon)
                                                .font(.system(size: 30))

                                            Text(sport_name)
                                                .foregroundColor(.black)
                                                .font(.system(size: 13))
                                        }
                                        .frame(width: 99, height: 105, alignment: .center)
                                        .background(Color.white)
                                        .cornerRadius(30)
                                       
                                        Text("\(value) matches")
                                            .font(.system(size: geo.size.width * 0.03))
                                            .offset(y: 3)
                                            .foregroundColor(.white)
                                    }
                                
                            }
                                .onTapGesture{
                                    sport_filtered = key
                                }
                            }
                            .padding(.trailing, 9)
                        }
                        .padding(.leading, geo.size.width * 0.06)
            }
                    .padding(.bottom)
                
                Text("Teams")
                    .foregroundColor(.white)
                    .frame(width: geo.size.width * 0.9, alignment: .leading)
                    ScrollView(.horizontal, showsIndicators: false){
                        HStack{

                            ForEach(teams, id: \.self) { team in
                                NavigationLink(destination: NewMatchView(selectedSport: sport_filtered, selectedTeam: team, selectedLocation: nil, homeStats: homeStats, token: token, city: $city, state: $state) ){
                                
                                let c = teams.firstIndex{$0 == team}
                                VStack{
                                    VStack{
                                        Text(team)
                                            .foregroundColor(.black)
                                            .font(.system(size: 25))
                                    }
                                    .frame(width: 99, height: 105, alignment: .center)
                                    .background(Color.white)
                                    .cornerRadius(30)
                                    
                                    Text("\(homeStats.team_match_count[c!]) matches")
                                        .font(.system(size: geo.size.width * 0.03))
                                        .offset(y: 3)
                                        .foregroundColor(.white)
                                }
                                
                            }
                                
                            .padding(.trailing, 9)
                        }
                        }
                        .padding(.leading, geo.size.width * 0.06)
            }

                    .padding(.bottom, 80)
                
            }
            .padding(.top, geo.size.height * 0.05)
            }
            .onAppear {
                location.getCityState() { place in
                    if place != nil{
                        city = place!.locality ?? ""
                        state = place!.administrativeArea ?? ""
                        Api().LHD( completion: { (stats) in
                            homeStats.counts = stats.counts
                            homeStats.team_match_count = stats.team_match_count
                            for sport in browseSports.keys {
                                let space_ind = sport.firstIndex(of: " ")!
                                let name2 = sport.index(after: space_ind)
                                let sport_name = sport[name2...]
                                print("sport NAME: \(sport_name)")
                                browseSports[sport] = homeStats.counts[String(sport_name)]
                                popular_locs = stats.popular_locations
                            }
                        
                            }, url: URL(string: "https://opm-backend.herokuapp.com/api/home/?state=\(place!.locality ?? "IN")&city=\(place!.administrativeArea ?? "Bloomington")")!)

                    }else{
                        
                        currentLocation = "No Location Found"
                        
                    }
                }
                    Api().LHD( completion: { (stats) in
                        homeStats.counts = stats.counts
                        homeStats.team_match_count = stats.team_match_count
                        for sport in browseSports.keys {
                            let space_ind = sport.firstIndex(of: " ")!
                            let name2 = sport.index(after: space_ind)
                            let sport_name = sport[name2...]
                            print("sport NAME: \(sport_name)")
                            browseSports[sport] = homeStats.counts[String(sport_name)]
                            popular_locs = stats.popular_locations
                        }
                    
                    }, url: URL(string: "https://opm-backend.herokuapp.com/api/home/?state=\(state)&city=\(city)")!)
                }
            
                Button{
                    showingSheet.toggle()
                } label: {
                    ZStack{
                        RoundedRectangle(cornerRadius: 25, style: .continuous)
                            .fill(Color.red)
                            .frame(width: 55, height: 55)
                        Text("+")
                            .foregroundColor(.white)
                            .font(.system(size: 35))
                                    
                    }
                }
                .offset(y: geo.size.height * 0.43)
                .shadow(radius: 10, x: 0, y: 0)
                .sheet(isPresented: $showingSheet) {
                    NavigationView {
                               Form {
                                            Section {
                                                Picker(
                                                    "Sport: \(sportOptions[selectedSportIndex])"
                                                    , selection: $selectedSportIndex) {
                                                    ForEach(0 ..< sportOptions.count) {
                                                        Text(self.sportOptions[$0])
                                                  }
                                                }.pickerStyle(MenuPickerStyle())
                                            }
                                Section{
                                    Picker(
                                        "Teams Size: \(teamSizeNumber) vs \(teamSizeNumber)"
                                        , selection: $teamSizeNumber) {
                                        ForEach(1..<12) {
                                            Text("\($0) vs \($0)")
                                      }

                                    }.pickerStyle(MenuPickerStyle())
                                }
                                Section {
                                    DatePicker(
                                         "Match Date",
                                         selection: $time,
                                        displayedComponents: [.hourAndMinute]
                                     )

                                }
                                
                                Section(header: Text("Location")){
                                    NavigationLink(destination: location2(placemarkobject: $place)) {
                                        Text("\(place?.place.name ?? "Choose Location")")
                                        }
                                }
                                
                                Button(action: {
                                    
                                    let location_info = createMatchLocation(location_name: "\(place!.place.name!)", location_address: "\(place!.place.subThoroughfare!) \(place!.place.thoroughfare!)", location_city: "\(place!.place.locality!)", location_state: "\(place!.place.administrativeArea!)", timezone: TimeZone.current.abbreviation() ?? "s")
                                    
                                    let match_info = CreateMatch(owner: token.username, challenger: [], sport: sportOptions[selectedSportIndex], teamSize: teamSizeNumber, opponentSize: teamSizeNumber, time: dateFormatter.string(from: time), taken: false, match_location: location_info)
                                    Api().createMatch(match_info: match_info, auth_token: token.accessToken) {match in
                                        print("MATCH: \(match)")
                                        if match != nil{
                                            showingSheet = false
                                            token.current_match = match
                                        }
                                    }
                                }, label: {
                                    Text("Create Match")
                                        .foregroundColor(.green)
                                        .font(.system(size: 16, weight: .bold))
                                        
                                })
                               }
                               .navigationBarTitle("Create A Match")
                               
                           }
                }
            
            }
            
        }
        .background(Color(hex: 0x023049))
        .ignoresSafeArea(.all)
        .navigationTitle("")
        .navigationBarHidden(true)
        
        }
        
    }
}

struct newHomeView_Previews: PreviewProvider {
    static var previews: some View {
        newHomeView(homeStats: homeStat(), token: Tokens(), sport_filtered: "All", team_filtered: "All")
    }
}
