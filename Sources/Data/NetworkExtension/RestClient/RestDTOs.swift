//
//  RestDTOs.swift
//  Data
//
//  REST API Response DTOs
//

import Foundation

// MARK: - Entry DTOs

struct EntryDetailDTO: Decodable {
    let uri: String
    let entry: Int64
    let name: String
    let aliases: String?
    let kind: String
    let is_group: Bool
    let size: Int64
    let version: Int64?
    let namespace: String?
    let storage: String?
    let parent: Int64?
    let access: AccessDTO?
    let property: PropertyWrapperDTO?
    let document: DocumentWrapperDTO?
    let created_at: Date?
    let changed_at: Date?
    let modified_at: Date?
    let access_at: Date?
}

struct AccessDTO: Decodable {
    let uid: Int64
    let gid: Int64
    let permissions: [String]
}

struct PropertyWrapperDTO: Decodable {
    let tags: [String]?
    let properties: [String: String]?
}

struct FridayPropertyDTO: Decodable {
    let summary: String?
}

struct PropertiesResponse<T: Decodable>: Decodable {
    let properties: T
}

struct FridayPropertyResponse: Decodable {
    let property: FridayPropertyDTO
}

struct DocumentWrapperDTO: Decodable {
    let title: String?
    let author: String?
    let year: String?
    let source: String?
    let abstract: String?
    let keywords: [String]?
    let notes: String?
    let unread: Bool?
    let marked: Bool?
    let publish_at: Date?
    let url: String?
    let header_image: String?
    let site_name: String?
    let site_url: String?
}

struct EntryInfoDTO: Decodable {
    let uri: String
    let entry: Int64
    let name: String
    let kind: String
    let is_group: Bool
    let size: Int64
    let created_at: Date?
    let changed_at: Date?
    let modified_at: Date?
    let access_at: Date?
    let document: DocumentWrapperDTO?
}

struct EntriesResponse: Decodable {
    let entries: [EntryInfoDTO]
    let pagination: EntriesPagination?
}

struct EntriesPagination: Decodable {
    let page: Int64
    let page_size: Int64
}

struct EntryDetailResponse: Decodable {
    let entry: EntryDetailDTO
}

struct CreateEntryRequest: Encodable {
    let uri: String
    let kind: String?
    let rss: RSSConfigRequest?
    let filter: FilterRequest?
    let properties: EntryPropertiesRequest?
    let document: DocumentCreateRequest?
}

struct RSSConfigRequest: Encodable {
    let feed: String
    let site_name: String
    let site_url: String
    let file_type: String
}

struct FilterRequest: Encodable {
    let cel_pattern: String?
}

struct DocumentCreateRequest: Encodable {
    let title: String?
    let author: String?
    let year: String?
    let source: String?
    let abstract: String?
    let keywords: [String]?
    let notes: String?
    let url: String?
    let header_image: String?
}

struct BatchDeleteRequest: Encodable {
    let uri_list: [String]
}

struct BatchDeleteResponse: Decodable {
    let deleted: [String]
    let message: String?
}

struct ChangeParentRequest: Encodable {
    let entry_uri: String
    let new_entry_uri: String
    let replace: Bool?
    let exchange: Bool?
}

// MARK: - Entry Selector (for uri/id selection)

public struct EntrySelectorRequest: Encodable {
    public let uri: String?
    public let id: Int64?

    public init(uri: String? = nil, id: Int64? = nil) {
        self.uri = uri
        self.id = id
    }
}

public struct EntryDetailRequest: Encodable {
    public let uri: String?
    public let id: Int64?

    public init(uri: String? = nil, id: Int64? = nil) {
        self.uri = uri
        self.id = id
    }
}

public struct DeleteEntryRequest: Encodable {
    public let uri: String?
    public let id: Int64?

    public init(uri: String? = nil, id: Int64? = nil) {
        self.uri = uri
        self.id = id
    }
}

public struct GroupChildrenRequest: Encodable {
    public let uri: String?
    public let id: Int64?
    public let page: Int64?
    public let pageSize: Int64?
    public let sort: String?
    public let order: String?

    public init(uri: String? = nil, id: Int64? = nil, page: Int64? = nil, pageSize: Int64? = nil, sort: String? = nil, order: String? = nil) {
        self.uri = uri
        self.id = id
        self.page = page
        self.pageSize = pageSize
        self.sort = sort
        self.order = order
    }

    enum CodingKeys: String, CodingKey {
        case uri, id, page, sort, order
        case pageSize = "page_size"
    }
}

public struct FileContentRequest: Encodable {
    public let uri: String?
    public let id: Int64?

    public init(uri: String? = nil, id: Int64? = nil) {
        self.uri = uri
        self.id = id
    }
}

public struct FridayPropertyRequest: Encodable {
    public let uri: String?
    public let id: Int64?

    public init(uri: String? = nil, id: Int64? = nil) {
        self.uri = uri
        self.id = id
    }
}

public struct PropertyRequest: Encodable {
    public let uri: String?
    public let id: Int64?
    public let tags: [String]?
    public let properties: [String: String]?
}

