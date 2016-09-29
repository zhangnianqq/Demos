//
//  JOBTFirstViewController.m
//  BTDemo
//
//  Created by ligl on 15-07-21.
//
#import <UIKit/UIKit.h>
#import "JOBTFirstViewController.h"
#import "SPRTPrint.h"
#import "MBProgressHUD.h"
#import "Bluetooth.h"

// qzfeng begin 2015/05/10
/**/
//for issc
static NSString *const kWriteCharacteristicUUID_cj = @"49535343-8841-43F4-A8D4-ECBE34729BB3";
static NSString *const kReadCharacteristicUUID_cj = @"49535343-1E4D-4BD9-BA61-23C647249616";
static NSString *const kServiceUUID_cj = @"49535343-FE7D-4AE5-8FA9-9FAFD205E455";
/**/
// qzfeng end 2015/05/10

/*金瓯的模块读写特征反了、
static NSString *const  kReadCharacteristicUUID= @"49535343-8841-43F4-A8D4-ECBE34729BB3";
 static NSString *const kWriteCharacteristicUUID = @"49535343-1E4D-4BD9-BA61-23C647249616";
 static NSString *const kServiceUUID = @"49535343-FE7D-4AE5-8FA9-9FAFD205E455";*/
//for ivt
static NSString *const kFlowControlCharacteristicUUID = @"ff03";
static NSString *const kWriteCharacteristicUUID = @"ff02";
static NSString *const kReadCharacteristicUUID = @"ff01";
static NSString *const kServiceUUID = @"ff00";

//芝柯设备特征
static NSString *const kZhiKeServiceUUID = @"fff0";
static NSString *const kZhiKeWriteCharacteristicUUID = @"fff2";
static NSString *const kZhiKeReadCharacteristicUUID = @"fff1";

//万琛设备特征
static NSString *const kWanChenServiceUUID = @"49535343-FE7D-4AE5-8FA9-9FAFD205E455";


//设备名称 常量
static NSString *const kSiPuRuiTeName = @"L31 BT Printer";
static NSString *const kZhiKeName = @"XT423";
static NSString *const kWanChenName = @"QR380A_0B04F6";



//for jinou 单模，双模同issc

/*
static NSString *const kWriteCharacteristicUUID = @"fff2";
static NSString *const kReadCharacteristicUUID = @"fff1";
static NSString *const kServiceUUID = @"fff0";*/

CBPeripheral *activeDevice;
CBCharacteristic *activeWriteCharacteristic;
CBCharacteristic *activeReadCharacteristic;
CBCharacteristic *activeFlowControlCharacteristic;
int mtu = 20;
int credit = 0;
int response = 1;

int cjFlag=1;           // qzfeng 2016/05/10
int cmd=0;
id<CBPeripheralDelegate> deviceDelegate=nil;

@interface JOBTFirstViewController ()
{
    dispatch_queue_t queue;
    BOOL autoConnect;
    NSIndexPath *index;
    int seconds; //打印按钮计时
    UIButton * printButton;//打印按钮
    NSTimer * clockTimer;  //计时器
}
@property (strong, nonatomic) Bluetooth* bluetooth;
@end

@implementation JOBTFirstViewController
//NSThread *thread = NULL;

@synthesize deviceListTableView;
@synthesize scanConnectActivityInd;
//@synthesize centralManager;

@synthesize selectedPeripheral;


- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // 1.创建一个串行队列
    queue = dispatch_queue_create("cn.heima.queue", NULL);
    
    deviceListTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-64-118) style:UITableViewStylePlain ];
    deviceListTableView.delegate = self;
    deviceListTableView.dataSource = self;
    deviceListTableView.tableFooterView = [[UIView alloc]init];
    [self.view addSubview:deviceListTableView];
    
    scanConnectActivityInd = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    //设置风格
    scanConnectActivityInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    //设置停止时是否隐藏
    scanConnectActivityInd.hidesWhenStopped = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: scanConnectActivityInd];

    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
    
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(10, [UIScreen mainScreen].bounds.size.height-64-88-20, [UIScreen mainScreen].bounds.size.width-20, 44);
    [btn addTarget:self action:@selector(buttonStartDiscovery:) forControlEvents:UIControlEventTouchUpInside];
    btn.backgroundColor = [UIColor redColor];
    [btn setTitle:@"重连" forState:UIControlStateNormal];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [self.view addSubview:btn];
    
    printButton = [UIButton buttonWithType:UIButtonTypeCustom];
    printButton.frame = CGRectMake(10, [UIScreen mainScreen].bounds.size.height-64-44-10, [UIScreen mainScreen].bounds.size.width-20, 44);
    [printButton addTarget:self action:@selector(buttonPageModePrint:) forControlEvents:UIControlEventTouchUpInside];
    printButton.backgroundColor = [UIColor orangeColor];
    [printButton setTitle:@"打印" forState:UIControlStateNormal];
    [printButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [self.view addSubview:printButton];
    

    UIButton * back = [UIButton buttonWithType:UIButtonTypeCustom];
    back.frame = CGRectMake(0, 0, 44, 44);
    [back addTarget:self action:@selector(bacButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [back setImage:[UIImage imageNamed:@"nav_back"] forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: back];
    if (activeDevice != nil ){
        [self showMessage:@"自动连接上次设备中"];
    }
    
    self.bluetooth = [[Bluetooth alloc]init];
}

//显示提示信息
-(void)showMessage:(NSString *)message {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:true];
    hud.label.text = message;
    hud.mode = MBProgressHUDModeText;
    hud.offset = CGPointMake(0, MBProgressMaxOffset);
    [hud hideAnimated:true afterDelay:2];
}

//返回按钮触发
-(void)bacButtonClick {
    if (self.isPrintDan == YES) {
        [self.navigationController popViewControllerAnimated:true];
        return;
    }
    [self.navigationController popToRootViewControllerAnimated:false];
}

//打印按钮触发
- (void)buttonPageModePrint:(UIButton*)button {
    if (activeDevice==nil) {
        [self buttonStartDiscovery:button];
        [self alertMessage:@"没有设备连接不打印"];
        return;
    }
    [self startCountDown];
    NSString * subDateString = [self.sendDate substringWithRange:NSMakeRange(5, 11)];
    NSArray * array = [self.billCodeSub componentsSeparatedByString:@";"];
    for (int i = 1; i < array.count-1;i++){
        if(cjFlag==0){
            dispatch_async(queue, ^{
                [self selectPrint:array[i] subDateString:subDateString];
            });
        }else{
            [self selectPrint:array[i] subDateString:subDateString];
        }
    }
}

//根据设备执行对应设备的打印指令
-(void)selectPrint:(NSString *)subBillCode subDateString:(NSString *)subDateString {
    if ([[self.selectedPeripheral name] isEqualToString:kSiPuRuiTeName]) {
        [self pageModeSiPuRuiTePrint:subBillCode subDateString:subDateString isSiPuRuiTe:false];
    }else if ([[self.selectedPeripheral name] isEqualToString:kZhiKeName]) {
        [self pageModeZhiKePrint:subBillCode subDateString:subDateString];
    }else{
        [self pageModeSiPuRuiTePrint:subBillCode subDateString:subDateString isSiPuRuiTe:true];
//        [self pageModeZhiKePrint:subBillCode subDateString:subDateString];
    }
}

//计时器方法
- (void)startCountDown{
    seconds = 6;
    NSString *str = [NSString stringWithFormat:@"%d秒后可打印", seconds];
    [printButton setTitle:str forState:UIControlStateDisabled];
    [printButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
    printButton.backgroundColor = [UIColor lightGrayColor];
    [printButton setEnabled:NO];
    clockTimer = [NSTimer timerWithTimeInterval:1
                                          target:self
                                        selector:@selector(oneSecondPass)
                                        userInfo:nil
                                         repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:clockTimer forMode:NSDefaultRunLoopMode];
}
- (void)oneSecondPass{
    if (seconds > 0)
    {
        seconds = seconds - 1;
        NSString *str = [NSString stringWithFormat:@"%d秒后可打印", seconds];
        [printButton setTitle:str forState:UIControlStateDisabled];
        printButton.backgroundColor = [UIColor lightGrayColor];
    } else {
        printButton.backgroundColor = [UIColor orangeColor];
        [clockTimer invalidate];
        clockTimer = nil;
        [printButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [printButton setEnabled:YES];
    }
}

//芝柯打印表单
-(void)pageModeZhiKePrint:(NSString *)subBillCode subDateString:(NSString *)subDateString{
    //冲洗
    [self.bluetooth flushRead];
    //写入
    [self wrapPrintDatas:subBillCode subDateString:subDateString];
    //发送
    [self sendPrintData];
    //重启
    [self.bluetooth reset];

}
- (void)wrapPrintDatas:(NSString *)subBillCode subDateString:(NSString *)subDateString
{
    //打印区域
    [self.bluetooth StartPage:560 pageHeight:740];
    //矩形边框
    [self.bluetooth zp_darwRect:0 top:80 right:560 bottom:740 width:3];
    //类型
    [self.bluetooth zp_drawText:160 y:0 text:self.productType font:24 fontsize:2];
    //条码 默认编码格式CODE128
    [self.bluetooth zp_darw1D_barcode:80 y:90 height:160 text:subBillCode];
    //横线
    [self.bluetooth zp_drawLine:0 startPiontY:265 endPointX:560 endPointY:265 width:2];
    //条码字符
    [self.bluetooth zp_drawText:152 y:275 text:subBillCode font:24 fontsize:1];
    //横线
    [self.bluetooth zp_drawLine:0 startPiontY:320 endPointX:560 endPointY:320 width:2];
    //目的分拨
    [self.bluetooth zp_drawText:10 y:328 text:@"目的" font:55 fontsize:2];
    [self.bluetooth zp_drawText:10 y:360 text:@"分拨" font:55 fontsize:2];
    //横线
    [self.bluetooth zp_drawLine:0 startPiontY:400 endPointX:560 endPointY:400 width:2];
    //目的网点
    [self.bluetooth zp_drawText:10 y:408 text:@"目的" font:55 fontsize:2];
    [self.bluetooth zp_drawText:10 y:440 text:@"网点" font:55 fontsize:2];
    //横线
    [self.bluetooth zp_drawLine:0 startPiontY:480 endPointX:560 endPointY:480 width:2];
    //主单号
    [self.bluetooth zp_drawText:4 y:493 text:@"主单号" font:24 fontsize:1];
    //主单号与件数分割线
    [self.bluetooth zp_drawLine:290 startPiontY:480 endPointX:290 endPointY:528 width:2];
    //横线
    [self.bluetooth zp_drawLine:0 startPiontY:528 endPointX:560 endPointY:528 width:2];
    //详细地址
    [self.bluetooth zp_drawText:10 y:556 text:@"详细" font:55 fontsize:2];
    [self.bluetooth zp_drawText:10 y:588 text:@"地址" font:55 fontsize:2];
    //横线
    [self.bluetooth zp_drawLine:0 startPiontY:640 endPointX:560 endPointY:640 width:2];
    //目的分拨到详细地址的竖线
    [self.bluetooth zp_drawLine:78 startPiontY:320 endPointX:78 endPointY:640 width:2];
    //打印网点
    [self.bluetooth zp_drawText:6 y:658 text:@"打印网点" font:24 fontsize:1];
    //详细地址到打印网点的竖线
    [self.bluetooth zp_drawLine:114 startPiontY:640 endPointX:114 endPointY:696 width:2];
    //横线
    [self.bluetooth zp_drawLine:0 startPiontY:696 endPointX:560 endPointY:696 width:2];
    //派送
    [self.bluetooth zp_drawText:6 y:704 text:self.dispatchMode font:55 fontsize:2];
    //结束
    [self.bluetooth end];
}
-(void) sendPrintData{
    int r = self.bluetooth.dataLength;
    NSData *data = [self.bluetooth getData:r];
    [self.bluetooth writeData:data];
}
//思普瑞特打印表单
-(void)pageModeSiPuRuiTePrint:(NSString *)subBillCode subDateString:(NSString *)subDateString isSiPuRuiTe:(BOOL)isSiPuRuiTe {
    //打印区域
    [SPRTPrint pageSetup:560 pageHeightNum:740];
    
    //矩形边框
    [SPRTPrint drawBox:3 leftX:0 leftY:80 rightX:560 rightY:740];      // 第一联边框;
    
    //类型
    [SPRTPrint drawText:(160) textY:0 textStr:self.productType fontSizeNum:6 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
    //横线
    [SPRTPrint drawLine:2 startX:0 startY:(80) endX:560 endY:(80) isFullline:true]; // 第一联横线1;

    // 条码；
    [SPRTPrint drawBarCode:(80) startY:90 textStr:subBillCode typeNum:1 roateNum:0 lineWidthNum:3 heightNum:160];
    //+5+80+5
    [SPRTPrint drawLine:2 startX:0 startY:(265) endX:560 endY:(265) isFullline:true]; // 第一联横线1;
    // 条码字符；  +90+10
    [SPRTPrint drawText:(2+150) textY:275 textStr:subBillCode fontSizeNum:3 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
    
    //+100+10
    [SPRTPrint drawLine:2 startX:0 startY:(320) endX:560 endY:(320) isFullline:true]; // 第一联横线1;
    //    // 收件人；
    [SPRTPrint drawText:(2+8) textY:(320+8) widthNum:64 heightNum:64 textStr:@"目的分拨" fontSizeNum:3 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
    CGFloat destinationCenterWidth = [self computeStringWidth:self.destinationCenter oldSumWidth:(560-(2+4+64+8+8))];
    [SPRTPrint drawText:(2+4+64+8+8+destinationCenterWidth) textY:320+12 widthNum:(460) heightNum:60 textStr:self.destinationCenter fontSizeNum:4 rotateNum:0 isBold:1 isUnderLine:false isReverse:false];
    
    [SPRTPrint drawLine:2 startX:0 startY:(320+64+8+8) endX:(560) endY:(320+64+8+8) isFullline:true]; // 第一联横线2;
    
    // 目的网点
    [SPRTPrint drawText:(2+8) textY:(400+8) widthNum:64 heightNum:64 textStr:@"目的网点" fontSizeNum:3 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
    // 网点名
    CGFloat dispatchSiteWidth = [self computeStringWidth:self.dispatchSite oldSumWidth:(560-(2+4+64+8+8))];
    [SPRTPrint drawText:(2+4+64+8+8+dispatchSiteWidth) textY:(400+12) widthNum:(460) heightNum:60 textStr:self.dispatchSite fontSizeNum:4 rotateNum:0 isBold:1 isUnderLine:false isReverse:false];
    
    [SPRTPrint drawLine:2 startX:0 startY:(400+8+64+8) endX:(560) endY:(400+8+64+8) isFullline:true]; // 第一联横线2;
    
    // 主单号
    [SPRTPrint drawText:(2+2) textY:(480+8+5) textStr:@"主单号" fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
    [SPRTPrint drawText:(290+2+8) textY:(480+8+5) textStr:@"件数       第      件" fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
    
    [SPRTPrint drawText:(2+4+64+8+8) textY:(480+8+5) textStr:self.billCode fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
    [SPRTPrint drawText:(320+2+8+32+8) textY:(480+8+5) textStr:self.count fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
    NSArray * tmpArray = [subBillCode componentsSeparatedByString:@"-"];
    [SPRTPrint drawText:(390+2+8+64+5) textY:(480+8+5) textStr: [NSString stringWithFormat:@"%@",[tmpArray lastObject]] fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
    
    //竖线
    [SPRTPrint drawLine:2 startX:(290) startY:480 endX:(290) endY:(480+8+8+32) isFullline:true];
    [SPRTPrint drawLine:2 startX:(420) startY:480 endX:(420) endY:(480+8+8+32) isFullline:true];
    //横线
    [SPRTPrint drawLine:2 startX:0 startY:(480+8+32+8) endX:(560) endY:(480+8+32+8) isFullline:true]; // 第一联横线2;
    
    [SPRTPrint drawText:(2+8) textY:(548+8) widthNum:64 heightNum:96 textStr:@"详细地址" fontSizeNum:3 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
    [SPRTPrint drawText:(2+4+64+8+8) textY:528+8 widthNum:(460) heightNum:96 textStr:self.receiverAddress fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
    
    [SPRTPrint drawLine:2 startX:(2+4+64+8) startY:320 endX:(2+4+64+8) endY:(640) isFullline:true];
    
    [SPRTPrint drawLine:2 startX:0 startY:(640) endX:(560) endY:(640) isFullline:true]; // 第一联横线2;
    
    
    [SPRTPrint drawText:(2+4) textY:(640+8+10) textStr:@"打印网点" fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
    
    [SPRTPrint drawText:(200) textY:(640+8+10) textStr:[NSString stringWithFormat:@"%@ : %@",self.registerSite,subDateString] fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
    
    [SPRTPrint drawLine:2 startX:(2+4+8+100) startY:640 endX:(2+4+8+100) endY:(688+8) isFullline:true];
    
    [SPRTPrint drawLine:2 startX:0 startY:(688+8) endX:(560) endY:(688+8) isFullline:true]; // 第一联横线2;
    
    //派送方式
    [SPRTPrint drawText:(2+4) textY:704 textStr:self.dispatchMode fontSizeNum:3 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
    // 条码字符；
    [SPRTPrint drawText:(2+170) textY:704 textStr:subBillCode fontSizeNum:3 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
    
    
    [SPRTPrint drawText:(480) textY:(704) textStr:@"已检视" fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
    
    [SPRTPrint drawLine:2 startX:0 startY:(738) endX:560 endY:(738) isFullline:true]; // 第一联横线1;
    
    [SPRTPrint print:0 skipNum:1];
}

/*计算宽度然后推算出 前边需要添加的宽度 使其字符串居中
 string:字符串
 oldSumWidth:  原本字符创所占总宽度
 */
- (CGFloat)computeStringWidth:(NSString *)string oldSumWidth:(CGFloat)width{
    CGFloat stringWidth = string.length*48;
    if (stringWidth >= width) {
        return 0;
    }
    return (width-stringWidth)/2;
}

//视图退出时 销毁对像
- (void)viewDidUnload{
    [self.centralManager cancelPeripheralConnection:activeDevice];
    [self setDeviceListTableView:nil];
    [self setScanConnectActivityInd:nil];
    self.centralManager.delegate = nil;
    [super viewDidUnload];
}

//视图旋转
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

//重连
- (void)buttonStartDiscovery:(UIButton *)button {
    autoConnect = true;
    //if (self.peripheral.isConnected)
    if (self.selectedPeripheral.state==CBPeripheralStateConnected)
        [self.centralManager cancelPeripheralConnection:self.selectedPeripheral];
    //清空当前设备列表
		if ( self.deviceList == nil) self.deviceList = [[NSMutableArray alloc]init];
    else [self.deviceList removeAllObjects];
    [deviceListTableView reloadData];
    //[centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:kServiceUUID]] options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @YES}];
    
    [self.centralManager scanForPeripheralsWithServices:nil options:nil];
    [scanConnectActivityInd startAnimating];
    [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(stopScanPeripheral) userInfo:nil repeats:NO];
}
- (void) stopScanPeripheral
{
    [self.centralManager stopScan];
    [scanConnectActivityInd stopAnimating];
    NSLog(@"stop scan");
}

/*---------------------------------------------------------------------------------------------------------------------------------------
 *
 *  @method CBCentralManagerDelegate CBPeripheralDelegate
 *
----------------------------------------------------------------------------------------------------------------------------------------*/
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma  mark -- CBCentralManagerDelegate
//链接状态
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSString * state = nil;
		switch ([central state])
		{
			case CBCentralManagerStateUnsupported:
				state = @"The platform/hardware doesn't support Bluetooth Low Energy.";
				break;
			case CBCentralManagerStateUnauthorized:
				state = @"The app is not authorized to use Bluetooth Low Energy.";
				break;
			case CBCentralManagerStatePoweredOff:
				state = @"Bluetooth is currently powered off.";
				break;
			case CBCentralManagerStatePoweredOn:
				state = @"work";
				break;
			case CBCentralManagerStateUnknown:
			default:
			;
		}
		NSLog(@"Central manager state: %@", state);
    if (central.state == CBCentralManagerStatePoweredOn && activeDevice != nil && autoConnect == false) {
            //链接外部设备
            if ( self.deviceList == nil)
                self.deviceList = [[NSMutableArray alloc]init];
            //发现所有外部设备
            [self.centralManager scanForPeripheralsWithServices:nil options:nil];

    }
}
/**
 *  发现外部设备
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    if (peripheral)
    {
        if (peripheral.name.length <= 0) {
            return;
        }
        NSLog(@"foundDevice. name[%s]\n",peripheral.name.UTF8String,peripheral);
        //if ( [peripheral.name isEqualToString:@"T9 BT Printer"] )
        {
            //self.peripheral = peripheral;
            //发现设备后即可连接该设备 调用完该方法后会调用代理CBCentralManagerDelegate的- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral表示连接上了设别
            //如果不能连接会调用 - (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
            //[centralManager connectPeripheral:peripheral options:@{CBConnectPeripheralOptionNotifyOnConnectionKey : YES}];
            if (![self.deviceList containsObject:peripheral])
                [self.deviceList  addObject:peripheral];
            
            //NSLog(@"foundDevice. name[%s],RSSI[%d]\n",peripheral.name.UTF8String,peripheral.RSSI.intValue);
            [deviceListTableView reloadData];
        }
        if ([[activeDevice.identifier UUIDString] isEqualToString:[peripheral.identifier UUIDString]] && autoConnect == false) {
            [self.centralManager stopScan];
            NSLog(@"stop scan");
            self.selectedPeripheral = peripheral;
            //[self.centralManager stopScan];
            //NSLog(@"buttonStartConnect\n");
            //[bluetoothRadio startConnectDevice:device timeout:DEFAULT_CONNECT_TIMEOUT];
            [self.centralManager connectPeripheral:peripheral options:@{CBConnectPeripheralOptionNotifyOnConnectionKey : @YES}];
            index = [NSIndexPath indexPathForRow:self.deviceList.count-1 inSection:0];
        }
    }
}

//链接外设成功
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"has connected");
        //[mutableData setLength:0];
    self.selectedPeripheral.delegate = self;
    
    //此时设备已经连接上了  你要做的就是找到该设备上的指定服务 调用完该方法后会调用代理CBPeripheralDelegate（现在开始调用另一个代理的方法了）的
    //- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
    if ([[peripheral name] isEqualToString:kSiPuRuiTeName]){
        [self.selectedPeripheral discoverServices:@[[CBUUID UUIDWithString:kServiceUUID]]];
        [self.selectedPeripheral discoverServices:@[[CBUUID UUIDWithString:kServiceUUID_cj]]];
    }else if ([[peripheral name] isEqualToString:kZhiKeName]){
        //芝柯发现制定服务
        [self.selectedPeripheral discoverServices:@[[CBUUID UUIDWithString:kZhiKeServiceUUID]]];
    }else if ([[peripheral name] isEqualToString:kWanChenName]) {
        //万琛发现☞服务
        [self.selectedPeripheral discoverServices:@[[CBUUID UUIDWithString:kWanChenServiceUUID]]];
    }else{
        //发现所有服务
        [self.selectedPeripheral discoverServices:nil];
    }
    
    if ([[activeDevice.identifier UUIDString] isEqualToString: [peripheral.identifier UUIDString]] && autoConnect == false) {
        [ self tableView : self.deviceListTableView accessoryButtonTappedForRowWithIndexPath : index];
    }
    
}
//链接断开
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Peripheral Disconnected");
    //self.peripheral = nil;
    [deviceListTableView reloadData];
    [self alertMessage:@"连接断开！"];
}
//链接失败
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    //此时连接发生错误
    NSLog(@"connected periphheral failed");
    [self alertMessage:@"连接失败！"];
}


#pragma mark -- CBPeripheralDelegate
//数据返回？？？
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:error
{
		if (error==nil) 
		{
			NSLog(@"Write edata failed!");
			return;
		}
		NSLog(@"Write edata success!");
}


/*
 *  发现服务
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error==nil) 
    {
        //在这个方法中我们要查找到我们需要的服务  然后调用discoverCharacteristics方法查找我们需要的特性
        //该discoverCharacteristics方法调用完后会调用代理CBPeripheralDelegate的
        //- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
        NSLog(@"所有服务 %@",peripheral.services);
        for (CBService *service in peripheral.services)
        {
            if ([service.UUID isEqual:[CBUUID UUIDWithString:kServiceUUID]]) 
            {
                cjFlag=0;
                //[peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:kCharacteristicUUID]] forService:service];
                [peripheral discoverCharacteristics:nil forService:service];
            }
            // qzfeng begin 2016/05/10
            else if ([service.UUID isEqual:[CBUUID UUIDWithString:kServiceUUID_cj]])
            {
                //[peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:kCharacteristicUUID]] forService:service];
                cjFlag=1;       // qzfeng 2016/05/10
                [peripheral discoverCharacteristics:nil forService:service];
            }
            //芝柯服务中特性获取
            else if ([service.UUID isEqual:[CBUUID UUIDWithString:kZhiKeServiceUUID]]) {
                cjFlag=0;
                //[peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:kCharacteristicUUID]] forService:service];
                [peripheral discoverCharacteristics:nil forService:service];
            }
            else if ([service.UUID isEqual:[CBUUID UUIDWithString:kZhiKeServiceUUID]]) {
                cjFlag=0;
                [peripheral discoverCharacteristics:nil forService:service];
            }
        }
    }else{
        NSLog(@"未找到指定服务");
    }
}
/*
 * 发现服务里面的所有特征
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    if (error==nil) {
        //在这个方法中我们要找到我们所需的服务的特性 然后调用setNotifyValue方法告知我们要监测这个服务特性的状态变化
        //当setNotifyValue方法调用后调用代理CBPeripheralDelegate的- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
        NSLog(@"%@",service.characteristics);
        for (CBCharacteristic *characteristic in service.characteristics) 
        {
            if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kWriteCharacteristicUUID]]) 
            {
                   [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                    activeWriteCharacteristic = characteristic;
            }
            else
            if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kReadCharacteristicUUID]]) 
            {
                   [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                    activeReadCharacteristic = characteristic;
            }
            else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kFlowControlCharacteristicUUID]]) {
                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                activeFlowControlCharacteristic = characteristic;
                credit = 0;
                response = 1;
            }
            else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kWriteCharacteristicUUID_cj]]) {
            
                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                activeWriteCharacteristic = characteristic;
            }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kReadCharacteristicUUID_cj]]) {
                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                activeReadCharacteristic = characteristic;
            }
            //芝柯特性 写和读
            else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kZhiKeWriteCharacteristicUUID]]) {
                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                activeWriteCharacteristic = characteristic;
            }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kZhiKeReadCharacteristicUUID]]) {
                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                activeReadCharacteristic = characteristic;
            }
            //刷新列表
            [deviceListTableView reloadData];
            [scanConnectActivityInd stopAnimating];
            activeDevice = peripheral;
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
		NSLog(@"enter didUpdateNotificationStateForCharacteristic!");
    if (error==nil) 
    {
        //调用下面的方法后 会调用到代理的- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
        [peripheral readValueForCharacteristic:characteristic];
    }
}


- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"enter didUpdateValueForCharacteristic!");
    NSData *data = characteristic.value; 
    NSLog(@"read data=%@!",data);
    if (characteristic == activeFlowControlCharacteristic) {
        NSData * data = [characteristic value];
        NSUInteger len = [data length];
        int bytesRead = 0;
        if (len > 0) {
            unsigned char * measureData = (unsigned char *) [data bytes];
            unsigned char field = * measureData;
            measureData++;
            bytesRead++;
            if(field == 2){
                unsigned char low  = * measureData;
                measureData++;
                mtu =  low + (* measureData << 8);
            }
            if(field == 1){
                if(credit < 5) {
                    credit += * measureData;
                }
            }
        }
    }
}


//---------------------------------------------------------------------------------------------------------------------------------------



//－行的数量：
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section   
{
    return [self.deviceList count];
}

//－行的定义  
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  
{
    static NSString * CellIdentifier = @"JODeviceListIdentifier";  
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];  
    if (cell == nil)
    {
        //默认样式
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    //文字的设置
    NSUInteger row=[indexPath row];
    CBPeripheral * device = [self.deviceList objectAtIndex:row];
    cell.textLabel.text= device.name;
    
//    UIButton *button ; 
//    button = [ UIButton buttonWithType : UIButtonTypeRoundedRect ];
//    CGRect frame = CGRectMake ( 0.0 , 0.0 , 70 , 35 );
//    button. frame = frame;
//    //if(device.isConnected)
//    if(device.state==CBPeripheralStateConnected)
//    {
//        [button setTitle:@"断开" forState:UIControlStateNormal];        
//    }
//    else {
//        [button setTitle:@"连接" forState:UIControlStateNormal];
//    }
//    button.backgroundColor = [ UIColor clearColor ];
//    cell.accessoryView = button;
//    
//    [button addTarget : self action : @selector ( btnDeviceListClicked : event :)   forControlEvents :UIControlEventTouchUpInside ];
    
    if(device.state==CBPeripheralStateConnected)
    {
        cell.detailTextLabel.text = @"断开";
    }
    else {
        cell.detailTextLabel.text = @"连接";
    }

    
    return cell;  
}

/*!
 *
 *  用户按下连接或者断开按钮，进行连接或者断开操作
 */
-( void )tableView:( UITableView *) tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    CBPeripheral * device = [self.deviceList objectAtIndex:[indexPath row]];
    
    [scanConnectActivityInd stopAnimating];
    //if(device.isConnected)
    if ([[activeDevice.identifier UUIDString] isEqualToString:[device.identifier UUIDString]] && autoConnect == false) {
        [self.centralManager stopScan];
        NSLog(@"stop scan");
        self.selectedPeripheral = device;
        //[self.centralManager stopScan];
        //NSLog(@"buttonStartConnect\n");
        //[bluetoothRadio startConnectDevice:device timeout:DEFAULT_CONNECT_TIMEOUT];
        [self.centralManager connectPeripheral:device options:@{CBConnectPeripheralOptionNotifyOnConnectionKey : @YES}];
        autoConnect = true;
    }else{
        autoConnect = true;
        if(device.state==CBPeripheralStateConnected)
        {
            //NSLog(@"buttonStartDisconnect\n");
            //[bluetoothRadio startDisconnectDevice:device];
            [self.centralManager cancelPeripheralConnection:device];
        }
        else
        {
            [self.centralManager stopScan];
            NSLog(@"stop scan");
            self.selectedPeripheral = device;
            //[self.centralManager stopScan];
            //NSLog(@"buttonStartConnect\n");
            //[bluetoothRadio startConnectDevice:device timeout:DEFAULT_CONNECT_TIMEOUT];
            [self.centralManager connectPeripheral:device options:@{CBConnectPeripheralOptionNotifyOnConnectionKey : @YES}];
            
        }
    }
    [scanConnectActivityInd startAnimating];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [ self tableView : self.deviceListTableView accessoryButtonTappedForRowWithIndexPath : indexPath];
}
/*!
 *
 *  检查用户点击按钮时的位置，并转发事件到对应的 accessory tapped 事件
 */
- ( void )btnDeviceListClicked:( id )sender event:( id )event
{
    NSSet *touches = [event allTouches ];
    UITouch *touch = [touches anyObject ];
    CGPoint currentTouchPosition = [touch locationInView : self.deviceListTableView];
    NSIndexPath *indexPath = [ self.deviceListTableView indexPathForRowAtPoint : currentTouchPosition];
    if (indexPath != nil )
    {
        [ self tableView : self.deviceListTableView accessoryButtonTappedForRowWithIndexPath : indexPath];
    }
}

-(void) alertMessage:(NSString *)msg{
    UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"提示" 
                                                   message:msg
                                                  delegate:self
                                         cancelButtonTitle:@"关闭" 
                                         otherButtonTitles:nil];
    [alert show];
    //[alert release];
    
}
@end
