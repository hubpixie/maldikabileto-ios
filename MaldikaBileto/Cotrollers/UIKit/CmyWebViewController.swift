//
//  CmyWebViewController.swift
//  MaldikaBileto
//
//  Created by venus.janne on 2018/07/29.
//  Copyright © 2018 x.yang. All rights reserved.
//

import UIKit
import WebKit

class CmyWebViewController: CmyViewController {
    
    @IBOutlet weak var webView: UIWebView!
    fileprivate var wkWebView: WKWebView!
    
    var url: String?
    var pageTitle: String?
    fileprivate let kErrorPageHtml: String = "error_page"
    
    class func openUrl(source: UIViewController, url: String, pageTitle: String? ) {
        if let inst = UIStoryboard.main().instantiateViewController(withIdentifier: CmyStoryboardIds.webView.rawValue) as? CmyWebViewController {
            inst.url = url
            inst.pageTitle = pageTitle
            inst.sourceViewController = source as? CmyViewController
            
            source.navigationItem.title = ""
            source.tabBarController?.tabBar.isHidden = true

            source.navigationController?.show(inst, sender: source)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = self.pageTitle
        
        if #available(iOS 11, *) {
            self.webView.removeFromSuperview()
            
            self.wkWebView = WKWebView(frame: CGRect(x: 8, y: 0, width: self.view.frame.width - 16, height: self.view.frame.height))
            self.view.addSubview(self.wkWebView)
            self.wkWebView.uiDelegate = self
            self.wkWebView.navigationDelegate = self
        } else {
            self.webView.topAnchor.constraint(equalTo: self.view.compatibleSafeAreaLayoutGuide.topAnchor).isActive = true
            self.webView.backgroundColor = UIColor.white
            self.webView.delegate = self
        }

        self.myIndicator = UIActivityIndicatorView.setupIndicator(parentView: self.view)
        if let url = URL(string: self.url ?? "") {
            // check network connection
            /*if !CmyAPIClient.verifyConnect(host: self.url ?? "") {
                CmyMsgViewController.showError(sender: self, error:(NSURLErrorNotConnectedToInternet, nil, NSError(domain: "MaldikaBileto", code: NSURLErrorNotConnectedToInternet, userInfo: nil)), extra: nil)
                return
            }*/

            let request = URLRequest(url: url)
            if #available(iOS 11, *) {
                self.wkWebView.load(request)
            } else {
                self.webView.loadRequest(request)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if self.sourceViewController != nil {
            // タイトル設定
            self.sourceViewController?.resetNavigationItemTitle()
        }
        self.sourceViewController?.tabBarController?.tabBar.isHidden = false
        super.viewWillDisappear(animated)
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

}

extension CmyWebViewController: WKUIDelegate {
    
}

extension CmyWebViewController:  WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
        self.myIndicator.stopAnimatingEx(sender: nil)
        self.myIndicator.startAnimatingEx(sender: nil)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        
        self.myIndicator.stopAnimatingEx(sender: nil)
        self._showErrorPage(error: error)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        self.myIndicator.stopAnimatingEx(sender: nil)
        self._showErrorPage(error: error)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.myIndicator.stopAnimatingEx(sender: nil)
    }
    
    // エラー発生時のエラー表示
    //
    private func _showErrorPage(error: Error) {
        let htmlFilePath : String! = Bundle.main.path(forResource: self.kErrorPageHtml, ofType: "html")
        if var htmlString = try? String(contentsOfFile: htmlFilePath!) {
            
            //ウェbページへのアクセス不可::ウェブページ(%@)は次の理由で読み込めませんでした\n%@
            let msgTmp = CmyLocaleUtil.shared.localizedMisc(key: "Web.errorPage.offline.message", commenmt: "オフライン時のメッセージ").components(separatedBy: "::")
            var urlString: String!
            if #available(iOS 11, *) {
                urlString = self.wkWebView.url?.absoluteString ?? ""
            } else {
                urlString = (self.webView.request?.url?.absoluteString)!
            }
            urlString = (urlString == "") ? self.url : nil

            let msg = String(format: msgTmp[1], urlString ?? "", error.localizedDescription)
            htmlString = htmlString.replacingOccurrences(of: "{{ErrorTitle}}", with: msgTmp[0])
            htmlString = htmlString.replacingOccurrences(of: "{{ErrorMessage}}", with: msg)
            
            if #available(iOS 11, *) {
                self.wkWebView.loadHTMLString(htmlString, baseURL: Bundle.main.bundleURL)
            } else {
                self.webView.loadHTMLString(htmlString, baseURL: Bundle.main.bundleURL)
            }
        }
    }
}

extension CmyWebViewController: UIWebViewDelegate {
    func webViewDidStartLoad(_ webView: UIWebView) {
        self.myIndicator.stopAnimatingEx(sender: nil)
        self.myIndicator.startAnimatingEx(sender: nil)
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.myIndicator.stopAnimatingEx(sender: nil)
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        self.myIndicator.stopAnimatingEx(sender: nil)
        self._showErrorPage(error: error)
    }

}
