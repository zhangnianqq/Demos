//
//  SPRTPrint.m
//  BTDemo
//
//  Created by SPRT on 14-10-31.
//
//

#import "SPRTPrint.h"


extern CBPeripheral *activeDevice;
extern CBCharacteristic *activeWriteCharacteristic;
extern CBCharacteristic *activeReadCharacteristic;
extern CBCharacteristic *activeFlowControlCharacteristic;
extern int mtu;
extern int credit;
extern int response;

extern int cmd;

extern int cjFlag;          // qzfeng 2016/05/10

@interface SPRTPrint ()

@end
@implementation SPRTPrint

+ (void) write:(NSData *)data withResponse:(BOOL)withResponse {
    
        NSLog(@"credit4：%d",credit);//fdh
    @synchronized(self)
    {
         NSLog(@"credit5：%d",credit);//fdh
        
        if (activeWriteCharacteristic !=  nil) {
            unsigned long len = [data length];
            unsigned char buf[len];
            NSRange range;
            NSUInteger p = 0;
            NSUInteger l = 0;
            
            while (len > 0) {
                if (withResponse) {
                    if (response > 0) {
                        //l = len;
                        l = ((len > 100) ? 100 : len);
                        range.location = p;
                        range.length = l;
                        [data getBytes:buf range: range];
                        [activeDevice writeValue:[NSData dataWithBytes:buf length:l] forCharacteristic:activeWriteCharacteristic type:CBCharacteristicWriteWithResponse];
                        p += l;
                        len -= l;
                        NSLog(@"response：%d",response);//fdh
                        response--;
                    }else{
                        //NSLog(@"response：%d",response);//fdh
                    }
                } else {
                    if (activeFlowControlCharacteristic != nil) {
                        if (credit > 0) {
                            l = ((len > mtu) ? mtu : len);
                            range.location = p;
                            range.length = l;
                            [data getBytes:buf range: range];
                            [activeDevice writeValue:[NSData dataWithBytes:buf length:l] forCharacteristic:activeWriteCharacteristic type:CBCharacteristicWriteWithoutResponse];
                            p += l;
                            len -= l;
                            credit--;
                            NSLog(@"credit1：%d",credit);//fdh
                        }else{
                            NSLog(@"credit2：%d",credit);//fdh
                        }
                    } else {
                        l = len;
                        range.location = p;
                        range.length = l;
                        [data getBytes:buf range: range];
                        [activeDevice writeValue:[NSData dataWithBytes:buf length:l] forCharacteristic:activeWriteCharacteristic type:CBCharacteristicWriteWithoutResponse];
                        p += l;
                        len -= l;
                        NSLog(@"activeFlowControlCharacteristic != nil");//fdh
                         NSLog(@"credit3：%d",credit);//fdh
                    }
                }
            }
        }

    }
    
    }


+ (BOOL) printBin:(NSData *)bin
{
    //if(activeDevice==nil || !activeDevice.isConnected) return NO;
    if(activeDevice==nil || activeDevice.state!=CBPeripheralStateConnected) return NO;
    
    // qzfeng begin 2016/05/10
    NSLog(@"printBin cjFlag==%d",cjFlag);
    if(cjFlag==1) {
    // qzfeng end 2016/05/10

        if ( isBuffedWrite == YES)
        {
            //NSLog(@"isBufferedWrite==YES");
            NSLog(@"printBin isBuffedWrite ==YES ");
            if (NO==[self putInBuf:bin])
            {
                NSLog(@"printBin put bin=%@fail",bin);
                return NO;
            }
            else
            {
                if ( taskInRunning==NO )
                {
                    taskInRunning = YES;
                    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(SendTask) userInfo:nil repeats:NO];
                    NSLog(@"printBin start sendTask");
                    
                }
                return YES;
            }
        }
    // qzfeng begin 2016/05/10
        else
        {
            NSLog(@"printBin isBuffedWrite == NO,writeValue...");
            [activeDevice writeValue:bin forCharacteristic:activeWriteCharacteristic type:CBCharacteristicWriteWithResponse];
            return YES;
        }
    }
    // qzfeng end 2016/05/10
    else
    {
        NSLog(@"printBin is IVT write...");
        [self write:bin withResponse:false];  //true,等回复,速度慢,可以同步发送
                                             //false,不等回复,需要使用Credit,异步发送
        return YES;
    }
}
+ (BOOL) printTxt:(NSString *)txt
{
    if(activeDevice==nil || activeDevice.state!=CBPeripheralStateConnected) return NO;

	NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData* data=[txt dataUsingEncoding:enc];
    //Byte *b = (Byte*)[data bytes];
    
    // qzfeng begin 2016/05/10
    NSLog(@"printTxt cjFlag==%d",cjFlag);
    if(cjFlag==1) {
    // qzfeng end 2016/05/10
    
    
        if ( isBuffedWrite == YES)
        {
            NSLog(@"printTxt isBuffedWrite ==YES ");
            if (NO==[self putInBuf:data])
            {
                NSLog(@"printTxt put data=%@fail",data);
                return NO;
            }
            else
            {
                if ( taskInRunning==NO )
                {
                    taskInRunning = YES;
                    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(SendTask) userInfo:nil repeats:NO];
                    NSLog(@"printTxt start sendTask");
                }
                return YES;
            }
        }
    // qzfeng begin 2016/05/10
        else
        {
            NSLog(@"printTxt isBuffedWrite == NO,writeValue...");
            [activeDevice writeValue:data forCharacteristic:activeWriteCharacteristic type:CBCharacteristicWriteWithResponse];
            return YES;
        }
    
    }
    // qzfeng end 2016/05/10
    else
    {
        NSLog(@"printTxt is IVT write...");
        [self write:data withResponse:false];
        return YES;
    }
}
+ (BOOL) printAlignCenter
{
    Byte byte[] = {0x1b,0x61,0x01};//打印居中
    NSData *data = [[NSData alloc] initWithBytes:byte length:3];
    if(![self printBin:data]) return NO;
    return YES;
}
+ (BOOL) printAlignLeft
{
    Byte byte[] = {0x1b,0x61,0x00};//打印靠左
    NSData *data = [[NSData alloc] initWithBytes:byte length:3];
    if(![self printBin:data]) return NO;
    return YES;
}
+ (BOOL) printAlignRight
{
    Byte byte[] = {0x1b,0x61,0x02};//打印靠右
    NSData *data = [[NSData alloc] initWithBytes:byte length:3];
    if(![self printBin:data]) return NO;
    return YES;
}
+ (BOOL) sendCheckPaperOutCmd
{
    cmd = DLE_EOT_4;
    Byte byte[] = {0x10,0x04,0x04};//纸传感器状态指令
    NSData *data = [[NSData alloc] initWithBytes:byte length:3];
    if(![self printBin:data]) return NO;
    return YES;
}
+ (BOOL) sendCheckOfflineCmd
{
    cmd = DLE_EOT_1;
    Byte byte[] = {0x10,0x04,0x01};//打印机状态指令
    NSData *data = [[NSData alloc] initWithBytes:byte length:3];
    if(![self printBin:data]) return NO;
    return YES;
}
+ (BOOL) sendCheckErrorCmd
{
    cmd = DLE_EOT_3;
    Byte byte[] = {0x10,0x04,0x03};//错误状态指令
    NSData *data = [[NSData alloc] initWithBytes:byte length:3];
    if(![self printBin:data]) return NO;
    return YES;
}
+ (BOOL) print2DBarCode:(int)type para1:(int)v para2:(int)r para3:(int)k content:(NSData*)data
{
    Byte byte[10];
    //发GS Z n选择条码类型
    byte[0]=0x1d;
    byte[1]=0x5a;
    byte[2]=type;
    
    //发ESC Z v r nl nh d1...dn
    byte[3]=0x1b;
    byte[4]=0x5a;
    byte[5]=v;
    byte[6]=r;
    byte[7]=k;
    byte[8]=[data length]%256;
    byte[9]=[data length]/256;
    
    NSData *cmd = [[NSData alloc] initWithBytes:byte length:10];
    if(![self printBin:cmd]) return NO;
    if(![self printBin:data]) return NO;
    return YES;

}


