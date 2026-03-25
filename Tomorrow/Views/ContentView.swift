import SwiftUI

struct ContentView: View {
    @State private var viewModel = LibraryViewModel()
    @State private var selectedTab: Int = 0
    @State private var showingEditor = false
    @State private var letterToEdit: Letter?
    
    var body: some View {
        Group {
            if UIDevice.current.userInterfaceIdiom == .pad {
                iPadLayout
            } else {
                iPhoneLayout
            }
        }
        .environment(viewModel)
        .sheet(isPresented: $showingEditor) {
            LetterEditorView(letter: letterToEdit)
        }
        .task {
            viewModel.loadLetters()
            viewModel.requestNotificationPermission()
        }
    }
    
    private var iPhoneLayout: some View {
        ZStack {
            Color.tomorrowBackground.ignoresSafeArea()
            
            TabView(selection: $selectedTab) {
                LibraryView()
                    .tabItem {
                        Label("Library", systemImage: "books.vertical")
                    }
                    .tag(0)
                
                TimelineView()
                    .tabItem {
                        Label("Timeline", systemImage: "clock")
                    }
                    .tag(1)
                
                Color.clear
                    .tabItem {
                        Label("Create", systemImage: "plus.circle.fill")
                    }
                    .tag(2)
                
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
                    .tag(3)
            }
            .tint(Color.tomorrowPrimary)
        }
        .onChange(of: selectedTab) { oldValue, newValue in
            if newValue == 2 {
                letterToEdit = nil
                showingEditor = true
                selectedTab = oldValue
            }
        }
    }
    
    private var iPadLayout: some View {
        NavigationSplitView {
            // Sidebar
            List {
                Section {
                    Label("Library", systemImage: "books.vertical")
                        .onTapGesture { selectedTab = 0 }
                        .listRowBackground(selectedTab == 0 ? Color.tomorrowPrimary.opacity(0.15) : Color.clear)
                    
                    Label("Timeline", systemImage: "clock")
                        .onTapGesture { selectedTab = 1 }
                        .listRowBackground(selectedTab == 1 ? Color.tomorrowPrimary.opacity(0.15) : Color.clear)
                    
                    Label("Family Tree", systemImage: "tree")
                        .onTapGesture { selectedTab = 4 }
                        .listRowBackground(selectedTab == 4 ? Color.tomorrowPrimary.opacity(0.15) : Color.clear)
                }
                
                Section {
                    Label("Settings", systemImage: "gear")
                        .onTapGesture { selectedTab = 3 }
                        .listRowBackground(selectedTab == 3 ? Color.tomorrowPrimary.opacity(0.15) : Color.clear)
                }
            }
            .listStyle(.sidebar)
            .navigationTitle("Tomorrow")
        } detail: {
            switch selectedTab {
            case 0:
                LibraryView()
            case 1:
                TimelineView()
            case 2:
                Color.clear
            case 3:
                SettingsView()
            case 4:
                FamilyTreeView()
            default:
                LibraryView()
            }
        }
    }
}

struct FamilyTreeView: View {
    @Environment(LibraryViewModel.self) private var viewModel
    
    var body: some View {
        ZStack {
            Color.tomorrowBackground.ignoresSafeArea()
            
            if viewModel.letters.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "tree")
                        .font(.system(size: 64))
                        .foregroundColor(Color.tomorrowTextTertiary)
                    
                    Text("Your family tree is empty")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.tomorrowTextPrimary)
                    
                    Text("Write letters to build your legacy.\nLetters linked by relationship will\nappear here as a family tree.")
                        .font(.body)
                        .foregroundColor(Color.tomorrowTextSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(32)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.letters.filter { $0.parentLetterId == nil }) { letter in
                            TreeNodeView(letter: letter, depth: 0)
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Family Tree")
    }
}

struct TreeNodeView: View {
    let letter: Letter
    let depth: Int
    @Environment(LibraryViewModel.self) private var viewModel
    @State private var isExpanded = true
    
    var children: [Letter] {
        viewModel.letters.filter { $0.parentLetterId == letter.id }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                // Tree connector
                if depth > 0 {
                    ForEach(0..<depth, id: \.self) { _ in
                        Rectangle()
                            .fill(Color.tomorrowPrimary.opacity(0.3))
                            .frame(width: 1)
                            .padding(.leading, 16)
                    }
                }
                
                // Expand/collapse
                if !children.isEmpty {
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            isExpanded.toggle()
                        }
                    } label: {
                        Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                            .font(.caption)
                            .foregroundColor(Color.tomorrowPrimary)
                    }
                } else {
                    Circle()
                        .fill(Color.tomorrowPrimary)
                        .frame(width: 8, height: 8)
                }
                
                // Letter card
                VStack(alignment: .leading, spacing: 4) {
                    Text(letter.displayTitle)
                        .font(.headline)
                        .foregroundColor(Color.tomorrowTextPrimary)
                    
                    HStack(spacing: 8) {
                        Label(letter.status.displayName, systemImage: letter.status.iconName)
                        if let recipient = viewModel.recipient(for: letter.recipientId) {
                            Label(recipient.name, systemImage: "person")
                        }
                    }
                    .font(.caption)
                    .foregroundColor(Color.tomorrowTextSecondary)
                }
                
                Spacer()
                
                Text(letter.formattedScheduledDate)
                    .font(.caption)
                    .foregroundColor(Color.tomorrowTextTertiary)
            }
            .padding(12)
            .background(Color.tomorrowSurface)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Children
            if isExpanded {
                VStack(spacing: 8) {
                    ForEach(children) { child in
                        TreeNodeView(letter: child, depth: depth + 1)
                    }
                }
                .padding(.leading, 24)
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(LibraryViewModel())
}
