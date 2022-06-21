//
//  AppDelegate.swift
//  Notifications app
//
//  Created by Y.TOBITA on 2020/12/13.
//

import UIKit
import BackgroundTasks

class PrintOperation: Operation {
    let id: Int

    init(id: Int) {
        self.id = id
    }

    override func main() {
        print("this operation id is \(self.id)")
    }
}

@UIApplicationMain
//@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate{
    
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "jp.co.background_refresh_task", using: nil) { task in
            // バックグラウンド処理したい内容 ※後述します
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
        return true
    }

    private func scheduleAppRefresh() {
        
        // Info.plistで定義したIdentifierを指定
        let request = BGAppRefreshTaskRequest(identifier: "jp.co.background_refresh_task")
        // 最低で、どの程度の期間を置いてから実行するか指定
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)

        do {
            // スケジューラーに実行リクエストを登録
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // バックグラウンド起動に移ったときにルケジューリング登録
        scheduleAppRefresh()
    }
    
    private func handleAppRefresh(task: BGAppRefreshTask) {
          // 1日の間、何度も実行したい場合は、1回実行するごとに新たにスケジューリングに登録します
          scheduleAppRefresh()

          let queue = OperationQueue()
          queue.maxConcurrentOperationCount = 1

          // 時間内に実行完了しなかった場合は、処理を解放します
          // バックグラウンドで実行する処理は、次回に回しても問題ない処理のはずなので、これでOK
          task.expirationHandler = {
              queue.cancelAllOperations()
          }

          // サンプルの処理をキューに詰めます
          let array = [1, 2, 3, 4, 5]
          array.enumerated().forEach { arg in
              let (offset, value) = arg
              let operation = PrintOperation(id: value)
              if offset == array.count - 1 {
                  operation.completionBlock = {
                      // 最後の処理が完了したら、必ず完了したことを伝える必要があります
                      task.setTaskCompleted(success: operation.isFinished)
                  }
              }
              queue.addOperation(operation)
          }
      }
    //
    
    
if #available(iOS 10.0, *) {
    // iOS 10
    let center = UNUserNotificationCenter.current()
    center.requestAuthorization(options: [.badge, .sound, .alert], completionHandler: { (granted, error) in
        if error != nil {
            return
        }
        if granted {
            print("通知許可")
            
            let center = UNUserNotificationCenter.current()
            center.delegate = self
            
        } else {
            print("通知拒否")
        }
    })
    
} else {
    // iOS 9以下
    let settings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
    UIApplication.shared.registerUserNotificationSettings(settings)
}
return true

}

// MARK: UISceneSession Lifecycle

func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
}

func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}




extension AppDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        // アプリ起動時も通知を行う
        completionHandler([ .badge, .sound, .alert ])
    }
}