+ (BOOL) print1DBarCode:(int)type width:(int)w height:(int)h txtpositon:(int)positon content:(NSData*)data;
{
    
    Byte byte[13+[data length]*3];
    NSData * cmd;
    //发GS W n设置宽度
    byte[0]=0x1d;
    byte[1]=0x77;
    byte[2]=w;
    
    //发GS h n设置高度
    byte[3]=0x1d;
    byte[4]=0x68;
    byte[5]=h;
    
    //发GS H n设置文字位置
    byte[6]=0x1d;
    byte[7]=0x48;
    byte[8]=positon;
    
    if (type>=0 && type<=6)
    {
        //发GS k m d1...dk nul打印
        byte[9]=0x1d;
        byte[10]=0x6b;
        byte[11]=type;
        Byte *b=(Byte*)[data bytes];
        memcpy(byte+12,b,[data length]);
        byte[12+[data length]-1]=0x00;
        cmd = [[NSData alloc] initWithBytes:byte length:(12+[data length])];
    }
    else if (type>=65 && type<=73)
    {
        //发GS k m n d1...dn打印
        byte[9]=0x1d;
        byte[10]=0x6b;
        byte[11]=type;
        int t=0;
        if ( type==73 ) //code128
        {
            Byte *bd=(Byte*)[data bytes];
            Byte tmp[3*[data length]];
            int charset=0;//1=字符集A(00-5F) 2=字符集B(20-7f)
            
            for ( int i=0;i<[data length];i++)
            {
                if ( bd[i]>=0 && bd[i]<=0x5f )	//字符集A
                {
                    if (charset!=1)
                    {
                        charset=1;
                        tmp[t]=0x7b;t=t+1;
                        tmp[t]=0x41;t=t+1;
                    }
                    tmp[t]=bd[i];t=t+1;
                }
                else	if ( bd[i]>=0x20 && bd[i]<=0x7f )	//字符集B
                {
                    if (charset!=2)
                    {
                        charset=2;
                        tmp[t]=0x7b;t=t+1;
                        tmp[t]=0x42;t=t+1;
                    }
                    tmp[t]=bd[i];t=t+1;
                }
                else
                {
                    NSLog(@"this function just support char from 0x00 to 0x7f");
                    return NO;
                }
            }//for
            byte[12]=t;
            memcpy(byte+13,tmp,t);
            //NSLog(@"tmp=%@",byte);
        }
        else
        {
            byte[12]=[data length];
            Byte *b=(Byte*)[data bytes];
            memcpy(byte+13,b,[data length]);
            t = [data length];
        }
        cmd = [[NSData alloc] initWithBytes:byte length:(13+t)];
    }
    else return false;
    NSLog(@"cmd=%@",cmd);
    if(![self printBin:cmd]) return NO;
    return YES;
    
}


/**
 * 转换成code c128码
 * qzfeng 2015/11/11
 * data为输入字符串，必须为数字，dataBytes为转换后的字节，retDataBytesLen为转换后的字节的长度，
 **/

+ (BOOL) getCodeCByte: (NSData*)data content3:(Byte *)dataBytes retLen:(int *)retDataBytesLen;
{
    NSLog(@"qzf at getCodeCByte() come here0");
    NSLog(@"qzf at getCodeCByte() data=%@",data);
    
    Byte *bd=(Byte*)[data bytes];
    int dataLen=(int)[data length];
    
    if(dataLen==0)
    {
        *retDataBytesLen=0;
        return true;
    }
    if(dataLen==1)
    {
        dataBytes[0]=(Byte)(*bd-0x30);
        *retDataBytesLen=1;
        return true;
    }

    int k=0;
    for(int i=0; i<dataLen; i++)
    {
        int m=i%2;          // i为奇数则需处理;
        if((m!=0))
        {
            Byte b1=*(bd+i-1);
            Byte b2=*(bd+i);
            int idx=(int)(b1&0x0f)*10+(int)(b2&0x0f);
            dataBytes[k]=(Byte)idx;
            k++;
            NSLog(@"qzf at getCodeCByte() b1=%x,b2=%x,idx=%d",b1,b2,idx);
        }
        else
        {
            if(i==dataLen-1)
            {
//              dataBytes[k]=(Byte)(*(bd+i)-0x30);        // 测试总是为0？也没错，是日志问题； qzfeng 2015/11/11
                dataBytes[k]=(Byte)(*(bd+i)&0x0f);
                k++;

                NSLog(@"qzf at getCodeCByte() dataBytes3[%d]=%x,k=%d,(Byte)(*(bd+i)=%x,i=%d,(Byte)(*(bd+i)&0x0f)=%x",k-1,dataBytes[k-1],k,(Byte)*(bd+i),i,(Byte)(*(bd+i)&0x0f));
                
           }
            NSLog(@"qzf at getCodeCByte() i=%d,k=%d",i,k);
            
        }
    }
    *retDataBytesLen=k;
    NSLog(@"qzf at getCodeCByte() dataBytes[0]=%x,dataBytes[1]=%x",dataBytes[0],dataBytes[1]);
    NSLog(@"qzf at getCodeCByte() *retDataBytesLen=%d",*retDataBytesLen);
    return true;
    
}


