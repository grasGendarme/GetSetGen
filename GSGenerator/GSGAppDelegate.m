//
//  GSGAppDelegate.m
//  GSGenerator
//
//  Created by Louis on 3/11/12.
//  Copyright (c) 2012 grasGendarme. All rights reserved.
//

#import "GSGAppDelegate.h"

#import "GSGVariableContainer.h"
#import "GSGConstant.h"


@interface GSGAppDelegate () <NSTextViewDelegate>
@property (unsafe_unretained) IBOutlet NSTextView *inputBox;
@property (unsafe_unretained) IBOutlet NSTextView *outputBox;
@property (unsafe_unretained) IBOutlet NSButton *generateButton;

@property (nonatomic, strong) NSMutableSet *usedTypes;

@end

@implementation GSGAppDelegate

- (NSMutableSet *)usedTypes {
    if (!_usedTypes) {
        _usedTypes = [NSMutableSet setWithCapacity:30];
    }
    return _usedTypes;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // show example
    // todo : define it as nsstring const (in another file)
    self.inputBox.string = CCExpectedOutput;
    
    [self.inputBox setDelegate:self];
    [self.outputBox setEditable:NO];
}

- (IBAction)generateCodeButtonPressed:(NSButton *)sender {
    [self makeButtonGenerate:NO];
    [self.outputBox setString:[self convertInput:self.inputBox.string]];
}

- (void)textDidChange:(NSNotification *)notification {
    [self makeButtonGenerate:YES];
}

// will conver the main button from one function to the other (generate and copy to clipboard)
- (void)makeButtonGenerate:(BOOL)generate {
    if(generate) {
        self.generateButton.title = CCGenerate;
        self.generateButton.action = @selector(generateCodeButtonPressed:);
        [self.generateButton setEnabled:YES];
    } else {
        self.generateButton.title = CCCopyClipBoard ;
        self.generateButton.action = @selector(copyResultToClipBoard);
        [self.generateButton setEnabled:YES];
    }
    self.window.viewsNeedDisplay = YES;
}

- (void)copyResultToClipBoard {
    // writing self.outputbox.string to the pasteboard
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    [pasteboard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:nil];
    if([pasteboard setString:self.outputBox.string forType:NSStringPboardType]) {
        // TODO post a notification that the copy worked (via notification center?)
    }
    [self.generateButton setEnabled:NO];
}

// this is basically a parser calling GSGVariableContainer's createGetSet for each line
- (NSString *)convertInput:(NSString *)input {
    // trimming tabs
    input = [input stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\t"]];
    
    // Separate each lines in a NSMutableArray entry
    NSArray *variablesToGenerate = [input componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    NSMutableArray *generatedVariables = [NSMutableArray array];
    
    for (NSString *currentString in variablesToGenerate) {
        
        if(currentString.length > 1) {
            
            NSArray *oneSplittedLine = [currentString componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if (oneSplittedLine.count >= 2) {
                NSString *type = [oneSplittedLine objectAtIndex:0];
                NSString *name = [oneSplittedLine objectAtIndex:1];
                NSString *comment = @"";
                
                // add type to the type storage
                if ([self.usedTypes containsObject:type]) {
                    [self.usedTypes addObject:type];
                }
                
                //if we have a comment on the line
                if (oneSplittedLine.count >= 3 && [[oneSplittedLine objectAtIndex:2] rangeOfString:@"//"].location != NSNotFound) {
                    
                    // horrible bad cheating: we get the currentline and trim the beginning
                    comment = [currentString substringFromIndex:(type.length + name.length + 4)];
                }
                
                GSGVariableContainer *currentVariable = [[GSGVariableContainer alloc] initWithName:name type:type comment:comment];
                [generatedVariables addObject:currentVariable];
            }
        }
    }
    
    // create the actual output message
    NSString *output = @"";
    
    // formal declaration:
    for (GSGVariableContainer *currentVariableToPrint in generatedVariables) {
        output = [output stringByAppendingString:[currentVariableToPrint makeFormalDeclaration]];
    }
    output = [output stringByAppendingString:@"\n\n"];
    
    // getters and setters:
    for (GSGVariableContainer *currentVariableToPrint in generatedVariables) {
        output = [output stringByAppendingString:[currentVariableToPrint makeGetter]];
        output = [output stringByAppendingString:[currentVariableToPrint makeSetter]];
    }
    
    return output;
}


- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
    return YES;
}

@end
