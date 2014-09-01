//
//  rate2ViewController.m
//  rate2
//
//  Created by YK on 2014. 8. 26..
//  Copyright (c) 2014년 yk. All rights reserved.
//

#import "rate2ViewController.h"
#import "rate2AppDelegate.h"

@interface rate2ViewController ()
@end
Boolean dataGetFlag = NO;
@implementation rate2ViewController
@synthesize webData;
NSString *rateVelus;

- (void)viewDidLoad{
    [super viewDidLoad];
    [self goToURL];
    [super viewDidLoad];
    //왠지 모르겠지만 이게없음 테이블이 빨리 그려져 아무값도 표시가 안됨
    while (!dataGetFlag) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.2f]];
        //여기다 로딩 애니메이션 처리하면 되겠다
    }
    dataGetFlag = NO;
    //테스트 필드에 입력이 들어오면 클리어버튼을 활성화시킨다
    _inputKoreaMoney.clearButtonMode = UITextFieldViewModeWhileEditing;
    _outputValue.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    //shouldChangeCharactersInrange

}
- (void)goToURL{
    // Naver에서 제공하는 환율 xml 주소
    NSURL *url = [NSURL URLWithString:@"http://www.naver.com/include/timesquare/widget/exchange.xml"];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    ///////네이버가 쪼잔해서 네이버에서의 요청이 아니면 응답하지않게 되어있다 해더를 고쳐주자!///////
    [theRequest addValue:@"http://www.naver.com" forHTTPHeaderField:@"Referer"];
    ////////////////////////////////////////////////////////////////////////////
    // 포스트 겟 등 설정하는데 서버쪽 메소드에서 선언하는부분이 잇다 서버쪽 설정 확인하자
    [theRequest setHTTPMethod:@"POST"];
    // 실제 연결
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if( theConnection ){
        webData = [NSMutableData data] ; // 바이트 배열 초기화
        NSLog(@"Problem");
    }
    else{
        NSLog(@"theConnection is NULL");
    }
}

// 연결 될때
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    NSLog(@"did Receive Response");
    [webData setLength: 0];
}
// 데이터 받아올때
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"did Receive data");
    [webData appendData:data];
}
// 실패
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"ERROR with theConenction");
}
// 끝났을때
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    //NSLog(@"DONE. Received Bytes: %d", [webData length]);
    // 바이트 데이터를 스트링으로 변환
    NSString *theXML = [[NSString alloc] initWithBytes: [webData mutableBytes] length:[webData length] encoding:NSUTF8StringEncoding];
    //가져온 xml 로그에다 찍어보기
    //NSLog(@"DONE. Data : %@", theXML);
    
    NSData *osman = [theXML dataUsingEncoding:NSUTF8StringEncoding];
    
    _xmlValue = [[NSMutableString alloc] init];
    _receiveData = [[NSMutableData alloc] init];
    _xmlParseData = [[NSMutableArray alloc] init];
    _currectItem = [[NSMutableDictionary alloc] init];
    
    //파싱 준비
    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:osman];
    
    // 파서 델리게이트 먹이기
    xmlParser.delegate = self;
    
    //파서메소드 돌리기
    [xmlParser parse];
    /*
     //parser메소드로 데이터 가지고 오기 성공하면 1
     BOOL parsingResult = [xmlParser parse];
     //NSLog(@"parsingResult : %hhd", parsingResult);
     
     if(parsingResult){
         // 딕셔너리에서 데이터 빼오기
         for (int i = 0 ; i < [_xmlParseData count]; ++i){
             //NSLog (@" %2i   %@",i+1,  [_xmlParseData objectAtIndex: i]);
             NSDictionary *responseDict = [_xmlParseData objectAtIndex: i];
             NSLog(@"standard -> :   %@ ", [responseDict objectForKey:@"standard"]);
         }
     }
     */
    
}
// 시작 엘리먼트 - 속성은 여기서 빼내는듯.
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if ([elementName isEqualToString:@"currency"])
        _elementType = etItem;
    [_xmlValue setString:@""];
}

// 끝 엘리먼트
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    /*
     int i=1;
     NSLog(@"i : %d.elementName : %@",i, elementName);
     i++;
     //NSMutableArray *text = [NSMutableArray arrayWithCapacity:9];
     NSString *outItem = [NSString stringWithFormat:@""];
     outItem = [outItem stringByAppendingFormat:@"%@",elementName];
     outItem = [outItem stringByAppendingFormat:@"\n"];
     NSLog(@"parser : %@, outItem : %@",parser,outItem);
     */
    
    if (_elementType != etItem)
        return;
    if ([elementName isEqualToString:@"hname"]) {
        [_currectItem setValue:[NSString stringWithString:_xmlValue] forKey:elementName];
    } else if ([elementName isEqualToString:@"standard"]) {
        [_currectItem setValue:[NSString stringWithString:_xmlValue] forKey:elementName];
    } else if ([elementName isEqualToString:@"buy"]) {
        [_currectItem setValue:[NSString stringWithString:_xmlValue] forKey:elementName];
    } else if ([elementName isEqualToString:@"sell"]) {
        [_currectItem setValue:[NSString stringWithString:_xmlValue] forKey:elementName];
    } else if ([elementName isEqualToString:@"send"]) {
        [_currectItem setValue:[NSString stringWithString:_xmlValue] forKey:elementName];
    } else if ([elementName isEqualToString:@"receive"]) {
        [_currectItem setValue:[NSString stringWithString:_xmlValue] forKey:elementName];
    } else if ([elementName isEqualToString:@"sign"]) {
        [_currectItem setValue:[NSString stringWithString:_xmlValue] forKey:elementName];
    } else if ([elementName isEqualToString:@"change_val"]) {
        [_currectItem setValue:[NSString stringWithString:_xmlValue] forKey:elementName];
    } else if ([elementName isEqualToString:@"currency"]) {
        [_xmlParseData addObject:[NSDictionary dictionaryWithDictionary:_currectItem]];
        dataGetFlag = YES;
    }
}

