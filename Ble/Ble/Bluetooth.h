#ifndef Bluetooth_h
#define Bluetooth_h


#import <Foundation/Foundation.h>

#import <CoreBluetooth/CoreBluetooth.h>

#define MAX_DATA_SIZE (1024)
//#define MAX_DATA_SIZE (1024*20)
//typedef void(^BLOCK_CALLBACK_SCAN_FIND)(CBPeripheral*);

@interface Bluetooth : NSObject<CBCentralManagerDelegate,CBPeripheralDelegate>
{
    Byte _buffer[MAX_DATA_SIZE];
    int _offset;
    int _sendedDataLength;
    int leftDataLength;
    
}
//@property(assign)WrapDatas *wrap;
//- (void)scanStart:(BLOCK_CALLBACK_SCAN_FIND)callback;
//- (void)scanStop;
//- (bool)open:(CBPeripheral*)peripheral;
- (void)close;
- (bool)write:(NSString*)strData;
- (bool)writeData:(NSData*)data;
- (void)flushRead;
- (bool)readBytes:(BytePtr)data len:(int)len timeout:(int)timeout;


-(void)StartPage:(int) pageWidth  pageHeight:(int)pageHeight ;
-(void)end;
-(void)zp_drawText:(int)x y:(int)y text:(NSString*)text font:(int)fontsize fontsize:(int)fontsize;
-(void)zp_drawLine:(int)startPointX startPiontY:(int)startPointY endPointX:(int)endPointX endPointY:(int)endPointY width:(int)width;
-(void)zp_darw1D_barcode:(int)x y:(int)y  height:(int)height text:(NSString*)text;
-(void) zp_darwQRCode:(int)x y:(int)y unit_width:(int)unit_width  text:(NSString*)text;
-(void)zp_darwRect:(int)left top:(int)top right:(int)right bottom:(int)bottom width:(int)width;


@property (getter=getDataLength,readonly)int dataLength;
-(BOOL) addData:(Byte *)data length:(int)length;
-(BOOL) addByte:(Byte)byte;
-(BOOL) addShort:(ushort)data;
-(BOOL) add:(NSString *)text;
-(NSData*) getData:(int)sendLength;
-(void) reset;
-(BOOL) addC:(NSString *)text;
@end


    

#endif /* Bluetooth_h */





