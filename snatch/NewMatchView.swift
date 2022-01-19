//
//  NewMatchView.swift
//  snatch
//
//  Created by Nawaf on 7/8/21.
//

import SwiftUI
import Kingfisher
struct NewMatchView: View {
    @State var title = "Browse \nMatches"
    @State var browseSports = ["🏀 Basketball", "⚽️ Soccer", "🏈 Football", "🏐 Volleyball", "🏓 Tennis"]
    
    @State var selectedSport: String
    @State var selectedTeam: String 
    @State var selectedLocation: m_location?
    let matchSizes = ["1v1", "2v2", "3v3", "4v4", "5v5", "6v6", "7v7", "8v8", "9v9", "10v10", "11v11", "12v12", "13v13"]
    
    @State var isSheetShown: Bool = false
    @ObservedObject var homeStats : homeStat
    @State var pop_locs : [m_location]?
    let columns = [
            GridItem(.adaptive(minimum: 130))
        ]
    @State var showLocFilterModal = false
    @State var matches: [Match] = []
    @State var filteredMatches : [Match] = []
    @State var isLoading = true
    @State var numOfMatches: Int = 0
    @State var tappedMatch: Match?
    @State var filter_loc_image: KFImage?
    func loadMatchData(sport: String, teamSize: String, location: m_location? = nil) {
        var match_location: String = ""
        if location != nil {
            match_location = String(location!.id)
            
        }
        print("MATCH - LOCATION :\(match_location)")
        isLoading = true
        var teamFilter: String = ""
        var sportFilter: String = ""
        if sport != "All"{
            let space_ind = sport.firstIndex(of: " ")!
            let name2 = sport.index(after: space_ind)
            let sport_name = sport[name2...]
            sportFilter = sport_name.lowercased()
        }
        if teamSize != "All"{
            teamFilter = String(teamSize[teamSize.startIndex])
        }
        Api().loadData( completion: { (Matches) in
            matches = Matches
            filteredMatches = matches
            isLoading = false
        }, url: URL(string: "https://opm-backend.herokuapp.com/api/matches/?sport=\(sportFilter)&teamSize=\(teamFilter)&match_location=\(match_location)match_location__location_city=\(city)&match_location__location_state=\(state)")!)
    }
    
    
    func loadPopLocs(){
        Api().loadHomeData(completion: {hd in
            pop_locs = hd.popular_locations
        })
    }
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var token: Tokens
    @EnvironmentObject var location: LocationManager
    @Binding var city: String
    @Binding var state: String
    var body: some View {
        GeometryReader {geo in
            ZStack{
            
            VStack(){
            
            ScrollView{
                HStack{
                    Image(systemName: "arrow.backward").foregroundColor(.white)
                        .frame(height: geo.size.height * 0.06)
                        Text("back")
                                .foregroundColor(.white)
                        }
                .offset(x: -geo.size.width * 0.36, y: geo.size.height * 0.05)
                .onTapGesture{
                    self.presentationMode.wrappedValue.dismiss()
                }
                ZStack{
                    VStack(alignment: .leading){
                        Text(selectedLocation != nil ? selectedLocation!.location_name : title)
                    .frame(width: 200, alignment: .leading)
                    .font(.system(size: 23, weight: .bold, design: .default))
                    .foregroundColor(.white)
                        Text("\(selectedLocation != nil ? selectedLocation!.matches_count :numOfMatches) Matches Today")
                    .font(.system(size: 23, weight: .bold, design: .default))
                    .foregroundColor(.red)
                            
                    }
                    .frame(width: geo.size.width, alignment: .leading)
                    .padding(.bottom)
                    .padding(.top, 32)
                    .offset(x: geo.size.width * 0.05)
                    
                    ZStack{
                        
                        Text("Filter \nLocation")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                            .font(.system(size: 13))
                            .padding()
                            .opacity(selectedLocation != nil ? 0: 1)
                            .background(Color.red.opacity(selectedLocation != nil ? 0: 1))
                            .background(selectedLocation != nil ? KFImage(URL(string: selectedLocation!.location_image_url)).resizable().aspectRatio(contentMode: .fill): nil)
                            .cornerRadius(23)
                    }
                    .frame(width: geo.size.width, alignment: .trailing)
                    .offset(x: -geo.size.width * 0.05)
                    .onTapGesture {
                        showLocFilterModal = true
                    }
                    .padding(.top, 10)
                }
                ScrollView(.horizontal, showsIndicators: false){
                    let cw = geo.size.width * 0.33
                    let ch = geo.size.height * 0.2

                    HStack{
                        
                        
                        ForEach(browseSports, id: \.self) { sport in
                                HStack{
                                    
                                    let space_ind = sport.firstIndex(of: " ")!
                                    let name2 = sport.index(after: space_ind)
                                    let sport_name = sport[name2...]
                                    let icon = sport[..<name2]
                                    Text(sport == selectedSport ? "\(sport)": "\(String(icon))")
                                        .foregroundColor(.white)
                                        .padding(.leading)
                                        .padding(.trailing)
                                        .font(.system(size: 15))
                                }
                                .onTapGesture {
                                    if sport != selectedSport{
                                        selectedSport = sport
                                        loadMatchData(sport: selectedSport, teamSize: selectedTeam, location: selectedLocation)
                                    }else{
                                        selectedSport = "All"
                                        loadMatchData(sport: selectedSport, teamSize: selectedTeam, location: selectedLocation)
                                        title = "Browse \nMatches"
                                    }
                                }
                                .frame(height: 44, alignment: .leading)
                                .background(sport == selectedSport ? Color(hex: 0xFF6B00): Color.white)
                                .cornerRadius(17)
                        }
                        
                    }
                    .offset(x: 20)
                    .frame(width: geo.size.width, alignment: .leading)
        }
                
                
                ScrollView(.horizontal, showsIndicators: false){
                    let card_color = Color.blue
                    HStack{
                        ForEach(matchSizes, id: \.self) {size in
                        
                        let c = matchSizes.firstIndex{$0 == size}
 
                    HStack{
                        Text("\(size)")
                         .font(.system(size: 15, weight: .regular, design: .default))
                        .foregroundColor(size == selectedTeam ? Color.white : Color.black)
                            .padding(.leading)
                            .padding(.trailing)
                    }
                    .frame(width: selectedTeam == size ? geo.size.width * 0.23 : nil, height: 44, alignment: .center)
                    .background(size == selectedTeam ? Color(hex: 0xFF6B00):Color.white)
                    .cornerRadius(17)
                            
                .onTapGesture{
                    if size != selectedTeam{
                        selectedTeam = size
                        loadMatchData(sport: selectedSport, teamSize: selectedTeam, location: selectedLocation)
                    }else{
                        selectedTeam = "All"
                        loadMatchData(sport: selectedSport, teamSize: selectedTeam, location: selectedLocation)
                        title = "Browse \nMatches"

                    }
                }
                    }
                    }
                    
                   
                }
                .offset(x: 20)
                .frame(width: geo.size.width, alignment: .leading)
                LazyVStack{
                if !isLoading && filteredMatches.count != 0{
                    ForEach(filteredMatches) { match in
                        MCard(homeStats: homeStats, match: match, token: token)
                            .frame(width: geo.size.width)
                            .onTapGesture {
                                self.isSheetShown = true
                                self.tappedMatch = match
                            }
                            .padding(.top)
                            .padding(.bottom)
                            .frame(width: geo.size.width)
                           
                    }
                    .frame(width: geo.size.width, alignment: .center)
                }else if isLoading{
                    loading()
                        .offset(y: -geo.size.height * 0.25)
                        .frame(width: geo.size.width, height: geo.size.height)
                }else{
                    Text("No Available\n Matches :(")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .font(.system(size: 25))
                        .frame(height: geo.size.height * 0.4)
                }
                
                }
                }
                
            }
            .overlay(
                    RoundedRectangle(cornerRadius: 0)
                        .opacity(isSheetShown || showLocFilterModal ? 0.6: 0)
                        .onTapGesture {
                            if isSheetShown {
                                isSheetShown = false
                            }else if showLocFilterModal {
                                showLocFilterModal = false
                            }
                        }

            )
            
                BottomSheetView(isOpen: $isSheetShown, maxHeight: geo.size.height * 0.8) {
                    if tappedMatch != nil{
                    ZStack{
                        Text("\(tappedMatch!.sport.capitalized) \(tappedMatch!.teamSize)v\(tappedMatch!.opponentSize)")
                            .font(.headline)
                            .padding(.leading)
                            .frame(width:geo.size.width, alignment: .leading)
                    
                        Text("Join Match")
                            .foregroundColor(.green)
                            .font(.headline)
                            .padding(.trailing)
                            .onTapGesture{
                                Api().withdrawAcceptMatch(tappedMatch!, withdraw: false, token: token, homeStats: homeStats)
                            }
                            .frame(width:geo.size.width, alignment: .trailing)
                    }
                    .padding(.bottom)
                        
                    ScrollView{
                        
                        Text("Location")
                            .frame(width: geo.size.width, alignment: .leading)
                        
                        HStack{
                        KFImage(URL(string: tappedMatch!.match_location.location_image_url))
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 130, height: 149)
                            .clipped()
                            .cornerRadius(30)
                            
                            
                            VStack{
                                Text("\(tappedMatch!.match_location.location_name)")
                                Text(tappedMatch!.match_location.location_address)
                                    .foregroundColor(Color.gray)
                            }
                            .padding(.leading, 5)
                            .frame(width: 150)
                        }
                        .frame(width: geo.size.width, alignment: .topLeading)
                        .padding(.leading, 23)
                        .padding(.bottom)
                        
                        Text("Players: \(tappedMatch!.challenger.count + 1)/\(tappedMatch!.teamSize)")
                            .frame(width: geo.size.width, alignment: .leading)
                        HStack{
                        KFImage(URL(string: tappedMatch!.owner.user_picture!))
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 86, height:89)
                            .clipped()
                            .cornerRadius(30)
                        
                            Text("\(tappedMatch!.owner.first_name)  - \(tappedMatch!.owner.age) yrs \n 6'1 ft - \(tappedMatch!.owner.weight) lbs")
                            .padding(.leading, 5)
                            .frame(width: geo.size.width * 0.5, alignment: .leading)
                        }
                        .padding(.leading, 30)
                        .frame(width: geo.size.width, alignment: .leading)
                            ForEach(tappedMatch!.challenger, id: \.self){ user in
                                HStack{
                                KFImage(URL(string: user!.user_picture!))
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 86, height:89)
                                    .clipped()
                                    .cornerRadius(30)
                                
                                Text("\(user!.first_name) - \(user!.age) yrs \n 6'1 ft - \(user!.weight) lbs")
                                    .padding(.leading, 5)
                                    .frame(width: geo.size.width * 0.5, alignment: .leading)
                           
                            
                        }
                        
                        
                    }
                            .padding(.leading, 30)
                            .frame(width: geo.size.width, alignment: .leading)
                    }
                    .frame(width: geo.size.width, alignment: .leading)
                    }
                    
                }
                
