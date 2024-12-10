//
//  Config.swift
//  Domain
//
//  Created by Hypo on 2024/11/20.
//

import SwiftUI

@available(macOS 11.0, *)
public class Config {
    @AppStorage("org.basenana.nanafs.host", store: UserDefaults.standard)
    var apiHost: String = ""
    
    @AppStorage("org.basenana.nanafs.port", store: UserDefaults.standard)
    var apiPort: Int = 0
    
    @AppStorage("org.basenana.nanafs.auth.accessToken", store: UserDefaults.standard)
    var apiaccessTokenKey: String = ""
    
    @AppStorage("org.basenana.nanafs.auth.secretToken", store: UserDefaults.standard)
    var apiSecretToken: String = ""
    
    @AppStorage("org.basenana.nanafs.namespace", store: UserDefaults.standard)
    var apiNamespace: String = ""
    
    public init() { }
}
