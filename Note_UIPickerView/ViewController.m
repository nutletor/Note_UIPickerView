//
//  ViewController.m
//  Note_UIPickerView
//
//  Created by HuangFei on 16/1/9.
//  Copyright © 2016年 HuangFei. All rights reserved.
//

#import "ViewController.h"

#import "AreaModel.h"

@interface ViewController ()<UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIPickerView *areaPickerView;

@property (nonatomic, strong) NSMutableArray * provinceAry;
@property (nonatomic, strong) NSMutableArray * cityAry;
@property (nonatomic, assign) NSInteger provinceId;
@property (nonatomic, assign) NSInteger cityId;
@property (nonatomic, copy) NSString  * provinceStr;
@property (nonatomic, copy) NSString  * cityStr;

@property (nonatomic, assign) NSInteger provinceRow;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.areaPickerView.dataSource = self;
    self.areaPickerView.delegate = self;
    
    //将plist文件中的'省/市'信息分别解析为'省/市'数组
    NSString * filePath = [[NSBundle mainBundle] pathForResource:@"areas" ofType:@"plist"];
    NSArray * areaAry = [NSArray arrayWithContentsOfFile:filePath];
    self.provinceAry = [NSMutableArray array];
    self.cityAry = [NSMutableArray array];
    for (NSDictionary * provinceDic in areaAry) {
        AreaModel * province = [[AreaModel alloc] initWithDictionary:provinceDic];
        [self.provinceAry addObject:province];
        NSArray * citiesAry = [provinceDic objectForKey:@"children"];
        NSMutableArray * cityOfProAry = [NSMutableArray array];
        for (NSDictionary * cityDic in citiesAry) {
            AreaModel * city = [[AreaModel alloc] initWithDictionary:cityDic];
            [cityOfProAry addObject:city];
        }
        [self.cityAry addObject:cityOfProAry];
    }
    self.provinceId = 1;
    self.cityId = 61;
    self.provinceStr = @"北京市";
    self.cityStr = @"东城区";
    //我的实际项目中采取的策略是，将用户选择的'省/市'所匹配的id发送给服务器
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIPickerViewDataSource &Delegate
//设置组件个数
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

//设置组件行数
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (component) {
        case 0://省
        {
            return self.provinceAry.count;
        }
            break;
        case 1://市
        {
            //查找当前'省'对应的'市'的个数
            return [self.cityAry[self.provinceRow] count];
        }
            break;
        default:
            return 0;
            break;
    }
}

//<1>设置组件行视图（在任何组件滚动且即将显示之前未显示的行时便会调用该方法，类似tableview的重用机制）
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(nullable UIView *)view
{
    UILabel* pickerLabel = (UILabel*)view;
    if (!pickerLabel){
        pickerLabel = [[UILabel alloc] init];
        pickerLabel.textAlignment = NSTextAlignmentCenter;
        pickerLabel.font = [UIFont systemFontOfSize:20];
        pickerLabel.adjustsFontSizeToFitWidth = YES;//避免标题过长显示不全
    }
    
    pickerLabel.text = [self pickerView:pickerView titleForRow:row forComponent:component];
    return pickerLabel;
}

//<2>设置组件标题（如果同时实现了<1>的代理方法，便会优先调用<1>）
- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
//    NSLog(@"%ld %ld", [pickerView selectedRowInComponent:0], [pickerView selectedRowInComponent:1]);
    
    switch (component) {
        case 0://省
        {
            AreaModel * area = self.provinceAry[row];
            return area.name;
        }
            break;
        case 1://市
        {
            /*
            //selectedRowInComponent所返回的值会随着组件滚动实时变化，并非仅在组件停止滚动后才会发生变化
            NSInteger selectedRow = [pickerView selectedRowInComponent:0];
            AreaModel * area = self.cityAry[selectedRow][row];
            //以上代码，当同时滚动'省/市'组件时，会造成不同行内容错乱，甚至如果滚动中实时变化的'省'对应的'市'的数量大于当前滚动中'市'的数量，还会造成越位crash
            */
            
            //通过'省'组件停止滚动时保存的行数查找对应的'市'信息，便可避免越位crash
            AreaModel * area = self.cityAry[self.provinceRow][row];
            return area.name;
        }
            break;
        default:
            return @"";
            break;
    }
}

//组件停止滚动时调用
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    switch (component) {
        case 0://省
        {
            AreaModel * province = self.provinceAry[row];
            self.provinceId = province.idField;
            self.provinceStr = province.name;
            
            //在'省'组件停止滚动时保存行数
            self.provinceRow = [pickerView selectedRowInComponent:0];
            
            [pickerView reloadComponent:1];
            [pickerView selectRow:0 inComponent:1 animated:YES];
            AreaModel * city = self.cityAry[row][0];
            self.cityId = city.idField;
            self.cityStr = city.name;
        }
            break;
        case 1://市
        {
            AreaModel * city = self.cityAry[self.provinceRow][row];
            self.cityId = city.idField;
            self.cityStr = city.name;
        }
            break;
        default:
            break;
    }
}

@end
