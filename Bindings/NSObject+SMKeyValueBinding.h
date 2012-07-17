//
//  NSObject+SMKeyValueBinding.h
//  Bindings
//
//  Created by Stephan Michels on 16.01.12.
//  Copyright (c) 2012 Stephan Michels Softwareentwicklung und Beratung. All rights reserved.
//

#import <Foundation/Foundation.h>


// some original code from https://gist.github.com/570377
// and from http://ericmethot.com/code/cocoa/bidirectional-bindings/
// and from Frank Illenberger

extern NSString* const SMValueTransformerNameBindingOption;
extern NSString* const SMValueTransformerBindingOption;
extern NSString* const SMAllowsNullArgumentBindingOption;
extern NSString* const SMNullPlaceholderBindingOption;
extern NSString* const SMBidirectionalBindingOption;
extern NSString* const SMNoEqualCheckBindingOption;
extern NSString* const SMFormatterBindingOption;
extern NSString* const SMDebugBindingOption;

@class SMKeyValueBindingInfo;

@interface NSObject (SMKeyValueBinding)

- (SMKeyValueBindingInfo*)infoForBinding:(NSString *)binding;

- (void)bind:(NSString *)binding
    toObject:(id)controller
 withKeyPath:(NSString *)keyPath 
     options:(NSDictionary *)options;

- (void)unbind:(NSString *)binding;

@end