/**
 * 采用code c打印128条码
 * 15/11/10  fudaohui
 * 注意：data是code b字符集，dataBytes 是code c字符集的数据，
 **/

+ (BOOL) print128BarCode: (int)w height2:(int)h txtpositon2:(int)positon content0:(NSData*)data content2:(Byte *)dataBytes length2:(int)dataBytesLen;
{
    NSLog(@"qzf come here0");
    NSLog(@"qzf 2 dataBytesLen=%d",dataBytesLen);
    Byte byte[256];
    NSData * cmd;
    //发GS W n设置宽度
    byte[0]=0x1d;
    byte[1]=0x77;
    byte[2]=w;
    
    //发GS h n设置高度
    byte[3]=0x1d;
    byte[4]=0x68;
    byte[5]=h;
    
    //发GS H n设置文字位置
    byte[6]=0x1d;
    byte[7]=0x48;
    byte[8]=positon;
    
    
    //发GS k m n d1...dn打印
    byte[9]=0x1d;
    byte[10]=0x6b;
    byte[11]=73;
    
    byte[12]=0;
    int idx=13;
    
    int dataLen=[data length];
    if(dataLen!=0)
    {
        byte[idx]=0x7b;
        idx++;
        byte[idx]=0x42;
        idx++;
        memcpy(byte+idx,(Byte*)[data bytes],dataLen);
        idx+=dataLen;
    }
    if(dataBytesLen!=0)
    {
        byte[idx]=0x7b;
        idx++;
        byte[idx]=0x43;
        idx++;
        memcpy(byte+idx,dataBytes,dataBytesLen);
        idx+=dataBytesLen;
        
    }
    
    byte[12]=idx-13;
    
    NSLog(@"qzf idx=%d,dataLen=%d,dataBytesLen=%d",idx,dataLen,dataBytesLen);
    cmd = [[NSData alloc] initWithBytes:byte length:idx];
    
    
    NSLog(@"cmd=%@",cmd);
    if(![self printBin:cmd]) return NO;
    return YES;
    
}

/*
+ (BOOL) print128BarCode: (int)w height2:(int)h txtpositon2:(int)positon content2:(Byte *)dataBytes length2:(int)dataBytesLen;
{
    NSLog(@"qzf come here0");
    NSLog(@"qzf 2 dataBytesLen=%d",dataBytesLen);
    Byte byte[13+dataBytesLen+10];
    NSData * cmd;
    //发GS W n设置宽度
    byte[0]=0x1d;
    byte[1]=0x77;
    byte[2]=w;
    
    //发GS h n设置高度
    byte[3]=0x1d;
    byte[4]=0x68;
    byte[5]=h;
    
    //发GS H n设置文字位置
    byte[6]=0x1d;
    byte[7]=0x48;
    byte[8]=positon;
    
    
    //发GS k m n d1...dn打印
    byte[9]=0x1d;
    byte[10]=0x6b;
    byte[11]=73;
    
    byte[12]=2+dataBytesLen;
    byte[13]=0x7b;
    byte[14]=0x43;
    NSLog(@"qzf byte[13]=%x,byte[14]=%x,dataBytes[0]=%x",byte[13],byte[14],dataBytes[0]);
    memcpy(byte+15,dataBytes,dataBytesLen);
    
    NSLog(@"qzf dataBytesLen=%d",dataBytesLen);
    cmd = [[NSData alloc] initWithBytes:byte length:(13+2+dataBytesLen)];
    
    
    NSLog(@"cmd=%@",cmd);
    if(![self printBin:cmd]) return NO;
    return YES;
    
} */
+ (BOOL) printBitMap:(int)mode bitmap:(NSData*)bm
{
    Byte byte[5+[bm length]];
    NSData * cmd;
    //发ESC * m nl nh d1...dn(1b 2a m nl nh dl...dk)
    byte[0]=0x1b;
    byte[1]=0x2a;
    byte[2]=mode;
    byte[3]=[bm length]%256;
    byte[4]=[bm length]/256;
    
    Byte *b=(Byte*)[bm bytes];
    memcpy(byte+5, b, [bm length]);
    cmd = [[NSData alloc] initWithBytes:byte length:5+[bm length]];
    //NSLog(@"cmd=%@",cmd);
    if(![self printBin:cmd]) return NO;
    return YES;
}
+ (BOOL) setLineHeight:(int)n
{
    Byte byte[3];
    NSData * cmd;
    //发ESC 3 n(1b 33 n)
    byte[0]=0x1b;
    byte[1]=0x33;
    byte[2]=n;
    cmd = [[NSData alloc] initWithBytes:byte length:3];
    if(![self printBin:cmd]) return NO;
    return YES;

}
+ (BOOL) restoreDefaultLineHeight
{
    Byte byte[2];
    NSData * cmd;
    //发ESC 2 (1b 32)
    byte[0]=0x1b;
    byte[1]=0x32;
    cmd = [[NSData alloc] initWithBytes:byte length:2];
    if(![self printBin:cmd]) return NO;
    return YES;
   
}
+ (BOOL) setChineseWordFormat:(BOOL)isDoubleHeight doubleWidth:(BOOL)isDoubleWidth underline:(BOOL)isUnderLine
{
    Byte byte[3];
    NSData * cmd;
    //发FS ! n (1c 21 n)
    byte[0]=0x1c;
    byte[1]=0x21;
    byte[2]=0;
    if ( isDoubleHeight==YES ) byte[2] |= 0x08;
    else byte[2] &= 0xf7;
    
    if ( isDoubleWidth==YES ) byte[2] |= 0x04;
    else byte[2] &= 0xfb;
    
    if ( isUnderLine==YES ) byte[2] |= 0x80;
    else byte[2] &= 0xfb;
    
    cmd = [[NSData alloc] initWithBytes:byte length:3];
    if(![self printBin:cmd]) return NO;
    return YES;

    
}

