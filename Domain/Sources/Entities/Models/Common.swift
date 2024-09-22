//
//  Common.swift
//
//
//  Created by Hypo on 2024/9/14.
//

import Foundation


public struct Pagination {
    public var page: Int64
    public var pageSize: Int64
    
    public init() {
        self.page = 0
        self.pageSize = 20
    }
}
