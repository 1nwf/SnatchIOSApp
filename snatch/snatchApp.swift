//
//  snatchApp.swift
//  snatch
//
//  Created by Nawaf on 4/20/21.
//

import SwiftUI

@main
struct snatchApp: App {

    @StateObject var token: Tokens = Tokens()
    @StateObject var homeStats = homeStat()

    var body: some Scene {
        WindowGroup {
            ContentView(token: token, homeStats: homeStats)

        }
    }
}
