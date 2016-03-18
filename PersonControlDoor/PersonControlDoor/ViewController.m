//
//  ViewController.m
//  PersonControlDoor
//
//  Created by PC_201310113421 on 16/3/17.
//  Copyright © 2016年 PC_201310113421. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //扫描
    tabview.delegate=self;
    tabview.dataSource=self;
    peripheralArray=[[NSMutableArray alloc]init];
    manager=[[CBCentralManager alloc]initWithDelegate:self queue:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark-CBCentralManagerDelegate

//蓝牙状态
-(void)centralManagerDidUpdateState:(CBCentralManager *)central{
    if (central.state==CBCentralManagerStatePoweredOn) {
        //开始扫描
        [manager scanForPeripheralsWithServices:nil options:nil];
    }
    else{
        NSLog(@"ble close");
    }
}

//扫描结果
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI{
    NSLog(@"%@",advertisementData);
    if (![self isExistPeriheral:peripheral]) {
        [peripheralArray addObject:peripheral];
        [tabview reloadData];
        [manager connectPeripheral:peripheral options:nil];
    }
    
}
//链接
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    NSLog(@"%@ connected",peripheral.name);
    
    //发现服务
    peripheral.delegate=self;
    [peripheral discoverServices:nil];
    
}
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)erro{
     NSLog(@"%@ Fail connected",peripheral.name);
}
-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
     NSLog(@"%@ disConnected",peripheral.name);
    //重连
    [manager connectPeripheral:peripheral options:nil];
}


#pragma mark-CBPeripheralDelegate

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    if (error) {
        NSLog(@"发现服务错误，%@",error);
        return;
    }
    //发现特征
   
    for (CBService *service in peripheral.services) {
        NSLog(@"peripheral name=%@ service uuid=%@",peripheral.name,service.UUID);
        [peripheral discoverCharacteristics:nil forService:service];
    }
    
}

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    if (error) {
        NSLog(@"发现服务特征错误，%@",error);
        return;
    }
     [peripheral readRSSI];
    for (CBCharacteristic *c in service.characteristics) {
        NSLog(@"peripheral name=%@ service uuid=%@,c uuid=%@",peripheral.name,service.UUID,c.UUID);
        NSLog(@"%@",c);
        [peripheral readValueForCharacteristic:c];
        [peripheral setNotifyValue:YES forCharacteristic:c];
    }
    
}

-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error{
    NSLog(@"aaaaaa");
}

-(void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error{
    if (!error) {
         NSLog(@"%@ rssi %d", peripheral.name,[RSSI integerValue]);
    }
}
-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (error) {
        return;
    }
    
}
#pragma mark-私有
-(BOOL)isExistPeriheral:(CBPeripheral *)peripheral{
    BOOL isExist=NO;
    for (CBPeripheral *item in peripheralArray) {
        if ([item.name isEqualToString:peripheral.name]) {
            isExist=YES;
            break;
        }
    }
    return isExist;
}

#pragma mark-UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return peripheralArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CBPeripheral *p=[peripheralArray objectAtIndex:indexPath.row];
    NSString *idt=@"peripheralcell";
    UITableViewCell *cell=[tabview dequeueReusableCellWithIdentifier:idt];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:idt];
        cell.textLabel.text=p.name;
    }
    return cell;
}
@end
