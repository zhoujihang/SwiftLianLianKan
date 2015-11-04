//
//  ViewController.swift
//  SwiftLianLianKan
//
//  Created by 周际航 on 15/10/29.
//  Copyright © 2015年 zjh. All rights reserved.
//

import UIKit

let kCount_row = 6       // 多少行，只能取值偶数
let kCount_column = 6    // 多少列，只能取值偶数
let kBigScale:CGFloat = 1.3      // 变大的比例
let kMinOffset:CGFloat = 0.0000001       // 判断浮点数相等的精度
let kTimeSecond = 60     // 剩余时间秒数
// 棋子能走的路径
typealias ChessPath = (xArr:Array<CGPoint>,yArr:Array<CGPoint>)
class ViewController: UIViewController, UIAlertViewDelegate {
    
    // 开始按钮
    @IBOutlet weak var _startBtn: UIButton!
    // 暂停按钮
    @IBOutlet weak var _parseBtn: UIButton!
    // 重新排序按钮
    @IBOutlet weak var _reRangeBtn: UIButton!
    // 剩余时间进度条
    @IBOutlet weak var _timeProgress: UIProgressView!
    // 放棋子的棋盘
    @IBOutlet weak var _chessView: UIView!
    
    
    // iOS7 的游戏通关弹窗
    weak var _winAlert: UIAlertView?
    // 计时器
    var _timer: NSTimer?
    
    // 还活着的棋子
    var _lifingChesses: Array<ChessBtn> = []
    // 消去的棋子
    var _deadChesses: Array<ChessBtn> = []
    // 当前选中的棋子
    weak var _selectChess: ChessBtn?
    // 游戏是否正在进行
    var _isOnGame:Bool = false
    
    var _normalWidth: CGFloat = 0       // chess的宽
    var _normalHeight: CGFloat = 0      // chess的高
    var _beginCenterX: CGFloat = 0      // 第一个chess的center的x
    var _beginCenterY: CGFloat = 0      // 第一个chess的center的y
// MARK: - 生命周期方法
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpViews()
        self.darkLifingChess()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.setUpPosition()
    }
// MARK: - 创建视图
    func setUpViews(){
        self._timeProgress.progress = 1.0
        let chessModelArr = self.chessModelArr()
        
        if chessModelArr?.count >= 18 {
            let modelArr = chessModelArr!
            // 创建 棋子
            let count = kCount_row*kCount_column
            for(var i=0;i<count;i++){
                let tag:Int = i/2%modelArr.count
                let chessModel:ChessModel? = modelArr[tag]
                let model = chessModel!
                // 设置棋子属性
                let btn = ChessBtn(model: model)
                btn.tag = tag + 100
                btn.addTarget(self, action: Selector("chessBtnClicked:"), forControlEvents: UIControlEvents.TouchUpInside)
                self._chessView.addSubview(btn)
                self._lifingChesses.append(btn)
            }
        }
    }
    // 布局位置
    func setUpPosition(){
        self.view.updateConstraintsIfNeeded()
        self.view.layoutIfNeeded()
        for subView in self.view.subviews {
            subView.updateConstraintsIfNeeded()
            subView.layoutIfNeeded()
        }
//        for subView in self.view.subviews {
//            subView.updateConstraintsIfNeeded()
//            subView.layoutIfNeeded()
//        }
//        if #available(iOS 8.0, *) {
////            let hSizeClass = self.view.traitCollection.horizontalSizeClass
//            let vSizeClass = self.view.traitCollection.verticalSizeClass
//            if vSizeClass == UIUserInterfaceSizeClass.Compact {
//                print("compact")
//            }else if vSizeClass == UIUserInterfaceSizeClass.Regular {
//                print("Regular")
//            }else if vSizeClass == UIUserInterfaceSizeClass.Unspecified {
//                print("Unspecified")
//            }
//        } else {
//            
//        }
        let viewFrame = NSStringFromCGRect(self.view.frame)
        let chessViewFrame = NSStringFromCGRect(self._chessView.frame)
        print("viewFrame:",viewFrame,"chessViewFrame:",chessViewFrame)
        
        let topSpace:CGFloat = 0  // 顶部距离
        let leftSpace:CGFloat = 0      // 左边距离
        let rightSpace:CGFloat = 0     // 右边的距离
        
        // 单个chess的宽高
        self._normalWidth = (self._chessView.bounds.size.width-leftSpace-rightSpace)/CGFloat(kCount_column)
        self._normalHeight = self._chessView.bounds.size.height/CGFloat(kCount_row)
        
        self._beginCenterX = leftSpace + self._normalWidth*0.5
        self._beginCenterY = topSpace + self._normalHeight*0.5
        
        // 提供棋子的随机座位
        var indexArr:Array<Int> = []
        for(var i=0;i<kCount_row*kCount_column;i++){
            indexArr.append(i)
        }
        for(var i=0;i<self._lifingChesses.count;i++){
            let btn = self._lifingChesses[i]
            // 得到棋子在棋盘中的位置 chessIndex
            let randomIndex = Int(arc4random_uniform(UInt32(indexArr.count)))
            let chessIndex:Int = indexArr[randomIndex]
            indexArr.removeAtIndex(randomIndex)
            // 行数
            let row:Int = chessIndex/kCount_column
            // 列数
            let column:Int = chessIndex%kCount_column
            // x坐标
            let pointX = leftSpace + CGFloat(column)*self._normalWidth
            // y坐标
            let pointY = topSpace + CGFloat(row)*self._normalHeight
            btn.frame = CGRect(x: pointX, y: pointY, width: self._normalWidth, height: self._normalHeight)
        }
    }
    
    // 获取连连看图片信息的数组
    func chessModelArr()->Array<ChessModel>?{
        let path = NSBundle.mainBundle().pathForResource("llkDic.plist", ofType: nil)
        let picNameArr = NSArray(contentsOfFile: path!)
        
        var chessModelArr:Array<ChessModel> = []
        
        for dic in picNameArr! {
            let chessModel:ChessModel = ChessModel()
            chessModel.icon = dic["icon"] as? String
            chessModel.title = dic["title"] as? String
            chessModel.message = dic["message"] as? String
            chessModelArr.append(chessModel)
        }
        
        return chessModelArr
    }
    // 点亮棋盘上的棋子
    func lightLifingChess(){
        for chess in self._lifingChesses{
            chess.enabled = true
        }
    }
    // 置灰棋盘上的棋子
    func darkLifingChess(){
        for chess in self._lifingChesses{
            chess.enabled = false
        }
    }
