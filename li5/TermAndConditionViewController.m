//
//  TermAndConditionViewController.m
//  li5
//
//  Created by gustavo hansen on 11/16/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//

#import "TermAndConditionViewController.h"
@import MBProgressHUD;

@interface TermAndConditionViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation TermAndConditionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.topItem.title = @"";
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    
    NSURL *url = [NSURL URLWithString:[[NSBundle mainBundle].infoDictionary
                                       objectForKey:@"Li5TOSUrl"]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    
    [[urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if(data){
            
            [self.webView loadData:data MIMEType:@"text/html" textEncodingName:@"UTF-8" baseURL:url];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
        });
        
    }] resume];
    
    [self.webView loadRequest:request];
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationItem.title = [NSLocalizedString(@"Terms & Privacy Policy",nil) uppercaseString];
    self.navigationController.navigationBar.backItem.title = @"";
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
