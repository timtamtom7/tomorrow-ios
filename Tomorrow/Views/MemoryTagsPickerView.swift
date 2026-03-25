import SwiftUI

struct MemoryTagsPickerView: View {
    @Binding var letter: Letter
    @State private var selectedCategory: MemoryTag.Category = .general
    @State private var showingCustomTag = false
    @State private var customTagName = ""
    @State private var customTagEmoji = "📌"
    @State private var customTagCategory: MemoryTag.Category = .general
    
    var body: some View {
        VStack(spacing: 16) {
            if letter.memoryTags.isEmpty {
                emptyState
            } else {
                selectedTags
            }
            
            categoryPicker
            
            availableTags
        }
        .sheet(isPresented: $showingCustomTag) {
            CustomTagSheet(
                name: $customTagName,
                emoji: $customTagEmoji,
                category: $customTagCategory,
                onSave: addCustomTag
            )
            .presentationDetents([.height(280)])
            .presentationDragIndicator(.visible)
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "tag")
                .font(.system(size: 32))
                .foregroundColor(.tomorrowTextTertiary)
            
            Text("Tag this letter with a memory")
                .font(.subheadline)
                .foregroundColor(.tomorrowTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color.tomorrowSurface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var selectedTags: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Selected")
                .font(.caption)
                .foregroundColor(.tomorrowTextSecondary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(letter.memoryTags) { tag in
                        MemoryTagChip(tag: tag, isSelected: true) {
                            letter.memoryTags.removeAll { $0.id == tag.id }
                        }
                    }
                }
            }
        }
    }
    
    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(MemoryTag.Category.allCases, id: \.self) { category in
                    CategoryTab(
                        category: category,
                        isSelected: selectedCategory == category
                    ) {
                        selectedCategory = category
                    }
                }
            }
        }
    }
    
    private var availableTags: some View {
        let filtered = MemoryTag.defaultTags.filter { $0.category == selectedCategory }
        
        return VStack(alignment: .leading, spacing: 8) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(filtered) { tag in
                        let isSelected = letter.memoryTags.contains { $0.name == tag.name }
                        MemoryTagChip(tag: tag, isSelected: isSelected) {
                            if isSelected {
                                letter.memoryTags.removeAll { $0.name == tag.name }
                            } else {
                                letter.memoryTags.append(tag)
                            }
                        }
                    }
                    
                    // Add custom tag button
                    Button {
                        showingCustomTag = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                            Text("Custom")
                        }
                        .font(.caption)
                        .foregroundColor(.tomorrowTextSecondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.tomorrowSurface)
                        .clipShape(Capsule())
                    }
                }
            }
        }
    }
    
    private func addCustomTag() {
        guard !customTagName.isEmpty else { return }
        let tag = MemoryTag(
            name: customTagName,
            emoji: customTagEmoji,
            category: customTagCategory
        )
        letter.memoryTags.append(tag)
        customTagName = ""
        customTagEmoji = "📌"
        showingCustomTag = false
    }
}

struct MemoryTagChip: View {
    let tag: MemoryTag
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(tag.emoji)
                    .font(.caption)
                Text(tag.name)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .foregroundColor(isSelected ? .tomorrowBackground : .tomorrowTextPrimary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color(hex: tag.category.color) : Color.tomorrowSurface)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.clear : Color.tomorrowDivider, lineWidth: 1)
            )
        }
    }
}

struct CategoryTab: View {
    let category: MemoryTag.Category
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(category.rawValue)
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .tomorrowBackground : .tomorrowTextSecondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color(hex: category.color) : Color.tomorrowSurface)
                .clipShape(Capsule())
        }
    }
}

struct CustomTagSheet: View {
    @Binding var name: String
    @Binding var emoji: String
    @Binding var category: MemoryTag.Category
    let onSave: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    private let commonEmojis = ["📌", "⭐", "💡", "🌟", "❤️", "🎯", "🚀", "✨", "🎉", "💫", "🔥", "🌈"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.tomorrowBackground.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    TextField("Tag name", text: $name)
                        .font(.body)
                        .foregroundColor(.tomorrowTextPrimary)
                        .padding(12)
                        .background(Color.tomorrowSurface)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    // Emoji picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Choose an emoji")
                            .font(.caption)
                            .foregroundColor(.tomorrowTextSecondary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 8) {
                            ForEach(commonEmojis, id: \.self) { e in
                                Button {
                                    emoji = e
                                } label: {
                                    Text(e)
                                        .font(.title2)
                                        .frame(width: 44, height: 44)
                                        .background(emoji == e ? Color.tomorrowPrimary.opacity(0.2) : Color.tomorrowSurface)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding(24)
            }
            .navigationTitle("Create Tag")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.tomorrowTextSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        onSave()
                        dismiss()
                    }
                    .foregroundColor(.tomorrowPrimary)
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

#Preview {
    MemoryTagsPickerView(letter: .constant(Letter()))
        .padding()
        .background(Color.tomorrowBackground)
}
