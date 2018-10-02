//
//  CmyTicketListViewController.swift
//  MaldikaBileto
//
//  Created by x.yang on 2018/07/12.
//  Copyright © 2018年 x.yang. All rights reserved.
//

import UIKit

class CmyTicketListViewController: CmyViewController {

//    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageLabel: UILabel!

    
    var filterMenuView: ContextMenuView = ContextMenuView()
    
    private static var _noticeRegisted: Bool = false
    
    fileprivate var ticketList: TicketList = TicketList(tickets: [])
    fileprivate var isReloadedData: Bool = false
    fileprivate var _lastDisappearTime: Date = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.resetNavigationItemTitle()

        //filterメニュー
        self.filterMenuView.selectedRow = 0
        let items = CmyLocaleUtil.shared.localizedMisc(key: "TicketList.navigationbar.rightNaviButton.menuitems", commenmt: "fliterメニュー").components(separatedBy: ",")
        let naviFrame = self.navigationController?.navigationBar.frame
        self.filterMenuView.setupContents(position: CGPoint(x: self.view.frame.width - 170, y: (naviFrame?.origin.y)! + (naviFrame?.size.height)! + 3), items: items)
        self.view.addSubview(self.filterMenuView.contentView)
        self.filterMenuView.menuDelegate = self
        
