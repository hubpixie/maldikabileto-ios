//
//  CmyStartViewController.swift
//  MaldikaBileto
//
//  Created by x.yang on 2018/07/02.
//  Copyright © 2018年 x.yang. All rights reserved.
//

import UIKit

class CmyTutorialViewController: CmyViewController {
    
    let pageControl1 = PagingControl()

    @IBOutlet weak var bottomNavigationBar: UINavigationBar!
    @IBOutlet weak var pagingScrollView: UIScrollView!
    @IBOutlet weak var sizingView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.makePagingDataView(pageCount: 4)
    }

 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func makePagingDataView(pageCount: Int){
        /*
        let subTitleStrs: [String] = ["説明タイトル", "説明タイトル２", "説明タイトル３", "説明タイトル４"]
        let descStrs: [String] = ["アプリ説明１\nアプリ説明１\nアプリ説明１", "アプリ説明２\nアプリ説明２\nアプリ説明２", "アプリ説明３\nアプリ説明３\nアプリ説明３","アプリ説明４\nアプリ説明４\nアプリ説明４"]
        */
        let imgFiles: [String] = ["tutorial 1.png", "tutorial 2.png", "tutorial 3.png", "tutorial 4-a.png"]
        
        self.view.layoutIfNeeded()
        let scrollSize = sizingView.frame.width * (UIDevice.current.userInterfaceIdiom == .pad ? 1.10 : 0.97) // ScrollViewが少し大きめになるので調整
        
        // 横座標のオフセットを特定する
        let yOffset: CGFloat = {
            var retVal: CGFloat = 65
            if self.view.bounds.width > 750 { //iPad pro
                retVal = 160
            } else if self.view.bounds.width > 420  { //iPad
                retVal = 135
            } else if self.view.bounds.width >= 400  { //iPhone 6/7/8 plus
                retVal = 80
            } else if self.view.bounds.width >= 375 && self.view.bounds.height > 800 { //iPhone X
                retVal = 95
            } else if self.view.bounds.width > 320 && self.view.bounds.height < 700 { //iPhone 6/7/8
                retVal = 75
            } else {
                retVal = 65
            }
            return retVal
        }()
        let yMargin = sizingView.frame.origin.y / 2 + yOffset

        self.pagingScrollView.frame = CGRect(x: 0, y: 0, width: scrollSize, height: scrollSize * 1.5)
        self.pagingScrollView.center = view.center
        self.pagingScrollView.contentSize = CGSize(width: scrollSize * CGFloat(pageCount), height: scrollSize * 1.5)
        self.pagingScrollView.isPagingEnabled = true
        self.pagingScrollView.showsHorizontalScrollIndicator = false

        for index in 0..<pageCount {
            //コンテンツの画像
            let imgView = UIImageView(frame: CGRect(x: CGFloat(index) * scrollSize, y: yMargin, width: scrollSize, height: scrollSize ))
            imgView.contentMode = .scaleAspectFill
            let imageNamed = imgFiles[index]
            if let image = UIImage.fitSizedImage(image: UIImage(named: imageNamed as String), widthOffset: 16)  {
                imgView.image =  image
                
            }
            self.pagingScrollView.addSubview(imgView)
        }
        self.view.addSubview(pagingScrollView)
        self.pagingScrollView.delegate = self
        
        self.pageControl1.center = CGPoint(x: self.pagingScrollView.center.x, y: self.pagingScrollView.frame.maxY - self.pageControl1.frame.size.height)
        self.pageControl1.numberOfPages = pageCount
        self.view.addSubview(self.pageControl1)

        self.view.layoutIfNeeded()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.destination is CmyPhoneNumberRegistrationViewController {
            //本画面のロード状況を記録し、次回から呼ばないようにする
            CmyUserDefault.shared.isTutorialShown = true
        }
    }
 
}

extension CmyTutorialViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        self.pageControl1.setProgress(contentOffsetX: self.pagingScrollView.contentOffset.x, pageWidth: self.pagingScrollView.bounds.width)
        //pageControl2.setProgress(contentOffsetX: scrollView.contentOffset.x, pageWidth: scrollView.bounds.width)
    }
}
