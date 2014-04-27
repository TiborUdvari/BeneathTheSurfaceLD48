//
//  UTWorldCollisionHandler.h
//  BeneathTheSurface
//
//  Created by Tibor Udvari on 26/04/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "cocos2d-ui.h"
#import "CCBuilderReader.h"

@class UTWorldCollisionHandler;

typedef enum : NSUInteger {
    UTWorldTypeInner,
    UTWorldTypeOuter
} UTWorldType;

@protocol UTWorldCollisionHandlerDelegate <NSObject>

- (void) worldGotHitHard : (UTWorldCollisionHandler *) sender;
- (void) heroHitSpyke : (UTWorldCollisionHandler *) sender;
- (void) heroEliminatedSpike : (UTWorldCollisionHandler *) sender;

@end


@interface UTWorldCollisionHandler : NSObject <CCPhysicsCollisionDelegate>

@property (weak, nonatomic) id<UTWorldCollisionHandlerDelegate> delegate;
@property UTWorldType worldType;

@end
