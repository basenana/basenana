//
//  Reducer.swift
//  Domain
//
//  Created by Hypo on 2024/9/21.
//


@available(macOS 14.0, *)
extension StateStore {
    func reducer(action: AppAction) -> Task<AppAction?, Error>? {
        switch action {
        case .alert(msg: let msg):
            if let hasMsg = msg {
                alert.display(msg: hasMsg)
            } else {
                alert.reset()
            }
            return nil

        case .setFsInfo(fsInfo: let fsInfo):
            self.fsInfo = fsInfo
            return nil

        case .gotoDestination(to: let to):
            destinations.append(to)
            return nil

        case .setDestination(to: let to):
            if destinations == to {
                return nil
            }
            if destinations.isEmpty {
                destinations = to
                return nil
            }
            destinations.removeAll()
            return Task {
                try await Task.sleep(nanoseconds: 1000)
                return .updateDestination(to: to)
            }
        case .updateDestination(to: let to):
            destinations = to
            return nil
            
        case .updateSidebarSelection(select: let select):
            sidebarSelection = select
            return nil
        }
    }
}
