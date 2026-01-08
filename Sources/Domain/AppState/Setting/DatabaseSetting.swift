//
//  DatabaseSetting.swift
//  Domain
//
//  Created by Hypo on 2024/11/20.
//

import SwiftUI

public class DatabaseSetting {
    @AppStorage("org.basenana.nanafs.host", store: UserDefaults.standard)
    public var apiHost: String = ""
    
    @AppStorage("org.basenana.nanafs.port", store: UserDefaults.standard)
    public var apiPort: Int = 0
    
    @AppStorage("org.basenana.nanafs.auth.accessToken", store: UserDefaults.standard)
    public var apiaccessTokenKey: String = ""
    
    @AppStorage("org.basenana.nanafs.auth.secretToken", store: UserDefaults.standard)
    public var apiSecretToken: String = ""
    
    @AppStorage("org.basenana.nanafs.namespace", store: UserDefaults.standard)
    public var apiNamespace: String = ""
    
    init() { }
}
