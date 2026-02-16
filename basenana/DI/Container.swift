//
//  Container.swift
//  basenana
//
//  Created by Hypo on 2024/11/20.
//

import Swinject
import Domain
import Domain
import Data
import Data
import Domain
import Domain
import Data
import Feature


@MainActor
class DIContainer {
    let c: Container

    private var state: StateStore
    private var environment: Environment = Environment.shared

    init(state: StateStore) {
        self.state = state
        self.c = Container()

        // ViewModels
        self.c.register(TreeViewModel.self) { r in
            TreeViewModel(store: state, entryUsecase: r.resolve(EntryUseCaseProtocol.self)!)
        }.inObjectScope(.container)
        self.c.register(GroupTableViewModel.self) { r in
            GroupTableViewModel(
                store: state,
                entryUsecase: r.resolve(EntryUseCaseProtocol.self)!,
                fileRepository: r.resolve(FileRepositoryProtocol.self)!,
                documentUsecase: r.resolve(DocumentUseCaseProtocol.self)!,
                syncUseCase: r.resolve(EntrySyncUseCase.self)!
            )
        }
        self.c.register(DocumentListViewModel.self, name: DocumentPrespective.marked.Title){ r in
            DocumentListViewModel(
                prespective: .marked,
                store: state,
                usecase: r.resolve(DocumentUseCaseProtocol.self)!,
                fileRepository: r.resolve(FileRepositoryProtocol.self)!
            )
        }//.inObjectScope(.container)
        self.c.register(DocumentListViewModel.self, name: DocumentPrespective.unread.Title){ r in
            DocumentListViewModel(
                prespective: .unread,
                store: state,
                usecase: r.resolve(DocumentUseCaseProtocol.self)!,
                fileRepository: r.resolve(FileRepositoryProtocol.self)!
            )
        }//.inObjectScope(.container)
        self.c.register(DocumentReadViewModel.self) { r, uri in
            DocumentReadViewModel(
                uri: uri,
                store: state,
                usecase: r.resolve(DocumentUseCaseProtocol.self)!,
                fileRepository: r.resolve(FileRepositoryProtocol.self)!
            )
        }
        self.c.register(WorkflowListViewModel.self) { r in
            WorkflowListViewModel(store: state, usecase: r.resolve(WorkflowUseCaseProtocol.self)!)
        }
        self.c.register(WorkflowDetailViewModel.self) { r, wfID in
            WorkflowDetailViewModel(workflow: wfID, store: state, usecase: r.resolve(WorkflowUseCaseProtocol.self)!)
        }
        self.c.register(WorkflowCreateViewModel.self) { r in
            WorkflowCreateViewModel(usecase: r.resolve(WorkflowUseCaseProtocol.self)!)
        }
        self.c.register(SearchViewModel.self) { r in
            SearchViewModel(store: state, searchUseCase: r.resolve(SearchUseCaseProtocol.self)!)
        }

        // UseCases
        self.c.register(EntrySyncUseCase.self) { r in
            EntrySyncUseCase(store: state)
        }.inObjectScope(.container)
        self.c.register(EntryUseCaseProtocol.self) { r in
            EntryUseCase(
                entryRepo: r.resolve(EntryRepositoryProtocol.self)!,
                fileRepo: r.resolve(FileRepositoryProtocol.self)!,
                syncUseCase: r.resolve(EntrySyncUseCase.self)!
            )
        }.inObjectScope(.container)
        self.c.register(DocumentUseCaseProtocol.self) { r in
            DocumentUseCase(entryRepo: r.resolve(EntryRepositoryProtocol.self)!)
        }.inObjectScope(.container)
        self.c.register(SearchUseCaseProtocol.self) { r in
            SearchUseCase(entryRepo: r.resolve(EntryRepositoryProtocol.self)!)
        }.inObjectScope(.container)
        self.c.register(WorkflowUseCaseProtocol.self) { r in
            WorkflowUseCase(repo: r.resolve(WorkflowRepositoryProtocol.self)!, entryRepo: r.resolve(EntryRepositoryProtocol.self)!)
        }.inObjectScope(.container)
        self.c.register(FetchWebPageUseCaseProtocol.self) { r in
            FetchWebPageUseCase(entryUsecase: r.resolve(EntryUseCaseProtocol.self)!, setting: GeneralSetting())
        }.inObjectScope(.container)
        self.c.register(FridayUseCaseProtocol.self) { r in
            FridayUseCase(repository: r.resolve(FridayRepositoryProtocol.self)!)
        }.inObjectScope(.container)

        // Repositories
        self.c.register(EntryRepositoryProtocol.self) { r in
            EntryRepository(core: r.resolve(EntriesClientProtocol.self)!)
        }.inObjectScope(.container)
        self.c.register(FileRepositoryProtocol.self) { r in
            FileRepository(core: r.resolve(FileClientProtocol.self)!)
        }.inObjectScope(.container)
        self.c.register(WorkflowRepositoryProtocol.self) { r in
            WorkflowRepository(core: r.resolve(WorkflowClientProtocol.self)!)
        }.inObjectScope(.container)
        self.c.register(FridayRepositoryProtocol.self) { r in
            FridayRepository(client: r.resolve(FridayClientProtocol.self)!)
        }.inObjectScope(.container)

        // Clients
        self.c.register(EntriesClientProtocol.self) { r in
            EntriesClient(apiClient: self.environment.restAPIClient!.apiClient)
        }.inObjectScope(.container)
        self.c.register(FileClientProtocol.self) { r in
            FileClient(apiClient: self.environment.restAPIClient!.apiClient)
        }.inObjectScope(.container)
        self.c.register(WorkflowClientProtocol.self) { r in
            WorkflowClient(apiClient: self.environment.restAPIClient!.apiClient)
        }.inObjectScope(.container)
        self.c.register(FridayClientProtocol.self) { r in
            FridayClient(apiClient: self.environment.restAPIClient!.apiClient)
        }.inObjectScope(.container)
    }
}
