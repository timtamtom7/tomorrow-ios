import Foundation

// MARK: - DatabaseService

@MainActor
final class DatabaseService {
    static let shared = DatabaseService()

    private let lettersKey = "tomorrow_letters"
    private let familyTreeKey = "tomorrow_family_tree"

    private init() {}

    // MARK: - Letters

    func saveLetters(_ letters: [Letter]) {
        do {
            let data = try JSONEncoder().encode(letters)
            UserDefaults.standard.set(data, forKey: lettersKey)
        } catch {
            print("Failed to save letters: \(error)")
        }
    }

    func loadLetters() -> [Letter] {
        guard let data = UserDefaults.standard.data(forKey: lettersKey) else {
            return []
        }
        do {
            return try JSONDecoder().decode([Letter].self, from: data)
        } catch {
            print("Failed to load letters: \(error)")
            return []
        }
    }

    func saveLetter(_ letter: Letter) {
        var letters = loadLetters()
        if let index = letters.firstIndex(where: { $0.id == letter.id }) {
            letters[index] = letter
        } else {
            letters.append(letter)
        }
        saveLetters(letters)
    }

    func deleteLetter(id: UUID) {
        var letters = loadLetters()
        letters.removeAll { $0.id == id }
        saveLetters(letters)

        // Also update family tree
        var tree = loadFamilyTree()
        tree.removeLetter(id: id)
        saveFamilyTree(tree)
    }

    // MARK: - Family Tree

    func saveFamilyTree(_ tree: FamilyTreeModel) {
        do {
            let data = try JSONEncoder().encode(tree)
            UserDefaults.standard.set(data, forKey: familyTreeKey)
        } catch {
            print("Failed to save family tree: \(error)")
        }
    }

    func loadFamilyTree() -> FamilyTreeModel {
        guard let data = UserDefaults.standard.data(forKey: familyTreeKey) else {
            return FamilyTreeModel()
        }
        do {
            return try JSONDecoder().decode(FamilyTreeModel.self, from: data)
        } catch {
            print("Failed to load family tree: \(error)")
            return FamilyTreeModel()
        }
    }

    // MARK: - Clear All

    func clearAll() {
        UserDefaults.standard.removeObject(forKey: lettersKey)
        UserDefaults.standard.removeObject(forKey: familyTreeKey)
    }
}
