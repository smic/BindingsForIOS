//
//  SMViewController.m
//  BindingsForIOS
//
//  Created by Stephan Michels on 17.07.12.
//  Copyright (c) 2012 Stephan Michels. All rights reserved.
//

#import "SMViewController.h"
#import "NSObject+SMKeyValueBinding.h"


@interface SMViewController ()

@property (weak, nonatomic) IBOutlet UILabel *operand1Label;
@property (weak, nonatomic) IBOutlet UILabel *operand2Label;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;

@property (nonatomic) NSInteger operand1;
@property (nonatomic) NSInteger operand2;
@property (nonatomic) NSInteger operation;
@property (nonatomic, readonly) NSInteger result;

@end

@implementation SMViewController

#pragma mark - Properties

@synthesize operand1Label = _operand1Label;
@synthesize operand2Label = _operand2Label;
@synthesize resultLabel = _resultLabel;

@synthesize operand1 = _operand1;
@synthesize operand2 = _operand2;
@synthesize operation = _operation;

- (NSInteger)result {
    switch (self.operation) {
        case 0:
            return self.operand1 + self.operand2;
        case 1:
            return self.operand1 - self.operand2;
            
        default:
            return 0;
    }
}

+ (NSSet *)keyPathsForValuesAffectingResult {
    return [NSSet setWithObjects:@"operand1", @"operand2", @"operation", nil];
}

#pragma mark - Lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    
    // establish bindings
    [self.operand1Label bind:@"text"
                     toObject:self
                  withKeyPath:@"operand1"
                      options:[NSDictionary dictionaryWithObjectsAndKeys:formatter, SMFormatterBindingOption, nil]];
    [self.operand2Label bind:@"text"
                    toObject:self
                 withKeyPath:@"operand2"
                     options:[NSDictionary dictionaryWithObjectsAndKeys:formatter, SMFormatterBindingOption, nil]];
    [self.resultLabel bind:@"text"
                  toObject:self
               withKeyPath:@"result"
                   options:[NSDictionary dictionaryWithObjectsAndKeys:formatter, SMFormatterBindingOption, nil]];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // remove bindings
    [self.operand1Label unbind:@"value"];
    [self.operand2Label unbind:@"value"];
    [self.resultLabel unbind:@"value"];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

#pragma mark - Actions

- (IBAction)operand1ValueChanged:(UISlider *)sender {
    self.operand1 = [sender value];
}

- (IBAction)operand2ValueChanged:(UISlider *)sender {
    self.operand2 = [sender value];
}

- (IBAction)operationValueChanged:(UISegmentedControl *)sender {
    self.operation = [sender selectedSegmentIndex];
}

@end
