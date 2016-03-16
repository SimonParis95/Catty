/**
 *  Copyright (C) 2010-2016 The Catrobat Team
 *  (http://developer.catrobat.org/credits)
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Affero General Public License as
 *  published by the Free Software Foundation, either version 3 of the
 *  License, or (at your option) any later version.
 *
 *  An additional term exception under section 7 of the GNU Affero
 *  General Public License, version 3, is available at
 *  (http://developer.catrobat.org/license_additional_term)
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU Affero General Public License for more details.
 *
 *  You should have received a copy of the GNU Affero General Public License
 *  along with this program.  If not, see http://www.gnu.org/licenses/.
 */


#import "BrickCellLookData.h"
#import "iOSCombobox.h"
#import "BrickCell.h"
#import "Script.h"
#import "Look.h"
#import "Brick.h"
#import "BrickLookProtocol.h"
#import "LooksTableViewController.h"
#import "LanguageTranslationDefines.h"
#import "RuntimeImageCache.h"

@implementation BrickCellLookData

- (instancetype)initWithFrame:(CGRect)frame andBrickCell:(BrickCell*)brickCell andLineNumber:(NSInteger)line andParameterNumber:(NSInteger)parameter
{
    if(self = [super initWithFrame:frame]) {
        _brickCell = brickCell;
        _lineNumber = line;
        _parameterNumber = parameter;
        NSMutableArray *options = [[NSMutableArray alloc] init];
        NSMutableArray *images = [[NSMutableArray alloc] init];
        [options addObject:kLocalizedNewElement];
        int currentOptionIndex = 0;
        if (!brickCell.isInserting) {
            SpriteObject* object;
            int optionIndex = 1;
            if([brickCell.scriptOrBrick conformsToProtocol:@protocol(BrickLookProtocol)]) {
                Brick<BrickLookProtocol> *lookBrick = (Brick<BrickLookProtocol>*)brickCell.scriptOrBrick;
                object = lookBrick.script.object;
                Look *currentLook = [lookBrick lookForLineNumber:line andParameterNumber:parameter];
                for(Look *look in lookBrick.script.object.lookList) {
                    [options addObject:look.name];
                    if([look.name isEqualToString:currentLook.name]){
                        NSString *path = [NSString stringWithFormat:@"%@%@/%@", [lookBrick.script.object projectPath], kProgramImagesDirName, look.fileName];
                        RuntimeImageCache *imageCache = [RuntimeImageCache sharedImageCache];
                        UIImage *image = [imageCache cachedImageForPath:path];
                        if (!image) {
                            [imageCache loadImageFromDiskWithPath:path onCompletion:^(UIImage *image, NSString* path) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    UITableView* tV = (UITableView*)self.brickCell.superview;
                                    [tV reloadData];
                                });
                            }];
                        }
                        if (image) {
                            [images addObject:image];
                        }
                        currentOptionIndex = optionIndex;
                    }
                    optionIndex++;
                }
//                if (currentLook && ![options containsObject:currentLook.name]) {
//                    [options addObject:currentLook.name];
//                    currentOptionIndex = optionIndex;
//                    NSString *path = [NSString stringWithFormat:@"%@%@/%@", [lookBrick.script.object projectPath], kProgramImagesDirName, currentLook.fileName];
//                    RuntimeImageCache *imageCache = [RuntimeImageCache sharedImageCache];
//                    UIImage *image = [imageCache cachedImageForPath:path];
//                    if (!image) {
//                        [imageCache loadImageFromDiskWithPath:path onCompletion:^(UIImage *image) {
//                            dispatch_async(dispatch_get_main_queue(), ^{
//                                UITableView* tV = (UITableView*)self.brickCell.superview;
//                                [tV reloadData];
//                            });
//                        }];
//                    }
//                    
//                    if (image) {
//                        [images addObject:image];
//                    }
//                    
//                }
            }
            
//            [self setImages:images];
            self.object = object;
            if (images.count) {
                [self setCurrentImage:images[0]];
            } else {
                [self setCurrentImage:nil];
            }
        }
        [self setValues:options];
        [self setCurrentValue:options[currentOptionIndex]];
        [self setDelegate:(id<iOSComboboxDelegate>)self];
    }
    return self;
}

- (void)comboboxDonePressed:(iOSCombobox *)combobox withValue:(NSString *)value
{
    [self.brickCell.dataDelegate updateBrickCellData:self withValue:value];
}

- (void)comboboxOpened:(iOSCombobox *)combobox
{
    [self.brickCell.dataDelegate disableUserInteractionAndHighlight:self.brickCell withMarginBottom:kiOSComboboxTotalHeight];
}

# pragma mark - User interaction
- (BOOL)isUserInteractionEnabled
{
    return self.brickCell.scriptOrBrick.isAnimatedInsertBrick == NO;
}

@end
