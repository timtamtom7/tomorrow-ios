import SwiftUI

// MARK: - ContentView

struct ContentView: View {
    @Environment(LibraryViewModel.self) private var viewModel
    @State private var selectedTab: Int = 0
    @State private var showingEditor = false
    @State private var letterToEdit: Letter?

    var body: some View {
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
                // Reset to previous tab
                selectedTab = oldValue
            }
        }
        .sheet(isPresented: $showingEditor) {
            LetterEditorView(letter: letterToEdit)
        }
        .task {
            viewModel.loadLetters()
        }
    }
}

#Preview {
    ContentView()
        .environment(LibraryViewModel())
}