        // タイトルバーからフィルタメニューを閉じれるようにカスタマイズする
        self.navigationItem.titleView = {() -> UIView in
            let titleView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 250, height: 150))
            
            let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.viewGestureRecognizerTapped(recognizer:)))
            tapGesture.numberOfTapsRequired = 1
            titleView.addGestureRecognizer(tapGesture)
            return titleView
        }()
        
        //一覧表の設定
        self.tableView.register(TicketInfoCell.nib, forCellReuseIdentifier: TicketInfoCell.identifier)
        self.tableView.contentInset = .zero
        self.tableView.tableFooterView = UIView()
        self.tableView.register(TicketInfoCell.nib, forCellReuseIdentifier: TicketInfoCell.identifier)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        // 長時間処理インジケーターの設定
        self.myIndicator = UIActivityIndicatorView.setupIndicator(parentView: self.view)
        
        //起動画面判定
        //
        self.judgeLoginView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //長時間処理Indicatorを起動する
        self.myIndicator.startAnimatingEx(sender: nil)
        
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let check_load_data = {() -> Bool in
            let timeInterval = Date().timeIntervalSince(self._lastDisappearTime)
            let ms = Int(timeInterval * 1000)
            return ms <= 3000
        }
        
        //チェック一覧実行要否を判定する
        self.isReloadedData = check_load_data()

        //長時間処理Indicatorを止める
        self.myIndicator.stopAnimatingEx(sender: nil)
        self.messageLabel.isHidden = true

        // １秒後で最新表示を行う
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // 1秒後に実行する処理
            if !self.isReloadedData {
                //すべてのチケットを対象に検索する
                self.getTicketList(fitler: self.filterMenuView.selectedRow)
                
                //プッシュ通知登録
                if !CmyTicketListViewController._noticeRegisted {
                    CmyViewController.appDelegate?.registerFirebseMessaging(for: UIApplication.shared, completionHandler: {
                        //お知らせ一覧取得する
                        CmyAPIClient.fetchInquireList(completionHander: nil)
                    })
                    CmyTicketListViewController._noticeRegisted = true
                } else {
                    //お知らせ一覧取得する
                    CmyAPIClient.fetchInquireList(completionHander: nil)
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self._lastDisappearTime = Date()
        self.isReloadedData = true
        //フィルタメニューを非表示にする
        self.filterMenuView.showMenu(showed: false)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.isReloadedData = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //reset navigation title
    //
    override func resetNavigationItemTitle() {
        self.navigationItem.title = CmyLocaleUtil.shared.localizedMisc(key: "TicketList.navigationbar.top.title", commenmt: "TICKET LIST")
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        self.filterMenuView.showMenu(showed: false)

        //チケット発行画面の遷移
        let move_ticket_issue = {(destVC: CmyTicketIssueViewController) in
            //遷移先実行後のコールバックを設定
            destVC.dismissHandler = {(ticketItem , ticketImageData) in
                guard let ticketItem = ticketItem else {return}
                CATransaction.begin()
                CATransaction.setCompletionBlock({
                    // タブバーを表示する
                    self.tabBarController?.tabBar.isHidden = false
                    self.resetNavigationItemTitle()
                    //share ticket for other app
                    self.shareTicket(data: ticketImageData!, ticketItem: ticketItem)
                })
                self.navigationController?.popViewController(animated: true)
                CATransaction.commit()
            }
            //遷移元を記録する
            destVC.sourceViewController = self
            
            //自己使用チケット使用_QR画面へ遷移する
            self.clearNavigationItemTitle()
            
            self.tabBarController?.tabBar.isHidden = true
            self.navigationController?.pushViewController(destVC, animated: true)
        }
        
        //チケット発行APIの呼び出し
        //呼ぶ前に、標準カードが登録されているかを確認する
        let call_publish_ticket = {[weak self] (destVC: CmySelfTicketViewViewController) in
            self?.myIndicator.startAnimatingEx(sender: sender)
            CmyCardAPI.getCardList(completion: {(cardList, err) in
                self?.myIndicator.stopAnimatingEx(sender: sender)
                
                guard let weakSelf = self else {return}
                if let err = CmyAPIClient.errorInfo(error: err), err.0 != CmyAPIClient.HttpStatusCode.notFound.rawValue {
                    CmyMsgViewController.showError(sender: weakSelf, error:err, extra: nil/*CmyLocaleUtil.shared.localizedMisc(key: "TicketIssue.view.check.1", commenmt: "")*/)
                    return
                }
                
                if let card = cardList?.cards.first(where: { (aCard) -> Bool in
                    return aCard.defaultCard == Card.DefaultCard.checked
                }) {
                    let ticketPreviewItem = TicketForAdd(
                        ticketType: ._private,
                        ticketAmount: nil,
                        ticketTitle: nil,
                        ticketExpirationDate: nil,
                        cardId: card.cardId)
                    
                    weakSelf.myIndicator.startAnimatingEx(sender: sender)

                    //チケット発行APIの呼び出し
                    CmyTicketAPI.publishTicket(
                        body: ticketPreviewItem,
                        completion: { (result, error) in
                            weakSelf.myIndicator.stopAnimatingEx(sender: nil)
                            
                            if let err = CmyAPIClient.errorInfo(error: error) {
                                CmyMsgViewController.showError(sender: weakSelf, error:err, extra:nil/* CmyLocaleUtil.shared.localizedMisc(key: "TicketIssuePreview.view.check.2", commenmt: "通信エラーが発生しました。\n実行します。")*/)
                                return
                            }

                            //MaldikaBiletoにFcmトークン更新を行う
                            //
                            weakSelf.myIndicator.startAnimatingEx(sender: nil)

                            let updUser = UserForUpdate(phoneNumber: nil, nickname: nil, birthday: nil, gender: nil, email: nil, password: nil,fcmToken: Messaging.messaging().fcmToken)
                            CmyUserAPI.updateUser(body: updUser, completion: {_, error2 in
                                weakSelf.myIndicator.stopAnimatingEx(sender: nil)

                                if let err2 = CmyAPIClient.errorInfo(error: error) {
                                    CmyMsgViewController.showError(sender: weakSelf, error:err2, extra: nil/* CmyLocaleUtil.shared.localizedMisc(key: "TicketIssuePreview.view.check.2", commenmt: "通信エラーが発生しました。\n実行します。")*/)
                                    return
                                }
                                //遷移先にデータを渡す
                                destVC.imageData = result?.ticketImage
                                destVC.card = card
                                
                                //終了コールバックを設定する
                                destVC.dismissHandler = {
                                    weakSelf.getTicketList(fitler: weakSelf.filterMenuView.selectedRow)
                                }
                                //自己使用チケット使用_QR画面へ遷移する
                                destVC.sourceViewController = weakSelf
                                weakSelf.clearNavigationItemTitle()
                                weakSelf.tabBarController?.tabBar.isHidden = true
                                weakSelf.navigationController?.pushViewController(destVC, animated: true)
                            })
                    })

                } else {
                    CmyMsgViewController.showMsg(sender: weakSelf, msg: CmyLocaleUtil.shared.localizedMisc(key: "TicketList.view.check.3" ,commenmt: "標準カードが登録されておりません。標準カード登録後、再度実行してください。"), title: "")
                    weakSelf.myIndicator.stopAnimatingEx(sender: nil)
                    
                }
            })
        }
        
        //
        // チケット発行画面遷移処理
        //
        if let mySegue = segue as? CmyPushFadeSegue , let destVC = segue.destination as? CmyTicketIssueViewController {
            mySegue.extraHandler = {
                
                //メール認証状態取得
                if let _ = Auth.auth().currentUser?.email {
                Auth.auth().currentUser?.getIDTokenForcingRefresh(false, completion: {[weak self] (idToken, error) in
                    guard let weakSelf = self else {return}
                    if !CmyAPIClient.prepareHeaders(sender: self, idToken: idToken, error:  error) {return}
                    weakSelf.myIndicator.startAnimatingEx(sender: sender)
                    
                    CmyUserAPI.getTicketIssuePermission(
                        completion: { (result, error2) in
                            weakSelf.myIndicator.stopAnimatingEx(sender: sender)
                            if let err2 = CmyAPIClient.errorInfo(error: error2), err2.0 != CmyAPIClient.HttpStatusCode.notFound.rawValue {
                                CmyMsgViewController.showError(sender: weakSelf, error:err2, extra: CmyLocaleUtil.shared.localizedMisc(key: "TicketList.view.check.2" ,commenmt: ""))
                                return
                            }
                            
                            if let result = result, result.permission {
                                //チケット発行画面
                                move_ticket_issue(destVC)
                            }else{
                                CmyMsgViewController.showMsg(sender: weakSelf, msg: CmyLocaleUtil.shared.localizedMisc(key: "Common.email.approvalState.check.none" ,commenmt: "メール未認証"), title: "")
                                return
                            }
                    })
                })
                } else {
                    //チケット発行画面
                    move_ticket_issue(destVC)
                }
            }
            return
        }
        
        //
        // 自分で使う画面へ遷移処理
        //
        if segue.destination is CmySelfTicketViewViewController {
            self.checkPasscodeSetting {[weak self]() in
                guard let weakSelf = self else {return}
                //メール認証状態取得
                if let _ = Auth.auth().currentUser?.email {
                    Auth.auth().currentUser?.getIDTokenForcingRefresh(false, completion: { (idToken, error) in
                        if !CmyAPIClient.prepareHeaders(sender: self, idToken: idToken, error:  error) {return}
                        weakSelf.myIndicator.startAnimatingEx(sender: nil)

                        CmyUserAPI.getTicketIssuePermission(
                            completion: { (result, error2) in
                                weakSelf.myIndicator.stopAnimatingEx(sender: nil)
                                if let err2 = CmyAPIClient.errorInfo(error: error2), err2.0 != CmyAPIClient.HttpStatusCode.notFound.rawValue {
                                    CmyMsgViewController.showError(sender: weakSelf, error:err2, extra: nil/* CmyLocaleUtil.shared.localizedMisc(key: "TicketList.view.check.2" ,commenmt: "")*/)
                                    return
                                }
                                
                                if let result = result, result.permission {
                                    //チケット発行API呼び出し
                                    call_publish_ticket(segue.destination as! CmySelfTicketViewViewController)
                                }else{
                                    CmyMsgViewController.showMsg(sender: weakSelf, msg: CmyLocaleUtil.shared.localizedMisc(key: "Common.email.approvalState.check.none" ,commenmt: "メール未認証"), title: "")
                                    weakSelf.myIndicator.stopAnimatingEx(sender: nil)
                                    return
                                }
                        })
                    })
                } else {
                    //チケット発行API呼び出し
                    call_publish_ticket(segue.destination as! CmySelfTicketViewViewController)
                }
            }
            return
        }

        //
        // 自チケット詳細への遷移処理
        //
        if let indexPath = sender as? IndexPath {
            guard let mySegue = segue as? CmyPushFadeSegue else {return}
            mySegue.extraHandler = {
                Auth.auth().currentUser?.getIDTokenForcingRefresh(false, completion: {[weak self] (idToken, error) in
                    guard let weakSelf = self else {return}
                    if !CmyAPIClient.prepareHeaders(sender: self, idToken: idToken, error:  error) {return}
                    weakSelf.myIndicator.startAnimatingEx(sender: nil)

                    //チケット詳細情報を取得する
                    CmyTicketAPI.getTicket(
                        ticketNumber: weakSelf.ticketList.tickets[indexPath.row].ticketNumber!,
                        completion: { (ticket, error) in
                            weakSelf.myIndicator.stopAnimatingEx(sender: nil)
                            if let err = CmyAPIClient.errorInfo(error: error) {
                                CmyMsgViewController.showError(sender: weakSelf, error: err, extra: nil)
                                return
                            }
 
                            //エラーない場合、該当の詳細画面へ遷移する
                            if let destVC = segue.destination as? CmyUnusedGiftTicketDetailsViewController  {
                                destVC.ticket = ticket
                                destVC.sourceViewController = weakSelf
                                destVC.dismissHandler = {
                                    weakSelf.getTicketList(fitler: weakSelf.filterMenuView.selectedRow)
                                }
                            } else if let destVC = segue.destination as? CmyUnusedPrivateTicketDetailsViewController  {
                                destVC.ticket = ticket
                                destVC.sourceViewController = weakSelf
                                destVC.dismissHandler = {
                                    weakSelf.getTicketList(fitler: weakSelf.filterMenuView.selectedRow)
                                }
                            } else if let destVC = segue.destination as? CmyUsedGiftTicketDetailsViewController  {
                                destVC.ticket = ticket
                                destVC.sourceViewController = weakSelf
                                destVC.dismissHandler = {
                                    weakSelf.getTicketList(fitler: weakSelf.filterMenuView.selectedRow)
                                }
                            } else if let destVC = segue.destination as? CmyUsedPrivateTicketDetailsViewController  {
                                destVC.ticket = ticket
                                destVC.sourceViewController = weakSelf
                                destVC.dismissHandler = {
                                    weakSelf.getTicketList(fitler: weakSelf.filterMenuView.selectedRow)
                                }
                            } else if let destVC = segue.destination as? CmyErredTicketDetailsViewController  {
                                destVC.ticket = ticket
                                destVC.sourceViewController = weakSelf
                                destVC.dismissHandler = {
                                    weakSelf.getTicketList(fitler: weakSelf.filterMenuView.selectedRow)
                                }
                            } else {
                                return
                            }
                            weakSelf.clearNavigationItemTitle()
                            weakSelf.tabBarController?.tabBar.isHidden = true
                            weakSelf.navigationController?.pushViewController(segue.destination, animated: true)
                    })
                })
            }
        }
        super.prepare(for: segue, sender: self)
    }
    
    // MARK: Data share
    //
    func shareTicket(data: TicketImageData, ticketItem: TicketListItem?) {
        
        var objectsToShare = [AnyObject]()
        
//        if let url = url {
//            objectsToShare = [url as AnyObject]
//        }
//
        if let image = UIImage.generateQRCodeWithBase64(from: data.ticketImage) {
            objectsToShare = [image as AnyObject]
        }
        
//        if let msg = msg {
//            objectsToShare = [msg as AnyObject]
//        }
        
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityVC.modalPresentationStyle = .popover
        activityVC.popoverPresentationController?.sourceView = self.navigationController?.topViewController?.view
        
        //チケット一覧データの再表示
        self.present(activityVC, animated: true) {
            if let _ = ticketItem {
                self.getTicketList(fitler: self.filterMenuView.selectedRow)
            }
        }
    }
    
    // Manage keyboard and tableView visibility
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        guard let touch:UITouch = touches.first else
        {
            return;
        }
        if touch.view == self.view
            || touch.view == self.filterMenuView.contentView
        {
            self.filterMenuView.showMenu(showed: false)
        }

    }

    // filterボタンタップ時処理
    //
    @IBAction func rightNaviButtonDidTap(sender: UIBarButtonItem) {
        self.filterMenuView.showMenu(showed: self.filterMenuView.isHidden)
    }
    
    //フィルタメニュー外タップ時処理
    @objc func viewGestureRecognizerTapped(recognizer:UITapGestureRecognizer) {
        if recognizer.numberOfTapsRequired == 1 && recognizer.view != self.filterMenuView{
            self.filterMenuView.showMenu(showed: false)
        }
    }

    // MARK: TICKECT LIST API CALL
    //チケット一覧取得
    func getTicketList(fitler: Int) {
        self.isReloadedData = true

        let nodata_proc = {[weak self] () in
            //データない場合
            self?.ticketList = TicketList(tickets: [])
            self?.tableView.reloadData()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                // 1秒後に実行する処理
                self?.messageLabel.isHidden = false
                //長時間処理インジケータの停止
                self?.myIndicator.stopAnimatingEx(sender: nil)
            }
        }
        
        self.myIndicator.startAnimatingEx(sender: nil)
        Auth.auth().currentUser?.getIDTokenForcingRefresh(false, completion: { [weak self](idToken, error) in
            self?.myIndicator.stopAnimatingEx(sender: nil)
            if !CmyAPIClient.prepareHeaders(sender: self, idToken: idToken, error:  error) {
                //データない場合
                nodata_proc()
                return
            }
            self?.myIndicator.startAnimatingEx(sender: nil)

            CmyTicketAPI.getTicketList(filter: fitler, sort: "ticket_expiration_date", order: "desc", completion: { (result, err) in

                if let err = CmyAPIClient.errorInfo(error: err), err.0 != CmyAPIClient.HttpStatusCode.notFound.rawValue {
                    CmyMsgViewController.showError(sender: self, error:err, extra: CmyLocaleUtil.shared.localizedMisc(key: "TicketList.view.check.1" ,commenmt: ""))
                    //データない場合
                    nodata_proc()
                    return
                }
                self?.myIndicator.startAnimatingEx(sender: nil)
                
                //データ有無判定
                if let result = result, result.tickets.count > 0 {
                    self?.ticketList = result
                    self?.tableView.reloadData()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        // 1秒後に実行する処理
                        self?.messageLabel.isHidden = true
                        
                        //長時間処理インジケータの停止
                        self?.myIndicator.stopAnimatingEx(sender: nil)
                    }

                } else {
                    //データない場合
                    nodata_proc()
                }
            })
        })
    }

    // スプラッシュ画面を表示する
    //
    func splashScreenWithAnimation() {
        guard let views = UIStoryboard.splash().instantiateInitialViewController()?.view.subviews else {return }
        var imgView: UIImageView!
        for view in views {
            if view is UIImageView {
                imgView = view as? UIImageView
                break
            }
        }
        
        if let imgView = imgView {
            //透明から不透明まで
            imgView.alpha = 0.05
            UIView.animate(withDuration: 1.0,
                           delay: 0.1,
                           options: UIViewAnimationOptions.curveLinear,
                           animations: { () in
                            //imgView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                            
                            imgView.alpha = 1.0
            }, completion: { (Bool) in
                sleep(3)
            })
        }
    }

    // MARK: - judge which viewcntroller to be launched
    //
    func judgeLoginView() {
         //カレントユーザのログイン状態によりどの画面を起動するかを判別する
        CmyViewController.mainViewController = self
         CmyViewController.loadCheckForMaldikaBileto(
            checkHandler: { [weak self](loadState, error) in
                 guard let weakSelf = self else {return}
                if let error = CmyAPIClient.errorInfo(error: error), error.0 != CmyAPIClient.HttpStatusCode.notFound.rawValue {
                     CmyMsgViewController.showError(sender: weakSelf, error:error, extra: nil/*"アプリ起動エラー"*/)
                     return
                 }
            
                 //初期起動画面を判定
                 let storyboard = UIStoryboard.main()
                 var firstVC: UIViewController?
                 switch (loadState) {
                    case .dummy:/*
                        let nav = storyboard.instantiateViewController(withIdentifier:CmyStoryboardIds.tutorialNav.rawValue) as! UINavigationController
                        //nav.viewControllers = [storyboard.instantiateViewController(withIdentifier:CmyStoryboardIds.userRegistration.rawValue)]
                        nav.viewControllers = [storyboard.instantiateViewController(withIdentifier:CmyStoryboardIds.userLogin.rawValue)]
                        firstVC = nav*/
                    //firstVC = storyboard.instantiateViewController(withIdentifier:CmyStoryboardIds.userLoginNav.rawValue)
                    break
                 case .passcode:
                    //firstVC = storyboard.instantiateViewController(withIdentifier:"MainTabs")
                    break
                 case .tutorial:
                    firstVC = storyboard.instantiateViewController(withIdentifier:CmyStoryboardIds.tutorialNav.rawValue)
                 case .phoneNumberReg:
                    let nav = storyboard.instantiateViewController(withIdentifier:CmyStoryboardIds.tutorialNav.rawValue) as! UINavigationController
                    nav.viewControllers = [storyboard.instantiateViewController(withIdentifier:CmyStoryboardIds.phoneNumberRegistration.rawValue)]
                    firstVC = nav
                 case .main:
                    break
                }
         
                //チケット一覧表示後の後処理を用意する
                //
                let show_ticketlist_post_proc = {
                    //チケット一覧取得
                    //filter: 0（すべて）
                    weakSelf.getTicketList(fitler: 0)
                    
                    //プッシュ通知登録
                    if !CmyTicketListViewController._noticeRegisted {
                        CmyViewController.appDelegate?.registerFirebseMessaging(for: UIApplication.shared, completionHandler:  {
                            //お知らせ一覧取得
                            CmyAPIClient.fetchInquireList(completionHander: nil)
                        })
                        CmyTicketListViewController._noticeRegisted = true
                    }
                }
                
                //遷移先の画面を表示させる
                if let firstVC = firstVC {
                    firstVC.modalTransitionStyle = .crossDissolve
                    weakSelf.present(firstVC, animated: true, completion:nil)
                }  else if loadState == .passcode {
                    weakSelf.checkPasscodeSetting() {
                        //チケット一覧表示後の後処理を実施する
                        show_ticketlist_post_proc()
                    }
                } else {
                    //チケット一覧表示後の後処理を実施する
                    show_ticketlist_post_proc()
                }
         })
 
    }
}


