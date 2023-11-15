import SwiftUI

struct DebugView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject var viewModel = DebugModel()
    
    @State private var showingAlert = false
    
    @State private var showingAlertText = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Debug URL")) {
                    HStack {
                        Text("Debug URL:")
                        Divider()
                        TextField("Debug URL",
                                  text: $viewModel.debugUrl,
                                  prompt: Text("Debug URL")).frame(alignment: .center)
                    }
                    Button(action: {
                        Task {
                            if await sendTest() {
                                showingAlertText = "Connected"
                            } else {
                                showingAlertText = "No connection"
                            }
                            showingAlert = true
                        }
                    }) {
                        Text("Test connection")
                    }
                    .alert(isPresented: $showingAlert) {
                        Alert(title: Text("Alert"),
                              message: Text(showingAlertText),
                              dismissButton: .default(Text("OK")))
                    }
                }
                Section(header: Text("Debug Token")) {
                    TextField("Token",
                              text: $viewModel.debugToken,
                              prompt: Text("Debug Token")).frame(alignment: .center)
                }
            }
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button(action: {
                            viewModel.saveInUserDefault()
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Done")
                        }
                    }
                    ToolbarItem(placement: .cancellationAction) {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Dismiss")
                        }
                    }
                }
                
        }
    }
}

@MainActor func sendTest() async -> Bool {
    let _buildingRepository: IBuildingInfoRepository = BuildingInfoRepository()
    do {
        let rawData = try await _buildingRepository.getInfoByDecriptor(descriptor: [12.1])
        print("Yes, get data")
        return true
    } catch {
        print("No data")
        return false
    }
}

#Preview {
    DebugView()
}
