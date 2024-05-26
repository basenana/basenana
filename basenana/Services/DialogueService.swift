//
//  MessageService.swift
//  basenana
//
//  Created by zww on 2024/4/7.
//

import Foundation
import SwiftData
import GRDB
import SwiftProtobuf

let dialogueService = DialogueService()

class DialogueService: ObservableObject {
    
    func getRooms(docId: Int64, entryId: Int64) -> [RoomModel] {
        do {
            var request = Api_V1_ListRoomsRequest()
            request.entryID = entryId
            
            let call = clientSet?.dialogue.listRooms(request, callOptions: nil)
            let response = try call?.response.wait()
            
            var rooms: [RoomModel] = []
            for room in response!.rooms {
                rooms.append(room2Model(room: room))
            }
            return rooms
        } catch {
            log.error("get rooms failed \(error)")
            return []
        }
    }
    
    func openRoom(docId: Int64, entryId: Int64) -> RoomModel? {
        do {
            var request = Api_V1_OpenRoomRequest()
            request.entryID = entryId
            let call = clientSet!.dialogue.openRoom(request, callOptions: nil)
            let response = try call.response.wait()
            
            // todo: get message with pagination
            return room2Model(room: response.room)
        } catch {
            log.error("get rooms or messages failed \(error)")
            return nil
        }
    }
    
    func chatInRoom(roomId: Int64, newRequest: String, callbackFn: @escaping (RoomMessageModel, RoomMessageModel) -> Void) throws {
        var request = Api_V1_ChatRequest()
        let requestSendAt = Date()
        
        var requestMsg: RoomMessageModel = RoomMessageModel(
            roomid: roomId, sender: "user",
            message: newRequest, sendAt: requestSendAt, createdAt: Date()
        )
        var replyMsg: String = ""
        var replyLine: String = ""
        
        var responseMsg: RoomMessageModel = RoomMessageModel(
            roomid: roomId, sender: "",
            message: "", sendAt: Date(), createdAt: Date()
        )
        
        var timestamp = SwiftProtobuf.Google_Protobuf_Timestamp()
        timestamp.seconds = Int64(requestSendAt.timeIntervalSince1970)
        timestamp.nanos = 0
        
        request.roomID = roomId
        request.newRequest = newRequest
        request.sendAt = timestamp
        
        var waitingLLM = true
        let _ = clientSet!.dialogue.chatInRoom(request, callOptions: nil) { response in
            replyLine = response.responseMessage
            if response.sender != "" && response.sender != "thinking" && waitingLLM {
                waitingLLM = false
                replyMsg = ""
            }
            replyMsg += replyLine
            callbackFn(requestMsg, responseMsg)
        }
    }
    
    func clearMessage(roomId: Int64) {
        do {
            var request = Api_V1_ClearRoomRequest()
            request.roomID = roomId
            let call = clientSet!.dialogue.clearRoom(request, callOptions: nil)
            let _ = try call.response.wait()
        }catch{
            log.error("clear room & message by roomId \(roomId) failed")
        }
    }
    
    func room2Model(room: Api_V1_RoomInfo) -> RoomModel {
        let messages = room.messages
        var ms: [RoomMessageModel] = []
        for message in messages {
            ms.append(RoomMessageModel(roomid: message.id, sender: message.sender, message: message.message, sendAt: message.sendAt.date, createdAt: message.createdAt.date))
        }
        return RoomModel(
            id: room.id, namespace: room.namespace, oid: room.entryID,
            title: room.title, prompt: room.prompt,
            createdAt: room.createdAt.date, messages: ms
        )
    }
}
