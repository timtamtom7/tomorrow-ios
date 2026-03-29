import SwiftUI

struct MenuBarView: View {
    @State private var selectedTab: Tab = .tomorrow

    enum Tab: String, CaseIterable {
        case tomorrow = "Today"
        case forecast = "Horizon"
        case plan = "Plan"
        case reflect = "Reflect"
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header with tab picker
            headerView

            Divider()

            // Content
            TabView(selection: $selectedTab) {
                TomorrowView()
                    .tag(Tab.tomorrow)

                ForecastView()
                    .tag(Tab.forecast)

                PlanningView()
                    .tag(Tab.plan)

                ReflectionView()
                    .tag(Tab.reflect)
            }
            .tabViewStyle(.automatic)
        }
        .frame(width: 360, height: 480)
        .background(Theme.surface)
    }

    private var headerView: some View {
        VStack(spacing: Theme.spacing_sm) {
            HStack {
                Image(systemName: "sun.horizon.fill")
                    .foregroundStyle(Theme.sunriseGradient)
                    .font(.title2)

                Text("Tomorrow")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(Theme.textPrimary)

                Spacer()

                Text(formattedDate)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Theme.textSecondary)
            }
            .padding(.horizontal, Theme.spacing_md)
            .padding(.top, Theme.spacing_md)

            // Tab bar
            HStack(spacing: 0) {
                ForEach(Tab.allCases, id: \.self) { tab in
                    Button {
                        withAnimation(Theme.springAnimation) {
                            selectedTab = tab
                        }
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: iconFor(tab))
                                .font(.system(size: 14, weight: .medium))
                            Text(tab.rawValue)
                                .font(.system(size: 10, weight: .medium))
                        }
                        .foregroundColor(selectedTab == tab ? Theme.horizonBlue : Theme.textMuted)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Theme.spacing_sm)
                        .background(
                            selectedTab == tab ?
                            Theme.horizonBlue.opacity(0.1) : Color.clear
                        )
                        .cornerRadius(Theme.radius_sm)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, Theme.spacing_sm)
            .padding(.bottom, Theme.spacing_sm)
        }
    }

    private func iconFor(_ tab: Tab) -> String {
        switch tab {
        case .tomorrow: return "sun.max"
        case .forecast: return "calendar"
        case .plan: return "checklist"
        case .reflect: return "moon.stars"
        }
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        return formatter.string(from: Date())
    }
}