+ (BOOL) setAsciiWordFormat:(int)type bold:(BOOL)isbold doubleHeight:(BOOL)isDoubleHeight doubleWidth:(BOOL)isDoubleWidth underline:(BOOL)isUnderLine
{
    Byte byte[3];
    NSData * cmd;
    //发ESC ! n (1b 21 n)
    byte[0]=0x1b;
    byte[1]=0x21;
    byte[2]=0;
    
    if ( type==1 ) byte[2] |= 0x01;
    
    if ( isbold==YES ) byte[2] |= 0x08;
    else byte[2] &= 0xf7;

    
    if ( isDoubleHeight==YES ) byte[2] |= 0x10;
    else byte[2] &= 0xef;
    
    if ( isDoubleWidth==YES ) byte[2] |= 0x20;
    else byte[2] &= 0xdf;
    
    if ( isUnderLine==YES ) byte[2] |= 0x80;
    else byte[2] &= 0xfb;

    cmd = [[NSData alloc] initWithBytes:byte length:3];
    if(![self printBin:cmd]) return NO;
    return YES;

}

+ (void) buffedWriteCtrl:(BOOL)isBuffed
{
    isBuffedWrite = isBuffed;
    NSLog(@"isbuffedWrite=%d",isBuffedWrite);
}

//head+1 point to first data postion,fetch start position
//tail point to last data positon positon,
+ (BOOL) putInBuf:(NSData *)data
{
    int dataLen = [data length];
    Byte *b = (Byte*)[data bytes];
    int emptyLen;
    
    if (tail>=head)
    {
        emptyLen=(BUF_SIZE-(tail-head));
        //NSLog(@"before head=%d,tail=%d,emptyLen=%d",head,tail,emptyLen);
        
        if ( emptyLen<dataLen ) return NO;//no place to put
        if ( (BUF_SIZE-tail-1)>=dataLen )
        {
            memcpy(sndBuf+tail+1, b, dataLen);
            tail +=dataLen;
            //if (tail>=BUF_SIZE) tail=0;
        }
        else
        {
            memcpy(sndBuf+tail+1, b, BUF_SIZE-tail-1);
            memcpy(sndBuf,b+BUF_SIZE-tail-1,dataLen-(BUF_SIZE-tail-1));
            tail=dataLen-(BUF_SIZE-tail-1)-1;
        }
    }
    else
    {
        emptyLen=head-tail;
        
        //NSLog(@"before head=%d,tail=%d,emptyLen=%d",head,tail,emptyLen);
        if (emptyLen<dataLen) return NO;//no place to put
        memcpy(sndBuf+tail+1, b, dataLen);
        tail += dataLen;
    }
    //NSLog(@"after head=%d,tail=%d",head,tail);
    return YES;
}
+ (NSData *)getFromBuf
{
    Byte b[GET_NUM];
    int dataLen=0,leftLen=0;
    if ( head == tail ) return nil;
    if ( head>tail)
    {
        if ( (BUF_SIZE-head-1)>=GET_NUM ) //have enough data,no wrap
        {
            dataLen = GET_NUM;
            memcpy(b, sndBuf+head+1, GET_NUM);
            head += GET_NUM;
        }
        else
        {
            dataLen = BUF_SIZE-head-1;
            if (dataLen>0) memcpy(b, sndBuf+head+1, dataLen);
            leftLen = GET_NUM - dataLen;
            
            if (leftLen>=(tail+1)) leftLen=tail+1;
            memcpy(b+dataLen, sndBuf, leftLen);
            dataLen += leftLen;
            head = leftLen-1;
        }
    }
    else
    {
        if ((tail-head)<GET_NUM ) dataLen=tail-head;
        else dataLen = GET_NUM;
        memcpy(b, sndBuf+head+1, dataLen);
        head += dataLen;
    }
    //NSLog(@"getfrom head=%d,tail=%d",head,tail);
    NSData *data = [[NSData alloc] initWithBytes:b length:dataLen];
    //[data retain];
    return data;
}