// MARK: - 点击事件
    //棋子点击事件
    func chessBtnClicked(sender: ChessBtn?){
        if sender == nil {
            // 取消选中的棋子
            if self._selectChess != nil{
                self.normalChess(self._selectChess!)
                self._selectChess = nil
            }
            return
        }

        if self._selectChess == nil {
            // 第一次点击棋子
            self._selectChess = sender
            self.bigChess(self._selectChess!)
        }else{
            let lastChess = sender!
            let nowChess = self._selectChess!
            // 点击的第二个棋子
            let canEat = self.canChessEat(nowChess, chess2: lastChess)
            
            if canEat {
                // 消去棋子
                self.chessEat(nowChess, chess2: lastChess)
                
                // 检查是否有可消路径
                if self.checkExistPath() == nil{
                    self.reRangeBtnClicked(nil)
                }
                // 检查是否已经赢了游戏
                self.checkWin()
                
                return
            }
            self.normalChess(self._selectChess!)
            self._selectChess = sender
            self.bigChess(self._selectChess!)
        }
    }
    // 开始游戏
    @IBAction func startGame(sender: UIButton) {
        self._lifingChesses = self._lifingChesses + self._deadChesses
        self._deadChesses = []
        self.lightLifingChess()
        self.reRangeBtnClicked(nil)
        sender.enabled = false
        self._isOnGame = true
        
        self._timeProgress.setProgress(1.0, animated: true)
        self._timer?.invalidate()
        self._timer = nil
        self._timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("timerTask:"), userInfo: nil, repeats: true)
    }
    // 暂停按钮
    @IBAction func parseBtnClicked(sender: UIButton) {
        if self._isOnGame == false {return}
        let title = sender.titleForState(UIControlState.Normal)!
        
        if title == "暂停" {
            // 暂停游戏，用来调试
            self._timer?.invalidate()
            self._timer = nil
            self.darkLifingChess()
            self._parseBtn.setTitle("继续", forState: UIControlState.Normal)
        }else if title == "继续" {
            // 继续游戏
            self._timer?.invalidate()
            self._timer = nil
            self.lightLifingChess()
            self._timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("timerTask:"), userInfo: nil, repeats: true)
            self._parseBtn.setTitle("暂停", forState: UIControlState.Normal)
        }
    }
    // 重新排序棋子
    @IBAction func reRangeBtnClicked(sender: UIButton?) {
        
        self.chessBtnClicked(nil)
        
        UIView .animateWithDuration(0.5, animations: { () -> Void in
            self.setUpPosition()
            }) { (stop) -> Void in
                // 检查是否有可消路径
                if self.checkExistPath() == nil{
                    self.reRangeBtnClicked(nil)
                }
        }
    }
    
    // 提示
    @IBAction func tips(sender: UIButton) {
        
        self.chessBtnClicked(nil)
        
        if let (chess1,chess2) = self.checkExistPath(){
            self.view.bringSubviewToFront(chess1)
            self.view.bringSubviewToFront(chess2)
            
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                // 先放大
                chess1.transform = CGAffineTransformMakeScale(kBigScale, kBigScale)
                chess2.transform = CGAffineTransformMakeScale(kBigScale, kBigScale)
                }, completion: { (stop) -> Void in
                    // 再缩小
                    UIView.animateWithDuration(0.15, animations: { () -> Void in
                        chess1.transform = CGAffineTransformIdentity
                        chess2.transform = CGAffineTransformIdentity
                        
                    })
            })
        }
    }
    // 定时器的任务
    func timerTask(timer:NSTimer){
        print(NSDate(),timer)
        if self._timeProgress.progress <= 0 {
            // 游戏结束了
            self.gameFail()
            return
        }
        var progress = self._timeProgress.progress - 1/Float(kTimeSecond)
        progress = progress>=0 ? progress : 0
        self._timeProgress.setProgress(progress, animated: true)
        if self._timeProgress.progress <= 0 {
            // 游戏结束了
            self.gameFail()
            return
        }
    }
