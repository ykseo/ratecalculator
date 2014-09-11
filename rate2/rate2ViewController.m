//
//  rate2ViewController.m
//  rate2
//
//  Created by YK on 2014. 8. 26..
//  Copyright (c) 2014년 yk. All rights reserved.
//

#import "rate2ViewController.h"
#import "TFHpple.h"

@interface rate2ViewController ()
@end
@implementation rate2ViewController
@synthesize webData;
NSString *rateVelus; //계산할 환율값
#define MAX_LENGTH 8 //텍스트 필드 입력 최대자릿수
float inputNumber; //입력된 값
int row;// 선택된 테이블 행
UIActivityIndicatorView *spinner;
UITableView *tableV;
bool flag = NO;

- (void)viewDidLoad{
    [super viewDidLoad];
    [self goToURL];
    
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = CGPointMake(160, 240);
    spinner.tag = 12;
    [self.view addSubview:spinner];
    [spinner startAnimating];
    
    _inputKoreaMoney.clearButtonMode = UITextFieldViewModeWhileEditing;
    _outputValue.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    [_cashOrRenittance addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    [_changeLable addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    
}
- (void)goToURL{
    NSURLRequest  *theRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://community.fxkeb.com/fxportal/jsp/RS/DEPLOY_EXRATE/fxrate_all.html"]];
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if( theConnection ){
        webData = [NSMutableData data];
    }
    else{
        NSLog(@"theConnection is NULL");
    }
}
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    [webData setLength: 0];
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [webData appendData:data];
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"ERROR with theConenction");
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSString *theHtml = [[NSString alloc] initWithData:webData encoding:0x80000003];
    theHtml = [theHtml stringByReplacingOccurrencesOfString:@"charset=euc-kr\"" withString:@"charset=UTF-8\""];
    NSData *htmlData = [theHtml dataUsingEncoding:NSUTF8StringEncoding];
    _xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData];
    _xmlParseData = [[NSMutableArray alloc] init];
    _currectItem = [[NSMutableDictionary alloc] init];
    if([self dataParsing]){
        [tableV reloadData];
    }
}
/////////////////////////////////////////////////////////////////////////////////////////////
-(void)loadingDataLable:(NSArray *)date{
    for(int i=0;i<[date count];i++){
        TFHppleElement *em = [date objectAtIndex:i];
        _lodingDate.text = [NSString stringWithFormat:@"외환은행 %@",[[[em children] objectAtIndex:0] content]];
    }
}
- (BOOL)dataParsing{
    NSArray *date = [_xpathParser searchWithXPathQuery:[NSString stringWithFormat:@"//table[2]//tr//td//b//font"]];
    [self loadingDataLable:date];
    for(int j =5; j < 27; j++){
        NSArray *arr = [_xpathParser searchWithXPathQuery:[NSString stringWithFormat:@"//table[3]//tr[%d]//td",j]];
        for (int i=0; i<[arr count]; i++) {
            _element = [arr objectAtIndex:i];
            _element = [[_element children] objectAtIndex:0];
            if(i == 0){
                //앞뒤 공백과 줄바꿈이있음 삭제해 주자
                NSString *eleCountry = [[_element content] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                //중간에    이 있음 공백으로 바꿔주자 ex>일 본   JPY(100)
                eleCountry = [eleCountry stringByReplacingOccurrencesOfString:@"   " withString:@" "];
                [_currectItem setValue:[NSString stringWithString:eleCountry] forKey:@"country"];
                //NSLog(@"eleCountry : %@",eleCountry);
            }else if(i == 1){
                [_currectItem setValue:[NSString stringWithString:[_element content]] forKey:@"sell"];
            }else if(i == 2){
                [_currectItem setValue:[NSString stringWithString:[_element content]] forKey:@"buy"];
            }else if(i == 3){
                [_currectItem setValue:[NSString stringWithString:[_element content]] forKey:@"send"];
            }else if(i == 4){
                [_currectItem setValue:[NSString stringWithString:[_element content]] forKey:@"receive"];
            }else if(i == 5){
                [_currectItem setValue:[NSString stringWithString:[_element content]] forKey:@"check"];
            }else if(i == 6){
                [_currectItem setValue:[NSString stringWithString:[_element content]] forKey:@"standard"];
            }else if(i == 7){
                [_xmlParseData addObject:[NSDictionary dictionaryWithDictionary:_currectItem]];
            }
        }
    }
    return true;
}
-(void)switchAction:(UISwitch *) changeValue{
    [self removeTextField];
    if(changeValue.tag == 0){
        if (changeValue.on) {
            _changeLable1.text = @"보내기";
            _changeLable2.text = @"받기";
            if(_changeLable.on){
                rateVelus = [[_xmlParseData objectAtIndex:row] objectForKey:@"receive"];
            }else{
            rateVelus = [[_xmlParseData objectAtIndex:row] objectForKey:@"send"];
            }
        }else{
            _changeLable1.text = @"팔기";
            _changeLable2.text = @"사기";
            if (_changeLable.on) {
                rateVelus = [[_xmlParseData objectAtIndex:row] objectForKey:@"buy"];
            }else{
                rateVelus = [[_xmlParseData objectAtIndex:row] objectForKey:@"sell"];
            }
        }
    }else{
        if (_changeLable.on) {
            if(_cashOrRenittance.on){
                rateVelus = [[_xmlParseData objectAtIndex:row] objectForKey:@"receive"];
                
            }else{
                rateVelus = [[_xmlParseData objectAtIndex:row] objectForKey:@"buy"];
            }
        }else{
            if (_cashOrRenittance.on) {
                rateVelus = [[_xmlParseData objectAtIndex:row] objectForKey:@"send"];
            }else{
                rateVelus = [[_xmlParseData objectAtIndex:row] objectForKey:@"sell"];
            }
        }
    
    }
}
////////////////////////////////////////////////////////////////////////////////////////////
 //세션인 몇개인지 선언
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    tableV = tableView;
    return 1;
}
//테이블 뷰에 몇개의 셀정보가 들어갈지 선언
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_xmlParseData count];
}
//각 테이블 셀에 들어갈 정보 선언
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:simpleTableIdentifier];
    }
    if(indexPath.row == 0){
        row = 0;
        if(_cashOrRenittance.on){
            if(_changeLable.on){
                rateVelus = [[_xmlParseData objectAtIndex:indexPath.row] objectForKey:@"receive"];
            }
            rateVelus = [[_xmlParseData objectAtIndex:indexPath.row] objectForKey:@"send"];
        }else{
            if(_changeLable.on){
                rateVelus = [[_xmlParseData objectAtIndex:indexPath.row] objectForKey:@"buy"];
            }
            rateVelus = [[_xmlParseData objectAtIndex:indexPath.row] objectForKey:@"sell"];
        }
        _seleteCountry.text = [[_xmlParseData objectAtIndex:indexPath.row] objectForKey:@"country"];
    }
    cell.detailTextLabel.text = [[_xmlParseData objectAtIndex:indexPath.row] objectForKey:@"standard"];
    cell.textLabel.text = [[_xmlParseData objectAtIndex:indexPath.row] objectForKey:@"country"];
    
    [spinner stopAnimating];
    return cell;
    
}
 //셀을 터치했을 때의 동작을 정의
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    row = indexPath.row;
    [self.view endEditing:YES];//키보드 감추기
    if(![_outputValue.text  isEqual: @""] && ![_inputKoreaMoney.text  isEqual: @""]){
        [self removeTextField];
    }
    if(_cashOrRenittance.on){
        if(_changeLable.on){
            rateVelus = [[_xmlParseData objectAtIndex:indexPath.row] objectForKey:@"receive"];
        }
        rateVelus = [[_xmlParseData objectAtIndex:indexPath.row] objectForKey:@"send"];
    }else{
        if(_changeLable.on){
            rateVelus = [[_xmlParseData objectAtIndex:indexPath.row] objectForKey:@"buy"];
        }
        rateVelus = [[_xmlParseData objectAtIndex:indexPath.row] objectForKey:@"sell"];
    }
    _seleteCountry.text = [[_xmlParseData objectAtIndex:indexPath.row] objectForKey:@"country"];
}
/////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
        NSString *number = [[textField.text stringByReplacingCharactersInRange:range withString:string] stringByReplacingOccurrencesOfString:@"," withString:@""];
    if([number isEqual: @""]){
        [self removeTextField];
    }else if([number length] <= MAX_LENGTH){
        if (!flag) {//no
            if([number rangeOfString:@"."].location != NSNotFound){
                flag = YES;
                if([[number substringFromIndex:([number length]-1)] isEqualToString:@"."]){//.이 끝에 있을때
                    [textField setText:number];
                }else {//점이 중간에 있을때
                    NSArray *arr = [number componentsSeparatedByString:@"."];
                    inputNumber = [arr[0] intValue];
                    [textField setText:[NSString stringWithFormat:@"%@.%@",[self moneyFormat:inputNumber],arr[1]]];
                }
            }else {//점없음
                inputNumber = [number floatValue];
                [textField setText:[self moneyFormat:inputNumber]];
            }
        }else {
            if([number rangeOfString:@"."].location != NSNotFound){//yes 이미 점이 있으니깐 2번째 점은 무시
                NSArray *arr = [number componentsSeparatedByString:@"."];
                inputNumber = [arr[0] intValue];
                [textField setText:[NSString stringWithFormat:@"%@.%@",[self moneyFormat:inputNumber],arr[1]]];
            }else{// no "." if flag is YES
                [textField setText:number];
                flag = NO;
            }
        }
        [self rateToCalcuation:textField];
    }
    return NO;
}
-(NSString*)moneyFormat:(float)strNumber{
    NSLog(@"strNumber : %f",strNumber);
    //숫자 폼맷현식 선언
    NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
    [fmt setNumberStyle:NSNumberFormatterDecimalStyle] ;
    //strNumber를 숫자로 만들어서 콤마가추가된 포맷으로 바꿔서 다시 스트링으로 리턴
    return [fmt stringFromNumber:[NSNumber numberWithFloat:strNumber]];
    //return [fmt stringFromNumber:[NSString stringWithFormat:@"%f",strNumber]];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.view endEditing:YES];
    return YES;
}
-(void)rateToCalcuation:(UITextField *)textField{
    if (textField == _outputValue){
        float value = inputNumber * [self rateFigure];
        _inputKoreaMoney.text = [NSString stringWithFormat:@"%.2f", value];
    }else if(textField == _inputKoreaMoney){
        float value = inputNumber / [self rateFigure];
        _outputValue.text = [NSString stringWithFormat:@"%.2f", value];
    }
}
-(BOOL)textFieldShouldClear:(UITextField *)textField {
    [self removeTextField];
    return YES;
}
-(void)removeTextField{
    _outputValue.text = @"";
    _inputKoreaMoney.text = @"";
}
-(float)rateFigure{
    float rate;
    if([_seleteCountry.text isEqual: @"일 본 JPY(100)"]){
        rate = [rateVelus floatValue] / 100.00 ;
    }else{
        rate = [rateVelus floatValue];
    }
    return rate;
}

///////////////////////////////////////////////////////////////////////////////////
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
