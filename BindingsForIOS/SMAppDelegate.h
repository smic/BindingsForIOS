//
//  SMAppDelegate.h
//  BindingsForIOS
//
//  Created by Stephan Michels on 17.07.12.
//  Copyright (c) 2012 Stephan Michels. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SMViewController;

@interface SMAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) SMViewController *viewController;

@end
