//
//  SignUpView.swift
//  snatch
//
//  Created by Nawaf on 4/22/21.
//

import SwiftUI
let lightGreyColor = Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0)

class Tokens: ObservableObject{
    @Published var accessToken: String = ""
    @Published var refreshToken: String = ""
    @Published var user_id: Int = 0
    @Published var username: String = ""
    @Published var first_name: String = ""
    @Published var last_name: String = ""
    @Published var age: Int = 0
    @Published var weight: Int = 0
    @Published var height: String = ""
    @Published var user_picture: String = ""
    @Published var current_match: Match?
    @Published var matchData: [Match] = []
    @Published var buttontxt = "Sign In"
    @Published var loading = false
}

struct SignUpView: View {
    @Binding var loggedIn: Bool
    @State private var showingAlert = false
    @State var password: String = ""
    @Binding var usermatchesinfo: [TokensJson]
    @State private var showFalseCredAlert = false
    @State private var onSignUp = false
    @State var userInfo: [TokensJson] = []
    @State var showLoading = false
    @ObservedObject var token: Tokens
    @State var apires: Int = 0
    @ObservedObject var locationManager : LocationManager
    var body: some View {
        NavigationView{
        ZStack{
        VStack {
            WelcomeText()
            TextField("Username", text: $token.username)
                .padding()
                .background(lightGreyColor)
                .cornerRadius(15.0)
                .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 20))
            SecureField("Password", text: $password)
                .padding()
                .background(lightGreyColor)
                .cornerRadius(15.0)
                .padding(EdgeInsets(top: 0, leading: 10, bottom: 20, trailing: 20))


            Button {
                if password == "" || token.username == ""{
                    showingAlert = true
                }else{
                token.buttontxt = "loading..."
                self.showLoading.toggle()
                                let url = URL(string: "https://opm-backend.herokuapp.com/api/token/")!
                                let success = 200...299
                                let data = ["username": token.username, "password": password]
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
                                        token.buttontxt = "Sign Up"
                                        showingAlert.toggle()
                                        showLoading = false
                                    } else {
                                        let jsonRes = try? JSONSerialization.jsonObject(with: data!, options: [])
                                        let httpResponse = response as? HTTPURLResponse
                                        let access = jsonRes as? [String: Any]
                                        let matchesPost = try! JSONDecoder().decode([TokensJson].self, from: data!)
                                        token.accessToken = matchesPost[0].access
                                        token.refreshToken = matchesPost[0].refresh
                                        token.user_id = matchesPost[0].user_id
                                        token.username = matchesPost[0].username
                                        token.first_name = matchesPost[0].first_name
                                        token.last_name = matchesPost[0].last_name
                                        token.age = matchesPost[0].age
                                        token.weight = matchesPost[0].weight
                                        token.height = matchesPost[0].height
                                        token.user_picture = matchesPost[0].user_picture
                                        token.current_match = matchesPost[0].current_match
                                        usermatchesinfo = matchesPost

                                        print("NWF DDM")
                                        self.onSignUp.toggle()
                                        loggedIn.toggle()
                                        
                                    }

                                }.resume()
                }
                                


            } label: {
                Text("Sign In")
                    .fontWeight(.semibold)
                    .padding(EdgeInsets(top: 10, leading: 24, bottom: 10, trailing: 24))
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(30)
//
            }
            .alert(isPresented: $showingAlert) {
                       return  Alert(title: Text("Incorrect Credentials"), message: Text("Try Again"), dismissButton: .default(Text("Ok")))
                    }
    
            .padding()
            NavigationLink(
                destination: CreateAccount(token: token, loggedIn: $loggedIn, locationManager: locationManager)){
            Text("Sign up")
                .foregroundColor(.blue)
                .font(.system(size: 14))
                .offset(y: -15)
            }
            


    }
            if showLoading {
                GeometryReader {geo in
                    loading()
                        .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
                }.background(Color.black.opacity(0.6).edgesIgnoringSafeArea(.all))
                
            }
        }
        }
    }}

struct WelcomeText: View {
    var body: some View {
        Text("Welcome!")
            .font(.largeTitle)
            .fontWeight(.semibold)
            .padding(.bottom, 10)
    }
}
