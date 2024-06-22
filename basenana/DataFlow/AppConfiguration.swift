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
    var host: String = ""
    
    @AppStorage("org.basenana.nanafs.port", store: UserDefaults.standard)
    var port: Int = 0
    
    @AppStorage("org.basenana.nanafs.auth.accessToken", store: UserDefaults.standard)
    var accessTokenKey: String = ""
    
    @AppStorage("org.basenana.nanafs.auth.secretToken", store: UserDefaults.standard)
    var secretToken: String = ""
    
    @AppStorage("org.basenana.nanafs.document.autoRead", store: UserDefaults.standard)
    var autoRead: Bool = false

    static let share = AppConfiguration()
}
