//
//  DialogueViewModel.swift
//  basenana
//
//  Created by zww on 2024/4/19.
//

import Foundation
import SwiftProtobuf

@Observable
class DialogueViewModel {
    var propertyModel: PropertyViewModel = PropertyViewModel()
    var entryId: Int64 = 0
    var room: RoomModel? = nil
    
    var messageToSend: String = ""
    var newReply: String = ""
    var messages: [RoomMessageModel] = []
    
    func initDialogue(entryId: Int64) async throws{
        self.entryId = entryId
        try await propertyModel.initEntry(entryID: entryId)
        
        let clientSet = try clientFactory.makeClient()
        var request = Api_V1_OpenRoomRequest()
        request.entryID = entryId
        let call = clientSet.dialogue.openRoom(request, callOptions: defaultCallOptions)
        
        // todo: get message with pagination
        let response = try await call.response.get()
        
        room = response.room.room()
        messages = room?.messages ?? []
    }
    
    func sendMessage() async throws {
        let messageNeedToSend = self.messageToSend
        self.messageToSend = ""
        var requestNeedToSave = true
        var hasApply = false
        let roomId = room?.id ?? 0
        
        let clientSet = try clientFactory.makeClient()
        var request = Api_V1_ChatRequest()
        let requestSendAt = Date()
        
        var replyMsg: String = ""
        var replyLine: String = ""
        
        var timestamp = SwiftProtobuf.Google_Protobuf_Timestamp()
        timestamp.seconds = Int64(requestSendAt.timeIntervalSince1970)
        timestamp.nanos = 0
        
        request.roomID = roomId
        request.newRequest = messageNeedToSend
        request.sendAt = timestamp
        
        var waitingLLM = true
        let _ = clientSet.dialogue.chatInRoom(request, callOptions: nil) { response in
            replyLine = response.responseMessage
            if response.sender != "" && response.sender != "thinking" && waitingLLM {
                waitingLLM = false
                replyMsg = ""
            }
            replyMsg += replyLine
            if requestNeedToSave {
                requestNeedToSave = false
                self.messages.append(RoomMessageModel(
                    id: response.requestID,
                    roomid: roomId,
                    sender: "user",
                    message: messageNeedToSend,
                    sendAt: requestSendAt,
                    createdAt: requestSendAt
                ))
            }
            if response.responseID != 0 {
                if !hasApply{
                    self.messages.append(RoomMessageModel(
                        id: response.responseID,
                        roomid: roomId,
                        sender: response.sender,
                        message: replyMsg,
                        sendAt: response.sendAt.date,
                        createdAt: response.createdAt.date
                    ))
                    hasApply = true
                }else{
                    let count = self.messages.count > 10 ? 10:self.messages.count
                    for i in 0..<count{
                        var msg = self.messages[self.messages.count-1-i]
                        if msg.id == response.responseID {
                            msg.sender = response.sender
                            msg.message = replyMsg
                            self.messages[self.messages.count-1-i] = msg
                            break
                        }
                    }
                }
            }
        }
    }
    
    func ingestDocument() async throws {
        let clientSet = try clientFactory.makeClient()
        var requset = Api_V1_TriggerWorkflowRequest()
        requset.workflowID = "buildin.ingest"
        requset.target.entryID = entryId
        let call = clientSet.workflow.triggerWorkflow(requset, callOptions: defaultCallOptions)
        let _ = try await call.response.get()
        
        while true {
            try await propertyModel.fetchProperty()
            let ingestState = propertyModel.getProperty(k: "org.basenana.friday/ingest")?.value ?? ""
            if ingestState == "finish" {
                return
            }
            try? await Task.sleep(nanoseconds: 1_000_000_000)
        }
    }
    
    func clearMessages() async throws {
        let clientSet = try clientFactory.makeClient()
        var request = Api_V1_ClearRoomRequest()
        request.roomID = room?.id ?? 0
        let call = clientSet.dialogue.clearRoom(request, callOptions: defaultCallOptions)
        let _ = try await call.response.get()
        messages = []
    }
}
