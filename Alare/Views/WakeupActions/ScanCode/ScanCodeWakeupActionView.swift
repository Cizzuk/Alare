//
//  ScanCodeWakeupActionView.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/24.
//

import AVFoundation
import SwiftUI
import VisionKit

// MARK: - Settings

struct ScanCodeWakeupActionSettingsView: View {
    @ObservedObject private var manager = WakeupActionManager.shared
    @State private var isShowingScanner = false
    @State private var isShowingShareSheet = false
    
    private let cameraAuthStatus = AVCaptureDevice.authorizationStatus(for: .video)
    private var isCameraAccessDenied: Bool {
        cameraAuthStatus == .denied || cameraAuthStatus == .restricted
    }

    var body: some View {
        Section {
            HStack {
                Text("Code")
                Spacer()
                if let code = manager.settings.scanCode_code {
                    Text(code)
                        .lineLimit(1)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Not Set")
                        .foregroundStyle(.secondary)
                }
            }
            
            Button("Scan to Set a New Code") {
                isShowingScanner = true
            }
            .disabled(isCameraAccessDenied)
            .sheet(isPresented: $isShowingScanner) {
                NavigationStack {
                    BarcodeScannerView { code in
                        manager.settings.scanCode_code = code
                        isShowingScanner = false
                    }
                    .ignoresSafeArea()
                    .navigationTitle("Scan a Code")
                    .toolbarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button(action: { isShowingScanner = false }) {
                                Label("Cancel", systemImage: "xmark")
                            }
                        }
                    }
                }
            }
        } footer: {
            VStack(alignment: .leading, spacing: 5) {
                switch cameraAuthStatus {
                case .denied:
                    Text("Camera access is denied. Please grant permission in Settings.")
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        Button(action: { UIApplication.shared.open(url) }) {
                            Text("Open Settings...")
                        }
                    }
                case .restricted:
                    Text("Camera access is restricted.")
                default:
                    if manager.settings.scanCode_code == nil {
                        Text("First you need to scan the code to use it for this action.")
                    } else {
                        Text("It's recommended to place the code away from the bed.")
                    }
                }
            }
            .font(.footnote)
        }
        
        if let image = UIImage(named: "scancode-image") {
            Section {
                ShareLink(
                    item: Image(uiImage: image),
                    preview: SharePreview("Alare Code", image: Image(uiImage: image))
                ) {
                    Label("Create New Code", systemImage: "qrcode")
                }
            }
        }
    }
}

// MARK: - Execution

struct ScanCodeWakeupActionExecutionView: View {
    @ObservedObject var vm: WakeupActionExecutionViewModel
    @State var incorrectCodeEntered = false
    private let expectedCode = WakeupActionManager.shared.settings.scanCode_code

    var body: some View {
        VStack() {
            Text("Scan the Code to Wake Up!")
                .font(.largeTitle)
                .bold()
                .padding()
            
            if incorrectCodeEntered {
                Text("Incorrect code. Please try another code.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text("Code: \(expectedCode ?? "Not Set")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            
            BarcodeScannerView { code in
                if code == expectedCode || code == completeWakeupActionURL {
                    vm.complete()
                } else {
                    incorrectCodeEntered = true
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(NightGradient.ignoresSafeArea())
    }
}

// MARK: - Barcode Scanner

private struct BarcodeScannerView: UIViewControllerRepresentable {
    let onCodeScanned: (String) -> Void

    func makeUIViewController(context: Context) -> DataScannerViewController {
        let vc = DataScannerViewController(
            recognizedDataTypes: [.barcode()],
            isHighlightingEnabled: true
        )
        
        vc.delegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ vc: DataScannerViewController, context: Context) {
        if !vc.isScanning { try? vc.startScanning() }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onCodeScanned: onCodeScanned)
    }

    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        let onCodeScanned: (String) -> Void
        
        init(onCodeScanned: @escaping (String) -> Void) {
            self.onCodeScanned = onCodeScanned
        }
        
        func dataScanner(
            _ dataScanner: DataScannerViewController,
            didAdd addedItems: [RecognizedItem],
            allItems: [RecognizedItem]
        ) {
            for item in addedItems {
                if case .barcode(let barcode) = item,
                   let value = barcode.payloadStringValue {
                    DispatchQueue.main.async {
                        self.onCodeScanned(value)
                    }
                    return
                }
            }
        }
    }
}
