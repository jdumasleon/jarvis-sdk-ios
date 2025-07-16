import SwiftUI
import JarvisDesignSystem

public struct PreferenceEditorView: View {
    let key: String
    @State private var currentValue: String = ""
    @State private var newValue: String = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @Environment(\.dismiss) private var dismiss
    
    public init(key: String) {
        self.key = key
    }
    
    public var body: some View {
        NavigationView {
            VStack(spacing: JarvisSpacing.lg) {
                keySection
                currentValueSection
                editorSection
                
                Spacer()
            }
            .padding(JarvisSpacing.lg)
            .background(Color.jarvis.secondaryBackground.ignoresSafeArea())
            .navigationTitle("Edit Preference")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    JarvisButton("Cancel", style: .ghost, size: .small) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    JarvisButton("Save", style: .primary, size: .small) {
                        savePreference()
                    }
                }
            }
        }
        .onAppear {
            loadCurrentValue()
        }
        .alert("Preference Updated", isPresented: $showingAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    private var keySection: some View {
        VStack(alignment: .leading, spacing: JarvisSpacing.sm) {
            Text("Preference Key")
                .font(JarvisFont.headline)
                .foregroundColor(Color.jarvis.text)
            
            JarvisCard {
                Text(key)
                    .font(JarvisFont.codeMono)
                    .foregroundColor(Color.jarvis.text)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
    private var currentValueSection: some View {
        VStack(alignment: .leading, spacing: JarvisSpacing.sm) {
            Text("Current Value")
                .font(JarvisFont.headline)
                .foregroundColor(Color.jarvis.text)
            
            JarvisCard {
                Text(currentValue.isEmpty ? "No value" : currentValue)
                    .font(JarvisFont.codeMono)
                    .foregroundColor(currentValue.isEmpty ? Color.jarvis.secondaryText : Color.jarvis.text)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
    private var editorSection: some View {
        VStack(alignment: .leading, spacing: JarvisSpacing.sm) {
            Text("New Value")
                .font(JarvisFont.headline)
                .foregroundColor(Color.jarvis.text)
            
            JarvisCard {
                TextField("Enter new value", text: $newValue, axis: .vertical)
                    .font(JarvisFont.codeMono)
                    .textFieldStyle(.plain)
                    .lineLimit(5...10)
            }
            
            VStack(spacing: JarvisSpacing.sm) {
                quickActionButton("Set to empty string", value: "")
                quickActionButton("Set to true", value: "true")
                quickActionButton("Set to false", value: "false")
                quickActionButton("Set to 0", value: "0")
            }
        }
    }
    
    private func quickActionButton(_ title: String, value: String) -> some View {
        JarvisButton(title, style: .secondary, size: .small) {
            newValue = value
        }
    }
    
    private func loadCurrentValue() {
        let userDefaults = UserDefaults.standard
        let value = userDefaults.object(forKey: key)
        currentValue = value != nil ? "\(value!)" : ""
        newValue = currentValue
    }
    
    private func savePreference() {
        let userDefaults = UserDefaults.standard
        
        // Try to infer the type and set the appropriate value
        if newValue.isEmpty {
            userDefaults.removeObject(forKey: key)
            alertMessage = "Preference deleted successfully"
        } else if let intValue = Int(newValue) {
            userDefaults.set(intValue, forKey: key)
            alertMessage = "Preference updated as Integer: \(intValue)"
        } else if let doubleValue = Double(newValue) {
            userDefaults.set(doubleValue, forKey: key)
            alertMessage = "Preference updated as Double: \(doubleValue)"
        } else if newValue.lowercased() == "true" {
            userDefaults.set(true, forKey: key)
            alertMessage = "Preference updated as Boolean: true"
        } else if newValue.lowercased() == "false" {
            userDefaults.set(false, forKey: key)
            alertMessage = "Preference updated as Boolean: false"
        } else {
            userDefaults.set(newValue, forKey: key)
            alertMessage = "Preference updated as String: \(newValue)"
        }
        
        userDefaults.synchronize()
        showingAlert = true
    }
}