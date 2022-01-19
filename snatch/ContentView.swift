////
////  ContentView.swift
////  snatch
////
////  Created by Nawaf on 4/20/21.
////
//
import SwiftUI


struct ContentView: View {

    @State private var loggedIn: Bool = false
    @State var usermatchesinfo: [TokensJson] = []
    @ObservedObject var token: Tokens
    @ObservedObject var homeStats: homeStat
    @StateObject var locationManager = LocationManager()
    @StateObject var location = MapViewModel()
    var userLatitude: Double? {
        return locationManager.lastLocation?.coordinate.latitude
    }
        
    var userLongitude: Double? {
        return locationManager.lastLocation?.coordinate.longitude
    }
    var long: Double? {
        return location.user_Location?.coordinate.longitude
    }
    var lat: Double? {
        return location.user_Location?.coordinate.latitude
    }
    var body: some View {
        GeometryReader {geo in
        VStack{
            if locationManager.statusString != true {
                VStack(alignment: .center){
                Group{
                Image(systemName: "location.fill")
                    .font(.system(size: 50))
                    .padding()
                Text("This app needs location services to be enabled in settings in order to show sport matches in your region.")
                    .padding()
                    Text("Go to Settings > Privacy > Location Services")
                        .font(.system(size: 13))
                
                }
                .foregroundColor(.white)
                }
               
            }else{
        if !loggedIn {
            SignUpView(loggedIn: $loggedIn, usermatchesinfo: $usermatchesinfo, token: token, locationManager: locationManager)
                .transition(.slide)
            
        }else if token.current_match == nil{
            newHomeView(homeStats: homeStats, token: token)
                .environmentObject(locationManager)
                .environmentObject(location)
                .transition(AnyTransition.slide)
                .animation(.linear(duration: 0.7))


        }else{
            ChallengeMatch(match: token.current_match!, token: token, homeStats: homeStats)
                .transition(AnyTransition.slide)
                .animation(.spring(response: 3, dampingFraction: 1, blendDuration: 2))
                .background(
                    Text("Challenge \nAccepted \n🎉🎉🎉")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .font(.system(size: 50, weight: .bold))
                        
                )
                .background(Color.red)
                .ignoresSafeArea(.all)
        }
            }
        }
        
        .frame(width: geo.size.width, height: geo.size.height)
        
        }
        .background(Color(hex: 0x023049))
        .ignoresSafeArea(.all)

        
       
    }
}