+ (BOOL) isBuffEmpty
{
    if ( head == tail ) return YES;
    else return NO;
}
+ (void) SendTask
{
    NSLog(@"SendTask started");
    int interval=0.1;
    
    NSData *data;
    if ( lastData!=nil )        //上次有发送失败的，优先发送
    {
        data = [[NSData alloc] initWithData:lastData];
        lastData=nil;
        //NSLog(@"datafromlast=%@",data);
    }
    else
        data = [self getFromBuf];
    // NSLog(@"getFromBuf=%@",data);
    
    if ( data==nil)
    {
        taskInRunning=NO;
        NSLog(@"stop SendTask");
        
    }
    else if ([data length] > 0 )
    {
        NSLog(@"datalen=%d",[data length]);
        //Boolean ret=[activeDevice writeData:data];
        [activeDevice writeValue:data forCharacteristic:activeWriteCharacteristic type:CBCharacteristicWriteWithResponse];
        Boolean ret=YES;
        {
            if (!ret)
            {
                
                NSLog(@"write data failed");
                lastData = [[NSMutableData alloc] initWithData:data];
                NSLog(@"lastData=%@ failed",lastData);
                interval = 1;
            }
            else interval=0.1;
        }
        if ( NO==[self isBuffEmpty] || lastData!=nil )
            [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(SendTask) userInfo:nil repeats:NO];
        else taskInRunning=NO;
    }
    
}
+ (BOOL) printPNG_JPG:(NSString *)filename offset:(int) xoff
{
    if (xoff<0) return NO;
    Byte BayerPattern[8][8] =
				{
					 {0, 32,  8, 40,  2, 34, 10, 42},
					 {48, 16, 56, 24, 50, 18, 58, 26},
					 {12, 44,  4, 36, 14, 46,  6, 38},
					 {60, 28, 52, 20, 62, 30, 54, 22},
					 {3, 35, 11, 43,  1, 33,  9, 41},
					 {51, 19, 59, 27, 49, 17, 57, 25},
					 {15, 47,  7, 39, 13, 45,  5, 37},
					 {63, 31, 55, 23, 61, 29, 53, 21}
				 };

		UIImage *image = [UIImage imageNamed:filename];
		int imageWidth = image.size.width;
    int imageHeight = image.size.height;
    size_t bytesPerRow = imageWidth * 4;
    uint32_t* rgbImageBuf = (uint32_t*)malloc(bytesPerRow * imageHeight);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,kCGImageAlphaPremultipliedFirst);
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), image.CGImage);

	int	bytesPerLine = (imageWidth+7)/8;
    Byte bitmap[imageHeight][bytesPerLine];
    
    for (int i = 0; i < imageHeight; i++) 
			for (int j = 0; j < bytesPerLine; j++)
				bitmap[i][j] = 0;
				
		//遍历像素,生成打印点阵

    uint32_t* pCurPtr = rgbImageBuf;
    
    for (int i = 0; i < imageHeight; i++) 
    {
			for (int j = 0; j < imageWidth; j++)
			{
				int grey = pCurPtr[imageWidth*i+j];

				int red = ((grey & 0x00FF0000) >> 16);
				int green = ((grey & 0x0000FF00) >> 8);
				int blue = (grey & 0x000000FF);

				grey = (int) (red * 0.3 + green * 0.59 + blue * 0.11);
				if( (grey>>2)<BayerPattern[i%8][j%8] )
				{
					bitmap[i][j/8] |= 1<<(7-(j%8));
				}
			}
    }
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    free(rgbImageBuf);
    Byte lineData[(4+bytesPerLine+xoff)*imageHeight+6];
    NSLog(@"datesize=%d",(4+bytesPerLine+xoff)*imageHeight+6);
    lineData[(4+bytesPerLine+xoff)*imageHeight+3]=0x1d;
    lineData[(4+bytesPerLine+xoff)*imageHeight+4]=0x44;
    lineData[(4+bytesPerLine+xoff)*imageHeight+5]=0x0;
    for (int n = 0; n < imageHeight; n++)
    {
		  lineData[3+(4+bytesPerLine+xoff)*n]=0x16;
          lineData[3+(4+bytesPerLine+xoff)*n+1]=bytesPerLine+xoff;
          if (xoff>0) memset(lineData+3+(4+bytesPerLine+xoff)*n+2,0,xoff);
		  for ( int m=0;m<bytesPerLine;m++) lineData[3+(4+bytesPerLine+xoff)*n+2+xoff+m]=bitmap[n][m];
		  lineData[3+(4+bytesPerLine+xoff)*n+bytesPerLine+xoff+2]=0x15;
		  lineData[3+(4+bytesPerLine+xoff)*n+bytesPerLine+xoff+3]=0x01;
			
    }
    lineData[0]=0x1d;
    lineData[1]=0x44;
    lineData[2]=0x01;
    NSData *data=[[NSData alloc] initWithBytes:lineData length:(6+(4+bytesPerLine+xoff)*imageHeight)];
    NSLog(@"date=%d",[data length]);
    if(![self printBin:data]) return NO;
    else return YES;
  

    //return YES;
}
+ (BOOL) cutPaper:(int) mode feed_distance:(int) dis
{
		Byte byte[4];
    NSData * cmd;
    //发GS V m/GS V m n
    byte[0]=0x1d;
    byte[1]=0x56;
    byte[2]=mode;
    if ( mode==0 || mode==1 || mode==48 || mode==49 )
    	cmd = [[NSData alloc] initWithBytes:byte length:3];
    else 
    {
    	byte[3]=dis;
    	cmd = [[NSData alloc] initWithBytes:byte length:4];
    }
    if(![self printBin:cmd]) return NO;
    return YES;
}


/*********************************************************************************************/
/*
	以下是圆通接口函数实现，完成L31标签打印功能;
	qzfeng begin 2015/12/07
 */
/*********************************************************************************************/

/********************************************************************
 函数名：print
 功能:打印标签
 参数:
	horizontal:
	0:正常打印，不旋转；
	1：整个页面顺时针旋转180°后，再打印
 
	skip：
	0：打印结束后不定位，直接停止；
	1：打印结束后定位到标签分割线，如果无缝隙，最大进纸30mm后停止
 
 返回：
	无
 
 ********************************************************************/
+ (void) print:(int) horizontal skipNum:(int) skip
{
    int val=0;
    NSString *pStr1;
    if(horizontal == 1){
        val=2;
    }else{
        val=0;
    }
    if(skip == 1){
        pStr1=[NSString stringWithFormat:@"PR %d\r\nFORM\r\nPRINT\r\n",val];
    }else{
        pStr1=[NSString stringWithFormat:@"PR %d\r\nPRINT\r\n",val];
    }
    
    NSLog(@"qzf at SPRTPrint.m print() pStr1=%@",pStr1);
    
    if(![self printTxt:pStr1])
    {
        NSLog(@"qzf at SPRTPrint.m print() printTxt fail!pStr1=%@",pStr1);
        return ;
    }
    cmd=DLE_EOT_5;      // qzfeng 2015/12/23
    NSLog(@"qzf at SPRTPrint.m print() printTxt succ!");
    return ;
}

/********************************************************************
 函数名：pageSetup
 功能:设置打印纸张大小（打印区域）的大小
 参数:
	pageWidth:打印区域宽度
	pageHeight:打印区域高度
 
 返回：
	无
 
 ********************************************************************/
+ (void) pageSetup:(int) pageWidth pageHeightNum:(int) pageHeight
{
//    NSString *pStr1=[NSString stringWithFormat:@"! 0 200 200 %d 1\r\nPW %d\r\n",pageHeight,pageWidth];
    NSString *pStr1=[NSString stringWithFormat:@"! 0 200 200 %d 1\r\nPW %d\r\nAUTO-BACK\r\n",pageHeight,pageWidth];     // qzfeng 2015/12/23
//    NSString *pStr1=[NSString stringWithFormat:@"! 0 200 200 %d 1\r\nPW %d\r\n",pageHeight,pageWidth];     // 去除自动返回状态；qzfeng 2015/12/23
    NSLog(@"qzf at SPRTPrint.m pageSetup() pStr1=%@",pStr1);
    
    if(![self printTxt:pStr1])
    {
        NSLog(@"qzf at SPRTPrint.m pageSetup() printTxt fail!pStr1=%@",pStr1);
        return ;
    }
    NSLog(@"qzf at SPRTPrint.m pageSetup() printTxt succ!");
    return ;
    
}

