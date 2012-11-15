//
//  GSGVariableContainer.m
//  GSGenerator
//
//  Created by Louis on 3/11/12.
//  Copyright (c) 2012 grasGendarme. All rights reserved.
//

#import "GSGVariableContainer.h"

@interface GSGVariableContainer()
@property (nonatomic, readonly) NSString *internalName;

@end

@implementation GSGVariableContainer


- (NSString *)internalName {
    return [NSString stringWithFormat:@"m_%@", self.name];
}

- (GSGVariableContainer *)initWithName:(NSString *)name type:(NSString *)type comment:(NSString *)comment {
    self = [super init];
    _name = name;
    _type = type;
    _comment = comment;
    
    return self;
}

- (NSString *)makeFormalDeclaration {
    NSMutableString *returnValue = [NSMutableString stringWithFormat:@"private %@ %@;", self.type, self.internalName];
    if(self.comment.length > 0) {
        [returnValue appendFormat:@"\t\t//%@", self.comment];
    }
    [returnValue appendString:@"\n"];
    return [returnValue copy];
}

- (NSString *)makeGetter {
    NSMutableString *getter;
    // if the type is boolean, we want the getter to look like "isName" instead of "getName"
    if ([self.type isEqualToString:@"boolean"]) {
        getter = [NSMutableString stringWithFormat:@"public %@ is%@() {\n", self.type, [GSGVariableContainer capitalizeFirstLetter:self.name]];
    } else {
    getter = [NSMutableString stringWithFormat:@"public %@ get%@() {\n", self.type, [GSGVariableContainer capitalizeFirstLetter:self.name]];
    }
    [getter appendFormat:@"\treturn %@;\n}\n", self.internalName];
    
    return [getter copy];
}

- (NSString *)makeSetter {
    NSMutableString *setter = [NSMutableString stringWithFormat:@"public void set%@(%@ %@) {\n", [GSGVariableContainer capitalizeFirstLetter:self.name], self.type, self.name];

    [setter appendFormat:@"\t%@ = %@;\n}\n", self.internalName, self.name];
    
    return [setter copy];

}

- (NSString *)makeConstructorElement {
    return [NSString stringWithFormat:@"\tthis.%@ = %@;\n", self.internalName, self.name];
}

+ (NSString *)buildConstructorFromArrayOfGSGVariables:(NSArray *)array {
    NSMutableString *output = [NSMutableString string];
    //build constructor signature
    [output appendString:@"\npublic Constructor("];
    
    for (int i = 1; i < array.count; i++) {
        GSGVariableContainer *currentVariable = [array objectAtIndex:i];
        if(i < array.count - 1) {
            [output appendFormat:@"%@ %@, ", currentVariable.type, currentVariable.name];
        } else {
            [output appendFormat:@"%@ %@", currentVariable.type, currentVariable.name];
        }
    }
    [output appendString:@") {\n"];
    
    // build the constructor body:
    for (GSGVariableContainer *currentVariable in array) {
        [output appendString:[currentVariable makeConstructorElement]];
    }
    [output appendString:@"}\n"];
    return [output copy];
}

// utility method
+ (NSString *)capitalizeFirstLetter:(NSString *)string {
    if(string.length > 1) {
        return [string stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[string substringToIndex:1] capitalizedString]];
    } else {
        return string;
    }
}

@end
