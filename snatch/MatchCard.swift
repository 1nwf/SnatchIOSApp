//
//  Drag.swift
//  snatch
//
//  Created by Nawaf on 6/1/21.
//

import SwiftUI
import Kingfisher


struct RemoteImage: View {
    private enum LoadState {
        case loading, success, failure
    }

    private class Loader: ObservableObject {
        var data = Data()
        var state = LoadState.loading

        init(url: String) {
            guard let parsedURL = URL(string: url) else {
                fatalError("Invalid URL: \(url)")
            }

            URLSession.shared.dataTask(with: parsedURL) { data, response, error in
                if let data = data, data.count > 0 {
                    self.data = data
                    self.state = .success
                } else {
                    self.state = .failure
                }

                DispatchQueue.main.async {
                    self.objectWillChange.send()
                }
            }.resume()
        }
    }

    @StateObject private var loader: Loader
    var isloading: Image
    var failure: Image

    var body: some View {
        if selectImage() == nil{
            loading()
        }else{
        selectImage()!
            .resizable()
    }
    }

    init(url: String, isloading: Image = Image(systemName: "trash"), failure: Image = Image(systemName: "multiply.circle")) {
        _loader = StateObject(wrappedValue: Loader(url: url))
        self.isloading = isloading
        self.failure = failure
    }

    private func selectImage() -> Image? {
        switch loader.state {
        case .loading:
            return isloading
        case .failure:
            return failure
        default:
            if let image = UIImage(data: loader.data) {
                return Image(uiImage: image)
            } else {
                return nil
            }
        }
    }
}











struct SwipeButton<Content: View>: View {
    private let content: () -> Content
    @State var txt = "swipe to accept"
    @State private var offset = CGSize.zero
    @State var xoffset = CGFloat(20)
    @State var w = CGFloat(120)
    
    @State var showingModal = false
    @State var o = CGFloat(46)
    private let onAction: () -> ()
    
    init(@ViewBuilder content: @escaping () -> Content, onAction: @escaping () -> Void) {
        self.content = content
        self.onAction = onAction
    }
    
    var body: some View {
        GeometryReader { (geometry) in
            ZStack(alignment: .center){
                
                Text("\(self.txt)")
                    .frame(width: geometry.size.width * 0.9, height: self.w, alignment: .center)
                    .foregroundColor(.black)
                    .background(Color(hex: 0x33FF8B))
                    .cornerRadius(29)
                    .offset(x: xoffset)
                content()
                    .cornerRadius(20)
                    .offset(x: self.offset.width - 20)
                    .cornerRadius(30)
                    .frame(width: 329, height: 145, alignment: .center)
                    .gesture(DragGesture(minimumDistance: 30, coordinateSpace: .local)
                                .onChanged { gestrue in
                                    if gestrue.translation.width < 0  {
                                        self.w = 130
                                        self.offset.width = gestrue.translation.width
                                        
                                    }
                                    print(offset)
                                }
                                .onEnded { value in
                                    if value.translation.width < -85{
                                        txt = "Challenge Accepted"
                                        self.offset.width = -geometry.size.width
                                        self.o = .zero
                                        xoffset = 0
                                        onAction()
                                    }else{
                                        self.w = CGFloat(100)
                                        self.offset.width = .zero
                                        txt = "Swipe to Accept"
                                    }
                                }
                    )
                    .shadow(radius: 10)
            }
            
            .frame(width: geometry.size.width, alignment: .center)
        }
        .animation(.easeIn)
    }
}






struct MCard: View {
    @State var isSheetShown = false
    @ObservedObject var homeStats: homeStat
    var match: Match
    @ObservedObject var token: Tokens
    var body: some View {
        GeometryReader{ geo in
        ZStack{
     
        SwipeButton {
            HStack{
                let font_size = geo.size.width * 0.035
                VStack(alignment: .leading, spacing: 11){
                    let height = String(match.owner.height)
                    let ind = height.index(height.startIndex, offsetBy: 3)
                    Group{
                        Text("\(match.owner.first_name) - \(match.owner.age) yrs - \(match.owner.weight) lbs - \(match.owner.height)")
                        Text("\(match.match_location.location_name)")
                    }
                
                    .font(.system(size: font_size))
                    HStack{
                        Text("\(match.sport) \(match.teamSize)v\(match.opponentSize)")
                            .font(.system(size: font_size))
                        Text("\(match.challenger.count)/\(match.teamSize)")
                            .font(.system(size: font_size - 2))
                        Text("- \(match.time ?? "2:30pm")")
                            .font(.system(size: font_size))
                    }
                    HStack{
                        RemoteImage(url: match.owner.user_picture!)
                        .aspectRatio(contentMode: .fill)
                        .frame(width:geo.size.width * 0.06, height: 25)
                        .clipped()
                        .cornerRadius(6)
                        if match.challenger.count > 0 {
                        ForEach(match.challenger, id: \.self){user in
                            RemoteImage(url: user!.user_picture!)
                            .aspectRatio(contentMode: .fill)
                            .frame(width:geo.size.width * 0.06, height:25)
                            .clipped()
                            .cornerRadius(6)
                        }
                        }
                        

                    
                    }
                }
                .frame(width: geo.size.width * 0.55)
                .padding(.leading, geo.size.width * 0.05)
                RemoteImage(url: match.owner.user_picture!)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 65, height: 117)
                    .clipped()
                    .cornerRadius(20)
               
                }
            .padding()
            .background(Color.white).foregroundColor(Color.black)
            
           
                } onAction: {
                    Api().withdrawAcceptMatch(match, withdraw: false, token: token, homeStats: homeStats)
                }
        .frame(width: geo.size.width * 0.88, height: geo.size.height * 0.9, alignment: .center)
        }
        .frame(width: geo.size.width)
        }
        .frame(height: 135)
    }
    
}

//struct Drag_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//            var user1 = user(id: 1, username: "nwef", first_name: "Nawaf", last_name: "Aloufi", height:"6'1", weight: 120, age: 18, user_picture: "https://nba.nbcsports.com/wp-content/uploads/sites/12/2021/06/GettyImages-1233226298-e1622733402729.jpg?w=1024")
//            var users: [user] = [user1]
//            var match = Match(id: 2, owner: user1, challenger: users, sport: "Basketball", teamSize: 1, opponentSize: 1, time: "6:30pm", taken: false, match_location: m_location(id: 1, location_name: "Twin Lakes Recreation Center", location_address: "2522 E May Bloat Rd", location_city: "San Francisco", location_state: "California", location_image_url: "https://ritchiecenter.du.edu/images/2020/9/17/stapleton_pavilion_basketball_night.jpg", matches_count: 5))
//            MCard(homeStats: homeStat(), match: match, token: Tokens())
//        }
//    }
//}
//


