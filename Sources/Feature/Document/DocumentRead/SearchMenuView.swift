//
//  SwiftUIView.swift
//  Document
//
//  Created by Weiwei on 2025/4/12.
//

import SwiftUI
import Foundation
import Domain
import Domain
import Styleguide

struct SearchMenuView: View {
    @Binding var document: DocumentSearchItem
    @State var viewModel: SearchViewModel
    
    init(document: Binding<DocumentSearchItem>, viewModel: SearchViewModel) {
        self._document = document
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            
            if let u = parseUrlString(urlStr: getEntryProperty(keys: [Property.WebPageURL, Property.WebSiteURL])?.value ?? "" ){
                Section(){
                    Button("Launch URL", action: {
                        openUrlInBrowser(url: u)
                    })
                    Button("Copy URL", action: {
                        copyToClipBoard(content: "\(u)")
                    })
                }
            }
        }
    }
    
    func getEntryProperty(keys: [String]) -> EntryProperty?{
        for k in keys {
            for p in document.properties {
                if p.key == k {
                    return p
                }
            }
        }
        return nil
        
    }
}