// MARK: - 棋子动画
    // 让棋子变大
    func bigChess(sender: UIButton){
        UIView.animateWithDuration(0.25) { () -> Void in
            sender.transform = CGAffineTransformMakeScale(kBigScale, kBigScale)
        }
        self.view.bringSubviewToFront(sender)
    }
    // 让棋子恢复正常大小
    func normalChess(sender: UIButton){
        UIView.animateWithDuration(0.25) { () -> Void in
            sender.transform = CGAffineTransformIdentity
        }
    }

// MARK: - 消除规则
    // 检查是否存在可消去的棋子
    func checkExistPath()->(chess1:ChessBtn, chess2:ChessBtn)?{
        var lifingChesses = self._lifingChesses
        
        while lifingChesses.count>0 {
            let c1 = lifingChesses[0]
            for c2 in lifingChesses{
                if (c1.tag==c2.tag) && (c1 != c2){
                    if self.canChessEat(c1, chess2: c2){
                        return (c1,c2)
                    }else{
                        lifingChesses.removeAtIndex(lifingChesses.indexOf(c1)!)
                        lifingChesses.removeAtIndex(lifingChesses.indexOf(c2)!)
                        break
                    }
                }
            }
        }
        return nil
    }
    
    // 棋子是否能消去
    func canChessEat(chess1:ChessBtn, chess2:ChessBtn)->Bool{
        if chess1.isEqual(chess2) {return false}
        if chess1.tag != chess2.tag {return false}
        
        var canEat:Bool = false
        
        let chess1Path = self.pathCanGo(chess1)
        let chess2Path = self.pathCanGo(chess2)
        
        canEat = self.oneLine(chess1.center, point2: chess2.center)
        if !canEat {
            canEat = self.twoLine(chess1Path, chess2Path: chess2Path)
            if !canEat {
                canEat = self.threeLine(chess1Path, chess2Path: chess2Path)
            }
        }
        return canEat
    }
    // 消去相同的棋子
    func chessEat(chess1:ChessBtn, chess2:ChessBtn){
        if chess1.isEqual(chess2) {return}
        if chess1.tag != chess2.tag {return}
        
        self._selectChess = nil
        let index1 = self._lifingChesses.indexOf(chess2)
        self._lifingChesses.removeAtIndex(index1!)
        let index2 = self._lifingChesses.indexOf(chess1)
        self._lifingChesses.removeAtIndex(index2!)
        self._deadChesses.append(chess2)
        self._deadChesses.append(chess1)
        self.normalChess(chess1)
        self.normalChess(chess2)
        chess2.frame = CGRectZero
        chess1.frame = CGRectZero
        chess2.enabled = false
        chess1.enabled = false
    }
    // 判断能否通过 1 条线吃掉
    func oneLine(point1:CGPoint, point2:CGPoint)->Bool{
        if abs(point1.x - point2.x)<kMinOffset {
            // 判断y轴上能否连在一起
            let count:Int = Int(abs((point2.y-point1.y)/self._normalHeight)+0.5)
            let padding = point2.y > point1.y ? self._normalHeight : -self._normalHeight
            var isLine = true
            for(var i=1;i<=count;i++){
                let y = point1.y + padding*CGFloat(i)
                let point = CGPoint(x: point1.x, y: y)
                
                if i == 1 {
                    // 1.距离为1表示相连
                    if pointEqualToPoint(point, point2: point2){
                        isLine = true
                        break
                    }
                }
                if i == count {
                    // 2.距离为count不用判断
                    break
                }
                // 3.判断中间是否都是空闲的
                if self.isIdlePoint(point) == false {
                    //  无法直连
                    isLine = false
                    break
                }
            }
            return isLine
        }
        if abs(point1.y - point2.y)<kMinOffset {
            // 判断x轴上能否连在一起
            let count:Int = Int(abs((point2.x-point1.x)/self._normalWidth)+0.5)
            let padding = point2.x > point1.x ? self._normalWidth : -self._normalWidth
            var isLine = true
            for(var i=1;i<=count;i++){
                let x = point1.x + padding*CGFloat(i)
                let point = CGPoint(x: x, y: point1.y)
                if i == 1 {
                    // 1.相连
                    if pointEqualToPoint(point, point2: point2){
                        isLine = true
                        break
                    }
                }
                if i == count {
                    // 2.距离为count不用判断
                    break
                }
                // 3.判断中间是否都是空闲的
                if self.isIdlePoint(point) == false {
                    //  无法直连
                    isLine = false
                    break
                }
            }
            return isLine
        }
        return false
    }
    // 判断能否通过 2 条线吃掉
    func twoLine(chess1Path:ChessPath, chess2Path:ChessPath)->Bool{
        // chess1的x轴路线交与chesss2的y轴路线
        for(var i=0;i<chess1Path.xArr.count;i++){
            let xPoint = chess1Path.xArr[i]
            for(var j=0;j<chess2Path.yArr.count;j++){
                let yPoint = chess2Path.yArr[j]
                if pointEqualToPoint(xPoint, point2: yPoint) {return true}
            }
        }
        // chess1的y轴路线交与chesss2的x轴路线
        for(var i=0;i<chess1Path.yArr.count;i++){
            let yPoint = chess1Path.yArr[i]
            for(var j=0;j<chess2Path.xArr.count;j++){
                let xPoint = chess2Path.xArr[j]
                if pointEqualToPoint(yPoint, point2: xPoint) {return true}
            }
        }
        return false
    }
    // 判断能否通过 3 条线吃掉
    func threeLine(chess1Path:ChessPath, chess2Path:ChessPath)->Bool{
        // chess1的x轴路径与chess2的x轴路径有直连线存在
        for(var i=0;i<chess1Path.xArr.count;i++){
            let chess1Point:CGPoint = chess1Path.xArr[i]
            for(var j=0;j<chess2Path.xArr.count;j++){
                let chess2Point:CGPoint = chess2Path.xArr[j]
                let xOffset = abs(chess1Point.x - chess2Point.x)
                if xOffset < kMinOffset {
                    // x坐标相同的2点,判断此2点能否直连
                    if self.oneLine(chess1Point, point2: chess2Point) {
                        return true
                    }
                }
            }
        }
        // chess1的y轴路径与chess2的y轴路径有直连线存在
        for(var i=0;i<chess1Path.yArr.count;i++){
            let chess1Point:CGPoint = chess1Path.yArr[i]
            for(var j=0;j<chess2Path.yArr.count;j++){
                let chess2Point:CGPoint = chess2Path.yArr[j]
                let yOffset = abs(chess1Point.y - chess2Point.y)
                if yOffset < kMinOffset {
                    // y坐标相同的2点，判读此2点能否直连
                    if self.oneLine(chess1Point, point2: chess2Point) {
                        return true
                    }
                }
            }
        }
        return false
    }
    // 返回chess在x，y轴上能走的路径,路径不包含chess所在的点
    func pathCanGo(chess:ChessBtn)->(ChessPath){
        if self._lifingChesses.count < 0 {return ([],[])}
        
        let minX = self._beginCenterX - self._normalWidth
        let minY = self._beginCenterY - self._normalHeight
        let maxX = minX + CGFloat(kCount_column)*self._normalWidth + self._normalWidth
        let maxY = minY + CGFloat(kCount_row)*self._normalHeight + self._normalHeight
        let originX = chess.center.x
        let originY = chess.center.y
        
        var x1Arr:Array<CGPoint> = []
        for(var x=originX-self._normalWidth; x+kMinOffset>=minX ;x-=self._normalWidth){
            let point = CGPointMake(x, originY)
            if isIdlePoint(point){
                x1Arr.append(point)
            }else{
                break
            }
        }
        var x2Arr:Array<CGPoint> = []
        for(var x=originX+self._normalWidth; x-kMinOffset<=maxX ;x+=self._normalWidth){
            let point = CGPointMake(x, originY)
            if isIdlePoint(point){
                x2Arr.append(point)
            }else{
                break
            }
        }
        var y1Arr:Array<CGPoint> = []
        for(var y=originY-self._normalHeight; y+kMinOffset>=minY ;y-=self._normalHeight){
            let point = CGPointMake(originX, y)
            if isIdlePoint(point){
                y1Arr.append(point)
            }else{
                break
            }
        }
        var y2Arr:Array<CGPoint> = []
        for(var y=originY+self._normalHeight; y-kMinOffset<=maxY ;y+=self._normalHeight){
            let point = CGPointMake(originX, y)
            if isIdlePoint(point){
                y2Arr.append(point)
            }else{
                break
            }
        }
        
        let chessPath = ChessPath(x1Arr+x2Arr,y1Arr+y2Arr)
        
        return chessPath
    }
    // 判断point上是否有其他棋子
    func isIdlePoint(point:CGPoint)->Bool{
        var isIdle = true
        for chessbtn in self._lifingChesses{
            let chessPoint = chessbtn.center
            isIdle = !pointEqualToPoint(point, point2: chessPoint)
            if isIdle == false {break}
        }
        return isIdle
    }
    
    // 赢了
    func checkWin(){
        if self._lifingChesses.count == 0{
            self._timer?.invalidate()
            self._timer = nil
            self._isOnGame = false
            
            // 提示
            if #available(iOS 8.0, *) {
                let winAlert = UIAlertController(title: "连连看", message: "恭喜通过！", preferredStyle: UIAlertControllerStyle.Alert)
                winAlert.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.Cancel, handler: { (action:UIAlertAction) -> Void in
                    self.reSetChess()
                }))
                self.presentViewController(winAlert, animated: true, completion: nil)
            } else {
                let winAlert = UIAlertView(title: "连连看", message: "恭喜通过!", delegate: self, cancelButtonTitle: "确定")
                winAlert.show()
                self._winAlert = winAlert
            }
        }
    }
    // 输了
    func gameFail(){
        self.darkLifingChess()
        self._startBtn.enabled = true
        self._selectChess = nil
        self._timer?.invalidate()
        self._timer = nil
        self._isOnGame = false
        // 提示
        if #available(iOS 8.0, *) {
            let failAlert = UIAlertController(title: "连连看", message: "没有时间啦！", preferredStyle: UIAlertControllerStyle.Alert)
            failAlert.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.Cancel, handler: { (action:UIAlertAction) -> Void in

            }))
            self.presentViewController(failAlert, animated: true, completion: nil)
        } else {
            let failAlert = UIAlertView(title: "连连看", message: "没有时间啦!", delegate: nil, cancelButtonTitle: "确定")
            failAlert.show()
        }
    }
    // 重置棋盘
    func reSetChess(){
        self._timeProgress.setProgress(1.0, animated: true)
        self._timer?.invalidate()
        self._timer = nil
        
        self._startBtn.enabled = true
        self._lifingChesses = self._lifingChesses + self._deadChesses
        self._deadChesses = []
        self.darkLifingChess()
        self.setUpPosition()
        
    }
