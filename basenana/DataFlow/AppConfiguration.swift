//
//  AppConfiguration.swift
//  basenana
//
//  Created by Hypo on 2024/6/19.
//

import SwiftUI
import Foundation


final class AppConfiguration: ObservableObject {
    
    @AppStorage("org.basenana.nanafs.host", store: UserDefaults.standard)
    private var host: String = ""
    
    @AppStorage("org.basenana.nanafs.port", store: UserDefaults.standard)
    private var port: Int = 0
    
    @AppStorage("org.basenana.nanafs.auth.accessToken", store: UserDefaults.standard)
    private var accessTokenKey: String = ""
    
    @AppStorage("org.basenana.nanafs.auth.secretToken", store: UserDefaults.standard)
    private var secretToken: String = ""
    
    static let share = AppConfiguration()
}
