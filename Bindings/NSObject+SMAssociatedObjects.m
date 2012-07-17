//
//  NSObject+SMAssociatedObjects.m
//  Bindings
//
//  Created by Stephan Michels on 16.01.12.
//  Copyright (c) 2012 Stephan Michels Softwareentwicklung und Beratung. All rights reserved.
//

#import "NSObject+SMAssociatedObjects.h"
#import <objc/runtime.h>


@implementation NSObject (SMAssociatedObjects)

+ (void)setAssociateValue:(id)value withKey:(void *)key {
	objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_RETAIN);
}

+ (id)associatedValueForKey:(void *)key {
	return objc_getAssociatedObject(self, key);
}

- (void)setAssociateValue:(id)value withKey:(void *)key {
	objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_RETAIN);
}

- (id)associatedValueForKey:(void *)key {
	return objc_getAssociatedObject(self, key);
}

@end
