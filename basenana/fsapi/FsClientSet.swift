//
//  FsClient.swift
//  basenana
//
//  Created by Hypo on 2024/4/14.
//

import Foundation
import GRPC
import NIO


var clientSet = FsClientSet(host: "127.0.0.1", port: 7081)

class FsClientSet {
    var inbox: Api_V1_InboxClientProtocol
    var entries: Api_V1_EntriesClientProtocol
    var properties: Api_V1_PropertiesClientProtocol
    var document: Api_V1_DocumentClientProtocol
    var notify: Api_V1_NotifyClientProtocol
    
    init(host: String, port: Int) {
        let group = PlatformSupport.makeEventLoopGroup(loopCount: System.coreCount/2+1)
        let channel = ClientConnection(configuration: .default(target: ConnectionTarget.hostAndPort(host, port), eventLoopGroup: group))
        self.inbox = Api_V1_InboxNIOClient(channel: channel)
        self.entries = Api_V1_EntriesNIOClient(channel: channel)
        self.properties = Api_V1_PropertiesNIOClient(channel: channel)
        self.document = Api_V1_DocumentNIOClient(channel: channel)
        self.notify = Api_V1_NotifyNIOClient(channel: channel)
    }
    
}
