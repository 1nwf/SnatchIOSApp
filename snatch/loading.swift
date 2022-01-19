//
//  loading.swift
//  snatch
//
//  Created by Nawaf on 5/28/21.
//

import SwiftUI

struct loading: View {
    
    @State var animate = false
    var body: some View {
        GeometryReader {geo in
            VStack{
            Circle()
                .trim(from: 0, to: 0.8)
                .stroke(AngularGradient(gradient: .init(colors: [.green]), center: .center), style: StrokeStyle(lineWidth: 7, lineCap: .butt))
                .frame(width: geo.size.width, height: geo.size.height * 0.06, alignment: .center)
                .rotationEffect(.init(degrees: self.animate ? 360: 0))
                .animation(Animation.linear(duration: 0.7).repeatForever(autoreverses: false))
            }
            .frame(width: geo.size.width, height: geo.size.height , alignment: .center)
            .onAppear {
                self.animate = true
            }
            
        }
    }
}

struct loading_Previews: PreviewProvider {
    static var previews: some View {
        loading()
    }
}
