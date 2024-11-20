//
//  Container.swift
//  basenana
//
//  Created by Hypo on 2024/11/20.
//

import Swinject
import AppState
import RepositoryProtocol
import UseCaseProtocol
import Repositories
import UseCase
import GroupTable
import DocumentRead

extension macOSContentView{
    let container: Container = {
        let container = Container()
        return container
    }()
}


//    // AppState
//    static let store = Factory {
//        StateStore.empty
//    }
//
//    // Network
//    static let entryAPI = Factory<EntriesClientProtocol> {
//        EntriesC
//    }
//
//    // ViewModels
//    static let treeViewModel = Factory {
//        TreeViewModel(
//            store: store,
//            treeUsecase: entryTreeUseCase.callAsFunction(),
//            entryUsecase: entryUseCase.callAsFunction())
//    }
//
//    static let documentListViewModel = Factory {
////        DocumentListViewModel()
//    }
//    
//    static let inboxViewModel = Factory {
////        InboxViewModel()
//    }
//
//    // Repositories
//    static let entryRepository = Factory<EntryRepositoryProtocol> {
//    }
//    static let documentRepository = Factory<DocumentRepositoryProtocol> {
//    }
//    static let inboxRepository = Factory<InboxRepositoryProtocol> {
//    }
//    static let fileRepository = Factory<FileRepositoryProtocol> {
//    }
//
//    // UseCases
//    static let entryUseCase = Factory<EntryUseCaseProtocol> {
//        EntryUseCase(entryRepo: entryRepository.callAsFunction())
//    }
//    static let entryTreeUseCase = Factory<EntryTreeUseCaseProtocol> {
//        EntryTreeUseCase(entryRepo: entryRepository.callAsFunction())
//    }
//    static let documentUseCase = Factory<DocumentUseCaseProtocol> {
//        DocumentUseCase(docRepo: documentRepository.callAsFunction(), entryRepo: entryRepository.callAsFunction())
//    }
//    static let inboxUseCase = Factory<InboxUseCaseProtocol> {
//        InboxUseCase(inboxRepo: inboxRepository.callAsFunction(), entryRepo: entryRepository.callAsFunction(), fileRepo: fileRepository.callAsFunction())
//    }
