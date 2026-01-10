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
    let created_at: Date
    let changed_at: Date
    let modified_at: Date
    let access_at: Date
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
}

struct EntryInfoDTO: Decodable {
    let uri: String
    let entry: Int64
    let name: String
    let kind: String
    let is_group: Bool
    let size: Int64
    let created_at: Date
    let changed_at: Date
    let modified_at: Date
    let access_at: Date
    let document: DocumentWrapperDTO?
}

struct EntriesResponse: Decodable {
    let entries: [EntryInfoDTO]
}

struct EntryDetailResponse: Decodable {
    let entry: EntryDetailDTO
}

struct CreateEntryRequest: Encodable {
    let uri: String
    let kind: String?
    let rss: RSSConfigRequest?
    let filter: FilterRequest?
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

struct UpdateEntryRequest: Encodable {
    let name: String?
    let aliases: String?
}

struct BatchDeleteRequest: Encodable {
    let uri_list: [String]
}

struct ChangeParentRequest: Encodable {
    let new_entry_uri: String
    let replace: Bool?
    let exchange: Bool?
}

struct PropertyRequest: Encodable {
    let tags: [String]?
    let properties: [String: String]?
}

struct DocumentRequest: Encodable {
    let unread: Bool?
    let marked: Bool?
}

struct SearchRequest: Encodable {
    let cel_pattern: String
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
    let queue_name: String
    let created_at: Date
    let updated_at: Date
    let last_triggered_at: Date?
}

struct WorkflowsResponse: Decodable {
    let workflows: [WorkflowDTO]
}

struct WorkflowJobStepDTO: Decodable {
    let name: String
    let status: String
    let message: String
}

struct WorkflowJobTargetDTO: Decodable {
    let entries: [String]?
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
