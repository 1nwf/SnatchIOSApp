//
//  CreateAccount.swift
//  snatch
//
//  Created by Nawaf on 7/30/21.
//

import SwiftUI
import UIKit


struct ImagePicker: UIViewControllerRepresentable {
    
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) private var presentationMode

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator
        
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
        var parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage? {
                parent.selectedImage = image!
            }
            
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}





struct CreateAccount: View {
    @State var first_name: String = ""
    @State var last_name: String = ""
    @State var username: String = ""
    @State  var password: String = ""
    @State var age: String = ""
    @State var weight: String = ""
    @State var height_feet: String = ""
    @State var height_inch: String = ""
    @State var isShowPhotoLibrary: Bool = false
    @State var image : UIImage?
    @State var errorMessage: String?
    @State var successMessage: String?
    @State var requestErrorResponse: CreateUserErrorResponse?
    @State var resError: Bool = false
    @State var messageForError = ""
    @ObservedObject var token: Tokens
    @Binding var loggedIn: Bool
    @State var user_city: String = ""
    @State var user_state: String = ""
    @ObservedObject var locationManager : LocationManager
    let lightGreyColor = Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0)
    var body: some View {
            GeometryReader{ geo in
                ScrollView{

                VStack{
                TextField("First Name", text: $first_name)
                    .padding()
                    .background(lightGreyColor)
                    .cornerRadius(15.0)
                    .padding(EdgeInsets(top: 10, leading: 10, bottom: 15, trailing: 20))
                TextField("Last Name", text: $last_name)
                    .padding()
                    .background(lightGreyColor)
                    .cornerRadius(15.0)
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 20))
               
                    
                    TextField("Username", text: $username)
                    .padding()
                    .background(lightGreyColor)
                    .cornerRadius(15.0)
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 20))
                   
                HStack{
                TextField("Age", text: $age)
                    .keyboardType(.numberPad)
                    .padding()
                    .background(lightGreyColor)
                    .cornerRadius(15.0)
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 0))
                TextField("Weight", text: $weight)
                    .keyboardType(.numberPad)
                    .padding()
                    .background(lightGreyColor)
                    .cornerRadius(15.0)
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 20))
                    
                    
                }
                    HStack{
                    TextField("Height Feet", text: $height_feet)
                        .keyboardType(.numberPad)
                        .padding()
                        .background(lightGreyColor)
                        .cornerRadius(15.0)
                        .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 0))
                    TextField("Height Inches", text: $height_inch)
                        .keyboardType(.numberPad)
                        .padding()
                        .background(lightGreyColor)
                        .cornerRadius(15.0)
                        .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 20))
                    }
                SecureField("Paswsord", text: $password)
                    .padding()
                    .background(lightGreyColor)
                    .cornerRadius(15.0)
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 20, trailing: 20))
                    
                    Button(action: {
                        isShowPhotoLibrary = true
                    }) {
                        HStack {
                            Image(systemName: "photo")
                                .font(.system(size: 20))
                        
                            Text("Choose Profile Image")
                                .font(.headline)
                            }
                            .frame(minWidth: 50, maxWidth: .infinity, minHeight: 50, maxHeight: 50)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                            .padding(.horizontal)
                            .padding(.bottom)
                    }
                    
                    
                    if image != nil{
                    Image(uiImage: self.image!)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 20, height: 30)
                    }
            Text("Sign Up")
                .fontWeight(.semibold)
                .padding(EdgeInsets(top: 10, leading: 24, bottom: 10, trailing: 24))
                .background(Color.black)
                .foregroundColor(.white)
                .cornerRadius(30)
                .onTapGesture {
                    if height_inch == "" {
                        height_inch = "0"
                    }
                    let info = ["First Name": first_name, "Last Name": last_name, "Username": username, "age": age, "weight": weight, "Height Feet":height_feet, "password" : password, "image": image] as [String: Any]
                    for (name, item) in info {
                        if let val = item as? String  {
                            if let num = Int(val){
                                if num == 0{
                                    resError = true
                                    messageForError = "\(name) can not be less than 1"
                                }
                            }
                            if val.count == 0 {
                                resError = true
                                messageForError = "\(name) can not be empty"
                            }
                        }  else if let val = item as? UIImage? {
                            if val == nil{
                                resError = true
                                messageForError = "select a profile picture"
                            }
                        }
                    }
                    
                    if resError != true {
                        locationManager.getCityState() { place in
                            user_city = place!.locality!
                            user_state = place!.administrativeArea!
                            
                        }
                    
                        Api().userCreate(first_name: first_name, last_name: last_name, username: username, age: age, weight: weight, height: "\(height_feet)'\(height_inch)", password: password, pfp: image!, location_state: "IN", location_city: "Bloomington") { error, success in
                        if error != nil{
                            requestErrorResponse = error
                            resError = true
                            var strErrorRes = ""
                            for (key, val) in requestErrorResponse.dictionary! {
                                if let ting = val as? [String]?{
                                    if ting != nil{
                                        print("reqError Dict in view: \(key) - \(ting![0])")
                                        strErrorRes += "\(key): \(ting![0])"
                            }
                                }
                        }
                            messageForError = strErrorRes
                        }else {
                            token.accessToken = success!.access
                            token.refreshToken = success!.refresh
                            token.user_id = success!.user_id
                            token.username = success!.username
                            token.first_name = success!.first_name
                            token.last_name = success!.last_name
                            token.age = success!.age
                            token.weight = success!.weight
                            token.height = success!.height
                            token.user_picture = success!.user_picture
                            token.current_match = success!.current_match
                        
                            loggedIn = true
                        }
                    }
                    }
                    
                    
                    
                    
                }
                    }
                
                }
        }
            .alert(isPresented: $resError) {
                       return  Alert(title: Text("Incorrect Credentials"), message: Text(messageForError), dismissButton: .default(Text("Ok")))
                    
                    }
        .sheet(isPresented: $isShowPhotoLibrary) {
            ImagePicker(sourceType: .photoLibrary, selectedImage: self.$image)
        }
        .navigationTitle("Create Account")
       
    }
}


extension Encodable {
    var dictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
}
