//
//  File.swift
//  basenana
//
//  Created by Hypo on 2024/3/3.
//

import Foundation
import SwiftUI


struct QuickInboxView: View{
    @State private var offset = CGSize.zero
    @State private var isDragging = false
    @State private var urlInput: String = ""
    @State private var fileTypeOption = 0
    @State private var styleOption = 0
    
    var body: some View{
        VStack {
            TextField("Enter URL", text: $urlInput)
                .padding(.horizontal, 50.0)
                .padding(.top, 20)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(minWidth: 400, maxWidth: .infinity, minHeight: 20)
            HStack{
                Picker("File", selection: $fileTypeOption) {
                    Text("Webarchive").tag(0)
                    Text("Html").tag(1)
                    Text("Bookmark").tag(2)
                }
                .padding()
                Picker("Style", selection: $styleOption) {
                    Text("ClutterFree").tag(0)
                    Text("Raw").tag(1)
                }
                .padding()
            }
        }
        .background(Color.gray.opacity(0.2))
    }
}

#Preview {
    QuickInboxView()
}