// 중간의 실제 내용
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    //NSLog(@"foundCharacters : %@",string);
    if (_elementType == etItem) {
        [_xmlValue appendString:string];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////
 //세션인 몇개인지 선언
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
//테이블 뷰에 몇개의 셀정보가 들어갈지 선언
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    //_xmlParseData개숫만큼 셀을 선언 ex>33
    return [_xmlParseData count];
}
//각 테이블 셀에 들어갈 정보 선언
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
        //cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        //cell.detailTextLabel.text가 아래에 작게표시됨
        //cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:simpleTableIdentifier];
        //cell.detailTextLabel.text가 우측 정렬로 크지만 회색으로 표시
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:simpleTableIdentifier];
        //2개가 가우데 정렬로 서로 붙어나옴
        //cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:simpleTableIdentifier];
    }
    cell.detailTextLabel.text = [[_xmlParseData objectAtIndex:indexPath.row] objectForKey:@"standard"];
    cell.textLabel.text = [[_xmlParseData objectAtIndex:indexPath.row] objectForKey:@"hname"];
    return cell;
}

/*
 //섹션의 제목 지정
 - (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
 return [[_menuSectionItems objectForKey:@(section)] objectForKey:@"header"];
 
 }
 */
 //셀을 터치했을 때의 동작을 정의
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.view endEditing:YES];//키보드 감추기
    if(![_outputValue.text  isEqual: @""] && ![_inputKoreaMoney.text  isEqual: @""]){
        _outputValue.text = @"";
        _inputKoreaMoney.text = @"";
    }
    _seleteCountry.text = [[_xmlParseData objectAtIndex:indexPath.row] objectForKey:@"hname"];
    rateVelus = [[_xmlParseData objectAtIndex:indexPath.row] objectForKey:@"standard"];
}

/////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
	[textField setText:[self moneyFormat:newText]];
	return NO;
}
-(NSString*)moneyFormat:(NSString*)strNumber{
    
    //스트링을 INT로 변경
	strNumber = [strNumber stringByReplacingOccurrencesOfString:@"," withString:@""];
    int nTmp = [strNumber intValue];
    
    NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
    [fmt setNumberStyle:NSNumberFormatterDecimalStyle];
    
    //NSString 으로 저장
    NSString *formatedString = [fmt stringFromNumber:[NSNumber numberWithInt:nTmp]];
    
    return formatedString;
}
///////////////////////////////////////////////////////////////////////////////////
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)eventRemoveBut:(id)sender {
    _outputValue.text = @"";
    _inputKoreaMoney.text = @"";
}
- (IBAction)eventArithmeticBut:(id)sender {
    [self.view endEditing:YES];
    //어느쪽 텍스트필드에 인풋이 있는지 확인
    if([_seleteCountry.text isEqual: @"아래에서 나라 선택"]){
        UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"알림" message:@"환율 계산할 나라가 선택되어있지않습니다" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }else if([_inputKoreaMoney.text  isEqual: @""] && [_outputValue.text  isEqual: @""]){
        //값이 없다고 팝업을 뛰워주고싶다
        UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"알림" message:@"값이 없습니다" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }else if(![_outputValue.text  isEqual: @""] && ![_inputKoreaMoney.text  isEqual: @""]){
        //값을 지우라고 팝업을 뛰워주고싶다
        UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"알림" message:@"모든 입력란에 값이 있습니다. 계산을 원하시는 나라의 입력값을 지우십시요" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }else if (![_outputValue.text  isEqual: @""]){
        //레이트에 맞게 계산해서 빈 필드에 입력
        float countryMoney = [_outputValue.text floatValue];
        float value = countryMoney / [self rateFigure];
        _inputKoreaMoney.text = [NSString stringWithFormat:@"%.2f", value];

    }else if(![_inputKoreaMoney.text  isEqual: @""]){
        float koreaMoney = [_inputKoreaMoney.text floatValue];
        float value = koreaMoney * [self rateFigure];
        _outputValue.text = [NSString stringWithFormat:@"%.2f", value];
    }
}
-(float)rateFigure{
    float rate;
    if([_seleteCountry.text isEqual: @"일본"]){
        rate = [rateVelus floatValue] / 100.00 ;
    }else{
        rate = [rateVelus floatValue];
    }
    return rate;
}

@end
