import SwiftUI

struct TemplatePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    let onSelect: (LetterTemplate) -> Void
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.tomorrowBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(LetterTemplate.templates) { template in
                            TemplateCard(template: template) {
                                onSelect(template)
                                dismiss()
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Start from Template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color.tomorrowTextSecondary)
                }
            }
        }
    }
}

struct TemplateCard: View {
    let template: LetterTemplate
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "doc.text.fill")
                        .font(.title3)
                        .foregroundColor(Color.tomorrowPrimary)
                    
                    Text(template.title)
                        .font(.headline)
                        .foregroundColor(Color.tomorrowTextPrimary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(Color.tomorrowTextTertiary)
                }
                
                Text(template.prompt)
                    .font(.subheadline)
                    .foregroundColor(Color.tomorrowTextSecondary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                
                HStack {
                    Label("\(template.suggestedDuration / 365) year(s)", systemImage: "clock")
                    if let recipient = template.recipientPreset {
                        Label(recipient, systemImage: "person")
                    }
                }
                .font(.caption)
                .foregroundColor(Color.tomorrowTextTertiary)
            }
            .padding(16)
            .background(Color.tomorrowSurface)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

#Preview {
    TemplatePickerSheet { _ in }
}
