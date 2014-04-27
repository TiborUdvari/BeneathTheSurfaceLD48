//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "MainScene.h"
#import "cocos2d.h"
#import "cocos2d-ui.h"
#import "CCBuilderReader.h"

@interface MainScene ()

@property (nonatomic) NSInteger points;

@end

@implementation MainScene
{
    CCPhysicsNode *_physics;
    CCPhysicsNode *_innerWorldPhysics;
    
    CCSprite *_innerWorld;
    
    CCSprite *_hero;
    CCSprite *_world;
    CCSprite *_insideHero;
    NSMutableArray *_joints;
    NSArray *_worldCollisionHandlers;
    CCNodeColor *_ground;
    
    CCNodeColor *_sun;
    CCNodeColor *_monster;
    
    NSMutableArray *_innerWorldSpikes;
    NSMutableArray *_outerWorldSpikes;

    CCLabelTTF *_pointsLabel;
    CCLabelTTF *_bestLabel;
    
    CCButton *_menuButton;
    CCButton *_restartButton;
}

// ---------------------------------------------------------------------
#pragma mark - Initialization
// ---------------------------------------------------------------------

- (void) didLoadFromCCB
{
    [self restoreBestScore];
    _bestLabel.visible = NO;
    _menuButton.visible = NO;
    _restartButton.visible = NO;
    
    _joints = [[NSMutableArray alloc] init];
    
    //_physics.debugDraw = YES;
    //_innerWorldPhysics.debugDraw = YES;
    
    _innerWorld.physicsBody.sensor = YES;
    
    // Collision masks
    _world.physicsBody.collisionType = @"world";
    _hero.physicsBody.collisionType = @"hero";
    _ground.physicsBody.collisionType = @"ground";
    _insideHero.physicsBody.collisionType = @"hero";
    _monster.physicsBody.collisionType = @"spyke";
    _sun.physicsBody.collisionType = @"spyke";
    
    _innerWorldSpikes = [[NSMutableArray alloc] init];
    _outerWorldSpikes = [[NSMutableArray alloc] init];
    
    
    [self setupWorldCollisionHandlers];
    [self rotateWorlds];
    
    self.userInteractionEnabled = YES;
    
    [self createSpikeInInnerWorld];
    [self createSpikeOnOuterWorld];
}

- (void) setupWorldCollisionHandlers
{
    UTWorldCollisionHandler *innerWorldHandler = [[UTWorldCollisionHandler alloc] init];
    innerWorldHandler.worldType = UTWorldTypeInner;
    _innerWorldPhysics.collisionDelegate = innerWorldHandler;
    innerWorldHandler.delegate = self;
    
    UTWorldCollisionHandler *outerWorldCollisionHandler = [[UTWorldCollisionHandler alloc] init];
    _physics.collisionDelegate = outerWorldCollisionHandler;
    outerWorldCollisionHandler.worldType = UTWorldTypeOuter;
    outerWorldCollisionHandler.delegate = self;
    
    _worldCollisionHandlers = @[innerWorldHandler, outerWorldCollisionHandler];
}

- (void) rotateWorlds
{
    // Rotate the outer world
    CCActionRotateBy *rotate = [CCActionRotateBy actionWithDuration:5.0f angle:-360];
    CCActionRepeatForever *repeatRotate = [CCActionRepeatForever actionWithAction:rotate];
    [_world runAction:repeatRotate];
    
    // Rotate inner world
    CCActionRotateBy *rotateInnerWorld = [CCActionRotateBy actionWithDuration:3.5f angle:360];
    CCActionRepeatForever *rotateInnerWorldForever = [CCActionRepeatForever actionWithAction:rotateInnerWorld];
    [_innerWorld runAction:rotateInnerWorldForever];
}

// ---------------------------------------------------------------------
#pragma mark - User interaction
// ---------------------------------------------------------------------

- (void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGFloat impulseStrenght = 200.0f;
    _hero.physicsBody.velocity = ccp(_hero.physicsBody.velocity.x, 0.0f);
    [_hero.physicsBody applyImpulse:ccp(0.0f, impulseStrenght * 0.75f)];
    
    _insideHero.physicsBody.velocity = ccp(0.0f, _insideHero.physicsBody.velocity.y);
    [_insideHero.physicsBody applyImpulse:ccp(impulseStrenght , 0.0f)];
    
    [[OALSimpleAudio sharedInstance] playEffect:@"resources/Jump2.wav"];
    
    CCActionCallBlock *block = [CCActionCallBlock actionWithBlock:^{
        [[OALSimpleAudio sharedInstance] playEffect:@"resources/Jump1.wav"];
    }];
    [self runAction:[CCActionSequence actionWithArray:@[[CCActionDelay actionWithDuration:0.1f], block]]];
}

// ---------------------------------------------------------------------
#pragma mark - Spike creation
// ---------------------------------------------------------------------

