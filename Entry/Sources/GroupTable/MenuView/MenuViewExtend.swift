//
//  ExtendMenuView.swift
//  Entry
//
//  Created by Hypo on 2024/10/10.
//

import Foundation
import SwiftUI
import Entities
import AppState
import UseCaseProtocol


@available(macOS 14.0, *)
struct WebFileMenuView: View {
    private var viewModel: TreeViewModel
    private var targetEntry: EntryDetail
    
    init(viewModel: TreeViewModel, targetEntry: EntryDetail) {
        self.viewModel = viewModel
        self.targetEntry = targetEntry
    }
    
    var body: some View {
        Section(){
            Button("Launch URL", action: {
                for pk in [Property.WebPageURL, Property.WebSiteURL]{
                    if let pro = getEntryProperty(k: pk){
                        if let pageUrl = URL(string: pro.value){
                            //                                openURL.callAsFunction(pageUrl){ result in
                            //                                    log.info("open docuemnt url \(proVal), resule: \(result)")
                            //                                }
                            break
                        }
                    }
                }
            })
            Button("Copy URL", action: {
                for pk in [Property.WebPageURL, Property.WebSiteURL]{
                    if let pro = getEntryProperty(k: pk){
                        //                            copyToClipBoard(textToCopy: pro.value)
                        break
                    }
                }
            })
        }
    }
    
    func getEntryProperty(k: String) -> EntryProperty?{
        for p in targetEntry.properties {
            if p.key == k {
                return p
            }
        }
        return nil
    }
}
