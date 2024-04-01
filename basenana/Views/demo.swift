//
//  demo.swift
//  basenana
//
//  Created by zww on 2024/3/30.
//

import Foundation
import SwiftUI

struct ContentView: View {
    @State private var isDrawerOpen = true

    var body: some View {
        HStack(spacing: 0) {
            // Main content
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Article Title")
                        .font(.largeTitle)
                        .padding()

                    Text("Article content goes here...")
                        .font(.body)
                        .padding()
                }
            }

            // Drawer
            Drawer2View(isDrawerOpen: $isDrawerOpen)
        }
    }
}


struct Drawer2View: View {
    @Binding var isDrawerOpen: Bool

    var body: some View {
        HStack(spacing: 0) {
            if isDrawerOpen {
                TabView {
                    Text("Drawer Content 1")
                        .tabItem {
                            Image(systemName: "square.and.pencil")
                            Text("Tab 1")
                        }
                    
                    Text("Drawer Content 2")
                        .tabItem {
                            Image(systemName: "pencil.and.ellipsis.rectangle")
                            Text("Tab 2")
                        }
                    
                    Button(action: {
                        withAnimation {
                            self.isDrawerOpen.toggle()
                        }
                    }) {
                        Text("Close Drawer")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                    .tabItem {
                        Image(systemName: "xmark")
                        Text("Close")
                    }
                }
                .frame(width: 200, height: .infinity)
                .background(Color.blue)
                .edgesIgnoringSafeArea(.all)
            } else {
                Button(action: {
                    withAnimation {
                        self.isDrawerOpen.toggle()
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                }
            }
        }
    }
}
