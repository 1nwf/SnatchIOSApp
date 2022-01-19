//
//  location2.swift
//  snatch
//
//  Created by Nawaf on 5/21/21.
//

import SwiftUI
import CoreLocation
import MapKit
struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}
struct location2: View {
    @EnvironmentObject var location : MapViewModel
    @State var locationManager = CLLocationManager()
    @Binding var placemarkobject: Place?
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        ZStack{
            MapView()
                .ignoresSafeArea(.all, edges: .all)
            
            VStack{
                
                VStack(spacing: 0) {
                    HStack{
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search", text: $location.searchTxt)
                            .colorScheme(.light)
                    }
                    
                    .padding(.vertical, 10)
                    .padding(.horizontal)
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.bottom, 5)
                    if !location.places.isEmpty && location.searchTxt != "" {
                        ScrollView{
                            VStack(spacing: 15){
                                ForEach(location.places){ place in
                                    
                                    ZStack{
                                        VStack{
                                    Text(place.place.name ?? "")
                                        .foregroundColor(.black)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.leading)
                                            Text("\(place.place.thoroughfare ?? "") - \(place.place.locality ?? ""), \(place.place.administrativeArea ?? "")")
                                        .foregroundColor(.black)
                                        .font(.caption)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.leading)
                                        
                                }
                                }
                                    .onTapGesture {
                                       location.selectPlace(place: place)
                                    }
                                    Divider()
                                }
                            }
                        }
                       
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        
                    }
                    if location.currentPlace != nil{
                        let place = location.currentPlace!
                        
                        Text("Use Location: \(place.place.name ?? "")")
                            .foregroundColor(.white)
                            .font(.caption)
                            .padding()
                            .background(Color.green.opacity(1))
                            .cornerRadius(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .onTapGesture {
                                placemarkobject = place
                                self.presentationMode.wrappedValue.dismiss()

                            }
                    }
                }
                
                .padding()
                .offset(y: -40)
                
                
                Spacer()
                VStack{
                    Button(action: {location.focusLocation()}, label: {
                        Image(systemName: "location.fill")
                            .font(.title2)
                            .padding(10)
                            .background(Color.primary)
                            .clipShape(Circle())
                    })
                    Button(action: {location.updateMapType()}, label: {
                        Image(systemName: location.mapType == .standard ? "network" : "map")
                            .font(.title2)
                            .padding(10)
                            .background(Color.primary)
                            .clipShape(Circle())
                    })
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding()
            }
            
            
        }
        .ignoresSafeArea(.keyboard)
        .onAppear(perform: {
            locationManager.delegate = location
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestLocation()
            location.focusLocation()
        })
        .alert(isPresented: $location.permissionDenied, content: {
            Alert(title: Text("Permission Denied"), message: Text("Please Enable Permission in App Settings"), dismissButton: .default(Text("GoTo Settings"), action: {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }))
        })
        .onChange(of: location.searchTxt, perform: { value in
            let delay = 0.3
            DispatchQueue.main.asyncAfter(deadline: .now() + delay){
                if value == location.searchTxt{
                    self.location.searchQuery()
                }
            }
        })
    }
}
