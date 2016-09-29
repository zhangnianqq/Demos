#import <Foundation/Foundation.h>
#include "Bluetooth.h"

extern CBPeripheral *activeDevice;
extern CBCharacteristic *activeWriteCharacteristic;
extern CBCharacteristic *activeReadCharacteristic;
extern CBCharacteristic *activeFlowControlCharacteristic;
extern int mtu;
extern int credit;
extern int response;

extern int cmd;

extern int cjFlag;          // qzfeng 2016/05/10

@interface Bluetooth ()
- (void)waitUI:(int)ms;


//@property (strong, nonatomic) BLOCK_CALLBACK_SCAN_FIND scanFindCallback;
//@property (strong, nonatomic) CBCentralManager *centralManager;
//@property (strong, nonatomic) CBPeripheral* peripheral;
@property int connectState;
//@property (strong, nonatomic) CBCharacteristic* writeCharacteristic;
//@property (strong, nonatomic) CBCharacteristic* readCharacteristic;
//@property (strong, nonatomic) NSMutableArray* nServices;
@end

@implementation Bluetooth


static Byte receiveBuffer[1024];
static int receiveLength=0;

/* 芝柯官方Demo 链接设备
//开始查看服务, 蓝牙开启
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            break;
        default:
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    //NSLog(@"已发现 peripheral: %@ rssi: %@, advertisementData: %@", peripheral, RSSI, advertisementData);
    self.scanFindCallback(peripheral);
}

//连接外设成功
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    NSLog(@"成功连接 peripheral: %@",peripheral);
    [self.peripheral setDelegate:self];
    [self.peripheral discoverServices:nil];
    NSLog(@"扫描服务...");
}

//掉线时调用
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"periheral has disconnect %@",error);
    self.connectState=-1;
}

//连接外设失败
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"connect fail %@", error);
    self.connectState=-1;
}


//已发现服务
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    NSLog(@"发现服务!");
    int i = 0;
    for(CBService* s in peripheral.services){
        [self.nServices addObject:s];
    }
    for(CBService* s in peripheral.services){
        NSLog(@"%d :服务 UUID: %@(%@)", i, s.UUID.data, s.UUID);
        i++;
        [peripheral discoverCharacteristics:nil forService:s];
        NSLog(@"扫描Characteristics...");
    }
}

//已发现characteristcs
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    for(CBCharacteristic* c in service.characteristics){
        NSLog(@"特征 UUID: %@ (%@)", c.UUID.data, c.UUID);
        if([c.UUID isEqual:[CBUUID UUIDWithString:@"FFF2"]]){
//            self.writeCharacteristic = c;
            //            [self.myPeripheral setNotifyValue:YES forCharacteristic:c];
            //            [self.myPeripheral readValueForCharacteristic:c];
            NSLog(@"找到WRITE : %@", c);
            self.connectState=1;
        }else if([c.UUID isEqual:[CBUUID UUIDWithString:@"FFF1"]]){
//            self.readCharacteristic = c;
            //            CBDescriptor* description = [self.myPeripheral description];
            //            [description setValue:<#(id)#> forKey:<#(NSString *)#>];
            [self.peripheral setNotifyValue:YES forCharacteristic:c];
            [self.peripheral readValueForCharacteristic:c];
            NSLog(@"找到READ : %@", c);
        }
    }
}

//获取外设发来的数据,不论是read和notify,获取数据都从这个方法中读取
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{[peripheral readRSSI];
    if([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFF1"]]){
        NSData* data = characteristic.value;
        if(data!=nil)
        {
            //NSLog(@"didUpdateValueForCharacteristic :%@",data);
            Byte *pData=[data bytes];
            for(int i=0;i<[data length];i++)
            {
                receiveBuffer[receiveLength++]=pData[i];
            }
        }
    }
}

- (void)scanStart:(BLOCK_CALLBACK_SCAN_FIND)callback
{
    self.scanFindCallback=callback;
    if(self.centralManager==nil)
    {
        self.centralManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil options:nil];
    }
    [self.centralManager stopScan];
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds* NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        NSLog(@"扫描外设...");
        [self.centralManager scanForPeripheralsWithServices:nil options:nil];
        if(self.peripheral != nil){
            [self.centralManager cancelPeripheralConnection:self.peripheral];
        }
    });
}

- (void)scanStop
{
    [self.centralManager stopScan];
    NSLog(@"停止扫描!");
}

- (void)waitUI:(int)ms
{
    CFRunLoopRef currentLoop = CFRunLoopGetCurrent();
    double delayInSeconds = ms/1000.0f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds* NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        CFRunLoopStop(currentLoop);
    });
    CFRunLoopRun();
}

- (bool)open:(CBPeripheral *)peripheral {
    [self.centralManager stopScan];
    
    self.peripheral=peripheral;
    self.connectState=0;
    [self.centralManager connectPeripheral: self.peripheral  options:nil];
    while(self.connectState==0)
    {
        [self waitUI:50];
    }
    if(self.connectState!=1)return false;
    receiveLength=0;
    return true;
}

- (void)close
{
    [self.centralManager cancelPeripheralConnection:self.peripheral];
}
*/
- (bool)write:(NSString*)strData
{
    NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData *data=[strData dataUsingEncoding: gbkEncoding];
    
    int sended=0;
    while(sended<data.length)
    {
        int len=data.length-sended;
        if(len>20)len=20;
        NSData *d = [data subdataWithRange:NSMakeRange(sended, len)];
        [activeDevice writeValue:d forCharacteristic:activeWriteCharacteristic type:CBCharacteristicWriteWithResponse];
        sended+=len;
    }
    return true;
}

