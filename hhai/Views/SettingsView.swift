import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var firecrawlAPIKey = ""
    @State private var isShowingAPIKey = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack(spacing: DesignSystem.Spacing.xs) {
                        apiKeyField

                        Button {
                            isShowingAPIKey.toggle()
                        } label: {
                            Image(systemName: isShowingAPIKey ? "eye.slash" : "eye")
                        }
                        .buttonStyle(.borderless)
                        .accessibilityLabel(isShowingAPIKey ? "隐藏 API Key" : "显示 API Key")
                    }
                } header: {
                    Text("Firecrawl")
                } footer: {
                    Text("用于离线缓存最近 20 条 feed 的网页正文。留空时不会启用离线缓存服务。")
                }

                Section {
                    Button("清除自定义 Key", role: .destructive) {
                        firecrawlAPIKey = ""
                        FirecrawlSettings.apiKey = nil
                    }
                    .disabled(firecrawlAPIKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") {
                        saveAPIKey()
                        dismiss()
                    }
                }
            }
            .onAppear {
                firecrawlAPIKey = FirecrawlSettings.apiKey ?? ""
            }
            .onDisappear {
                saveAPIKey()
            }
        }
    }

    @ViewBuilder
    private var apiKeyField: some View {
        if isShowingAPIKey {
            TextField("Firecrawl API Key", text: $firecrawlAPIKey)
                .textContentType(.password)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .keyboardType(.asciiCapable)
                .submitLabel(.done)
                .privacySensitive()
                .onSubmit(saveAPIKey)
        } else {
            SecureField("Firecrawl API Key", text: $firecrawlAPIKey)
                .textContentType(.password)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .keyboardType(.asciiCapable)
                .submitLabel(.done)
                .privacySensitive()
                .onSubmit(saveAPIKey)
        }
    }

    private func saveAPIKey() {
        let trimmed = firecrawlAPIKey.trimmingCharacters(in: .whitespacesAndNewlines)
        FirecrawlSettings.apiKey = trimmed.isEmpty ? nil : trimmed
        firecrawlAPIKey = trimmed
    }
}
