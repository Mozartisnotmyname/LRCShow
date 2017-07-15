//
//  SCTableView.swift
//  playerTest4
//
//  Created by 凌       陈 on 7/15/17.
//  Copyright © 2017 凌       陈. All rights reserved.
//

import UIKit

class SCTableView: UITableView, UITableViewDelegate , UITableViewDataSource{
    
    var mCurrentSongIndex = 0
    var mUpdateTimer : Timer?

    var mLRCDictinary : [String : String] = [String : String]()
    var mTimeArray : [String] = [String]()
    var mIsLRCPrepared : Bool = false
    var mLineNumber : Int = -1
    
    var currentCell : SCLrcCell?
    
    var lrcOldCell : SCLrcCell?
    
    var old_Index : Int = 0
    
    
    var lrcProgress : CGFloat = 0.0{
        
        didSet{
            
            if currentCell != nil {
                
                autoUpdateLrc()
                
            }
        }
        
    }
    
    // 设置歌词index，显示哪一行
    var Lrc_Index : Int = 0 {
        
        didSet{
            
            if Lrc_Index == oldValue {
                return
            }
            
            // 滚动到指定index的位置
            // 新的indexPath
            let indexPath = NSIndexPath(row: Lrc_Index, section: 0  )
            self.scrollToRow(at: indexPath as IndexPath, at: .middle, animated: true)
            currentCell = self.cellForRow(at: indexPath as IndexPath) as? SCLrcCell
            currentCell?.mTitleLable.textColor = UIColor.red
            // 旧的indexPath
            let oldIndexpath = NSIndexPath(row: oldValue, section: 0)
            let oldCell = self.cellForRow(at: oldIndexpath as IndexPath) as? SCLrcCell
            old_Index = oldValue
            lrcOldCell = oldCell
            currentCell?.addAnimation(animationType: .scaleAlways)
            oldCell?.addAnimation(animationType: .scaleNormal)
            oldCell?.mTitleLable.textColor = UIColor.black
            //            oldCell?.lrcCell_textLabel?.progress = 0
        }
        
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.dataSource = self
        self.delegate = self
        
        
    }
    
    //MARK: -  解析歌词
    func prepareLRC(lrcPath:String) {
        //从资源中导入 lrc
        let url = Bundle.main.url(forResource: lrcPath, withExtension: nil)
        
        var contentStr = ""
        do{
            contentStr = try String(contentsOf: url!)
        }catch{
            
            print(error)
            
        }
        
        let lrcArray = contentStr.components(separatedBy: "\n")
        
        self.mLRCDictinary = [String : String]()
        self.mTimeArray = [String]()
        
        for line in lrcArray {
            
            // 首先处理歌词中无用的东西 
            // [ti:][ar:][al:]这类的直接跳过
            if line.contains("[0") || line.contains("[1") || line.contains("[2") || line.contains("[3") {
                
                var lineArr = line.components(separatedBy:"]")
                let str1 = (line as NSString).substring(with: NSRange(location: 3,length: 1))
                let str2 = (line as NSString).substring(with: NSRange(location: 6,length: 1))
                if str1 == ":" && str2 == "." {
                    let lrcStr = lineArr[1]
                    let timeStr = (lineArr[0] as NSString).substring(with: NSRange(location: 1, length: 5))
                    self.mLRCDictinary[timeStr] = lrcStr
                    self.mTimeArray.append(timeStr)
                    
                }
            } else {
                continue
            }
            
        }
        
        self.mIsLRCPrepared = true
        self.reloadData()
    }
    
    func updateLRC(currentTime:CGFloat) {
        for i in 0..<self.mLRCDictinary.count {
            var timeArr = self.mTimeArray[i].components(separatedBy:":")
            let time = CGFloat(Int(timeArr[0])!) * 60 + CGFloat(Int(timeArr[1])!)
            if i + 1 < self.mTimeArray.count {
                var timeArr1 = self.mTimeArray[i + 1].components(separatedBy:":")
                let time1 = CGFloat(Int(timeArr1[0])!) * 60 + CGFloat(Int(timeArr1[1])!)
                
                if currentTime > time && currentTime < time1 {
                    self.mLineNumber = i
                    self.reloadData()
                    self.selectRow(at: NSIndexPath(row: i, section: 0) as IndexPath, animated: true, scrollPosition: UITableViewScrollPosition.middle)
                }
            }
        }
    }
    
    /// 自动更新歌词进度方法
    fileprivate func autoUpdateLrc()  {
        //        let lrcModel = lrcModels[Lrc_Index]
        //        lrcModel.progress = lrcProgress
        //        lrcModels[Lrc_Index] = lrcModel
        let indexPath = NSIndexPath(row: Lrc_Index, section: 0) as IndexPath
        
        let count = self.visibleCells
        if count.count <= 0 || indexPath.row > self.mTimeArray.count - 1 {
            return
        }
        
        guard (self.cellForRow(at:indexPath ) != nil)  else {
            return
        }
        let cell = self.cellForRow(at:indexPath )
        
    }
    
    
    //MARK: - Table Delegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.mTimeArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "lrcCell") as! SCLrcCell
        
        cell.mTitleLable.text = self.mLRCDictinary[self.mTimeArray[indexPath.row]]
        
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        cell.mTitleLable.numberOfLines = 0
        cell.mTitleLable.lineBreakMode = NSLineBreakMode.byWordWrapping
        cell.mTitleLable.sizeToFit()
        
        if self.mLineNumber == indexPath.row {
            cell.mTitleLable.font = UIFont.systemFont(ofSize: 24)
            cell.mTitleLable.textColor = UIColor.red
        } else {
            cell.mTitleLable.font = UIFont.systemFont(ofSize: 20)
            cell.mTitleLable.textColor = UIColor.black
        }
        
        return cell
    }
    
    
   
}
