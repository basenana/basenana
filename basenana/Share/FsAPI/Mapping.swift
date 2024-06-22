//
//  Trans.swift
//  basenana
//
//  Created by Hypo on 2024/6/20.
//

import Foundation


extension Api_V1_EntryInfo {
    func toEntry() -> EntryInfoModel {
        return EntryInfoModel(
            id: self.id, name: self.name, kind: self.kind, isGroup: self.isGroup, size: self.size, parentID: self.parentID,
            createdAt: self.changedAt.date, changedAt: self.changedAt.date, modifiedAt: self.modifiedAt.date, accessAt: self.accessAt.date
        )
    }
    
    func toGroup() -> GroupModel? {
        if self.isGroup {
            return GroupModel(parentID: parentID, groupID: self.id, groupName: self.name)
        }
        return nil
    }
}


extension Api_V1_EntryDetail {
    func toEntry(properties: [Api_V1_Property]) -> EntryDetailModel {
        var enProperties: [EntryPropertyModel]=[]
        for property in properties {
            enProperties.append(EntryPropertyModel(key: property.key, value: property.value, encoded: property.encoded))
        }
        return EntryDetailModel(
            id: self.id, name: self.name, aliases: self.aliases, parent: self.parent.id,
            kind: self.kind, isGroup: self.isGroup, size: self.size, version: self.version,
            namespace: self.namespace, storage: self.storage,
            uid: self.access.uid, gid: self.access.gid, permissions: self.access.permissions,
            createdAt: self.changedAt.date, changedAt: self.changedAt.date, modifiedAt: self.modifiedAt.date, accessAt: self.accessAt.date,
            properties: enProperties
        )
    }
    
    static func fromEntryDetail(en: EntryDetailModel) -> Api_V1_EntryDetail {
        var entry = Api_V1_EntryDetail()
        entry.id = en.id
        // update name only
        entry.name = en.name != "" ? en.name : ""
        return entry
    }
}

extension Api_V1_Property {
    func toEntryProperty() -> EntryPropertyModel {
        return EntryPropertyModel(key: self.key, value: self.value, encoded: self.encoded)
    }
}


extension Api_V1_DocumentInfo {
    func toDocuement() -> DocumentInfoModel{
        return DocumentInfoModel(
            id: self.id, oid: self.entryID, parentId: self.parentEntryID, name: self.name, namespace: self.namespace, source: self.source,
            marked: self.marked, unread: self.unread, subContent: self.subContent,
            createdAt: self.createdAt.date, changedAt: self.changedAt.date)
    }
}


extension Api_V1_DocumentDescribe {
    func toDocuement() -> DocumentDetailModel{
        return DocumentDetailModel(
            id: self.id, oid: self.entryID, parentId: self.parentEntryID, name: self.name, namespace: self.namespace, source: self.source,
            marked: self.marked, unread: self.unread, keyWords: self.keyWords, content: self.htmlContent, summary: self.summary,
            createdAt: self.createdAt.date, changedAt: self.changedAt.date)
    }
}


extension Api_V1_RoomInfo {
    func room() -> RoomModel {
        let messages = self.messages
        var ms: [RoomMessageModel] = []
        for message in messages {
            ms.append(RoomMessageModel(
                id: message.id,
                namespace: message.namespace,
                roomid: message.id,
                sender: message.sender,
                message: message.message,
                sendAt: message.sendAt.date,
                createdAt: message.createdAt.date
            ))
        }
        return RoomModel(
            id: self.id, namespace: self.namespace, oid: self.entryID,
            title: self.title, prompt: self.prompt,
            createdAt: self.createdAt.date, messages: ms
        )
    }
}