// MARK:  - alertview的代理方法
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if alertView == self._winAlert {
            if buttonIndex == 0{
                // 确定
                self.reSetChess()
            }
        }
    }
    
// MARK: - 屏幕旋转事件
    // iOS7
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        super.willRotateToInterfaceOrientation(toInterfaceOrientation, duration: duration)
        print(__FUNCTION__)
    }
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        super.didRotateFromInterfaceOrientation(fromInterfaceOrientation)
        print(__FUNCTION__)
    }
    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        super.willAnimateRotationToInterfaceOrientation(toInterfaceOrientation, duration: duration)
        print(__FUNCTION__)
    }
    // iOS8
    @available(iOS 8.0, *)
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        print(__FUNCTION__)
        self.setUpPosition()
    }
    @available(iOS 8.0, *)
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        print(__FUNCTION__)
    }
    @available(iOS 8.0, *)
    override func willTransitionToTraitCollection(newCollection: UITraitCollection, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransitionToTraitCollection(newCollection, withTransitionCoordinator: coordinator)
        print(__FUNCTION__)
    }
    
}
// 判断两点是否相等
func pointEqualToPoint(point1:CGPoint, point2:CGPoint)->Bool{
    let xSet = point2.x - point1.x
    let ySet = point2.y - point1.y
    
    var isEqual:Bool = false
    if abs(xSet)<kMinOffset && abs(ySet)<kMinOffset {
        isEqual = true
    }
    return isEqual
}
