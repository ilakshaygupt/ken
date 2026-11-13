//
//  TrackedSourceID.swift
//  ken
//

import Foundation

enum TrackedSourceKind: String, Codable, CaseIterable {
    case leetcode, github, codeforces, habit
}

/// Composite identity for anything tracked, so a LeetCode "x", GitHub "x", and a
/// habit named "x" never collide. Used by the saved-sources list only — LeetCode's
/// own per-kind storage stays keyed by plain username.
struct TrackedSourceID: Codable, Hashable {
    let kind: TrackedSourceKind
    let identifier: String

    var storageKey: String { "\(kind.rawValue):\(identifier)" }

    init(kind: TrackedSourceKind, identifier: String) {
        self.kind = kind
        self.identifier = identifier
    }

    init?(storageKey: String) {
        guard let sep = storageKey.firstIndex(of: ":"),
              let kind = TrackedSourceKind(rawValue: String(storageKey[..<sep])) else { return nil }
        self.kind = kind
        self.identifier = String(storageKey[storageKey.index(after: sep)...])
    }
}
