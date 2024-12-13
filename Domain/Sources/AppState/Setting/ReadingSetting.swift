//
//  ReadingSetting.swift
//  Domain
//
//  Created by Hypo on 2024/12/11.
//

import SwiftUI


public class ReadingSetting {
    
    @AppStorage("org.basenana.reading.documentContent.font", store: UserDefaults.standard)
    public var documentFont: String = "default"
    @AppStorage("org.basenana.reading.documentContent.fontSize", store: UserDefaults.standard)
    public var documentFontSize: Int = 1
    @AppStorage("org.basenana.reading.documentContent.letterSpacing", store: UserDefaults.standard)
    public var documentLetterSpacing: Int = 0
    @AppStorage("org.basenana.reading.documentContent.maxWidth", store: UserDefaults.standard)
    public var documentMaxWidth: Int = 1
    @AppStorage("org.basenana.reading.documentContent.customCSS", store: UserDefaults.standard)
    public var documentCustomCSS: String = ""

    @AppStorage("org.basenana.reading.documentTitle.fontSize", store: UserDefaults.standard)
    public var documentTitleFontSize: Int = 1
    
    @AppStorage("org.basenana.reading.documentTitle.align", store: UserDefaults.standard)
    public var documentTitleAlign: String = "left" // left / centre
    
    @AppStorage("org.basenana.reading.documentTitle.blod", store: UserDefaults.standard)
    public var documentTitleBold: Bool = false

    init() {}
}
