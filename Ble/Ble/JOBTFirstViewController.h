//
//  JOBTFirstViewController.h
//  BTDemo
//
//  Created by ligl on 15-07-21.
//
#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreBluetooth/CBService.h>
#import <UIKit/UIKit.h>
@interface JOBTFirstViewController : UIViewController<CBCentralManagerDelegate,CBPeripheralDelegate,UITableViewDelegate,UITableViewDataSource>
{
  
}
//上级传参
@property(copy,nonatomic) NSString *productType;
@property(copy,nonatomic) NSString *billCodeSub;
@property(copy,nonatomic) NSString *destinationCenter;
@property(copy,nonatomic) NSString *dispatchSite;
@property(copy,nonatomic) NSString *billCode;
@property(copy,nonatomic) NSString *count;
@property(copy,nonatomic) NSString *receiverAddress;
@property(copy,nonatomic) NSString *registerSite;
@property(copy,nonatomic) NSString *sendDate;
@property(copy,nonatomic) NSString *dispatchMode;

@property(assign,nonatomic) BOOL isPrintDan; //是否是录单打印页面跳转进入

@property(strong,nonatomic)CBCentralManager *centralManager;
@property(strong,nonatomic)CBPeripheral *selectedPeripheral;
@property(strong,nonatomic)NSMutableArray *deviceList;

@property (strong, nonatomic) UITableView *deviceListTableView;
@property (strong, nonatomic) UIActivityIndicatorView *scanConnectActivityInd;
- (void)buttonStartDiscovery:(id)sender;
- (void) stopScanPeripheral;

@end