                BottomSheetView(isOpen: $showLocFilterModal, maxHeight: geo.size.height * 0.8) {
                    Text("Locations: \(homeStats.popular_locations?.count ?? 0)")
                        .font(.headline)
                    ScrollView{
                        LazyVGrid(columns: columns, spacing: 30){
                            if homeStats.popular_locations != nil{
                            ForEach(homeStats.popular_locations!, id: \.self){location in
                                VStack{
                                ZStack{
                                    RemoteImage(url: location.location_image_url)
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 133, height: 164)
                                        .clipped()
                                        .cornerRadius(30)
                                    Group{
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .fill(Color.red)
                                        .frame(width: 30, height: 30)
                                        Text("\(location.matches_count)")
                                        .foregroundColor(.white)
                                        .font(.system(size: 13))
                                    }
                                    .offset(x: -geo.size.width * 0.1 ,y: -geo.size.height * 0.07)
                                    }
                                
                                    Text(location.location_name)
                                        .multilineTextAlignment(.leading)
                                        .font(.system(size: 13))
                                        .frame(width: geo.size.width * 0.3)
                                    
                            }
                            .onTapGesture {
                                filter_loc_image = KFImage(URL(string: location.location_image_url))
                                    filteredMatches = matches.filter {$0.match_location.location_name == location.location_name}
                                    showLocFilterModal = false
                                    title = location.location_name
                                    numOfMatches = filteredMatches.count
                                    selectedLocation = location
                                }
                            }
                            }else{
                                Text("No popular locations for this region")
                            }
                        }
                    }
                    