// MARK: UITableViewDataSource

extension CmyTicketListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.ticketList.tickets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let select_segueId = {(cell: TicketInfoCell, item: TicketListItem) in
            var segueId: CmySegueIds!
            //チケット種別とステータスによって該当の明細を選別する
            if item.ticketType == TicketListItem.TicketType.gift {
                switch item.ticketStatus {
                case .unused:
                    segueId = CmySegueIds.unusedGiftTicketDetailsSegue
                case .used:
                    segueId = CmySegueIds.usedGiftTicketDetailsSegue
                case .error:
                    segueId = CmySegueIds.erredTicketDetailsSegue
                }
            }else if item.ticketType == TicketListItem.TicketType._private {
                switch item.ticketStatus {
                case .unused:
                    segueId = CmySegueIds.unusedPrivateTicketDetailsSegue
                case .used:
                    segueId = CmySegueIds.usedPrivateTicketDetailsSegue
                case .error:
                    segueId = CmySegueIds.erredTicketDetailsSegue
                }
            }
            
            cell.segueId = segueId
        }
        

        // Set text from the data model
        let cell = tableView.dequeueReusableCell(withIdentifier: TicketInfoCell.identifier) as! TicketInfoCell

        // カレントセルにあてるデータを取得する
        let ticketListItem: TicketListItem = self.ticketList.tickets[indexPath.row]
        //タイトル
        cell.titleLabel.text = ticketListItem.ticketTitle
        
        //ステータス
        let statusValues = CmyLocaleUtil.shared.localizedMisc(key: "Common.Ticket.Status", commenmt: "チケットステータス").components(separatedBy: ",")
        let idx: Int? = TicketListItem.TicketStatus.allValues.index(of: ticketListItem.ticketStatus)
        if let idx = idx {
            cell.statusLabel.text = statusValues[idx]
            // ステータス(アイコン)
            cell.statusImageIndex = idx
        }
        
        //金額
        if ticketListItem.ticketType == TicketListItem.TicketType.gift {
            cell.amountLabel.text = "\(String.formatCurrencyString(number: ticketListItem.ticketAmount!)!) " + CmyLocaleUtil.shared.localizedMisc(key: "Common.Yen", commenmt: "")
            cell.amountLabel.attributedText = {(string: String, subString: String) -> NSAttributedString in
                let attrString = NSMutableAttributedString(string: string)
                let range = (string as NSString).range(of: subString)
                attrString.addAttribute(.font, value: UIFont.systemFont(ofSize: 18), range: range)
                return attrString
            }(cell.amountLabel.text!, CmyLocaleUtil.shared.localizedMisc(key: "Common.Yen", commenmt: ""))
        } else {
            cell.amountLabel.text = CmyLocaleUtil.shared.localizedMisc(key: "TicketList.amountLabel.private.title", commenmt: "自分で使う")
        }
        // 決済エラーの場合、文字色を赤にする
        cell.amountLabel.textColor = (ticketListItem.ticketStatus == TicketListItem.TicketStatus.error) ? UIColor.red : UIColor.darkText
        
        //使用期限（「自分で使う」でない　かつ　未使用のチケットに対して期限切れあり）
        if let expDate = ticketListItem.ticketExpirationDate,ticketListItem.ticketType == .gift {
            cell.expiryDateLabel.text = CmyLocaleUtil.shared.localizedMisc(key: "Common.ticketExpirationDate.label", commenmt: "有効期限:")
                + expDate.replacingOccurrences(of: "-", with: "/")
            if Date().toYYYYMMDDStringWithHyphen() > expDate && ticketListItem.ticketStatus == .unused {
                // ステータス(アイコン)
                cell.statusImageIndex = TicketInfoCell.expiredIndex
                // ステータス(文言)
                cell.statusLabel.text = statusValues[TicketInfoCell.expiredIndex]
            }
        } else {
            cell.expiryDateLabel.text = ""
        }
        
        _ = cell.addBorder(toSide: .bottom, withColor: UIColor(displayP3Red: 0xD8/0xFF, green: 0xD8/0xFF, blue: 0xD8/0xFF, alpha: 1.0), andThickness: 1)
        //決済日付
        // TODO

        //遷移先のセグエを設定する
        select_segueId(cell, ticketListItem)
        
        //その他の属性
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .default
        
        return cell
    }
}

// MARK: UITableViewDelegate

extension CmyTicketListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //チケットの種別と使用状態により該当するチケット詳細へ遷移する
        if let cell: TicketInfoCell = tableView.cellForRow(at: indexPath) as? TicketInfoCell {
            cell.preventDoubleTap()
            self.performSegue(withIdentifier: cell.segueId.rawValue, sender: indexPath)
        }
    }
}

// MARK: UICollectionViewDelegate

extension CmyTicketListViewController: ContextMenuViewDelegate {
    func  menuItem(menuItem: MenuItemCell) {
        //フィルタメニューを閉じるようにします
        self.filterMenuView.showMenu(showed: false)
        
        //選択されたフィルタをキーに、チケット一覧を再取得します
        self.getTicketList(fitler: self.filterMenuView.selectedRow)
    }
}

