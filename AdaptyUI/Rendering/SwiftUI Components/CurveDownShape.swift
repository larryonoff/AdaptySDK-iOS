//
//  CurveDownShape.swift
//
//
//  Created by Aleksey Goncharov on 13.06.2024.
//

#if canImport(UIKit)

import Adapty
import SwiftUI

@available(iOS 15.0, *)
struct CurveDownShape: Shape {
    var curveHeight: CGFloat = 32.0
    
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))

        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))

        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY),
                          control: CGPoint(x: rect.midX, y: rect.minY + curveHeight))

        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))

        path.closeSubpath()
        
        return path
    }
}

#endif