/********************************************************************
 函数名：drawBox
 功能:打印的边框
 参数:
	lineWidth: 边框线条宽度
	top_left_x: 矩形框左上角x坐标
	top_left_y: 矩形框左上角y坐标
	bottom_right_x: 矩形框右下角x坐标
	bottom_right_y: 矩形框右下角y坐标
 
 返回：
	无
 
 ********************************************************************/
+ (void) drawBox:(int) lineWidth leftX:(int) top_left_x leftY:(int) top_left_y rightX:(int) bottom_right_x rightY:(int) bottom_right_y
{
    int brX=bottom_right_x;
    int lw=0;
    if((bottom_right_x+lineWidth)>576)
    {
        brX=576-lineWidth;
    }
    if(lineWidth > 5)	//线条宽度太大，打印机会烧坏;
    {
        lw = 1;
    }
    NSString *pStr1=[NSString stringWithFormat:@"BOX %d %d %d %d %d\r\n",top_left_x,top_left_y,brX,bottom_right_y,lw];
    NSLog(@"qzf at SPRTPrint.m drawBox() pStr1=%@",pStr1);
    
    if(![self printTxt:pStr1])
    {
        NSLog(@"qzf at SPRTPrint.m drawBox() printTxt fail! pStr1=%@",pStr1);
        return ;
    }
    NSLog(@"qzf at SPRTPrint.m drawBox() printTxt succ!");
    return ;
    
}

/********************************************************************
 函数名：drawLine
 功能:打印线条
 参数:
	lineWidth: 线条宽度
	start_x: 线条起始点x坐标
	start_y: 线条起始点y坐标
	end_x: 线条结束点x坐标
	end_y: 线条结束点y坐标
	fullline:  true:实线  false: 虚线
 
 
 返回：
	无
 
 ********************************************************************/
+ (void) drawLine:(int) lineWidth startX:(int) start_x startY:(int) start_y endX:(int) end_x endY:(int) end_y isFullline:(Boolean) fullline
{
    NSString *pStr1;
    if(fullline==true){	//实线
        pStr1=[NSString stringWithFormat:@"LINE %d %d %d %d %d\r\n",start_x,start_y,end_x,end_y,lineWidth];
    }else{	//虚线
        pStr1=[NSString stringWithFormat:@"DL %d %d %d %d %d 1 1\r\n",start_x,start_y,end_x,end_y,lineWidth];
    }
    NSLog(@"qzf at SPRTPrint.m drawLine() pStr1=%@",pStr1);
    
    if(![self printTxt:pStr1])
    {
        NSLog(@"qzf at SPRTPrint.m drawLine() printTxt fail! pStr1=%@",pStr1);
        return ;
    }
    NSLog(@"qzf at SPRTPrint.m drawLine() printTxt succ!");
    return ;
    
}

/********************************************************************
 函数名：drawText
 功能:打印文本框
 参数:
	text_x 起始横坐标
	text_y 起始纵坐标
	text  打印的文本内容
	fontSize 字体大小 :
 1：16点阵；
 2：24点阵；
 3：32点阵；
 4：24点阵放大一倍；
 5：32点阵放大一倍
 6：24点阵放大两倍；
 7：32点阵放大两倍；
 其他：24点阵
	rotate 旋转角度:
 0：不旋转；	1：90度；	2：180°；	3:270°
	bold 是否粗体
 0：否； 1：是
	underline 是否下划线
 false：不下划线；true：下划线
	reverse 是否反白
 false：不反白；true：反白
 返回：
	无
 
 ********************************************************************/
+ (void) drawText:(int) text_x textY:(int) text_y textStr:(NSString *) text fontSizeNum:(int) fontSize rotateNum:(int) rotate isBold:(int) bold isUnderLine:(Boolean) underline isReverse:(Boolean) reverse
{
    
    int font=0;
    int size=0;
    int mreverse=0;
    int munderline=0;
    switch (fontSize)
    {
        case 2: //12*24 24*24
            font = 24;
            size = 00;
            break;
        case 4: //24*48  48*48
            font = 24;
            size = 11;
            break;
        case 6: //24点阵  放大两倍; 36*72  72*72
            font = 24;
            size = 22;
            break;
        case 1:
            font = 55;//8*16   16点阵
            size = 00;
            break;
        case 3:		 //32点阵 16*32  32*32   32点阵
            font = 55;
            size = 11;
            break;
        case 5:      //32点阵放大一倍;   64点阵  32*64  64*64
            font = 55;//8*16
            size = 33;
            break;
        case 7:      //32点阵放大两倍;.......
            font = 24;//12*24
            size = 33;
            break;
        default:	//24*24
            font = 24;
            size = 00;
            break;
    }
    if(reverse==true){
        mreverse = 1;
    }else{
        mreverse = 0;
    }
    if(underline==true){
        munderline = 2;		//这里默认选择打印1点下划线
    }else{
        munderline = 0;
    }
    
    NSString *pStr1;
    NSString *pStr2=@"TEXT";
    if(rotate==1)
    {
        pStr2=@"T90";
    }else if(rotate==2)
    {
        pStr2=@"T180";
    }else if(rotate==3)
    {
        pStr2=@"T270";
    }
    pStr1=[NSString stringWithFormat:@"UT %d\r\nSETBOLD %d\r\nIT %d\r\n%@ %d %d %d %d %@\r\n",munderline,bold,mreverse,pStr2,font,size,text_x,text_y,text];
    NSLog(@"qzf at SPRTPrint.m drawText() pStr1=%@",pStr1);
    
    if(![self printTxt:pStr1])
    {
        NSLog(@"qzf at SPRTPrint.m drawText() printTxt fail! pStr1=%@",pStr1);
        return ;
    }
    NSLog(@"qzf at SPRTPrint.m drawText() printTxt succ!");
    return ;
    
}


