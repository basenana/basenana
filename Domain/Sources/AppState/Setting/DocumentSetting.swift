//
//  DocumentSetting.swift
//  Domain
//
//  Created by Hypo on 2024/12/11.
//

import SwiftUI


public class DocumentSetting {
    
    @AppStorage("org.basenana.document.sortUnread", store: UserDefaults.standard)
    public var sortUnread: String = "newest" // newest / oldest
    
    @AppStorage("org.basenana.document.groupBy", store: UserDefaults.standard)
    public var groupBy: String = "date" // date / group
    
    @AppStorage("org.basenana.document.autoRead", store: UserDefaults.standard)
    public var autoRead: Bool = true
    
    @AppStorage("org.basenana.document.autoTranslate", store: UserDefaults.standard)
    public var autoTranslate: Bool = false

    @AppStorage("org.basenana.document.autoSummary", store: UserDefaults.standard)
    public var autoSummary: Bool = false
    
    init() {}
}
