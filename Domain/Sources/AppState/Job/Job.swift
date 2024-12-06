//
//  Job.swift
//  Domain
//
//  Created by Hypo on 2024/12/6.
//

import Foundation
import Entities

let backgroundQueue = DispatchQueue(label: "bg.jobs", qos: .background)

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
    
    public func newBackgroundJob(name: String, job: @escaping () -> Void, complete: @escaping () -> Void) {
        // Create a background queue
        assert(Thread.isMainThread)
        
        let j = BackgroundJob(name: name, startAt: Date())
        self.backgroupJobs.append(j)
        
        // Execute the job in the background
        backgroundQueue.async {
            job() // Perform the job
            
            // Once the job is done, call the completion handler on the main queue
            DispatchQueue.main.async {
                complete()
                self.backgroupJobs.removeAll(where: { $0.id == j.id })
            }
        }
    }
}