- (bool)writeData:(NSData*)data
{
    int sended=0;
    while(sended<data.length)
    {
        int len=data.length-sended;
        if(len>20)len=20;
        NSData *d = [data subdataWithRange:NSMakeRange(sended, len)];
        [activeDevice writeValue:d forCharacteristic:activeWriteCharacteristic type:CBCharacteristicWriteWithResponse];
        sended+=len;
    }
    return true;
}

- (void)flushRead
{
    receiveLength=0;
}

- (bool)readBytes:(BytePtr)data len:(int)len timeout:(int)timeout
{
    for(int i=0;i<timeout/10;i++)
    {
        if(receiveLength>=len)break;
        [self waitUI:10];
    }
    if(receiveLength<len)return false;
    for(int i=0;i<len;i++)
    {
        data[i]=receiveBuffer[i];
    }
    for(int i=len;i<receiveLength;i++)
    {
        receiveBuffer[i-len]=receiveBuffer[i];
    }
    receiveLength-=len;
    return true;
    
   
}
/*
 * 绘制打印页面
 */
-(void)StartPage:(int) pageWidth  pageHeight:(int)pageHeight
{
    NSString *stringInt = [NSString stringWithFormat:@"%d",pageHeight];
    NSString *pageWidths = [NSString stringWithFormat:@"%d",pageWidth];
    
    
    [self addC:@"! 0 200 200 "];
    [self addC:stringInt];
    [self addC:@" "];
    [self addC:@"1\n\r"];
    [self addC:@"PAGE-WIDTH "];
    [self addC:pageWidths];
    [self addC:@"\n\r"];
    
    [self addC:@"GAP-SENSE "];/////
    
}

/*
 * 绘制打印页面结束
 */
-(void)end{
    [  self addC:@"FORM\n\rPRINT\n\r"];
}

/*
 * 绘制text  x y为坐标，
 text为内容；
 font为字体，有24点阵和16点阵，24点阵填24，16点阵填55；
 fontsize 放大的倍数，填1表示 1乘以字体大小（等于没变大），所以想变大至少乘以2.
 */
-(void)zp_drawText:(int)x y:(int)y text:(NSString*)text font:(int)font fontsize:(int)fontsize;
{
    NSString *xx = [NSString stringWithFormat:@"%d",x];
    NSString *yy = [NSString stringWithFormat:@"%d",y];
    NSString *_font = [NSString stringWithFormat:@"%d",font];
    NSString *_fontsize = [NSString stringWithFormat:@"%d",fontsize];
    
    [self addC:@"SETMAG "];
    [self addC:_fontsize];
    [self addC:@" "];
    [self addC:_fontsize];
    [self addC:@"\n\r"];
    
    [self addC:@"T "];
    [self addC:_font];
    [self addC:@" "];
    [self addC:@"0 "];
    [self addC:xx];
    [self addC:@" "];
    [self addC:yy];
    [self addC:@" "];
    [self addC:text];
    [self addC:@"\n\r"];
    
    [self addC:@"SETMAG "];
    [self addC:@"1 "];
    [self addC:@"1 "];
    [self addC:@"\n\r"];
}

//划线
-(void)zp_drawLine:(int)startPointX startPiontY:(int)startPointY endPointX:(int)endPointX endPointY:(int)endPointY width:(int)width
{
    NSString *strsx = [NSString stringWithFormat:@"%d",startPointX];
    NSString *strsy = [NSString stringWithFormat:@"%d",startPointY];
    NSString *strsex = [NSString stringWithFormat:@"%d",endPointX];
    NSString *strey = [NSString stringWithFormat:@"%d",endPointY];
    NSString *wi = [NSString stringWithFormat:@"%d",width];
    
    
    [self addC:@"LINE "];
    [self addC:strsx];
    [self addC:@" "];
    [self addC:strsy];
    [self addC:@" "];
    [self addC:strsex];
    [self addC:@" "];
    [self addC:strey];
    [self addC:@" "];
    [self addC:wi];
    [self addC:@"\n\r"];
    
}


