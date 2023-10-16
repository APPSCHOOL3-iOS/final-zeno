//
//  CommSideBarView.swift
//  Zeno
//
//  Created by woojin Shin on 2023/09/26.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI

struct CommSideBarView: View {
    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject private var commViewModel: CommViewModel
    @Binding var isPresented: Bool
    
    @State private var isSelectContent: Bool = false
    @State private var isSettingPresented: Bool = false
    @State private var isLeaveCommAlert: Bool = false
    @State private var isNeedDelegateAlert: Bool = false
    @State private var isDeleteCommAlert: Bool = false
    @State private var isDelegateManagerView: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(commViewModel.currentComm?.name ?? "가입된 커뮤니티가 없습니다.")
						.font(.regular(16))
                    Text("\(commViewModel.currentComm?.joinMembers.count ?? 0)명 참여중")
						.font(.thin(12))
                    Text("생성일 \(commViewModel.currentComm?.createdAt.convertDate ?? "가입된 커뮤니티가 없습니다.")")
						.font(.thin(12))
                        .foregroundStyle(.gray)
                }
				.foregroundColor(.primary)
				.padding(.top, 20)
				.padding(.bottom, 10)
                .padding(.horizontal)
                Divider()
                VStack(alignment: .leading, spacing: 30) {
                    ForEach(SideMenu.allCases) { item in
                        Button {
                            isPresented = false
                            switch item {
                            case .memberMGMT:
                                isSelectContent.toggle()
                            case .inviteComm:
                                    commViewModel.kakao()
                            case .delegateManager:
                                if commViewModel.isCurrentCommManager {
                                    isDelegateManagerView = true
                                }
                            }
                        } label: {
                            if item == .inviteComm {
                                HStack {
                                    Text(item.title)
                                    Spacer()
                                    Image(systemName: "chevron.right")
										.foregroundColor(.gray)
                                }
                            } else {
                                if commViewModel.isCurrentCommManager {
                                    HStack {
                                        Text(item.title)
										Spacer()
                                        Spacer()
                                        Image(systemName: "chevron.right")
											.foregroundColor(.gray)
                                    }
                                }
                            }
                        }
						.foregroundColor(.primary)
						.font(.regular(14))
                    }
                }
                .padding(.top, 20)
                .padding(.horizontal)
            }
			.background(RoundedCorners(tl: 22, tr: 0, bl: 0, br: 0).fill(Color(uiColor: .systemBackground)))
            Spacer()
            HStack {
                ForEach(SideBarBtn.allCases) { btn in
                    Button {
                        switch btn {
                        case .out:
                            if commViewModel.isCurrentCommManager {
                                if commViewModel.isCurrentCommMembersEmpty {
                                    isDeleteCommAlert = true
                                } else {
                                    isNeedDelegateAlert = true
                                }
                            } else {
                                isLeaveCommAlert.toggle()
                            }
                        case .alert:
                            Task {
                                await userViewModel.commAlertToggle(id: commViewModel.currentComm?.id ?? "")
                            }
                        case .setting:
                            isPresented = false
                            isSettingPresented.toggle()
                        }
                    } label: {
                        if btn == .setting {
                            if commViewModel.isCurrentCommManager {
                                Image(
                                    systemName: btn.getImageStr(isOn: commViewModel.isAlertOn)
                                )
                                .padding(.leading, 30)
                            }
                        } else {
                            Image(
                                systemName: btn.getImageStr(isOn: commViewModel.isAlertOn)
                            )
                        }
                    }
                    if btn == .out {
                        Spacer()
                    }
                }
            }
			.foregroundColor(.primary)
            .padding(.horizontal)
            .frame(maxWidth: .infinity)
            .frame(height: 55)
            .padding(.bottom, CGFloat.screenHeight == 667 ? 10 : 0)
            .background(Color.purple2.opacity(0.4))
        }
        .fullScreenCover(isPresented: $isSettingPresented) {
            CommSettingView(editMode: .edit)
        }
        .fullScreenCover(isPresented: $isSelectContent) {
            CommUserMgmtView()
        }
        .fullScreenCover(isPresented: $isDelegateManagerView) {
            CommDelegateManagerView(isPresented: $isDelegateManagerView)
        }
        .alert("그룹에서 나가시겠습니까?", isPresented: $isLeaveCommAlert) {
            Button("예", role: .destructive) {
                Task {
                    guard let currntID = commViewModel.currentComm?.id else { return }
                    await commViewModel.leaveComm()
                    await userViewModel.leaveComm(commID: currntID)
                    isPresented = false
                }
            }
            Button("취소", role: .cancel) { }
        } message: {
            Text("해당 그룹으로 진행되던 모든 알림 및 정보들이 삭제됩니다.")
        }
        .alert("그룹을 나가려면 매니저 권한을 위임하세요", isPresented: $isNeedDelegateAlert) {
            Button("유저 선택") {
                isDelegateManagerView = true
            }
            Button("그룹 제거", role: .destructive) {
                isDeleteCommAlert = true
            }
            Button("취소", role: .cancel) { }
        }
        .alert("그룹이 제거됩니다.", isPresented: $isDeleteCommAlert) {
            Button("제거하기", role: .destructive) {
                Task {
                    await commViewModel.deleteComm()
                    try? await userViewModel.loadUserData()
                    isPresented = false
                }
            }
            Button("취소", role: .cancel) { }
        } message: {
            Text("해당 그룹의 모든 유저의 알림 및 정보들이 삭제됩니다.")
        }
    }
    
    private enum SideMenu: CaseIterable, Identifiable {
        case inviteComm, memberMGMT, delegateManager
        
        var title: String {
            switch self {
            case .inviteComm:
                return "그룹 초대"
            case .memberMGMT:
                return "구성원 관리"
            case .delegateManager:
                return "매니저 위임"
            }
        }
        
        var id: Self { self }
    }
    
    private enum SideBarBtn: CaseIterable, Identifiable {
        case out
        case alert
        case setting
        
        func getImageStr(isOn: Bool) -> String {
            switch self {
            case .out:
                return "rectangle.portrait.and.arrow.forward"
            case .alert:
                return isOn ? "bell.fill" : "bell.slash"
            case .setting:
                return "gearshape"
            }
        }
        
        var id: Self { self }
    }
	
	struct RoundedCorners: Shape {
		var tl: CGFloat = 0.0
		var tr: CGFloat = 0.0
		var bl: CGFloat = 0.0
		var br: CGFloat = 0.0
		
		func path(in rect: CGRect) -> Path {
			var path = Path()
			
			let w = rect.size.width
			let h = rect.size.height
			
			let tr = min(min(self.tr, h/2), w/2)
			let tl = min(min(self.tl, h/2), w/2)
			let bl = min(min(self.bl, h/2), w/2)
			let br = min(min(self.br, h/2), w/2)
			
			path.move(to: CGPoint(x: w / 2.0, y: 0))
			path.addLine(to: CGPoint(x: w - tr, y: 0))
			path.addArc(center: CGPoint(x: w - tr, y: tr), radius: tr,
						startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)
			
			path.addLine(to: CGPoint(x: w, y: h - br))
			path.addArc(center: CGPoint(x: w - br, y: h - br), radius: br,
						startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)
			
			path.addLine(to: CGPoint(x: bl, y: h))
			path.addArc(center: CGPoint(x: bl, y: h - bl), radius: bl,
						startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)
			
			path.addLine(to: CGPoint(x: 0, y: tl))
			path.addArc(center: CGPoint(x: tl, y: tl), radius: tl,
						startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)
			path.closeSubpath()
			
			return path
		}
	}
}

struct GroupSideBarView_Preview: PreviewProvider {
    struct Preview: View {
        @StateObject private var commViewModel: CommViewModel = .init()
        @State private var isPresented = false
        
        var body: some View {
            CommSideBarView(isPresented: $isPresented)
                .environmentObject(commViewModel)
                .environmentObject(UserViewModel())
                .onAppear {
                    commViewModel.currentCommMembers = [
                        .fakeCurrentUser,
                        .fakeCurrentUser,
                        .fakeCurrentUser,
                    ]
                }
        }
    }
    
    static var previews: some View {
        Preview()
    }
}
