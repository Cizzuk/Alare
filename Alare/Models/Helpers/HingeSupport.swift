//
//  HingeSupport.swift
//  Alare
//
//  Created by Cizzuk on 2026/09/19.
//

import SwiftUI

struct AltDeviceHingeContext: Equatable {
    var hinge: AltDeviceHinge?
    
    @available(iOS 27.1, *)
    static func make(_ context: DeviceHingeContext) -> Self {
        if let hinge = context.hinge {
            let status: AltDeviceHinge.Status
            
            switch hinge.status {
            case .closed:
                status = .closed
            case .fullyOpen:
                status = .fullyOpen
            case .partiallyOpen:
                status = .partiallyOpen
            default:
                status = .unknown
            }
            
            return Self(hinge: AltDeviceHinge(angle: hinge.angle, status: status))
        } else {
            return Self(hinge: nil)
        }
    }
}

struct AltDeviceHinge: Equatable, Hashable {
    var angle: Angle
    var status: Self.Status
    
    struct Status: Equatable, Hashable {
        let rawValue: Int
        static let unknown = Status(rawValue: -1)
        static let closed = Status(rawValue: 0)
        static let fullyOpen = Status(rawValue: 1)
        static let partiallyOpen = Status(rawValue: 2)
    }
}

extension View {
    func onHingeChangeIfAvailable(
        isEnabled: Bool = true,
        _ action: @escaping (AltDeviceHingeContext, AltDeviceHingeContext) -> Void
    ) -> some View {
        if #available(iOS 27.1, *) {
            return self
                .onHingeChange(isEnabled: isEnabled) { oldContext, newContext in
                    action(
                        AltDeviceHingeContext.make(oldContext),
                        AltDeviceHingeContext.make(newContext)
                    )
                }
        } else {
            return self
        }
    }
}
