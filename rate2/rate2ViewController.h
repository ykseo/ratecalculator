//
//  rate2ViewController.h
//  rate2
//
//  Created by YK on 2014. 8. 26..
//  Copyright (c) 2014년 yk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TFHpple.h"
@interface rate2ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, UITextFieldDelegate,UIWebViewDelegate>
@property NSMutableData   *webData; // 서버 데이터 받아옴
@property TFHppleElement *element;
@property TFHpple *xpathParser;
@property NSArray *parseData;
@property NSMutableArray *xmlParseData;
@property NSMutableDictionary *currectItem;
///////////////////////////////////
@property (weak, nonatomic) IBOutlet UILabel *lodingDate;
@property (weak, nonatomic) IBOutlet UISwitch *cashOrRenittance;
@property (weak, nonatomic) IBOutlet UISwitch *changeLable;
@property (weak, nonatomic) IBOutlet UILabel *changeLable1;
@property (weak, nonatomic) IBOutlet UILabel *changeLable2;

@property (weak, nonatomic) IBOutlet UILabel *seleteCountry;
@property (weak, nonatomic) IBOutlet UITextField *inputKoreaMoney;
@property (weak, nonatomic) IBOutlet UITextField *outputValue;
@end

