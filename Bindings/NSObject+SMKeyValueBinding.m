//
//  NSObject+SMKeyValueBinding.m
//  Bindings
//
//  Created by Stephan Michels on 16.01.12.
//  Copyright (c) 2012 Stephan Michels Softwareentwicklung und Beratung. All rights reserved.
//

#import "NSObject+SMKeyValueBinding.h"
#import "NSDictionary+SMKeyValueObserving.h"
#import "NSObject+SMAssociatedObjects.h"


NSString* const SMValueTransformerNameBindingOption = @"SMValueTransformerNameBindingOption";
NSString* const SMValueTransformerBindingOption     = @"SMValueTransformerBindingOption";
NSString* const SMAllowsNullArgumentBindingOption   = @"SMAllowsNullArgumentBindingOption";
NSString* const SMNullPlaceholderBindingOption      = @"SMNullPlaceholderBindingOption";
NSString* const SMBidirectionalBindingOption        = @"SMBidirectionalBindingOption";
NSString* const SMNoEqualCheckBindingOption         = @"SMNoEqualCheckBindingOption";
NSString* const SMFormatterBindingOption            = @"SMFormatterBindingOption";
NSString* const SMDebugBindingOption                = @"SMDebugBindingOption";


@interface SMKeyValueBindingInfo : NSObject {}

@property (nonatomic, copy) NSString *binding;
@property (nonatomic, copy) NSString *keyPath;
@property (nonatomic, copy) NSDictionary *options;
@property (nonatomic, weak) id controller;
@property (nonatomic, weak) id object;
@property (nonatomic, strong) NSValueTransformer *valueTransformer;
@property (nonatomic) BOOL allowsNullArgument;
@property (nonatomic, strong) id placeholder;
@property (nonatomic) BOOL bidirectional;
@property (nonatomic) BOOL noEqualCheck;
@property (nonatomic, strong) NSFormatter *formatter;
@property (nonatomic) BOOL debug;

- (id)initWithBinding:(NSString *)binding
           controller:(id)controller 
               object:(id)object 
          withKeyPath:(NSString *)keyPath 
              options:(NSDictionary *)options;

@end


@implementation SMKeyValueBindingInfo

@synthesize binding             = _binding;
@synthesize keyPath             = _keyPath;
@synthesize options             = _options;
@synthesize controller          = _controller;
@synthesize valueTransformer    = _valueTransformer;
@synthesize object              = _object;
@synthesize allowsNullArgument  = _allowsNullArgument;
@synthesize placeholder         = _placeholder;
@synthesize bidirectional       = _bidirectional;
@synthesize noEqualCheck		= _noEqualCheck;
@synthesize formatter			= _formatter;
@synthesize debug               = _debug;

static char SMKeyValueBindingContext;

