//
//  Job.swift
//  Domain
//
//  Created by Hypo on 2024/12/6.
//

import Foundation
import Entities

public final class BackgroundJob: Identifiable {
    public var id: String
    public var name: String
    public var startAt: Date
    
    public init(name: String, startAt: Date) {
        self.id = "\(RFC3339Formatter().string(from: Date()))-\(randomString(randomOfLength: 10))"
        self.name = name
        self.startAt = startAt
    }
}


extension StateStore {
    
    public func newBackgroundJob(name: String, job: @escaping () async -> Void, complete: @escaping () -> Void) {
        assert(Thread.isMainThread)
        
        let j = BackgroundJob(name: name, startAt: Date())
        self.backgroupJobs.append(j)
        
        let jid = j.id
        Task(priority: .background) {
            await job()
            await complateBackgroundJob(jid: jid, complete: complete)
        }
    }
    
    @MainActor
    private func complateBackgroundJob(jid: String, complete: @escaping () -> Void) {
        assert(Thread.isMainThread)
        complete()
        self.backgroupJobs.removeAll(where: { $0.id == jid })
    }
}
