//
//  GroupTree.swift
//  AppState
//
//  Created by Hypo on 2024/9/21.
//

import os
import SwiftUI
import Domain


@Observable
class GroupTree {
    static var shared = GroupTree()

    var children: [GroupLeaf]? = []
    var allGroups: [String: GroupLeaf] = [:]

    var root: EntryGroup = UnknownGroup.shared
    var inbox: EntryGroup = UnknownGroup.shared

    private static let logger = Logger(
            subsystem: Bundle.main.bundleIdentifier!,
            category: String(describing: InboxViewModel.self)
        )

    private init() {}

    func reset(root: EntryGroup) {
        self.root = root

        children = []
        allGroups = [:]

        guard root.children != nil else {
            return
        }

        for grp in root.children! where !grp.groupName.hasPrefix(".") {
            children!.append(paresGroupTreeChild(group: grp))
        }

        Self.logger.info("reset group tree root=\(root.id)")
    }

    func paresGroupTreeChild(group: EntryGroup) -> GroupLeaf {
        let gvl = GroupLeaf(group: group)
        allGroups[gvl.uri] = gvl


        guard let children = group.children else {
            return gvl
        }

        if !children.isEmpty {
            gvl.children = []
            for grp in children where !grp.groupName.hasPrefix(".") {
                gvl.children?.append(paresGroupTreeChild(group: grp))
            }
        }
        return gvl
    }

    func getGroup(uri: String) -> GroupLeaf? {
        return allGroups[uri]
    }

    func changeParent(uri: String, newParentUri: String) {
        if let leaf = self.allGroups[uri] {
            if leaf.parentUri == newParentUri {
                return
            }
            if let newParent = self.allGroups[newParentUri]{
                for exist in newParent.children ?? [] {
                    if exist.groupName == leaf.groupName {
                        return
                    }
                }
            }
            if isInLoop(uri: uri, newParentUri: newParentUri) {
                return
            }
            self.removeChildGroup(parentUri: leaf.parentUri, childUri: leaf.uri)
            self.addChildGroup(parentUri: newParentUri, child: leaf.group, grandChildren: leaf.children)
            return
        }
        return
    }

    func addChildGroup(parentUri: String, child: EntryGroup, grandChildren: [GroupLeaf]?){
        let newGroup = GroupLeaf(group: child)
        if grandChildren != nil{
            newGroup.children = grandChildren
        }

        if let parent = self.allGroups[parentUri]{
            if parent.children == nil{
                parent.children = [newGroup]
                return
            }

            for ch in parent.children! {
                if ch.groupName == child.groupName {
                    ch.group = child
                    ch.children = grandChildren
                    return
                }
            }

            parent.children!.append(newGroup)
            self.allGroups[child.uri] = newGroup
        }else {
            if children == nil {
                children = []
            }
            allGroups[newGroup.uri] = newGroup
            children?.append(newGroup)
        }

    }

    func removeChildGroup(parentUri: String, childUri: String){
        guard let _ = self.allGroups[childUri] else {
            Self.logger.info("[removeChildGroup] delete \(parentUri)/\(childUri) but child not found")
            return
        }

        if let parent = self.allGroups[parentUri]{
            if parent.children == nil{
                Self.logger.info("[removeChildGroup] delete \(parentUri)/\(childUri) parent has not child")
                return
            }

            parent.children = parent.children!.filter { $0.uri != childUri }
            if parent.children?.isEmpty ?? false {
                parent.children = nil
            }
            self.allGroups[childUri] = nil
        }
    }

    func isInLoop(uri: String, newParentUri: String) -> Bool {
        var nextUri: String = newParentUri
        while let parent = allGroups[nextUri] {
            if parent.uri == uri {
                return true
            }
            nextUri = parent.parentUri
        }
        return false
    }
}


@Observable
class GroupLeaf: Identifiable, Hashable {
    var id: String {
        uri
    }
    var uri: String {
        group.uri
    }
    var groupName: String {
        group.groupName
    }
    var parentID: Int64 {
        group.parentID
    }
    var parentUri: String {
        let components = uri.split(separator: "/")
        if components.count > 1 {
            return "/" + components.dropLast().joined(separator: "/")
        }
        return ""
    }


    var group: EntryGroup
    var children: [GroupLeaf]?

    init(group: EntryGroup, children: [GroupLeaf]? = nil) {
        self.group = group
        self.children = children
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(groupName)
    }

    static func == (lhs: GroupLeaf, rhs: GroupLeaf) -> Bool {
        return lhs.id == rhs.id
    }
}


class TreeUpdate {
    var oldLeaf: GroupLeaf
    var newLeaf: GroupLeaf?
    
    init(oldLeaf: GroupLeaf, newLeaf: GroupLeaf? = nil) {
        self.oldLeaf = oldLeaf
        self.newLeaf = newLeaf
    }
}
