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
    case groupsChildren(uri: String?, id: Int64?, page: Int64?, pageSize: Int64?, sort: String?, order: String?)
    case groupsTree
    case filesContent(uri: String?, id: Int64?)
    case filesUpload(uri: String?, id: Int64?)
    case messages(all: Bool)
    case messagesRead
    case workflows
    case workflow(id: String)
    case workflowJobs(id: String)
    case workflowJob(id: String, jobId: String)
    case workflowJobPause(id: String, jobId: String)
    case workflowJobResume(id: String, jobId: String)
    case workflowJobCancel(id: String, jobId: String)
    case workflowTrigger(id: String)
    case workflowUpdate(id: String)
    case workflowDelete(id: String)
    case configsGroup(group: String)
    case config(group: String, name: String)
    case configSet(group: String, name: String)
    case configDelete(group: String, name: String)

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
        case .entriesUpdate, .entriesDelete:
            return "/api/v1/entries"
        case .entriesParent:
            return "/api/v1/entries/parent"
        case .entriesProperty:
            return "/api/v1/entries/property"
        case .entriesDocument:
            return "/api/v1/entries/document"
        case .entriesBatchDelete:
            return "/api/v1/entries/batch-delete"
        case .groupsChildren:
            return "/api/v1/groups/children"
        case .groupsTree:
            return "/api/v1/groups/tree"
        case .filesContent:
            return "/api/v1/files/content"
        case .filesUpload:
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
        case .workflowJob(let id, let jobId):
            return "/api/v1/workflows/\(id)/jobs/\(jobId)"
        case .workflowJobPause(let id, let jobId):
            return "/api/v1/workflows/\(id)/jobs/\(jobId)/pause"
        case .workflowJobResume(let id, let jobId):
            return "/api/v1/workflows/\(id)/jobs/\(jobId)/resume"
        case .workflowJobCancel(let id, let jobId):
            return "/api/v1/workflows/\(id)/jobs/\(jobId)/cancel"
        case .workflowTrigger(let id):
            return "/api/v1/workflows/\(id)/trigger"
        case .workflowUpdate(let id):
            return "/api/v1/workflows/\(id)"
        case .workflowDelete(let id):
            return "/api/v1/workflows/\(id)"
        case .configsGroup(let group):
            return "/api/v1/configs/\(group)"
        case .config(let group, let name):
            return "/api/v1/configs/\(group)/\(name)"
        case .configSet(let group, let name):
            return "/api/v1/configs/\(group)/\(name)"
        case .configDelete(let group, let name):
            return "/api/v1/configs/\(group)/\(name)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .healthCheck, .entriesDetails, .groupsChildren, .groupsTree, .filesContent, .messages, .workflows, .workflow, .workflowJobs, .workflowJob, .configsGroup, .config:
            return .get
        case .filesUpload:
            return .post
        case .entriesCreate, .entriesBatchDelete, .entriesSearch, .messagesRead, .workflowTrigger:
            return .post
        case .entriesUpdate, .entriesParent, .entriesProperty, .entriesDocument, .workflowUpdate, .configSet:
            return .put
        case .entriesDelete, .workflowDelete, .configDelete:
            return .delete
        case .workflowJobPause, .workflowJobResume, .workflowJobCancel:
            return .post
        }
    }

    func queryItems() -> [URLQueryItem] {
        var items: [URLQueryItem] = []

        switch self {
        case .entriesDetails(let uri, let id), .entriesUpdate(let uri, let id), .entriesDelete(let uri, let id):
            if let uri = uri { items.append(URLQueryItem(name: "uri", value: encodeURI(uri))) }
            if let id = id { items.append(URLQueryItem(name: "id", value: String(id))) }

        case .entriesParent(let uri, let id, _):
            if let uri = uri { items.append(URLQueryItem(name: "uri", value: encodeURI(uri))) }
            if let id = id { items.append(URLQueryItem(name: "id", value: String(id))) }

        case .entriesProperty(let uri, let id), .entriesDocument(let uri, let id):
            if let uri = uri { items.append(URLQueryItem(name: "uri", value: encodeURI(uri))) }
            if let id = id { items.append(URLQueryItem(name: "id", value: String(id))) }

        case .entriesSearch:
            break

        case .groupsChildren(let uri, let id, let page, let pageSize, let sort, let order):
            if let uri = uri { items.append(URLQueryItem(name: "uri", value: encodeURI(uri))) }
            if let id = id { items.append(URLQueryItem(name: "id", value: String(id))) }
            if let page = page { items.append(URLQueryItem(name: "page", value: String(page))) }
            if let pageSize = pageSize { items.append(URLQueryItem(name: "page_size", value: String(pageSize))) }
            if let sort = sort { items.append(URLQueryItem(name: "sort", value: sort)) }
            if let order = order { items.append(URLQueryItem(name: "order", value: order)) }

        case .filesContent(let uri, let id), .filesUpload(let uri, let id):
            if let uri = uri { items.append(URLQueryItem(name: "uri", value: encodeURI(uri))) }
            if let id = id { items.append(URLQueryItem(name: "id", value: String(id))) }

        case .messages(let all):
            items.append(URLQueryItem(name: "all", value: String(all)))

        default:
            break
        }

        return items
    }

    private func encodeURI(_ uri: String) -> String {
        // URLQueryItem does not encode + (it has special meaning in query strings).
        // We manually encode + to %2B, and let the backend handle other encodings.
        return uri.replacingOccurrences(of: "+", with: "%2B")
    }
}
