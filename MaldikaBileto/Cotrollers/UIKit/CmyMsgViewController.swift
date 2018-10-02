//
//  CmyMsgViewController.swift
//  MaldikaBileto
//
//  Created by x.yang on 2018/06/28.
//  Copyright © 2018年 x.yang. All rights reserved.
//

import UIKit

class CmyMsgViewController: UIAlertController {
    
    static let errorTitle: String = {
        return CmyLocaleUtil.shared.localizedMisc(key: "Common.errorMessage.title", commenmt: "エラー")
    }()
    static let warningTitle: String = {
        return CmyLocaleUtil.shared.localizedMisc(key: "Common.warningMessage.title", commenmt: "警告")
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    class func showError(sender:UIViewController?, error: Error, extra: String?) {
        guard let sender = sender else { return }
        var msg: String = ""
        var title: String = CmyMsgViewController.errorTitle
        if let extra = extra {
            msg = extra
        }
        if error._code != CmyAPIClient.HttpStatusCode.firebaseNetworkError.rawValue { //通信エラー
            msg = "\(msg)\n\(error.localizedDescription) (code:\(error._code))"
        } else {
            let msgTmp = CmyLocaleUtil.shared.localizedMisc(key: "Common.cmyApi.message.code", commenmt: "").components(separatedBy: "::")
            title = msgTmp[0]
            msg = String(format: msgTmp[1], error._code)
        }
        let vc = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        vc.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        sender.present(vc, animated: true, completion: nil)
    }
    
/*
    "Common.cmyApi.message.400" = "認証エラー::不正なアクセスと判断されました。(code:400)";
    "Common.cmyApi.message.404" = "エラー::ユーザまたは、データが存在しません。(code:404)";
    "Common.cmyApi.message.406" = "コンテンツエラー::権限が無いか、ステータスが一致しません。(code:406)";
    "Common.cmyApi.message.409" = "データエラー::データが重複しています。(code:409)";
    "Common.cmyApi.message.422" = "入力エラー::入力内容が不正です。\n入力内容を確認してください。(code:422)";
    "Common.cmyApi.message.500" = "システム内部エラー::時間をおいて再度実行してください。(code:500)";
    "Common.cmyApi.message.code" = "通信エラー::サーバとの通信に失敗しました。電波の良いところで実行するか、時間をおいて再度実行してください。(code:%d)";
 */
    class func showError(sender:UIViewController?, error: (Int, Data?, Error), extra: String?) {
        guard let sender = sender else { return }
        var msg: String = ""
        var title: String = CmyMsgViewController.errorTitle
        
        if let extra = extra {
            if extra.contains("[VeriTrans]") {
                if let dic = try! JSONSerialization.jsonObject(with: error.1!, options: []) as? [String: Any] {
                    msg = dic["message"] as? String ?? ""
                }
            } else {
                msg = "\(extra)\n\(error.2.localizedDescription)"
            }
        } else {
            var msgTmp: [String]!
            //Http Status Codeが400 - 500であれば、該当のメッセージを取得する
            // それ以外の場合、通信エラーとする
            // エラー500のときだけ、エラーを細かく見る
            var netErrFlg: Bool = false
            if error.0 == CmyAPIClient.HttpStatusCode.internalError.rawValue {
                netErrFlg = !CmyAPIClient.verifyConnect(host: CmyAPIClient.webApiPath)
            }
            if [CmyAPIClient.HttpStatusCode.invalidAccess.rawValue,
                CmyAPIClient.HttpStatusCode.notFound.rawValue,
                CmyAPIClient.HttpStatusCode.notPermited.rawValue,
                CmyAPIClient.HttpStatusCode.duplicatedData.rawValue,
                CmyAPIClient.HttpStatusCode.dirtyData.rawValue,
                CmyAPIClient.HttpStatusCode.internalError.rawValue].contains(error.0) && !netErrFlg {
                msgTmp = CmyLocaleUtil.shared.localizedMisc(key: "Common.cmyApi.message.\(error.0)", commenmt: "").components(separatedBy: "::")
                title = msgTmp[0]
                msg = msgTmp[1]
            } else {
                msgTmp = CmyLocaleUtil.shared.localizedMisc(key: "Common.cmyApi.message.code", commenmt: "").components(separatedBy: "::")
                title = msgTmp[0]
                msg = String(format: msgTmp[1], error.2._code)
            }
        }
        //msg = "\(msg)\(error.2.localizedDescription)(error code\(error.0))"
        let vc = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        vc.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        sender.present(vc, animated: true, completion: nil)
    }

    class func showMsg(sender:UIViewController?, msg: String, title: String, okHandler: ((UIAlertAction) -> Swift.Void)? = nil) {
        guard let sender = sender else { return }
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: okHandler))
        sender.present(alert, animated: true, completion: nil)
    }

    class func showWarn(sender:UIViewController?, msg: String, title: String) {
        guard let sender = sender else { return }
        let vc = UIAlertController(title: CmyMsgViewController.warningTitle, message: msg, preferredStyle: .alert)
        vc.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        sender.present(vc, animated: true, completion: nil)
    }
}