public struct EntryPropertiesRequest: Encodable {
    public let tags: [String]?
    public let properties: [String: String]?
}

public struct UpdateEntryRequest: Encodable {
    public let uri: String?
    public let name: String?
    public let aliases: String?

    public init(uri: String? = nil, name: String? = nil, aliases: String? = nil) {
        self.uri = uri
        self.name = name
        self.aliases = aliases
    }
}

struct DocumentRequest: Encodable {
    let uri: String?
    let id: Int64?
    let title: String?
    let author: String?
    let year: String?
    let source: String?
    let abstract: String?
    let notes: String?
    let keywords: [String]?
    let url: String?
    let site_name: String?
    let site_url: String?
    let header_image: String?
    let unread: Bool?
    let marked: Bool?
    let publish_at: Int64?
}

struct SearchRequest: Encodable {
    let cel_pattern: String
    let page: Int64?
    let page_size: Int64?
    let sort: String?
    let order: String?

    enum CodingKeys: String, CodingKey {
        case cel_pattern, page, page_size, sort, order
    }
}

// MARK: - EntryGroup Tree DTOs

struct GroupTreeNodeDTO: Decodable {
    let name: String
    let uri: String
    let children: [GroupTreeNodeDTO]?
}

struct GroupTreeResponse: Decodable {
    let root: GroupTreeNodeDTO
}

// MARK: - Messages DTOs

struct MessageDTO: Decodable {
    let id: String
    let title: String
    let message: String
    let type: String
    let source: String
    let action: String
    let status: String
    let time: Date
}

struct MessagesResponse: Decodable {
    let messages: [MessageDTO]
}

struct ReadMessagesRequest: Encodable {
    let message_id_list: [String]
}

// MARK: - Workflow DTOs

struct WorkflowDTO: Decodable {
    let id: String
    let name: String
    let enable: Bool?
    let queue_name: String
    let namespace: String?
    let trigger: WorkflowTriggerDTO?
    let nodes: [WorkflowNodeDTO]?
    let created_at: Date
    let updated_at: Date
    let last_triggered_at: Date?
}

struct WorkflowTriggerRSSDTO: Codable {
    let feed: String?
    let interval: Int?
}

struct WorkflowTriggerIntervalDTO: Codable {
    let interval: Int?
}

struct WorkflowTriggerLocalFileWatchDTO: Codable {
    let directory: String?
    let event: String?
    let file_pattern: String?
    let file_types: String?
    let min_file_size: Int?
    let max_file_size: Int?
    let cel_pattern: String?
}

struct WorkflowTriggerDTO: Codable {
    let rss: WorkflowTriggerRSSDTO?
    let interval: Int?
    let local_file_watch: WorkflowTriggerLocalFileWatchDTO?
    let input_parameters: [WorkflowInputParameterDTO]?
}

struct WorkflowInputParameterDTO: Codable {
    let name: String
    let describe: String
    let required: Bool
}

struct WorkflowNodeInputDTO: Codable {
    let source: String?
    let feed: String?
    let file_path: String?
    let site_name: String?
    let site_url: String?
    let title: String?
    let url: String?
    let document: String?
    let parent_uri: String?
    private var otherFields: [String: String]?

    init() {
        self.source = nil
        self.feed = nil
        self.file_path = nil
        self.site_name = nil
        self.site_url = nil
        self.title = nil
        self.url = nil
        self.document = nil
        self.parent_uri = nil
        self.otherFields = nil
    }

    init(from input: APIWorkflowNodeInput) {
        self.source = input.source
        self.feed = input.feed
        self.file_path = input.file_path
        self.site_name = input.site_name
        self.site_url = input.site_url
        self.title = input.title
        self.url = input.url
        self.document = input.document
        self.parent_uri = input.parent_uri
        self.otherFields = input.otherFields
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        source = try container.decodeIfPresent(String.self, forKey: .source)
        feed = try container.decodeIfPresent(String.self, forKey: .feed)
        file_path = try container.decodeIfPresent(String.self, forKey: .file_path)
        site_name = try container.decodeIfPresent(String.self, forKey: .site_name)
        site_url = try container.decodeIfPresent(String.self, forKey: .site_url)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        url = try container.decodeIfPresent(String.self, forKey: .url)
        document = try container.decodeIfPresent(String.self, forKey: .document)
        parent_uri = try container.decodeIfPresent(String.self, forKey: .parent_uri)

        var otherFields: [String: String] = [:]
        for key in container.allKeys {
            if CodingKeys(stringValue: key.stringValue) == nil {
                if let value = try? container.decodeIfPresent(String.self, forKey: key) {
                    otherFields[key.stringValue] = value
                }
            }
        }
        self.otherFields = otherFields.isEmpty ? nil : otherFields
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(source, forKey: .source)
        try container.encodeIfPresent(feed, forKey: .feed)
        try container.encodeIfPresent(file_path, forKey: .file_path)
        try container.encodeIfPresent(site_name, forKey: .site_name)
        try container.encodeIfPresent(site_url, forKey: .site_url)
        try container.encodeIfPresent(title, forKey: .title)
        try container.encodeIfPresent(url, forKey: .url)
        try container.encodeIfPresent(document, forKey: .document)
        try container.encodeIfPresent(parent_uri, forKey: .parent_uri)

        if let otherFields = otherFields {
            for (key, value) in otherFields {
                try container.encode(value, forKey: CodingKeys(stringValue: key)!)
            }
        }
    }

