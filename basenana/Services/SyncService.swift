//
//  SyncService.swift
//  basenana
//
//  Created by Hypo on 2024/4/14.
//

import Foundation
import GRPC
import GRDB

let syncService = SyncService()

class SyncService {
    private var clientSet: FsClientSet
    
    init() {
        self.clientSet = FsClientSet(host: "127.0.0.1", port: 7081)
    }
    
    func getLatestSequence() {
        var request = Api_V1_GetLatestSequenceRequest()
        let option = CallOptions(eventLoopPreference: .indifferent)
        let unaryCall = clientSet.notify.getLatestSequence(request, callOptions: option)
    }
}
