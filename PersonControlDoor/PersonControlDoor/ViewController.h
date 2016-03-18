//
//  ViewController.h
//  PersonControlDoor
//
//  Created by PC_201310113421 on 16/3/17.
//  Copyright © 2016年 PC_201310113421. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface ViewController : UIViewController<CBCentralManagerDelegate,CBPeripheralDelegate,UITableViewDelegate,UITableViewDataSource>
{
    CBCentralManager *manager;
    NSMutableArray *peripheralArray;
    __weak IBOutlet UITableView *tabview;
}

@end

