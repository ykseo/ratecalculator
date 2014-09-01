//
//  rate2ViewController.h
//  rate2
//
//  Created by YK on 2014. 8. 26..
//  Copyright (c) 2014년 yk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface rate2ViewController : UIViewController <NSXMLParserDelegate, UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, UITextFieldDelegate>
@property NSMutableData   *webData; // 서버 데이터 받아옴

typedef enum {
    etNone = 0,
    etItem
} eElementType;
@property eElementType elementType;
@property NSMutableString *xmlValue;
@property NSMutableData *receiveData;
@property NSMutableArray *xmlParseData;
@property NSMutableDictionary *currectItem;

//@property float rate;

//@property (weak, nonatomic) IBOutlet UITableView *countryRate;
@property (weak, nonatomic) IBOutlet UILabel *titleLable;
@property (weak, nonatomic) IBOutlet UILabel *seleteCountry;
@property (weak, nonatomic) IBOutlet UILabel *koreaMoney;
@property (weak, nonatomic) IBOutlet UITextField *inputKoreaMoney;
@property (weak, nonatomic) IBOutlet UIButton *arithmeticBut;
@property (weak, nonatomic) IBOutlet UIButton *removeBut;
@property (weak, nonatomic) IBOutlet UITextField *outputValue;
@end