    func getValue(forKey key: String) -> String? {
        switch key {
        case "source": return source
        case "feed": return feed
        case "file_path": return file_path
        case "site_name": return site_name
        case "site_url": return site_url
        case "title": return title
        case "url": return url
        case "document": return document
        case "parent_uri": return parent_uri
        default: return otherFields?[key]
        }
    }

    func getAnyValue(forKey key: String) -> Any? {
        switch key {
        case "source": return source
        case "feed": return feed
        case "file_path": return file_path
        case "site_name": return site_name
        case "site_url": return site_url
        case "title": return title
        case "url": return url
        case "document": return document
        case "parent_uri": return parent_uri
        default: return otherFields?[key]
        }
    }

    enum CodingKeys: String, CodingKey {
        case source, feed, file_path, site_name, site_url, title, url, document, parent_uri
    }
}

struct WorkflowNodeMatrixDTO: Codable {
    let data: [String: String]?
}

struct WorkflowNodeCaseDTO: Codable {
    let value: String
    let next: String
}

struct WorkflowNodeDTO: Codable {
    let name: String
    let type: String
    let params: [String: String]?
    let input: WorkflowNodeInputDTO?
    let next: String?
    let condition: String?
    let branches: [String: String]?
    let cases: [WorkflowNodeCaseDTO]?
    let `default`: String?
    let matrix: WorkflowNodeMatrixDTO?

    enum CodingKeys: String, CodingKey {
        case name, type, params, input, next, condition, branches, cases, matrix
        case `default` = "default"
    }
}

struct WorkflowsResponse: Decodable {
    let workflows: [WorkflowDTO]
    let pagination: EntriesPagination?
}

struct WorkflowResponse: Decodable {
    let workflow: WorkflowDTO
}

struct WorkflowJobStepDTO: Decodable {
    let name: String
    let status: String
    let message: String
}

struct WorkflowJobTargetDTO: Decodable {
    let entries: [String]?
    let parent_entry_id: String?
}

struct WorkflowJobDTO: Decodable {
    let id: String
    let workflow: String
    let trigger_reason: String
    let status: String
    let message: String
    let queue_name: String
    let target: WorkflowJobTargetDTO?
    let steps: [WorkflowJobStepDTO]?
    let created_at: Date
    let updated_at: Date
    let start_at: Date?
    let finish_at: Date?
}

struct WorkflowJobsResponse: Decodable {
    let jobs: [WorkflowJobDTO]
    let pagination: EntriesPagination?
}

struct TriggerWorkflowRequest: Encodable {
    let uri: String?
    let reason: String?
    let timeout: Int64?
    let parameters: [String: String]?
}

struct CreateWorkflowRequest: Encodable {
    let name: String
    let trigger: WorkflowTriggerDTO
    let nodes: [WorkflowNodeDTO]
    let enable: Bool
    let queue_name: String?
}

struct TriggerWorkflowResponse: Decodable {
    let job_id: String
}

struct WorkflowJobDetailResponse: Decodable {
    let job: WorkflowJobDTO
}

struct UpdateWorkflowRequest: Encodable {
    let name: String?
    let enable: Bool?
    let queue_name: String?
}

// MARK: - Configs DTOs

struct ConfigItemDTO: Decodable {
    let group: String
    let name: String
    let value: String
    let changed_at: Date?
}

struct ConfigsResponse: Decodable {
    let items: [ConfigItemDTO]
}

struct ConfigResponse: Decodable {
    let group: String
    let name: String
    let value: String
}

struct SetConfigRequest: Encodable {
    let value: String
}

struct DeleteConfigResponse: Decodable {
    let group: String
    let name: String
    let deleted: Bool
}

struct DeleteWorkflowResponse: Decodable {
    let message: String
}

// MARK: - File Response

struct FileUploadResponse: Decodable {
    let len: Int64
}

// MARK: - Workflow Plugin DTOs

struct WorkflowPluginParamDTO: Codable {
    let name: String
    let required: Bool
    let defaultValue: String?
    let description: String?
    let options: [String]?

    enum CodingKeys: String, CodingKey {
        case name, required, options
        case defaultValue = "default"
        case description
    }
}

struct WorkflowPluginDTO: Codable {
    let name: String
    let version: String
    let type: String
    let initParameters: [WorkflowPluginParamDTO]?
    let parameters: [WorkflowPluginParamDTO]?

    enum CodingKeys: String, CodingKey {
        case name, version, type
        case initParameters = "init_parameters"
        case parameters
    }
}

struct WorkflowPluginsResponse: Decodable {
    let plugins: [WorkflowPluginDTO]
}

// MARK: - Empty Response

struct VoidResponse: Decodable { }
