//
//  SenderContentViewController.m
//  TaoliWang
//
//  Created by Mac OS X on 14-2-10.
//  Copyright (c) 2014年 Custom. All rights reserved.
//

#import "SenderContentViewController.h"
#import "MySpaceModel.h"
#import "PublishMySpaceDataRequest.h"
#import <QuartzCore/QuartzCore.h>

@interface SenderContentViewController ()
@property (weak, nonatomic) IBOutlet UITextView         *ContentTextView;
@property (weak, nonatomic) IBOutlet UILabel            *NumberLable;
@property (weak, nonatomic) IBOutlet UIView             *BackView;
@property (weak, nonatomic) IBOutlet UIView             *MoveView;
@property (weak, nonatomic) IBOutlet UIButton           *ImageButton;
@property (strong, nonatomic) UIImage                   *SaveImage;
@property (assign, nonatomic) float                      level;

@end

@implementation SenderContentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
#pragma mark
-(void)starPublishDataRequest
{
    NSString *str = [_ContentTextView.text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    if ([[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0 || [_ContentTextView.text isEqualToString:@"请输入文本..."]) {
        _ContentTextView.text = @"请输入文本...";
        [UIAlertView popupAlertByDelegate:self andTag:1001 title:@"提示" message:@"请输入您要发布的内容"];
        return;
    }

    NSDictionary *param;
    if (self.SaveImage) {
        param = @{@"yhid": self.UserId,
                  @"wzbt": @"",
                  @"wzlr": str,
                  @"file": self.SaveImage,
                  @"tpgd": [NSString stringWithFormat:@"%.2f",self.level]};
    }else{
        param = @{@"yhid": self.UserId,
                  @"wzbt": @"",
                  @"wzlr": str,
                  @"file": @"",
                  @"tpgd": @"0"};
    }
    [PublishMySpaceDataRequest requestWithParameters:param withIndicatorView:self.view withCancelSubject:nil onRequestStart:^(ITTBaseDataRequest *request) {
        
        NSLog(@"开始");
    } onRequestFinished:^(ITTBaseDataRequest *request) {
        
        if ([[request.handleredResult[@"code"]stringValue] isEqualToString:@"1"]) {
            [UIAlertView popupAlertByDelegate:self andTag:1002 title:@"消息" message:request.handleredResult[@"msg"]];
        }
    } onRequestCanceled:^(ITTBaseDataRequest *request) {
        
        NSLog(@"取消");
    } onRequestFailed:^(ITTBaseDataRequest *request) {
        
        NSLog(@"失败");
    }];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
}
#pragma mark
#pragma mark LoadingUI
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}
-(void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([_ContentTextView.text isEqualToString:@"请输入文本..."]) {
        _ContentTextView.text = @"";
    }
}
-(void)textViewDidEndEditing:(UITextView *)textView
{
    if ([_ContentTextView.text length] == 0) {
        _ContentTextView.text = @"请输入文本...";
    }
}
-(void)textViewDidChange:(UITextView *)textView{
    _NumberLable.text = [NSString stringWithFormat:@"%d/140",[_ContentTextView.text length]];
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    if ([_ContentTextView.text length] >= 140 && range.length == 0){
        [_ContentTextView.text substringToIndex:140];
        return NO;
    }
    return YES;
}

#pragma mark
#pragma mark UIButtonAction
- (IBAction)SelectPhotoButtonClick:(id)sender {
    _BackView.hidden = NO;
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    [UIView animateWithDuration:0.5 animations:^{
        if (isIOS7) {
            _MoveView.frame = CGRectMake(0, Screen_height-118, 320, 118);
        }else{
            _MoveView.frame = CGRectMake(0, Screen_height-118-20, 320, 118);
        }
    } completion:^(BOOL finished) {
        
    }];

}
- (IBAction)ConfirmButtonClick:(id)sender {
    [self starPublishDataRequest];
}
- (IBAction)PopControllerButtonClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)TakePhotoButtonClick:(id)sender {
     [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc]init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:picker animated:YES completion:^{}];
        
        [UIView animateWithDuration:0.5 animations:^{
            _MoveView.frame = CGRectMake(0, Screen_height, 320, 118);
        } completion:^(BOOL finished) {
            _BackView.hidden = YES;
        }];

    }else{
        NSLog(@"Camera is not available.");
    }
}
- (IBAction)SelectInPhotoButtonClick:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc]init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        [self presentViewController:picker animated:YES completion:^{}];
        
        [UIView animateWithDuration:0.5 animations:^{
            _MoveView.frame = CGRectMake(0, Screen_height, 320, 118);
        } completion:^(BOOL finished) {
            _BackView.hidden = YES;
        }];

    }else{
        NSLog(@"livbrary is not available.");
    }
}
- (IBAction)CancelButtonClick:(id)sender {
    [UIView animateWithDuration:0.5 animations:^{
        _MoveView.frame = CGRectMake(0, Screen_height, 320, 118);
    } completion:^(BOOL finished) {
        _BackView.hidden = YES;
    }];
}
#pragma mark
#pragma mark UIImagePickControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //获取图片进行压缩
    self.SaveImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    self.level = self.SaveImage.size.height/self.SaveImage.size.width;
     [self dismissViewControllerAnimated:YES completion:^{}];
    int i = (int)self.SaveImage.size.width/220;
    CGFloat ImageHeight = self.SaveImage.size.height/i;
    NSLog(@"sss == %f",ImageHeight);
    CGSize size = CGSizeMake(220.0f, ImageHeight);
   self.SaveImage = [self imageWithImageSimple:self.SaveImage scaledToSize:size];
    
   
    [_ImageButton setBackgroundImage:self.SaveImage forState:UIControlStateNormal];
    [_ImageButton setBackgroundImage:self.SaveImage forState:UIControlStateHighlighted];
    _ImageButton.layer.masksToBounds = YES;
    _ImageButton.layer.cornerRadius = 5.0;
    _ImageButton.layer.borderWidth = 1.0;
    _ImageButton.layer.borderColor = [[UIColor whiteColor]CGColor];
    
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

#pragma mark
#pragma mark UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1002) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}




//#pragma mark
//#pragma mark UIAlertViewDelegate
//-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    if (alertView.tag == 1001) {
//    }
//}




//-(void)saveImageToDocument:(UIImage*)image imageName:(NSString *)imagename;
//{
//    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
//    NSString *filePath = [[paths objectAtIndex:0]stringByAppendingPathComponent:[NSString stringWithFormat:imagename,nil]];  // 保存文件的名称
//    [UIImageJPEGRepresentation(image, 0.005)writeToFile: filePath atomically:YES];
//}
//-(void)SaveInformation
//{
//    MySpaceModel *model = [[MySpaceModel alloc]init];
//    NSString *str = [self GetTime];
//    NSArray *arr = [str componentsSeparatedByString:@"-"];
//    model.Day = [arr objectAtIndex:1];
//    model.Mouth = [PhoneCode NumberChangeForChinese:[arr objectAtIndex:0]];
//    model.Content = _ContentTextView.text;
//}
//-(NSString *)GetTime
//{
//    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
//    [formatter setDateFormat:@"MM-dd"];
//    NSDate *date = [NSDate date];
//    NSString *str = [formatter stringFromDate:date];
//    return str;
//}
//#pragma mark
//#pragma mark ImageSaveDate
//-(NSString *)GetDate
//{
//    NSDate *date = [NSDate date];
//    NSString *timeStr = [NSString stringWithFormat:@"%ld",(long)[date timeIntervalSince1970]];
//    return timeStr;
//}
@end
