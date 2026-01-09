//
//  APIEndpoints.swift
//  Data
//
//  REST API endpoints for NanaFS
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

public enum APIEndpoint {
    case healthCheck
    case entriesDetails(uri: String?, id: Int64?)
    case entriesCreate
    case entriesUpdate(uri: String?, id: Int64?)
    case entriesDelete(uri: String?, id: Int64?)
    case entriesBatchDelete
    case entriesParent(uri: String?, id: Int64?, newUri: String)
    case entriesProperty(uri: String?, id: Int64?)
    case entriesDocument(uri: String?, id: Int64?)
    case entriesSearch
    case groupsChildren(uri: String?, id: Int64?, offset: Int?, limit: Int?, order: String?, desc: Bool?)
    case groupsTree
    case filesContent(uri: String?, id: Int64?)
    case messages(all: Bool)
    case messagesRead
    case workflows
    case workflow(id: String)
    case workflowJobs(id: String)
    case workflowTrigger(id: String)
    case configsGroup(group: String)
    case config(group: String, name: String)

    var path: String {
        switch self {
        case .healthCheck:
            return "/_ping"
        case .entriesDetails:
            return "/api/v1/entries/details"
        case .entriesCreate:
            return "/api/v1/entries"
        case .entriesSearch:
            return "/api/v1/entries/search"
        case .entriesUpdate, .entriesDelete, .entriesParent, .entriesProperty, .entriesDocument:
            return "/api/v1/entries"
        case .entriesBatchDelete:
            return "/api/v1/entries/batch-delete"
        case .groupsChildren:
            return "/api/v1/groups/children"
        case .groupsTree:
            return "/api/v1/groups/tree"
        case .filesContent:
            return "/api/v1/files/content"
        case .messages(let all):
            if all == true {
                return "/api/v1/messages?all=true"
            }
            return "/api/v1/messages"
        case .messagesRead:
            return "/api/v1/messages/read"
        case .workflows:
            return "/api/v1/workflows"
        case .workflow(let id):
            return "/api/v1/workflows/\(id)"
        case .workflowJobs(let id):
            return "/api/v1/workflows/\(id)/jobs"
        case .workflowTrigger(let id):
            return "/api/v1/workflows/\(id)/trigger"
        case .configsGroup(let group):
            return "/api/v1/configs/\(group)"
        case .config(let group, let name):
            return "/api/v1/configs/\(group)/\(name)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .healthCheck, .entriesDetails, .groupsChildren, .groupsTree, .filesContent, .messages, .workflows, .workflow, .workflowJobs, .configsGroup, .config:
            return .get
        case .entriesCreate, .entriesSearch, .messagesRead, .workflowTrigger:
            return .post
        case .entriesUpdate, .entriesParent, .entriesProperty, .entriesDocument:
            return .put
        case .entriesDelete, .entriesBatchDelete:
            return .delete
        }
    }

    func queryItems() -> [URLQueryItem] {
        var items: [URLQueryItem] = []

        switch self {
        case .entriesDetails(let uri, let id):
            if let uri = uri { items.append(URLQueryItem(name: "uri", value: uri)) }
            if let id = id { items.append(URLQueryItem(name: "id", value: String(id))) }

        case .entriesUpdate(let uri, let id), .entriesDelete(let uri, let id):
            if let uri = uri { items.append(URLQueryItem(name: "uri", value: uri)) }
            if let id = id { items.append(URLQueryItem(name: "id", value: String(id))) }

        case .entriesParent(let uri, let id, let newUri):
            if let uri = uri { items.append(URLQueryItem(name: "uri", value: uri)) }
            if let id = id { items.append(URLQueryItem(name: "id", value: String(id))) }
            items.append(URLQueryItem(name: "new_uri", value: newUri))

        case .entriesProperty(let uri, let id), .entriesDocument(let uri, let id):
            if let uri = uri { items.append(URLQueryItem(name: "uri", value: uri)) }
            if let id = id { items.append(URLQueryItem(name: "id", value: String(id))) }

        case .groupsChildren(let uri, let id, let offset, let limit, let order, let desc):
            if let uri = uri { items.append(URLQueryItem(name: "uri", value: uri)) }
            if let id = id { items.append(URLQueryItem(name: "id", value: String(id))) }
            if let offset = offset { items.append(URLQueryItem(name: "offset", value: String(offset))) }
            if let limit = limit { items.append(URLQueryItem(name: "limit", value: String(limit))) }
            if let order = order { items.append(URLQueryItem(name: "order", value: order)) }
            if let desc = desc { items.append(URLQueryItem(name: "desc", value: String(desc))) }

        case .filesContent(let uri, let id):
            if let uri = uri { items.append(URLQueryItem(name: "uri", value: uri)) }
            if let id = id { items.append(URLQueryItem(name: "id", value: String(id))) }

        case .messages(let all):
            items.append(URLQueryItem(name: "all", value: String(all)))

        default:
            break
        }

        return items
    }
}
