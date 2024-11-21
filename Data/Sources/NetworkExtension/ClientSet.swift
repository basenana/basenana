//
//  Connection.swift
//
//
//  Created by Hypo on 2024/9/15.
//

import Foundation
import Entities
import SwiftUI
import GRPC
import NIO
import NIOSSL

let clientEventLoopGroup = PlatformSupport.makeEventLoopGroup(loopCount: System.coreCount/2+1)

@available(macOS 11.0, *)
public class FSAPI {
    private var host: String
    private var port: Int
    private var accessTokenKey: String
    private var secretToken: String
    
    public init(host: String, port: Int, accessTokenKey: String, secretToken: String) {
        self.host = host
        self.port = port
        self.accessTokenKey = accessTokenKey
        self.secretToken = secretToken
    }
    
    var isLogined: Bool = false
    var clientCrt: [UInt8] = []
    var clientKey: [UInt8] = []
    var namespace: String = ""
    
    public func login() throws -> ClientSet {
        if self.host == ""{
            throw RepositoryError.invalidHost
        }
        
        if self.port == 0{
            throw RepositoryError.invalidPort
        }
        
        if self.accessTokenKey == "" || self.secretToken == "" {
            throw RepositoryError.invalidAccessKey
        }
        
        let authChannel = ClientConnection
            .usingTLSBackedByNIOSSL(on: clientEventLoopGroup)
            .withTLS(certificateVerification: .none)
            .connect(host: host, port: port)
        let auth = Api_V1_AuthNIOClient(channel: authChannel)
        
        if !self.isLogined {
            var request = Api_V1_AccessTokenRequest()
            request.accessTokenKey = self.accessTokenKey
            request.secretToken = self.secretToken
            let call = auth.accessToken(request, callOptions: defaultCallOptions)
            do {
                let response = try call.response.wait()
                self.clientCrt = try response.clientCrt.base64Decoded()
                self.clientKey = try response.clientKey.base64Decoded()
                self.namespace = response.namespace
            } catch {
                throw RepositoryError.loginFailed(error)
            }
        }
        
        self.isLogined = true
        print("login succeed")
        return try ClientSet(host: host, port: port, clientCrt: clientCrt, clientKey: clientKey, namespace: namespace)
    }
}


@available(macOS 11.0, *)
public class ClientSet {
    
    var inbox: Api_V1_InboxClientProtocol
    var entries: Api_V1_EntriesClientProtocol
    var properties: Api_V1_PropertiesClientProtocol
    var document: Api_V1_DocumentClientProtocol
    var dialogue: Api_V1_RoomClientProtocol
    var workflow: Api_V1_WorkflowClientProtocol
    var notify: Api_V1_NotifyClientProtocol
    
    private var namespace: String
    
    public init(host: String, port: Int, clientCrt: [UInt8], clientKey: [UInt8], namespace: String) throws {
        let tlsChannel = ClientConnection
            .usingTLSBackedByNIOSSL(on: clientEventLoopGroup)
            .withTLS(certificateChain: [try .init(bytes: clientCrt, format: .pem)])
            .withTLS(privateKey: try .init(bytes: clientKey, format: .pem))
            .withTLS(certificateVerification: .none)
            .connect(host: host, port: port)
        
        self.inbox = Api_V1_InboxNIOClient(channel: tlsChannel)
        self.entries = Api_V1_EntriesNIOClient(channel: tlsChannel)
        self.properties = Api_V1_PropertiesNIOClient(channel: tlsChannel)
        self.document = Api_V1_DocumentNIOClient(channel: tlsChannel)
        self.dialogue = Api_V1_RoomNIOClient(channel: tlsChannel)
        self.workflow = Api_V1_WorkflowNIOClient(channel: tlsChannel)
        self.notify = Api_V1_NotifyNIOClient(channel: tlsChannel)
        
        self.namespace = namespace
    }
    
    public func fsInfo() throws -> FSInfo {
        let result = FSInfo()
        result.namespace = namespace
        
        do {
            var req = Api_V1_FindEntryDetailRequest()
            req.root = true
            let resp = try entries.findEntryDetail(req, callOptions: defaultCallOptions).response.wait()
            result.rootID = resp.entry.id
        } catch {
            print("refush fs info error, get root entry failed \(error)")
            throw error
        }
        
        do {
            var req = Api_V1_FindEntryDetailRequest()
            req.parentID = result.rootID
            req.name = ".inbox"
            let resp = try entries.findEntryDetail(req, callOptions: defaultCallOptions).response.wait()
            result.inboxID = resp.entry.id
        } catch {
            print("refush fs info error, get inbox entry failed \(error)")
            throw error
        }
        
        return result
    }
}

public class FSInfo {
    public var namespace = ""
    public var rootID: Int64 = 0
    public var inboxID: Int64 = 0
}
