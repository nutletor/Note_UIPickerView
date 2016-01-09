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
    
    //将plist文件中的省市信息分别解析为省、市数组
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
    //我的实际项目中采取的策略是，将用户选择的省市所匹配的id发送给服务器
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
//{
//    
//}

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
        case 0:
        {
            return self.provinceAry.count;
        }
            break;
        case 1:
        {
            //查找当前省对应的市的个数
            return [self.cityAry[self.provinceRow] count];
        }
            break;
        default:
            return 0;
            break;
    }
}

//设置组件标题（在任何组件滚动且即将显示之前未显示的行时便会调用该方法，类似tableview的重用机制）
- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSLog(@"%ld %ld", [pickerView selectedRowInComponent:0], [pickerView selectedRowInComponent:1]);
    
    switch (component) {
        case 0:
        {
            AreaModel * area = self.provinceAry[row];
            return area.name;
        }
            break;
        case 1:
        {
            //selectedRowInComponent所返回的值会随着组件滚动实时变化，并非仅在组件停止滚动后才会发生变化
            NSInteger selectedRow = [pickerView selectedRowInComponent:0];
//            AreaModel * area = self.cityAry[selectedRow][row];
            //以上代码，当同时滚动省市组件时，会造成不同行内容错乱，甚至如果滚动中实时变化的省对应的市的数量大于当前滚动中市的数量，还会造成越位crash
            
            //通过省组件停止滚动时保存的行数查找对应的市信息，便可避免越位crash
            if (row >= [self.cityAry[self.provinceRow] count]) {
                return @"";
            }
//            NSInteger count = [self.cityAry[self.provinceRow] count];
//            NSInteger index = row < count ? row : count;
            AreaModel * area = self.cityAry[self.provinceRow][row];
            return area.name;
        }
            break;
        default:
            return @"";
            break;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    switch (component) {
        case 0:
        {
            AreaModel * province = self.provinceAry[row];
            self.provinceId = province.idField;
            self.provinceStr = province.name;
            
//            NSLog(@"%@", pickerView.subviews);
//            for (UIGestureRecognizer * gesture in pickerView.gestureRecognizers) {
//                [pickerView removeGestureRecognizer:gesture];
////                gesture.cancelsTouchesInView = YES;
//            }
            
            [pickerView reloadComponent:1];
            [pickerView selectRow:0 inComponent:1 animated:YES];
            AreaModel * city = self.cityAry[row][0];
            self.cityId = city.idField;
            self.cityStr = city.name;
            
            //在省组件停止滚动时保存行数
            self.provinceRow = [pickerView selectedRowInComponent:0];
        }
            break;
        case 1:
        {
            NSInteger selectedRow = [pickerView selectedRowInComponent:0];
//            AreaModel * city = self.cityAry[selectedRow][row];
            //以上代码，同样可能造成越位crash
            
            if (row >= [self.cityAry[self.provinceRow] count]) {
                return;
            }
//            NSInteger count = [self.cityAry[self.provinceRow] count];
//            NSInteger index = row < count ? row : count;
            AreaModel * city = self.cityAry[self.provinceRow][row];
            self.cityId = city.idField;
            self.cityStr = city.name;
        }
            break;
        default:
            break;
    }
}

//- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(nullable UIView *)view

@end
