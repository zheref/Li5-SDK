//
//  UserSettingsViewController.h
//  li5
//
//  Created by Martin Cocaro on 5/22/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserSettingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *settingsTableView;

@end

@interface SettingViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *title;

@end