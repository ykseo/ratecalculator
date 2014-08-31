//
//  rateTableView.m
//  rate2
//
//  Created by YK on 2014. 8. 29..
//  Copyright (c) 2014년 yk. All rights reserved.
//

#import "rateTableView.h"
#import "TBXML+HTTP.h"

enum cellSubviewTag {
    CELL_IMAGE = 10,
    CELL_LOCATION,
    CELL_TEMP,
    CELL_DESCRIPTION
};

@implementation rateTableView


#pragma mark - XML Parsing

// XML 로드에 성공했을 때 실행됨
void (^tbxmlSuccessBlock)(TBXML *) = ^(TBXML *tbxml) {
    
    // 최상위 엘리먼트 (current), weather 엘리먼트, local 엘리먼트를 가리킬 포인터 생성
    TBXMLElement *elemRoot = nil, *elemWeather = nil, *elemLocal = nil;
    
    // 날씨 정보를 담을 스트링 포인터 생성
    NSString *year = nil, *month = nil, *day = nil, *hour = nil;
    
    // 최상위 엘리먼트의 주소를 가져옴
    elemRoot = tbxml.rootXMLElement;
    
    // 최상위 엘리먼트가 존재한다면(즉, xml을 제대로 읽었다면)
    if(elemRoot) {
        
        // 날씨 엘리먼트 가져옴
        elemWeather = [TBXML childElementNamed:@"weather" parentElement:elemRoot];
        
        // 날씨 엘리먼트가 존재한다면
        if(elemWeather) {
            // 날짜 가져옴
            year = [TBXML valueOfAttributeNamed:@"year" forElement:elemWeather];
            month = [TBXML valueOfAttributeNamed:@"month" forElement:elemWeather];
            day = [TBXML valueOfAttributeNamed:@"day" forElement:elemWeather];
            hour = [TBXML valueOfAttributeNamed:@"hour" forElement:elemWeather];
            NSLog(@"%@. %@. %@. %@:00", year, month, day, hour);
            
            // 날짜 정보를 담은 딕셔너리
            NSDictionary *dateDic = [[NSDictionary alloc] initWithObjectsAndKeys:year, @"year",
                                     month, @"month",
                                     day, @"day",
                                     hour, @"hour",
                                     nil];
            
            // 날짜 정보를 담은 딕셔너리와 함께 노티피케이션 송출
            [[NSNotificationCenter defaultCenter] postNotificationName:@"recieveWeatherInfo"
                                                                object:nil
                                                              userInfo:dateDic];
            
            // 지역 엘리먼트 가져옴
            elemLocal = [TBXML childElementNamed:@"local" parentElement:elemWeather];
            
            // 지역 엘리먼트가 발견되었다면 지역 엘리먼트가 끝날때까지 반복함
            while(elemLocal) {
                
                // 지역명 가져옴
                NSString *localString = [TBXML textForElement:elemLocal];
                
                // 날씨설명, 온도 가져옴
                NSString *descString = [TBXML valueOfAttributeNamed:@"desc" forElement:elemLocal];
                NSString *taString = [TBXML valueOfAttributeNamed:@"ta" forElement:elemLocal];
                
                NSLog(@"Local : %@", localString);
                NSLog(@"Desc : %@", descString);
                NSLog(@"Ta : %@", taString);
                
                // item Dictionary 만들어줌
                NSDictionary *itemDic = [[NSDictionary alloc] initWithObjectsAndKeys:localString, @"local",
                                         descString, @"desc",
                                         taString, @"ta",
                                         nil];
                
                // 어느 한 지역의 날씨정보를 담고있는 item 딕셔너리와 함께 노티피케이션 송출
                [[NSNotificationCenter defaultCenter] postNotificationName:@"recieveNewItem"
                                                                    object:nil
                                                                  userInfo:itemDic];
                // 다음 지역을 가져옴. 지금 지역이 마지막이라면 nil 반환이 되므로 반복 종료
                elemLocal = elemLocal->nextSibling;
            }
        }
    }
};

// XML 로드에 실패했을때 실행됨
void (^tbxmlFailureBlock)(TBXML *, NSError *) = ^(TBXML *tbxml, NSError *error) {
    NSLog(@"Error : %@", error);
};

