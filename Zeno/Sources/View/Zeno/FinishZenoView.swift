//
//  FinishZenoView.swift
//  Zeno
//
//  Created by 유하은 on 2023/09/27.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI

struct FinishZenoView: View {
    // 타이머 뷰 진입시 3~5초부터 시작하는 버그?
    @StateObject private var timerViewModel = TimerViewModel()
    @EnvironmentObject private var zenoViewModel: ZenoViewModel
    @EnvironmentObject private var userViewModel: UserViewModel
    
    var body: some View {
        ZStack {
            VStack {
                LottieView(lottieFile: "beforeZenoFirst")
                
                if timerViewModel.timesUp {
                    Text(" 시간이 다 됐어요! ")
                        .blueAndBMfont()
                        .offset(y: 30)
                    Button {
                        zenoViewModel.resetZenoNavigation()
                    } label: {
                        WideButton(buttonName: "제노하러가기", isplay: true)
                    }
                } else {
                    Text("다음 제노까지 \(timerViewModel.timeRemaining) ")
                        .blueAndBMfont()
                        .offset(y: 30)
                }
            }
        }
        .onAppear {
            timerViewModel.myZenoTimer = Int(timerViewModel.comparingTime(currentUser: userViewModel.currentUser))
            timerViewModel.futureData = Calendar.current.date(byAdding: .second, value: Int(timerViewModel.myZenoTimer), to: Date())
            timerViewModel.updateTimeRemaining()
        }
        .onReceive(timerViewModel.timer) {_ in
            timerViewModel.updateTimeRemaining()
        }
        .onDisappear {
            // 타이머
            print("FinishZenoView - OnDisappear")
//            timerViewModel.timer
        }
        .navigationBarBackButtonHidden()
    }
}

struct FinishZenoView_Previews: PreviewProvider {
    struct Preview: View {
        @StateObject private var userViewModel: UserViewModel = .init()
        @StateObject private var commViewModel: CommViewModel = .init()
        @StateObject private var zenoViewModel: ZenoViewModel = .init()
        @StateObject private var mypageViewModel: MypageViewModel = .init()
        @StateObject private var alarmViewModel: AlarmViewModel = .init()
        
        var body: some View {
            TabBarView()
                .environmentObject(userViewModel)
                .environmentObject(commViewModel)
                .environmentObject(zenoViewModel)
                .environmentObject(mypageViewModel)
                .environmentObject(alarmViewModel)
                .onAppear {
                    Task {
                        let result = await FirebaseManager.shared.read(type: User.self, id: "neWZ4Vm1VsTH5qY5X5PQyXTNU8g2")
                        switch result {
                        case .success(let user):
                            userViewModel.currentUser = user
                            commViewModel.updateCurrentUser(user: user)
                        case .failure:
                            print("preview 유저로드 실패")
                    }
                }
            }
        }
    }
    
    static var previews: some View {
        Preview()
    }
}
