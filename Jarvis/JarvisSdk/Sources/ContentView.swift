import SwiftUI
import Jarvis

struct ContentView: View {
    @State private var showingInspector = false
    @State private var networkRequestCount = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                headerSection
                
                demoActionsSection
                
                instructionsSection
                
                Spacer()
            }
            .padding()
            .navigationTitle("Jarvis Demo")
        }
        .sheet(isPresented: $showingInspector) {
            Jarvis.shared.showInspector()
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass.circle.fill")
                .font(.system(size: 64))
                .foregroundColor(.blue)
            
            Text("Jarvis SDK Demo")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Cross-platform developer toolkit for mobile apps")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var demoActionsSection: some View {
        VStack(spacing: 12) {
            Button("🔍 Open Inspector") {
                showingInspector = true
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            
            Button("🌐 Make Test Network Request") {
                makeTestNetworkRequest()
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            
            Button("💾 Add Test Preferences") {
                addTestPreferences()
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            
            if networkRequestCount > 0 {
                Text("Made \(networkRequestCount) test request(s)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var instructionsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Shake your device to open the inspector", systemImage: "iphone.and.arrow.forward")
            Label("Monitor network requests in real-time", systemImage: "network")
            Label("Edit UserDefaults and preferences", systemImage: "gearshape")
            Label("Perfect for debugging and QA testing", systemImage: "hammer")
        }
        .font(.caption)
        .foregroundColor(.secondary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
    
    private func makeTestNetworkRequest() {
        let urls = [
            "https://jsonplaceholder.typicode.com/posts/1",
            "https://httpbin.org/get",
            "https://api.github.com/users/octocat",
            "https://jsonplaceholder.typicode.com/users"
        ]
        
        guard let url = URL(string: urls.randomElement() ?? urls[0]) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                networkRequestCount += 1
            }
        }
        task.resume()
    }
    
    private func addTestPreferences() {
        let userDefaults = UserDefaults.standard
        
        let timestamp = Date().timeIntervalSince1970
        userDefaults.set("Test value \(Int(timestamp))", forKey: "jarvis_test_string")
        userDefaults.set(Int.random(in: 1...100), forKey: "jarvis_test_int")
        userDefaults.set(Double.random(in: 0...1), forKey: "jarvis_test_double")
        userDefaults.set(Bool.random(), forKey: "jarvis_test_bool")
        userDefaults.set(["item1", "item2", "item3"], forKey: "jarvis_test_array")
        userDefaults.set(["key1": "value1", "key2": "value2"], forKey: "jarvis_test_dict")
        
        userDefaults.synchronize()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}