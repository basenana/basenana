//
//  DialogueClient.swift
//
//
//  Created by Hypo on 2024/9/16.
//

import Foundation
import Entities
import GRPC
import NetworkCore


@available(macOS 11.0, *)
public class DialogueClient: DialogueClientProtocol {
    
    var client: Api_V1_RoomAsyncClientProtocol
    
    public init(clientSet: ClientSet) {
        self.client = clientSet.dialogue
    }
    
    public func ListRoomes(entry: Int64) async throws -> [NetworkCore.APIRoom] {
        var result: [NetworkCore.APIRoom] = []
        do {
            let resp = try await client.listRooms(
                Api_V1_ListRoomsRequest(), callOptions: defaultCallOptions)
            for room in resp.rooms {
                result.append(room.toRoom())
            }
        } catch let error as GRPCStatusTransformable where error.makeGRPCStatus().code == .cancelled {
            throw RepositoryError.canceled
        } catch {
            throw error
        }
        
        return result
    }
    
    public func OpenRoom(entry: Int64, room: Int64, option: Entities.RoomOption) async throws -> NetworkCore.APIRoom {
        var req = Api_V1_OpenRoomRequest()
        req.entryID = entry
        req.roomID = room
        req.option = Api_V1_OpenRoomRequest.Option()
        req.option.prompt = option.prompt
        do {
            let resp = try await client.openRoom(req, callOptions: defaultCallOptions)
            return resp.room.toRoom()
        } catch let error as GRPCStatusTransformable where error.makeGRPCStatus().code == .cancelled {
            throw RepositoryError.canceled
        } catch {
            throw error
        }
    }
    
    public func UpdateRoom(room: Int64, option: Entities.RoomOption) async throws {
        var req = Api_V1_UpdateRoomRequest()
        req.roomID = room
        req.prompt = option.prompt
        do {
            let resp = try await client.updateRoom(req, callOptions: defaultCallOptions)
            let _ = resp.roomID
        } catch let error as GRPCStatusTransformable where error.makeGRPCStatus().code == .cancelled {
            throw RepositoryError.canceled
        } catch {
            throw error
        }
    }
    
    public func DeleteRoom(room: Int64) async throws {
        var req = Api_V1_DeleteRoomRequest()
        req.roomID = room
        do {
            let _ = try await client.deleteRoom(req, callOptions: defaultCallOptions)
        } catch let error as GRPCStatusTransformable where error.makeGRPCStatus().code == .cancelled {
            throw RepositoryError.canceled
        } catch {
            throw error
        }
    }
    
    public func ClearRoom(room: Int64) async throws {
        var req = Api_V1_ClearRoomRequest()
        req.roomID = room
        do {
            let _ = try await client.clearRoom(req, callOptions: defaultCallOptions)
        } catch let error as GRPCStatusTransformable where error.makeGRPCStatus().code == .cancelled {
            throw RepositoryError.canceled
        } catch {
            throw error
        }
    }
    
    public func ChatInRoom(room: Int64, message: String, handler: @escaping (APIRoomMessage, Bool) async -> Void) async throws {
        var req = Api_V1_ChatRequest()
        req.roomID = room
        req.newRequest = message
        
        var reply: APIRoomMessage?
        var stream = client.chatInRoom(req, callOptions: defaultCallOptions).makeAsyncIterator()
        
        do {
            while let resp = try await stream.next() {
                if reply == nil {
                    reply = APIRoomMessage(
                        id: resp.requestID, namespace: "", // TODO: need a namespace
                        roomid: room, sender: resp.sender, message: resp.responseMessage,
                        sendAt: resp.sendAt.date, createdAt: resp.createdAt.date)
                }
                await handler(reply!, true)
            }
            
            if reply == nil {
                throw RepositoryError.streamBroken
            }
            await handler(reply!, false)
        } catch let error as GRPCStatusTransformable where error.makeGRPCStatus().code == .cancelled {
            throw RepositoryError.canceled
        } catch {
            throw error
        }
    }
}
