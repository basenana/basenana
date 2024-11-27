//
//  Container.swift
//  basenana
//
//  Created by Hypo on 2024/11/20.
//

import Swinject
import AppState
import Entities
import NetworkCore
import NetworkExtension
import RepositoryProtocol
import UseCaseProtocol
import Repositories
import UseCase
import GroupTable
import DocumentRead


@MainActor
class DIContainer {
    let c: Container
    
    private var state: StateStore
    private var environment: Environment
    
    init(state: StateStore, environment: Environment) {
        self.state = state
        self.environment = environment
        self.c = Container()
        
        // ViewModels
        self.c.register(TreeViewModel.self) { r in
            TreeViewModel(store: state, entryUsecase: r.resolve(EntryUseCaseProtocol.self)!)
        }.inObjectScope(.container)
        self.c.register(GroupTableViewModel.self) { r in
            GroupTableViewModel(store: state, entryUsecase: r.resolve(EntryUseCaseProtocol.self)!)
        }
        self.c.register(DocumentListViewModel.self, name: DocumentPrespective.marked.Title){ r in
            DocumentListViewModel(prespective: .marked, store: state, usecase: r.resolve(DocumentUseCaseProtocol.self)!)
        }.inObjectScope(.container)
        self.c.register(DocumentListViewModel.self, name: DocumentPrespective.unread.Title){ r in
            DocumentListViewModel(prespective: .unread, store: state, usecase: r.resolve(DocumentUseCaseProtocol.self)!)
        }.inObjectScope(.container)
        self.c.register(DocumentReadViewModel.self) { r, docID in
            DocumentReadViewModel(docID: docID, store: state, usecase: r.resolve(DocumentUseCaseProtocol.self)!)
        }
        
        // UseCases
        self.c.register(EntryUseCaseProtocol.self) { r in
            EntryUseCase(inboxRepo: r.resolve(InboxRepositoryProtocol.self)!, entryRepo: r.resolve(EntryRepositoryProtocol.self)!, fileRepo: r.resolve(FileRepositoryProtocol.self)!)
        }.inObjectScope(.container)
        self.c.register(DocumentUseCaseProtocol.self) { r in
            DocumentUseCase(docRepo: r.resolve(DocumentRepositoryProtocol.self)!, entryRepo: r.resolve(EntryRepositoryProtocol.self)!)
        }.inObjectScope(.container)

        // Repositories
        self.c.register(EntryRepositoryProtocol.self) { r in
            EntryRepository(core: r.resolve(EntriesClientProtocol.self)!)
        }.inObjectScope(.container)
        self.c.register(DocumentRepositoryProtocol.self) { r in
            DocumentRepository(core: r.resolve(DocumentClientProtocol.self)!)
        }.inObjectScope(.container)
        self.c.register(InboxRepositoryProtocol.self) { r in
            InboxRepository(core: r.resolve(InboxClientProtocol.self)!)
        }.inObjectScope(.container)
        self.c.register(FileRepositoryProtocol.self) { r in
            FileRepository(core: r.resolve(FileClientProtocol.self)!)
        }.inObjectScope(.container)
        
        // Clients
        self.c.register(EntriesClientProtocol.self) { r in
            EntriesClient(clientSet: environment.clientSet!)
        }.inObjectScope(.container)
        self.c.register(DocumentClientProtocol.self) { r in
            DocumentClient(clientSet: environment.clientSet!)
        }.inObjectScope(.container)
        self.c.register(InboxClientProtocol.self) { r in
            InboxClient(clientSet: environment.clientSet!)
        }.inObjectScope(.container)
        self.c.register(FileClientProtocol.self) { r in
            FileClient(clientSet: environment.clientSet!)
        }.inObjectScope(.container)
    }
}