/*
 *一维条码绘制
 */
-(void)zp_darw1D_barcode:(int)x y:(int)y  height:(int)height text:(NSString*)text
{

    NSString *xx = [NSString stringWithFormat:@"%d",x];
    NSString *yy = [NSString stringWithFormat:@"%d",y];
    NSString *heights = [NSString stringWithFormat:@"%d",height];
    NSString *CODE128 = [NSString stringWithFormat:@"%d",128];
    [self addC:@"B "];
    [self addC:CODE128];
    [self addC:@" "];
    [self addC:@"2 "];
    [self addC:@"1 "];
    [self addC:heights];
    [self addC:@" "];
    [self addC:xx];
    [self addC:@" "];
    [self addC:yy];
    [self addC:@" "];
    [self addC:text];
    [self addC:@"\n\r"];
    
}


/*
 * QRCode
 *
 
 */
-(void) zp_darwQRCode:(int)x y:(int)y unit_width:(int)unit_width  text:(NSString*)text
{

    NSString *xx = [NSString stringWithFormat:@"%d",x];
    NSString *yy = [NSString stringWithFormat:@"%d",y];

    NSString *unit_widthss = [NSString stringWithFormat:@"%d",unit_width];
    [self addC:@"B QR "];
    [self addC:xx];
    [self addC:@" "];
    [self addC:yy];
    [self addC:@" "];
    [self addC:@"M 2"];
    [self addC:@" U "];
    [self addC:unit_widthss];
    [self addC:@"\n\r"];
    [self addC:@"MA,"];
    [self addC:text];
    [self addC:@"\n\r"];
    [self addC:@"ENDQR\n\r"];
}


-(void)zp_darwRect:(int)left top:(int)top right:(int)right bottom:(int)bottom width:(int)width 
{

    NSString *lefts = [NSString stringWithFormat:@"%d",left];
    NSString *tops = [NSString stringWithFormat:@"%d",top];
    NSString *rights = [NSString stringWithFormat:@"%d",right];
    NSString *bottoms = [NSString stringWithFormat:@"%d",bottom];
    NSString *widths = [NSString stringWithFormat:@"%d",width];
    [self addC:@"BOX "];
    [self addC:lefts];
    [self addC:@" "];
    [self addC:tops];
    [self addC:@" "];
    [self addC:rights];
    [self addC:@" "];
    [self addC:bottoms];
    [self addC:@" "];
    [self addC:widths];
    [self addC:@"\n\r"];
}





@synthesize dataLength;
-(id)init{
    self = [super init];
    _offset = 0;
    _sendedDataLength = 0;
    return self;
}

-(void)reset{
    _offset = 0;
    _sendedDataLength = 0;
}

-(int) getDataLength{
    return _offset;
}

-(BOOL) addData:(Byte *)data length:(int)length{
    if (_offset + length > MAX_DATA_SIZE)
        return FALSE;
    memcpy(_buffer + _offset, data, length);
    _offset += length;
    return TRUE;
}

-(BOOL) addByte:(Byte)byte{
    if (_offset + 1 > MAX_DATA_SIZE)
        return FALSE;
    _buffer[_offset++] = byte;
    return TRUE;
}

-(BOOL) addShort:(ushort)data{
    if (_offset + 2 > MAX_DATA_SIZE)
        return FALSE;
    _buffer[_offset++] = (Byte)data;
    _buffer[_offset++] = (Byte)(data>>8);
    return TRUE;
}

-(BOOL) add:(NSString *)text{
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData* gbk = [text dataUsingEncoding:enc];
    Byte* gbkBytes = (Byte*)[gbk bytes]  ;
    if(![self addData:gbkBytes length:gbk.length])
        return FALSE;
    return [self addByte:0x00];
}

-(BOOL) addC:(NSString *)text{
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData* gbk = [text dataUsingEncoding:enc];
    Byte* gbkBytes = (Byte*)[gbk bytes]  ;
    if(![self addData:gbkBytes length:gbk.length])
        return FALSE;
    return true;
}

-(NSData*) getData:(int)sendLength{
    NSData *data;
    data = [[NSData alloc]initWithBytes:_buffer+_sendedDataLength length:sendLength];
    _offset -= sendLength;
    _sendedDataLength +=sendLength;
    return data;
}


@end


