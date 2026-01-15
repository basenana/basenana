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

struct PropertiesResponse<T: Decodable>: Decodable {
    let properties: T
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
    let properties: PropertyRequest?
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

struct UpdateEntryRequest: Encodable {
    let name: String?
    let aliases: String?
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

struct PropertyRequest: Encodable {
    let tags: [String]?
    let properties: [String: String]?
}

struct DocumentRequest: Encodable {
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

    enum CodingKeys: String, CodingKey {
        case title, author, year, source, abstract, notes, keywords,
             url, site_name, site_url, header_image, unread, marked, publish_at
    }
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

struct WorkflowTriggerRSSDTO: Decodable {
    let feed: String?
    let interval: Int?
}

struct WorkflowTriggerIntervalDTO: Decodable {
    let interval: Int?
}

struct WorkflowTriggerLocalFileWatchDTO: Decodable {
    let path: String?
}

struct WorkflowTriggerDTO: Decodable {
    let rss: WorkflowTriggerRSSDTO?
    let interval: Int?
    let local_file_watch: WorkflowTriggerLocalFileWatchDTO?
}

struct WorkflowNodeInputDTO: Decodable {
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
            if let value = try? container.decodeIfPresent(String.self, forKey: key) {
                otherFields[key.stringValue] = value
            }
        }
        self.otherFields = otherFields
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
        default: return nil
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
        default: return nil
        }
    }

    enum CodingKeys: String, CodingKey {
        case source, feed, file_path, site_name, site_url, title, url, document, parent_uri
    }
}

struct WorkflowNodeMatrixDTO: Decodable {
    let data: [String: String]?
}

struct WorkflowNodeDTO: Decodable {
    let name: String
    let type: String
    let params: [String: String]?
    let input: WorkflowNodeInputDTO?
    let next: String?
    let matrix: WorkflowNodeMatrixDTO?
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

// MARK: - Empty Response

struct VoidResponse: Decodable { }
