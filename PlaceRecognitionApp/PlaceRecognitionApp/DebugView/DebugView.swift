import SwiftUI

struct DebugView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject var viewModel = DebugModel()

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
                        sendTest()
                    }) {
                        Text("Test connection")
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

@MainActor func sendTest() {
    let _buildingRepository: IBuildingInfoRepository = BuildingInfoRepository()
    Task {
        let rawData = try await _buildingRepository.getInfoByDecriptor(descriptor: [12.1])
        print("Yes, get data")
    }

}

#Preview {
    DebugView()
}