- (void) createSpikeOnOuterWorld
{
    CCSprite *spike = (CCSprite *)[CCBReader load:@"OuterSpike"];
    spike.physicsBody.collisionType = @"spyke";
    spike.scale = 0.5f;
    //spike.position = ccp(_world.position.x, _world.position.y + _world.contentSize.height / 2.0f * _world.scale + spike.contentSize.height / 2.0f * spike.scale);

    spike.position = ccp(_world.position.x - _world.contentSize.width/2.0f * _world.scale - spike.contentSize.height / 2.0f * spike.scale, _world.position.y);
    [_physics addChild:spike];
    [_outerWorldSpikes addObject:spike];
    
    spike.physicsBody.sensor = YES;
    
    CCPhysicsJoint *leftPinJoint = [CCPhysicsJoint connectedPivotJointWithBodyA:spike.physicsBody bodyB:_world.physicsBody anchorA:CGPointZero];
    [_joints addObject:leftPinJoint];
    
    CCPhysicsJoint *rightPinJoint = [CCPhysicsJoint connectedPivotJointWithBodyA:spike.physicsBody bodyB:_world.physicsBody anchorA:ccp(spike.contentSize.width, 0.0f )];
    [_joints addObject:rightPinJoint];
    
    [spike runAction:[CCActionSequence actionWithArray:@[[CCActionDelay actionWithDuration:2.0f],[CCActionCallBlock actionWithBlock:^{
        spike.physicsBody.sensor = NO;
    }]]]];
    self.points ++;
    [[OALSimpleAudio sharedInstance] playEffect:@"resources/mountainCreation.wav"];
}

- (void) createSpikeInInnerWorld
{
    CCSprite *spike = (CCSprite *)[CCBReader load:@"Obstacle"];
    spike.physicsBody.collisionType = @"spyke";

    spike.scaleX = 0.5f;
    spike.scaleY = -0.5f;
    
    spike.position = ccp(_world.position.x, _world.position.y + _world.contentSize.height / 2.0f * _world.scale + spike.contentSize.height / 2.0f * spike.scaleY -10.0f );
    [_innerWorldPhysics addChild:spike];
    [_innerWorldSpikes addObject:spike];
    
    spike.physicsBody.sensor = YES;
    
    CCPhysicsJoint *leftPinJoint = [CCPhysicsJoint connectedPivotJointWithBodyA:spike.physicsBody bodyB:_innerWorld.physicsBody anchorA:CGPointZero];
    [_joints addObject:leftPinJoint];
    
    CCPhysicsJoint *rightPinJoint = [CCPhysicsJoint connectedPivotJointWithBodyA:spike.physicsBody bodyB:_innerWorld.physicsBody anchorA:ccp(spike.contentSize.width, 0.0f)];
    [_joints addObject:rightPinJoint];
    
    [spike runAction:[CCActionSequence actionWithArray:@[[CCActionDelay actionWithDuration:2.0f],[CCActionCallBlock actionWithBlock:^{
        spike.physicsBody.sensor = NO;
    }]]]];
    self.points++;
    [[OALSimpleAudio sharedInstance] playEffect:@"resources/mountainCreation.wav"];
}

- (void) gameOver
{
    [self saveScore];
    _bestLabel.visible = YES;
    _menuButton.visible = YES;
    _restartButton.visible = YES;
    self.paused = YES;
}

// ---------------------------------------------------------------------
#pragma mark - Setters
// ---------------------------------------------------------------------

- (void) setPoints:(NSInteger)points
{
    _points = points;
    _pointsLabel.string = [NSString stringWithFormat:@"%ld", (long)_points];
}

// ---------------------------------------------------------------------
#pragma mark - Target Action
// ---------------------------------------------------------------------

- (void) menu
{
    [[CCDirector sharedDirector] replaceScene:[CCBReader loadAsScene:@"MenuScene"]];
}

- (void) restart
{
    [[CCDirector sharedDirector] replaceScene:[CCBReader loadAsScene:@"MainScene"]];
}

// ---------------------------------------------------------------------
#pragma mark - Best Score
// ---------------------------------------------------------------------

NSString * const  kBestScoreKey = @"bestScore";

- (void) saveScore
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger bestScore = [defaults integerForKey:kBestScoreKey];
    if (self.points > bestScore)
    {
        [defaults setInteger:self.points forKey:kBestScoreKey];
    }
}

- (void) restoreBestScore
{
    NSInteger bestScore = [[NSUserDefaults standardUserDefaults] integerForKey:kBestScoreKey];
    _bestLabel.string = [NSString stringWithFormat:@"Best: %ld", (long)bestScore];
}

// ---------------------------------------------------------------------
#pragma mark - World collision handler delegate methods
// ---------------------------------------------------------------------

- (void) heroEliminatedSpike : (UTWorldCollisionHandler *) sender
{
    // Already gets a point for creating a mountain
    self.points += 2;
    [[OALSimpleAudio sharedInstance] playEffect:@"resources/mountainDestruction.wav"];
}

- (void) heroHitSpyke : (UTWorldCollisionHandler *) sender
{
    [[OALSimpleAudio sharedInstance] playEffect:@"resources/hit.wav"];
    [self gameOver];
}

- (void) worldGotHitHard : (UTWorldCollisionHandler *) sender
{
    switch (sender.worldType) {
        case UTWorldTypeInner:
            [self createSpikeOnOuterWorld];
            break;
        case UTWorldTypeOuter:
            [self createSpikeInInnerWorld];
            break;
        default:
            break;
    }
}

@end
