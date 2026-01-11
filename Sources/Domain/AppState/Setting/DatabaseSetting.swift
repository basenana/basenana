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

    @AppStorage("org.basenana.nanafs.auth.bearerToken", store: UserDefaults.standard)
    public var apiBearerToken: String = ""

    @AppStorage("org.basenana.nanafs.namespace", store: UserDefaults.standard)
    public var apiNamespace: String = ""

    init() { }
}
