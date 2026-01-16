//
//  ReadingSetting.swift
//  Domain
//
//  Created by Hypo on 2024/12/11.
//

import Foundation
import SwiftUI
import Observation

@Observable
public class ReadingSetting {
    public var documentFont: String {
        get {
            access(keyPath: \.documentFont)
            return UserDefaults.standard.string(forKey: "org.basenana.reading.documentContent.font") ?? "default"
        }
        set {
            withMutation(keyPath: \.documentFont) {
                UserDefaults.standard.set(newValue, forKey: "org.basenana.reading.documentContent.font")
            }
        }
    }

    public var documentFontSize: Int {
        get {
            access(keyPath: \.documentFontSize)
            return UserDefaults.standard.integer(forKey: "org.basenana.reading.documentContent.fontSize")
        }
        set {
            withMutation(keyPath: \.documentFontSize) {
                UserDefaults.standard.set(newValue, forKey: "org.basenana.reading.documentContent.fontSize")
            }
        }
    }

    public var documentLetterSpacing: Int {
        get {
            access(keyPath: \.documentLetterSpacing)
            return UserDefaults.standard.integer(forKey: "org.basenana.reading.documentContent.letterSpacing")
        }
        set {
            withMutation(keyPath: \.documentLetterSpacing) {
                UserDefaults.standard.set(newValue, forKey: "org.basenana.reading.documentContent.letterSpacing")
            }
        }
    }

    public var documentMaxWidth: Int {
        get {
            access(keyPath: \.documentMaxWidth)
            return UserDefaults.standard.integer(forKey: "org.basenana.reading.documentContent.maxWidth")
        }
        set {
            withMutation(keyPath: \.documentMaxWidth) {
                UserDefaults.standard.set(newValue, forKey: "org.basenana.reading.documentContent.maxWidth")
            }
        }
    }

    public var documentCustomCSS: String {
        get {
            access(keyPath: \.documentCustomCSS)
            return UserDefaults.standard.string(forKey: "org.basenana.reading.documentContent.customCSS") ?? ""
        }
        set {
            withMutation(keyPath: \.documentCustomCSS) {
                UserDefaults.standard.set(newValue, forKey: "org.basenana.reading.documentContent.customCSS")
            }
        }
    }

    public var documentTitleFontSize: Int {
        get {
            access(keyPath: \.documentTitleFontSize)
            return UserDefaults.standard.integer(forKey: "org.basenana.reading.documentTitle.fontSize")
        }
        set {
            withMutation(keyPath: \.documentTitleFontSize) {
                UserDefaults.standard.set(newValue, forKey: "org.basenana.reading.documentTitle.fontSize")
            }
        }
    }

    public var documentTitleAlign: String {
        get {
            access(keyPath: \.documentTitleAlign)
            return UserDefaults.standard.string(forKey: "org.basenana.reading.documentTitle.align") ?? "left"
        }
        set {
            withMutation(keyPath: \.documentTitleAlign) {
                UserDefaults.standard.set(newValue, forKey: "org.basenana.reading.documentTitle.align")
            }
        }
    }

    public var documentTitleBold: Bool {
        get {
            access(keyPath: \.documentTitleBold)
            return UserDefaults.standard.bool(forKey: "org.basenana.reading.documentTitle.blod")
        }
        set {
            withMutation(keyPath: \.documentTitleBold) {
                UserDefaults.standard.set(newValue, forKey: "org.basenana.reading.documentTitle.blod")
            }
        }
    }

    init() {}
}
