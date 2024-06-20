//
//  Store.swift
//  basenana
//
//  Created by Hypo on 2024/6/19.
//

import Foundation



@Observable
@MainActor
final class Store {
    var state = AppState()
    private let environment = AppEnvironment()
    
    func dispatch(_ action: AppAction) {
        log.info("recive new aciton \(action)")
        Task {
            if let task = reducer(state: &state, action: action, environment: environment) {
                do {
                    if let action = try await task.value{
                        dispatch(action)
                    }
                } catch {
                    log.error("dispatch action \(action) error: \(error)")
                    dispatch(.alert(msg: "\(error)"))
                }
            }
        }
    }
}

extension Store {
    static let share = Store()
}

