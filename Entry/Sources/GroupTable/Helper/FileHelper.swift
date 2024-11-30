//
//  FileHelper.swift
//  Entry
//
//  Created by Hypo on 2024/11/26.
//

import Foundation
import AppState
import Entities
import UseCaseProtocol


func uploadFiles(entryUsecase: EntryUseCaseProtocol, store: StateStore, parentID: Int64, files: [URL]) async throws  {
    for file in files {
        try await uploadFile(entryUsecase: entryUsecase, store: store, parentID: parentID, file: file)
    }
}

func uploadFile(entryUsecase: EntryUseCaseProtocol, store: StateStore, parentID: Int64, file: URL) async throws  {
    if try file.resourceValues(forKeys: [.isDirectoryKey]).isDirectory ?? false {
        throw BizError.isGroup
    }
    
    let en = try await entryUsecase.UploadFile(parent: parentID, file: file)
    print("upload new entry \(en.id)/\(en.name)")
    return
}