- (void)parseXML {
    
    // XML이 존재하는 URL 생성
    NSURL *weatherURL = [NSURL URLWithString:@"http://www.kma.go.kr/XML/weather/sfc_web_map.xml"];
    
    // 파싱 시작
    [TBXML newTBXMLWithURL:weatherURL success:tbxmlSuccessBlock failure:tbxmlFailureBlock];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    weatherDic = nil;
    itemArray = nil;
    
    // 처음 날씨 정보를 받아올 때의 노티피케이션 등록
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(recieveWeatherInfo:)
                                                 name:@"recieveWeatherInfo"
                                               object:nil];
    
    // 각각 아이템을 받아왔을 때의 노티피케이션 등록
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(recieveNewItem:)
                                                 name:@"recieveNewItem"
                                               object:nil];
    
    // 테이블뷰의 각 줄의 높이 80.0으로 세팅
    [[self tableView] setRowHeight:80.0f];
    
    [NSThread detachNewThreadSelector:@selector(parseXML) toTarget:self withObject:nil];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // 노티피케이션 제거
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Notification Methods

- (void)recieveWeatherInfo:(NSNotification *)noti
{
    // 노티피케이션으로 전달받은 딕셔너리
    NSDictionary *dateInfo = [[NSDictionary alloc] initWithDictionary:[noti userInfo]];
    
    // item들이 들어갈 배열 초기화
    itemArray = [[NSMutableArray alloc] init];
    
    // 날씨정보 딕셔너리에 날짜 정보 및 item 배열 세팅
    weatherDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:dateInfo, @"date",
                  itemArray, @"items",
                  nil];
    
    NSString *yearStr = [dateInfo objectForKey:@"year"];
    NSString *monthStr = [dateInfo objectForKey:@"month"];
    NSString *dayStr = [dateInfo objectForKey:@"day"];
    NSString *hourStr = [dateInfo objectForKey:@"hour"];
    
    // 날짜정보에 대한 얼럿 생성
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"날씨"
                                                    message:[NSString stringWithFormat:@"%@년 %@월 %@일 %@시의 날씨 상황입니다.", yearStr, monthStr, dayStr, hourStr]
                                                   delegate:nil
                                          cancelButtonTitle:@"확인"
                                          otherButtonTitles:nil];
    
    // 현재 이 메소드는 파싱 스레드에서 호출이 된다.
    // 그런데 화면에 표시하는 작업은 메인 스레드에 붙여주어야 한다.
    // 그래서 performSelectorOnMainThread 를 이용한다.
    //    [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
}


- (void)recieveNewItem:(NSNotification *)noti
{
    // 한 지역의 날씨정보가 들어가 있는 딕셔너리(item)
    NSDictionary *itemDic = [[NSDictionary alloc] initWithDictionary:[noti userInfo]];
    
    // item 배열에 item 추가해 줌
    [itemArray addObject:itemDic];
    
    // 현재 이 메소드는 파싱 스레드에서 호출이 된다.
    // 그런데 화면에 표시하는 작업은 메인 스레드에 붙여주어야 한다.
    // 그래서 performSelectorOnMainThread 를 이용한다.
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    //    return 1;
    // 테이블 줄 수는 아이템의 개수만큼 표시해 주면 된다.
    return [itemArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"exchangeRateCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if(cell == nil) {
        // Cell을 저장한 xib파일 로드
        NSArray *exchangeRateCellXib = [[NSBundle mainBundle] loadNibNamed:@"ExchangeRateTableViewCell"
                                                                     owner:self
                                                                   options:nil];
        // xib 파일에 담긴 object중 첫 번째 객체(셀) 가져옴
        cell = [exchangeRateCellXib objectAtIndex:0];
    }
    // 각각의 서브뷰 포인터 받아옴
    UIImageView *imgView = (UIImageView *)[cell viewWithTag:CELL_IMAGE];
    UILabel *locationLabel = (UILabel *)[cell viewWithTag:CELL_LOCATION];
    UILabel *tempLabel = (UILabel *)[cell viewWithTag:CELL_TEMP];
    UILabel *descriptionLabel = (UILabel *)[cell viewWithTag:CELL_DESCRIPTION];
    
    // 각각의 뷰 초기화
    [imgView setImage:nil];
    [locationLabel setText:nil];
    [tempLabel setText:nil];
    [descriptionLabel setText:nil];
    
    // 아이템 정보를 얻어 옴
    NSDictionary *itemDic = [itemArray objectAtIndex:indexPath.row];
    
    NSString *localStr = [itemDic objectForKey:@"local"];
    NSString *descStr = [itemDic objectForKey:@"desc"];
    NSString *taStr = [itemDic objectForKey:@"ta"];
    
    // 각각의 정보를 라벨에 세팅
    [locationLabel setText:localStr];
    [descriptionLabel setText:descStr];
    [tempLabel setText:taStr];
    
    return cell;
}

@end
