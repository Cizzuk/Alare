//
//  HingeSupport.swift
//  Alare
//
//  Created by Cizzuk on 2026/09/19.
//

import SwiftUI

struct DeviceHingeContext: Equatable {
    var hinge: Alare.DeviceHinge?
    
    @available(iOS 27.1, *)
    static func make(_ context: SwiftUI.DeviceHingeContext) -> Self {
        if let hinge = context.hinge {
            let status: Alare.DeviceHinge.Status
            
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
            
            return Self(hinge: Alare.DeviceHinge(angle: hinge.angle, status: status))
        } else {
            return Self(hinge: nil)
        }
    }
}

struct DeviceHinge: Equatable, Hashable {
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
        _ action: @escaping (Alare.DeviceHingeContext, Alare.DeviceHingeContext) -> Void
    ) -> some View {
        if #available(iOS 27.1, *) {
            return self
                .onHingeChange(isEnabled: isEnabled) { oldContext, newContext in
                    action(
                        Alare.DeviceHingeContext.make(oldContext),
                        Alare.DeviceHingeContext.make(newContext)
                    )
                }
        } else {
            return self
        }
    }
}
