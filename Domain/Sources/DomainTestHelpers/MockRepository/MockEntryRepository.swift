//
//  MockEntryRepository.swift
//  Entry
//
//  Created by Hypo on 2024/9/22.
//

import SwiftUI
import Entities
import RepositoryProtocol


public class MockEntryRepository: EntryRepositoryProtocol {
    public func GroupTree() throws -> any Entities.Group {
        throw RepositoryError.unimplement
    }
    
    public func RootEntry() throws -> any Entities.EntryDetail {
        throw RepositoryError.unimplement
    }
    
    public func FindEntry(parent: Int64, name: String) throws -> any Entities.EntryDetail {
        throw RepositoryError.unimplement
    }
    
    public func GetEntryDetail(entry: Int64) throws -> any Entities.EntryDetail {
        throw RepositoryError.unimplement
    }
    
    public func CreateEntry(entry: Entities.EntryCreate) throws -> any Entities.EntryInfo {
        throw RepositoryError.unimplement
    }
    
    public func UpdateEntry(entry: Entities.EntryUpdate) throws -> any Entities.EntryDetail {
        throw RepositoryError.unimplement
    }
    
    public func DeleteEntries(entrys: [Int64]) throws {
        throw RepositoryError.unimplement
    }
    
    public func ListGroupChildren(filter: Entities.EntryFilter) throws -> [any Entities.EntryInfo] {
        throw RepositoryError.unimplement
    }
    
    public func ChangeParent(entry: Int64, newParent: Int64, option: Entities.ChangeParentOption) throws {
        throw RepositoryError.unimplement
    }
    
    public func AddProperty(entry: Int64, key: String, val: String) throws {
        throw RepositoryError.unimplement
    }
    
    public func UpdateProperty(entry: Int64, key: String, val: String) throws {
        throw RepositoryError.unimplement
    }
    
    public func DeleteProperty(entry: Int64, key: String) throws {
        throw RepositoryError.unimplement
    }
    
    
    public init(){}
    
    
}
