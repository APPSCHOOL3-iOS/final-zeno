//
//  AlarmBackBtnModifier.swift
//  Zeno
//
//  Created by Jisoo HAM on 10/16/23.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct AlarmBackBtnModifier: ViewModifier {
    @Binding var isPresented: Bool
    
    let title: String
    let subTitle: String
    
    let primaryAction1: () -> Void
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            ZStack {
                if isPresented {
                    Rectangle()
                        .fill(.black.opacity(0.5))
                        .blur(radius: isPresented ? 2 : 0)
                        .ignoresSafeArea()
                        .onTapGesture {
                            self.isPresented = false // 외부 영역 터치 시 내려감
                        }
                    
                    AlarmBackBtnView(isPresented: self.$isPresented,
                                     title: self.title,
                                     subTitle: self.subTitle,
                                     primaryAction1: self.primaryAction1)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(
                isPresented
                ? .spring(response: 0.3)
                : .none,
                value: isPresented
            )
        }
    }
}
