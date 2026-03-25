import Foundation

// MARK: - FamilyTreeModel

struct FamilyTreeModel: Codable {
    var nodes: [UUID: Letter]
    var edges: [UUID: [UUID]]

    init() {
        nodes = [:]
        edges = [:]
    }

    mutating func addLetter(_ letter: Letter) {
        nodes[letter.id] = letter
    }

    mutating func linkLetter(parentId: UUID, childId: UUID) {
        guard nodes[parentId] != nil, nodes[childId] != nil else { return }
        nodes[childId]?.parentLetterId = parentId

        if edges[parentId] == nil {
            edges[parentId] = []
        }
        if !(edges[parentId]?.contains(childId) ?? false) {
            edges[parentId]?.append(childId)
        }
    }

    func getChildren(of letterId: UUID) -> [Letter] {
        guard let childIds = edges[letterId] else { return [] }
        return childIds.compactMap { nodes[$0] }
    }

    func getParent(of letterId: UUID) -> Letter? {
        guard let letter = nodes[letterId],
              let parentId = letter.parentLetterId else { return nil }
        return nodes[parentId]
    }

    func getRootLetters() -> [Letter] {
        nodes.values.filter { $0.parentLetterId == nil }
    }

    func getLetterChain(from letterId: UUID) -> [Letter] {
        var chain: [Letter] = []
        var currentId: UUID? = letterId

        while let id = currentId {
            guard let letter = nodes[id] else { break }
            chain.insert(letter, at: 0)
            currentId = letter.parentLetterId
        }

        return chain
    }

    mutating func removeLetter(id: UUID) {
        nodes.removeValue(forKey: id)
        edges.removeValue(forKey: id)

        for (parentId, children) in edges {
            edges[parentId] = children.filter { $0 != id }
        }
    }
}