                    .padding(.top)
                }
                .onAppear{
                    print("hi")
                }

        }
            
            .onAppear {
                loadMatchData(sport: selectedSport, teamSize: selectedTeam, location: selectedLocation)
                location.getCityState() { place in
                    if place != nil {
                        Api().LHD( completion: { (stats) in
                            
                            numOfMatches = stats.counts["All"]!
                            homeStats.counts = stats.counts
                            homeStats.team_match_count = stats.team_match_count
                            homeStats.popular_locations = stats.popular_locations
                        }, url: URL(string: "https://opm-backend.herokuapp.com/api/home/?city=\(place!.locality!)=&state=\(place!.administrativeArea!)")!)
                    } else {
                        print("No Place Found")
                    }
                }
                
            }
            .navigationBarBackButtonHidden(true)
            .background(Color(hex: 0x023049))
            .ignoresSafeArea(.all)
        }
        
    }
}

struct NewMatchView_Previews: PreviewProvider {
    static var previews: some View {
        NewMatchView(selectedSport: "All", selectedTeam: "All", selectedLocation: m_location(id: 2, location_name: "Twin Lakes Recreation Center", location_address: "2522 E May Bloat Rd", location_city: "San Francisco", location_state: "California", location_image_url: "https://ritchiecenter.du.edu/images/2020/9/17/stapleton_pavilion_basketball_night.jpg", matches_count: 5), homeStats: homeStat(), token: Tokens(), city: .constant("Bloomington"), state: .constant("IN"))
    }
}
