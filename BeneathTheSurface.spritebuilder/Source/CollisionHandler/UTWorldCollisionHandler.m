//
//  UTWorldCollisionHandler.m
//  BeneathTheSurface
//
//  Created by Tibor Udvari on 26/04/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "UTWorldCollisionHandler.h"

@implementation UTWorldCollisionHandler

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair spyke:(CCNode *)spyke1 spyke:(CCNode *)spyke2
{
    [spyke1 removeFromParentAndCleanup:YES];
    [spyke2 removeFromParentAndCleanup:YES];
    
    [self.delegate heroEliminatedSpike:self];
    
    return TRUE;
}


- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair hero:(CCNode *)hero spyke:(CCNode *)spyke
{
    if (!spyke.physicsBody.sensor)
    {
        [self.delegate heroHitSpyke:self];
    }
    return TRUE;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair hero:(CCNode *)hero world:(CCNode *)world
{
    return TRUE;
}

-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair hero:(CCNode *)hero world:(CCNode *)world
{
    [self handleHeroTouchingForCollisionPair:pair];
}

-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair hero:(CCNode *)hero ground:(CCNode *)ground
{
    [self handleHeroTouchingForCollisionPair:pair];
}

- (void) handleHeroTouchingForCollisionPair : (CCPhysicsCollisionPair *)pair
{
    CGFloat kineticEnergy = [pair totalKineticEnergy];
        
    if (kineticEnergy > 5000.0f)
    {
        [self.delegate worldGotHitHard:self];
    }
}



@end