/********************************************************************
 函数名：drawText
 功能:打印文本框
 参数:
	text_x 起始横坐标
	text_y 起始纵坐标
 width 文本框宽度
 height 文本库高度
	text  打印的文本内容
	fontSize 字体大小 :
 1：16点阵；
 2：24点阵；
 3：32点阵；
 4：24点阵放大一倍；
 5：32点阵放大一倍
 6：24点阵放大两倍；
 7：32点阵放大两倍；
 其他：24点阵
	rotate 旋转角度:
 0：不旋转；	1：90度；	2：180°；	3:270°
	bold 是否粗体
 0：否； 1：是
	underline 是否下划线
 false：不下划线；true：下划线
	reverse 是否反白
 false：不反白；true：反白
 返回：
	无
 
 ********************************************************************/
+ (void) drawText:(int) text_x textY:(int) text_y widthNum:(int) width heightNum:(int) height textStr:(NSString *) text fontSizeNum:(int) fontSize rotateNum:(int) rotate isBold:(int) bold isUnderLine:(Boolean) underline isReverse:(Boolean) reverse
{
    
    int text_x1 = text_x;
    int text_y1 = text_y;
    int curentXWidth = 0;
    int nextXwidth= 0;
    int totalWidth = 0;
    int XdotNumber=0;
    int count=0;
    switch (fontSize) {
        case 1:
            XdotNumber = 16;//16点阵  8*16 16*16
            break;
        case 2:
            XdotNumber = 24;//24点阵
            break;
        case 3:
            XdotNumber = 32;//32点阵
            break;
        case 4:
            XdotNumber = 48;//24点阵放大一倍
            break;
        case 5:
            XdotNumber = 64;//32点阵放大一倍
            break;
        case 6:
            XdotNumber = 72;//24点阵放大两倍
            break;
        case 7:
            XdotNumber = 96;//32点阵放大两倍 96*96
            break;
        default:
            XdotNumber = 24;//32点阵放大两倍 96*96
            break;
    }
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData *da = [text dataUsingEncoding:enc];
    
    unsigned long textLen = [da length];
    Byte *textBytes = (Byte*)[da bytes];
    
    int val=0;
    char retArry[1024];
    memset(retArry,0,sizeof(retArry));
    for (int i = 0; i < textLen; i++) {
        // GBK字符集; 8140-FEFE，首字节在8140-FEFE，首字节在 81-FE 之间，尾字节在 40-FE 之间，剔除 xx7F 一条线;		qzfeng 2015/12/09
        if(true==[self isChinese:textBytes index:i])
        {
            curentXWidth += XdotNumber;
            totalWidth += XdotNumber;
            val=2;
            NSLog(@"is chinese textLen=%ld,i=%d,curentXWidth=%d",textLen,i,curentXWidth);
        }
        else	// 英文;
        {
            curentXWidth += XdotNumber/2;
            totalWidth += XdotNumber/2;
            val=1;
            NSLog(@"is english textLen=%ld,i=%d,curentXWidth=%d",textLen,i,curentXWidth);
            
        }
        
        if ((i <= textLen -4) && (true==[self isChinese:textBytes index:(i+val)])){	// 判断下一个字符是中文还是英文
            nextXwidth = XdotNumber;
            NSLog(@"nextXWidth1=%d,(i+val)=%d",nextXwidth,(i+val));
        }else{
            if(i+val==textLen)
            {
                nextXwidth =0;
            }
            else
            {
                nextXwidth = XdotNumber/2;
            }
            NSLog(@"nextXWidth2=%d,(i+val)=%d",nextXwidth,(i+val));
        }
        
        if(val==1)
        {
            retArry[count++] = textBytes[i];
            NSLog(@"retArry1[%d]=%x",count-1,retArry[count-1]);
        }
        else
        {
            retArry[count++] = textBytes[i];
            NSLog(@"retArry2[%d]=%x",count-1,retArry[count-1]);
            retArry[count++] = textBytes[i+1];
            NSLog(@"retArry2[%d]=%x",count-1,retArry[count-1]);
        }
        
        if ((curentXWidth <= width) && ((curentXWidth+nextXwidth) > width)) {
            NSLog(@"qzf at SPRTPrint.m drawText2() curentXWidth=%d,width=%d,nextXwidth=%d",curentXWidth,width,nextXwidth);
            
            int nLen=(int)strlen(retArry);
            NSString *Str1=[[NSString alloc]initWithBytes:retArry length:nLen encoding:enc];
            NSLog(@"Str1=%@",Str1);
            memset(retArry,0,sizeof(retArry));
            
            [self drawText:text_x1 textY:text_y1 textStr:Str1 fontSizeNum:fontSize rotateNum:rotate isBold:bold isUnderLine:underline isReverse:reverse];
            text_y1 += XdotNumber+2;// 折行，打印满行
            count = 0;
            curentXWidth = 0;
            NSLog(@"text_y1=%d,count=%d,curentXWidth=%d",text_y1,count,curentXWidth);
            
        }
        NSLog(@"i=%d,textLen-1=%ld,curentXWidth=%d,width=%d",i,textLen-1,curentXWidth,width);
        i+=val-1;
        NSLog(@"i=%d,val=%d",i,val);
        if ((i == textLen-1) && curentXWidth <= width) {		//i == textLen -1  遍历完成时
            
            int nLen=(int)strlen(retArry);
            NSString *Str2=[[NSString alloc]initWithBytes:retArry length:nLen encoding:enc];
            
            NSLog(@"i=%d,textLen-1=%ld,curentXWidth=%d,width=%d,Str2=%@,sizeof(retArry)=%ld",i,textLen-1,curentXWidth,width,Str2,sizeof(retArry));
            memset(retArry,0,sizeof(retArry));
            [self drawText:text_x1 textY:text_y1 textStr:Str2 fontSizeNum:fontSize rotateNum:rotate isBold:bold isUnderLine:underline isReverse:reverse];
        }
        
        
    } // for
    
}



/********************************************************************
 函数名：drawBarCode
 功能:打印一维条码
 参数:
	start_x 一维码起始横坐标
	start_y 一维码起始纵坐标
	text    内容
	type 条码类型：
 0：CODE39；	1：CODE128；
 2：CODE93；	3：CODEBAR；
 4：EAN8；  	5：EAN13；
 6：UPCA;   	7:UPC-E;
 8:ITF
	linewidth 条码宽度
	height 条码高度
 
 返回：
	无
 
 ********************************************************************/