- (id)initWithBinding:(NSString *)binding 
           controller:(id)controller 
               object:(id)object 
          withKeyPath:(NSString *)keyPath 
              options:(NSDictionary *)options {
	NSParameterAssert(binding);
	NSParameterAssert(controller);
	NSParameterAssert(object);
	NSParameterAssert(keyPath);
    
	self = [super init];
    if (self) {
		self.binding          = binding;
		self.controller       = controller;
		self.keyPath          = keyPath;
		self.options          = options;
        self.object           = object;
        
		// evaluate the binding options
		self.valueTransformer = [options objectForKey:SMValueTransformerBindingOption];
		if (!self.valueTransformer) {
            NSString* transformerName = [options objectForKey:SMValueTransformerNameBindingOption];
            self.valueTransformer = [NSValueTransformer valueTransformerForName:transformerName];
        }
        self.allowsNullArgument = YES;
		if ([options objectForKey:SMAllowsNullArgumentBindingOption]) {
            self.allowsNullArgument = [[options objectForKey:SMAllowsNullArgumentBindingOption] boolValue];
        }
        self.bidirectional = NO;
        if ([options objectForKey:SMBidirectionalBindingOption]) {
            self.bidirectional = [[options objectForKey:SMBidirectionalBindingOption] boolValue];
        }
		
		self.placeholder = [options objectForKey:SMNullPlaceholderBindingOption];
		
		self.noEqualCheck = NO;
		if ([options objectForKey:SMNoEqualCheckBindingOption]) {
            self.noEqualCheck = [[options objectForKey:SMNoEqualCheckBindingOption] boolValue];
        }
		
		if ([options objectForKey:SMFormatterBindingOption]) {
			NSParameterAssert([[options objectForKey:SMFormatterBindingOption] isKindOfClass:[NSFormatter class]]);
			NSAssert(!self.bidirectional, @"No bidirectional binding with formatter supported");
            self.formatter = [options objectForKey:SMFormatterBindingOption];
        }
        
        if ([options objectForKey:SMDebugBindingOption]) {
            self.debug = [[options objectForKey:SMDebugBindingOption] boolValue];
        }
        
		// add observers
        if (self.bidirectional) {
            [self.object addObserver:self 
                          forKeyPath:self.binding 
                             options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                             context:&SMKeyValueBindingContext];
        }
        [self.controller addObserver:self 
						  forKeyPath:self.keyPath
							 options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
							 context:&SMKeyValueBindingContext];
	}
	return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change 
                       context:(void *)context {
	
	if (context != &SMKeyValueBindingContext) {
		[super observeValueForKeyPath:keyPath 
							 ofObject:object 
							   change:change 
							  context:context];
		return;
	}
	
    NSParameterAssert(keyPath);
    NSParameterAssert(object == self.object || object == self.controller);
    
	if (!self.noEqualCheck && ![change keyValueChanged]) {
		return;
	}
	id value = [change keyValueChangeNew];
    if (value == [NSNull null]) {
        value = nil;
    }
    if (self.valueTransformer) {
        value = [self.valueTransformer transformedValue:value];
	}
	if (value == nil) {
		value = self.placeholder;
	}
	if (self.formatter) {
		value = [self.formatter stringForObjectValue:value];
	}
    
	if (value == nil && !self.allowsNullArgument) {
		return;
	}
    
    if (self.debug) {
        NSLog(@"Set value %@ for key path %@ on object %@", value, self.binding, self.object);
    }
    
    id target = self.object; 
    NSString *targetKeyPath = self.binding;
	
    if (self.bidirectional) {
        // Update the object that this is *not* a KVO for (to mirror the value)
        if (object == self.object) {
            
            target = self.controller;
            targetKeyPath = self.keyPath;
        }
        
        [target removeObserver:self forKeyPath:targetKeyPath];
        [target setValue:value forKeyPath:targetKeyPath];
        [target addObserver:self forKeyPath:targetKeyPath options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:(void *)self];
    } else {
        [target setValue:value forKeyPath:targetKeyPath];
    }
}

- (void)invalidate {
	if (self.bidirectional) {
        [self.object removeObserver:self forKeyPath:self.binding];
    }
	[self.controller removeObserver:self forKeyPath:self.keyPath];
	
	self.controller = nil;
	self.object = nil;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"BindingInfo {object=%@, binding=%@, controller=%@, keyPath=%@}", self.object, self.binding, self.controller, self.keyPath];
}

- (void)dealloc {
    [self invalidate];
	
	self.binding = nil;
	self.controller = nil;
	self.keyPath = nil;
	self.options = nil;
	self.valueTransformer = nil;
    self.object = nil;
	self.placeholder = nil;
	self.formatter = nil;
}

@end


@implementation NSObject (SMKeyValueBinding)

// global 0 initialization is fine here, no 
// need to change it since the value of the
// variable is not used, just the address
static char InfosKey;

- (NSMutableDictionary *)bindingInfosByBindingName {
    NSMutableDictionary *infos = [self associatedValueForKey:&InfosKey];
    if (!infos) {
        infos = [NSMutableDictionary dictionary];
		[self setAssociateValue:infos withKey:&InfosKey];
    }
	return infos;
}

- (void)removeBindingInfos {
	[self setAssociateValue:nil withKey:&InfosKey];
}

- (SMKeyValueBindingInfo *)infoForBinding:(NSString *)binding {
	NSParameterAssert(binding);
	
	NSMutableDictionary *infos = [self associatedValueForKey:&InfosKey];
	return [infos objectForKey:binding];
}

- (void)setInfo:(SMKeyValueBindingInfo *)info forBinding:(NSString *)binding {
	NSParameterAssert(binding);
	
    [[self bindingInfosByBindingName] setValue:info forKey:binding];
    if ([[self bindingInfosByBindingName] count] <= 0) {
        [self removeBindingInfos];
    }
}   

- (void)bind:(NSString *)binding 
    toObject:(id)controller
 withKeyPath:(NSString *)keyPath 
     options:(NSDictionary *)options {

	NSParameterAssert(binding);
	NSParameterAssert(controller);
	NSParameterAssert(keyPath);
	
	NSAssert1([self infoForBinding:binding] == nil, @"An binding %@ exists already", binding);
	
	SMKeyValueBindingInfo *info = [[SMKeyValueBindingInfo alloc] initWithBinding:binding 
																		controller:controller 
																			object:self 
																	   withKeyPath:keyPath
																		   options:options];
	[self setInfo:info forBinding:binding];
}

- (void)unbind:(NSString *)binding {

	NSParameterAssert(binding);
	
	NSAssert1([self infoForBinding:binding] != nil, @"No binding %@ exists", binding);
	
    [self setInfo:nil forBinding:binding];
}

@end
