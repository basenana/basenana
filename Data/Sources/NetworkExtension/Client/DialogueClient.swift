//
//  DialogueClient.swift
//
//
//  Created by Hypo on 2024/9/16.
//

import Foundation
import Entities
import NetworkCore


@available(macOS 11.0, *)
public class DialogueClient: DialogueClientProtocol {
    
    var client: Api_V1_RoomClientProtocol
    
    public init(clientSet: ClientSet) {
        self.client = clientSet.dialogue
    }
    
    public func ListRoomes(entry: Int64) throws -> [NetworkCore.APIRoom] {
        let resp = try client.listRooms(
            Api_V1_ListRoomsRequest(), callOptions: defaultCallOptions).response.wait()
        
        var result: [NetworkCore.APIRoom] = []
        for room in resp.rooms {
            result.append(room.toRoom())
        }
        return result
    }
    
    public func OpenRoom(entry: Int64, room: Int64, option: Entities.RoomOption) throws -> NetworkCore.APIRoom {
        var req = Api_V1_OpenRoomRequest()
        req.entryID = entry
        req.roomID = room
        req.option = Api_V1_OpenRoomRequest.Option()
        req.option.prompt = option.prompt
        let resp = try client.openRoom(req, callOptions: defaultCallOptions).response.wait()
        return resp.room.toRoom()
    }
    
    public func UpdateRoom(room: Int64, option: Entities.RoomOption) throws {
        var req = Api_V1_UpdateRoomRequest()
        req.roomID = room
        req.prompt = option.prompt
        let resp = try client.updateRoom(req, callOptions: defaultCallOptions).response.wait()
        let _ = resp.roomID
    }
    
    public func DeleteRoom(room: Int64) throws {
        var req = Api_V1_DeleteRoomRequest()
        req.roomID = room
        let _ = try client.deleteRoom(req, callOptions: defaultCallOptions).response.wait()
    }
    
    public func ClearRoom(room: Int64) throws {
        var req = Api_V1_ClearRoomRequest()
        req.roomID = room
        let _ = try client.clearRoom(req, callOptions: defaultCallOptions).response.wait()
    }
    
    public func ChatInRoom(room: Int64, message: String, handler: @escaping (APIRoomMessage, Bool) -> Void) throws {
        var req = Api_V1_ChatRequest()
        req.roomID = room
        req.newRequest = message
        
        var reply: APIRoomMessage?
        let _ = client.chatInRoom(req, callOptions: defaultCallOptions, handler: { resp in
            if reply == nil {
                reply = APIRoomMessage(
                    id: resp.requestID, namespace: "", // TODO: need a namespace
                    roomid: room, sender: resp.sender, message: resp.responseMessage,
                    sendAt: resp.sendAt.date, createdAt: resp.createdAt.date)
            }
            handler(reply!, true)
        })
        
        if reply == nil {
            throw RepositoryError.streamBroken
        }
        handler(reply!, false)
    }
}