+ (void) drawBarCode:(int) start_x startY:(int) start_y textStr:(NSString *) text typeNum:(int) type roateNum:(int) rotate lineWidthNum:(int) linewidth heightNum:(int) height
{
   	NSString  *barcodeType;
    switch (type) {
        case 0://CODE39
            barcodeType = [NSString stringWithFormat:@"39"];
            break;
        case 1://CODE128
            barcodeType = [NSString stringWithFormat:@"128"];
            break;
        case 2://CODE93
            barcodeType = [NSString stringWithFormat:@"93"];
            break;
        case 3://CODEBAR
            barcodeType = [NSString stringWithFormat:@"CODABAR"];
            break;
        case 4://EAN8
            barcodeType = [NSString stringWithFormat:@"39"];
            break;
        case 5://EAN13
            barcodeType = [NSString stringWithFormat:@"EAN13"];
            break;
        case 6://UPCA
            barcodeType = [NSString stringWithFormat:@"UPCA"];
            break;
        case 7://UPCE
            barcodeType = [NSString stringWithFormat:@"UPCE"];
            break;
        case 8://ITF
            barcodeType = [NSString stringWithFormat:@"ITF"];
            break;
        default:
            barcodeType = [NSString stringWithFormat:@"128"];
            break;
    }
    
    NSString  *st1=@"B";
    if(rotate!=0)
    {
        st1=[NSString stringWithFormat:@"VB"];
    }
    
    int val=linewidth-1;			// 为适应用户坐标值调整打印效果;
    
    NSString *pStr1 =[NSString stringWithFormat:@"%@ %@ %d  2 %d %d %d %@\r\n",st1,barcodeType,val,height,start_x,start_y,text];
    NSLog(@"qzf at SPRTPrint.m drawBarCode() pStr1=%@",pStr1);
    
    if(![self printTxt:pStr1])
    {
        NSLog(@"qzf at SPRTPrint.m drawBarCode() printTxt fail! pStr1=%@",pStr1);
        return ;
    }
    NSLog(@"qzf at SPRTPrint.m drawBarCode() printTxt succ!");
    return ;
    
}

/********************************************************************
 函数名：drawQrCode
 功能:打印二维条码
 参数:
	start_x 二维码起始横坐标
	start_y 二维码起始纵坐标
	text    二维码内容
	rotate 旋转角度：
 0：不旋转；	1：90度；	2：180°；	3:270°
	ver  QrCode宽度(2-6)
	lel  QrCode纠错等级(0-20)
 
 返回：
	无
 
 ********************************************************************/
+ (void) drawQrCode:(int) start_x startY:(int) start_y textStr:(NSString *) text roateNum:(int) rotate verNum:(int) ver lelNum:(int) lel
{
    NSString *level = [NSString stringWithFormat:@"M"];
    if (lel == 0)
    {
        level = [NSString stringWithFormat:@"L"];
    }
    else if (lel == 1)
    {
        level = [NSString stringWithFormat:@"M"];
    }
    else if (lel == 2)
    {
        level = [NSString stringWithFormat:@"Q"];
    }
    else if (lel == 3)
    {
        level = [NSString stringWithFormat:@"H"];
    }
    
    NSString *rot = [NSString stringWithFormat:@"B"];
    if (rotate != 0)
    {
        rot = [NSString stringWithFormat:@"VB"];	//打印纵向条码
    }
    
    NSString *pStr1 =[NSString stringWithFormat:@"%@ QR %d %d M 2 U 6\r\n%@A,%@\r\nENDQR\r\n",rot,start_x,start_y,level,text];
    NSLog(@"qzf at SPRTPrint.m drawQrCode() pStr1=%@",pStr1);
    
    if(![self printTxt:pStr1])
    {
        NSLog(@"qzf at SPRTPrint.m drawQrCode() printTxt fail! pStr1=%@",pStr1);
        return ;
    }
    NSLog(@"qzf at SPRTPrint.m drawQrCode() printTxt succ!");
    return ;
    
    
    
}

/********************************************************************
 函数名：printerStatus
 功能:获取打印机状态
 参数:
	无
 
 返回：
	"ok": 成功;
	"no_paper": 缺纸;
	"cover_open":机舱盖打开;
	"connect_failed":通信失败;
 
 ********************************************************************/
+(NSString *) printerStatus
{
    int ret=0;
    /*
     if (ret == 0)
     {
     return "ok";
     }
     else if (ret == 1)
     {
     return "no_paper";
     }
     else if (ret == 2)
     {
     return "cover_open";
     }
     else if (ret == 3)
     {
     return "connect_failed";
     }
     */
    return NULL;
}




/********************************************************************
 函数名：feed
 功能:定位到标签
 参数:
	无
 
 返回：
	无
 
 ********************************************************************/
+ (void) feed
{
    Byte byte[1];
    NSData * cmd;
    byte[0]=0x0c;
   	cmd = [[NSData alloc] initWithBytes:byte length:1];
    if(![self printBin:cmd])
    {
        NSLog(@"qzf at SPRTPrint.m feed() printBin fail!");
        return ;
    }
    NSLog(@"qzf at SPRTPrint.m feed() printBin succ!");
    return ;
    
}


/********************************************************************
 函数名：isChinese
 功能:判断是否是中文
 参数:
	txtBytes:字节数据;
	idx:索引位置;
 
 返回：
	true:中文; false:英文;
 
 ********************************************************************/
+ (Boolean) isChinese:(Byte *) textBytes index:(int)idx
{
    // GBK字符集; 8140-FEFE，首字节在8140-FEFE，首字节在 81-FE 之间，尾字节在 40-FE 之间，剔除 xx7F 一条线;		qzfeng 2015/12/09
    if((textBytes[idx]>=0x81)&&(textBytes[idx]<=0xFE))
    {
        if((textBytes[idx+1]!=0x7F)&&(textBytes[idx+1]>=0x40)&&(textBytes[idx+1]<=0xFE))		// 汉字； qzfeng 2015/12/09
        {
            return true;
        }
        else		// 英文;
        {
            return false;
        }
    }
    else	// 英文;
    {
        return false;
    }
}



/********************************************************************/
/* 	qzfeng end 2015/12/07 */
/********************************************************************/


@end
