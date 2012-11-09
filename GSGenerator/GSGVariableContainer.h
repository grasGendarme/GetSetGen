//
//  GSGVariableContainer.h
//  GSGenerator
//
//  Created by Louis on 3/11/12.
//  Copyright (c) 2012 grasGendarme. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 * Contains a variable, defined by a type, a name, and a comment
 */
@interface GSGVariableContainer : NSObject
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *comment;
@property (nonatomic, readonly) NSString *type;

- (GSGVariableContainer *)initWithName:(NSString *)name type:(NSString *)type comment:(NSString *)comment;


- (NSString *)makeFormalDeclaration;
- (NSString *)makeGetter;
- (NSString *)makeSetter;
//- (NSString *)description;

@end
