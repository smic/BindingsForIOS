//
//  NSObject+SMAssociatedObjects.h
//  Bindings
//
//  Created by Stephan Michels on 16.01.12.
//  Copyright (c) 2012 Stephan Michels Softwareentwicklung und Beratung. All rights reserved.
//

#import <Foundation/Foundation.h>


// original source from https://github.com/andymatuschak/NSObject-AssociatedObjects

@interface NSObject (SMAssociatedObjects)

+ (void)setAssociateValue:(id)value withKey:(void *)key;
+ (id)associatedValueForKey:(void *)key;

- (void)setAssociateValue:(id)value withKey:(void *)key;
- (id)associatedValueForKey:(void *)key;

@end
