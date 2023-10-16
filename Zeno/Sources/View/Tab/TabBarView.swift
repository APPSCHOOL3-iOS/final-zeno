//
//  TabBarView.swift
//  Zeno
//
//  Created by Muker on 2023/09/26.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI

struct TabBarView: View {
    @AppStorage("fcmToken") var fcmToken: String = ""
    
    @EnvironmentObject private var commViewModel: CommViewModel
    @EnvironmentObject private var userViewModel: UserViewModel
    @StateObject private var tabBarViewModel = TabBarViewModel()
    @StateObject private var alarmViewModel: AlarmViewModel = AlarmViewModel()
    @StateObject private var iAPStore: IAPStore = IAPStore()
    
    var body: some View {
        TabView(selection: $tabBarViewModel.selected) {
            ForEach(MainTab.allCases) { tab in
                tab.view
            }
            .toolbarBackground(.hidden, for: .tabBar)
		}
        .overlay {
            VStack(alignment: .center) {
                Spacer()
                CustomTabView()
                    .frame(width: .screenWidth)
                    .offset(y: CGFloat.screenHeight == 667 ? 20 : 0)
            }
        }
        .environmentObject(tabBarViewModel)
        .environmentObject(alarmViewModel)
        .environmentObject(iAPStore)
        .onOpenURL { url in
            Task {
                await commViewModel.handleInviteURL(url)
                tabBarViewModel.selected = .comm
            }
        }
        .task {
            if let loginUser = userViewModel.currentUser {
                print("fetch alarm and update user fcmtoken")
                await alarmViewModel.fetchAlarm(showUserID: loginUser.id)
                await userViewModel.updateUserFCMToken(fcmToken)
            }
        }
	}
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView()
            .environmentObject(UserViewModel())
            .environmentObject(CommViewModel())
            .environmentObject(ZenoViewModel())
            .environmentObject(AlarmViewModel())
            .environmentObject(MypageViewModel())
    }
}
