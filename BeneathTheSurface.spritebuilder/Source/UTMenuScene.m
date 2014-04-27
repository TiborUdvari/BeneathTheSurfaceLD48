//
//  UTMenuScene.m
//  BeneathTheSurface
//
//  Created by Tibor Udvari on 27/04/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "UTMenuScene.h"
#import "cocos2d.h"
#import "cocos2d-ui.h"
#import "CCBuilderReader.h"


@implementation UTMenuScene

- (void) play
{
    [[CCDirector sharedDirector] replaceScene:[CCBReader loadAsScene:@"MainScene"]];
}

@end
