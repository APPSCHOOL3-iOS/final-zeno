//
//  AppDelegate+FCM.swift
//  Zeno
//
//  Created by gnksbm on 2023/10/13.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI
import FirebaseCore
import FirebaseMessaging

class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate {
    @AppStorage("fcmToken") var fcmToken: String = ""
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Firebase 설정
        guard let filePath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
//        guard let filePath = Bundle.main.path(forResource: "GoogleService-Info-2", ofType: "plist"),
              let options = FirebaseOptions(contentsOfFile: filePath)
        else { return true }
        
        FirebaseApp.configure(options: options)
        
        // 원격 알림 등록
        UNUserNotificationCenter.current().delegate = self
        
        // 앱에서 사용 가능한 알림 옵션 세팅
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
        )
        
        application.registerForRemoteNotifications()
        
        FirebaseMessaging.Messaging.messaging().delegate = self
        
        return true
    }
    
    /// fcm 토큰이 등록 되었을 때
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    /// fcm server 에서 받는 토큰 appStorage 에 저장
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("AppDelegate - Firebase registration token: \(String(describing: fcmToken))")
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
        self.fcmToken = fcmToken ?? ""
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    /// 푸시메세지가 앱이 켜져 있을 상태에서 push 메세지 받을 때 처리
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {  
        let userInfo = notification.request.content.userInfo
        
        print("willPresent: userInfo: ", userInfo)
        
        completionHandler([.banner, .sound, .badge])
    }
    
    /// 백그라운드 동작 중 psuh 메세지를 받았을 때
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print("didReceive: userInfo: ", userInfo)
        completionHandler()
    }
}
