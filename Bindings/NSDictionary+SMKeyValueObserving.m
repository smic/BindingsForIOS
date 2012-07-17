//
//  NSDictionary+SMKeyValueObserving.m
//  Bindings
//
//  Created by Stephan Michels on 16.01.12.
//  Copyright (c) 2012 Stephan Michels Softwareentwicklung und Beratung. All rights reserved.
//

#import "NSDictionary+SMKeyValueObserving.h"


@implementation NSDictionary (SMKeyValueObserving)

- (NSUInteger)keyValueChangeKind  {
	return [[self objectForKey:NSKeyValueChangeKindKey] unsignedIntegerValue];
}

- (id)keyValueChangeNew {
	return [self objectForKey:NSKeyValueChangeNewKey];
}

- (id)keyValueChangeOld {
	return [self objectForKey:NSKeyValueChangeOldKey];
}

- (NSIndexSet *)keyValueChangeIndexes {
	return [self objectForKey:NSKeyValueChangeIndexesKey];
}

- (BOOL)keyValueChanged {
    if ([self keyValueChangeOld] == nil) {
        return [self keyValueChangeNew] != nil;
    }
    return ![[self keyValueChangeNew] isEqual:[self keyValueChangeOld]];
}

@end
