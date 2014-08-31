//
//  rateTableView.h
//  rate2
//
//  Created by YK on 2014. 8. 29..
//  Copyright (c) 2014년 yk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface rateTableView : UITableViewController {
    
    // 날씨 정보 전체를 저장할 딕셔너리
    NSMutableDictionary *weatherDic;
    
    // 날씨 정보 item들을 담을 배열
    NSMutableArray *itemArray;
}

@end