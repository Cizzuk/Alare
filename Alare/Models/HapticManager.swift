//
//  HapticManager.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/24.
//

import AVFoundation
import CoreHaptics

enum HapticSounds {
    case success
    
    var filename: String {
        switch self {
        case .success:
            return "Success"
        }
    }
}

final class HapticManager {
    static let shared = HapticManager()
    
    var engine: CHHapticEngine?
    
    lazy var supportsHaptics: Bool = {
        return CHHapticEngine.capabilitiesForHardware().supportsHaptics
    }()
    
    private init() {
        guard supportsHaptics else { return }
        
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, options: [.mixWithOthers])
            engine = try CHHapticEngine(audioSession: session)
        } catch let error {
            print("CHHapticEngine Creation Error: \(error)")
        }
        
        guard let engine = engine else {
            print("Failed to create engine!")
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            try? engine.start()
        }
    }
    
    func playHaptics(_ sound: HapticSounds) {
        guard supportsHaptics, let engine = engine else { return }
        
        DispatchQueue.global(qos: .userInitiated).async {
            guard let path = Bundle.main.path(forResource: sound.filename, ofType: "ahap") else {
                print("AHAP file not found for sound: \(sound).")
                return
            }
            
            do {
                try engine.playPattern(from: URL(fileURLWithPath: path))
            } catch {
                print("Failed to play AHAP (\(sound)): \(error).")
            }
        }
    }
}
