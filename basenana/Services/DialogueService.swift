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
    
    func getRooms(docId: Int64, entryId: Int64) -> [RoomModel]? {
        do {
            var data: [RoomModel]
            data = try dbInstance.queue.read{ db in
                try RoomModel.filter(Column("docid") == docId).fetchAll(db)
            }
            return data
        } catch {
            log.error("get rooms failed \(error)")
            return nil
        }
    }
    
    func openRoom(docId: Int64, entryId: Int64) -> RoomViewModel? {
        do {
            var data: RoomModel?
            var msgs: [RoomMessageModel]? = []
            data = try dbInstance.queue.read{ db in
                try RoomModel.filter(Column("docid") == docId).fetchOne(db)
            }
            if data == nil {
                log.info("no rooms of document \(docId), get from server")
                var request = Api_V1_OpenRoomRequest()
                request.entryID = entryId
                let call = clientSet!.dialogue.openRoom(request, callOptions: nil)
                
                let response = try call.response.wait()
                let room = response.room
                
                let r = RoomModel(id: room.id, namespace: room.namespace, oid: room.entryID, docid: docId, createdAt: room.createdAt.date)
                saveRoom(room: r)
                return RoomViewModel(room: r, messages: [])
            }
            
            msgs = try dbInstance.queue.read{ db in
                try RoomMessageModel.filter(Column("roomid") == data?.id).fetchAll(db)
            }
            return RoomViewModel(room: data!, messages: msgs!)
        } catch {
            log.error("get rooms or messages failed \(error)")
            return nil
        }
    }
    
    func saveRoom(room: RoomModel) {
        var roomModel = room
        do {
            try dbInstance.queue.write{ db in
                try roomModel.save(db)
            }
        } catch {
            log.error("insert room failed \(error)")
        }
        return
    }
    
    func getRoomMessage(roomId: Int64) -> [RoomMessageModel]? {
        do {
            let data: [RoomMessageModel]? = try dbInstance.queue.read{ db in
                try RoomMessageModel.filter(Column("roomid") == roomId).fetchAll(db)
            }
            return data
        } catch {
            log.error("get room message failed \(error)")
            return nil
        }
    }
    func saveMessage(message: RoomMessageModel) {
        do {
            var msg: RoomMessageModel = message
            try dbInstance.queue.write{ db in
                try msg.save(db)
            }
        } catch {
            log.error("insert room message failed \(error)")
        }
        return
    }
    
    
    func chatInRoom(roomId: Int64, newRequest: String, callbackFn: @escaping (RoomMessageModel, RoomMessageModel) -> Void, whenSucceedFn: @escaping (RoomMessageModel) -> Void) throws {
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
        
        let call = clientSet!.dialogue.chatInRoom(request, callOptions: nil) { response in
            replyLine = response.responseMessage
            replyMsg += replyLine
            if response.requestID != 0 {
                requestMsg.id = response.requestID
                dialogueService.saveMessage(message: requestMsg)
            }
            responseMsg.sender = response.sender
            responseMsg.id = response.responseID
            responseMsg.sendAt = response.sendAt.date
            responseMsg.createdAt = response.createdAt.date
            responseMsg.message = replyMsg
            callbackFn(requestMsg, responseMsg)
        }
        
        call.status.whenSuccess{ val in
            dialogueService.saveMessage(message: responseMsg)
            whenSucceedFn(responseMsg)
        }
        
    }
    
    func clearMessage(roomId: Int64) {
        do {
            try dbInstance.queue.write{ db in
                try RoomModel.filter(Column("id") == roomId).deleteAll(db)
                try RoomMessageModel.filter(Column("roomid") == roomId).deleteAll(db)
            }
        }catch{
            log.error("clear room & message by roomId \(roomId) failed")
        }
    }
}
