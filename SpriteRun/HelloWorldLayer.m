//
//  HelloWorldLayer.m
//  SpriteRun
//
//  Created by xu wang on 8/30/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"
#import "CCTouchDispatcher.h"
#import "IntroLayer.h"
#import "GameOverLayer.h"

#pragma mark - HelloWorldLayer

int animalCount = 0;


// HelloWorldLayer implementation
@implementation HelloWorldLayer
{
    CGPoint init_position;
    CCSprite* _zoo;
    CCSprite* selSprite;
    NSMutableArray *_movableSprite;
    CCLabelTTF *animalNameLabel;
    NSMutableArray *animalName;
    int randomAnimalIndex;
    
    NSMutableArray *displayedName;
}

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super initWithColor:ccc4(255, 255, 255, 255)]) ) {
        _zoo = [CCSprite spriteWithFile:@"zoo.png"];
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        self.isTouchEnabled = YES;
        _zoo.position = ccp(winSize.width * 0.75, winSize.height * 0.5);
        [self addChild:_zoo];
        
        
        //initialize the animals in the zoo
        _movableSprite = [[NSMutableArray alloc] init];
        NSArray *animals = [NSArray arrayWithObjects:@"cat.png",@"dog.png",@"turtle.png"
                            ,@"bird.png",@"seeker.png",nil];
        animalName = [NSMutableArray arrayWithObjects:@"cat",@"dog",@"turtle",
                      @"bird",@"seeker", nil];
        
        displayedName = [[NSMutableArray alloc] init];
        
        
        int i = 0;
       
        for(NSString *animalImage in animals){
            CCSprite  *sprite = [CCSprite spriteWithFile:animalImage] ;
            sprite.tag = i;
            [_movableSprite addObject:sprite];
            float offsetFraction = (float)(i + 1) / (animals.count + 1);
            sprite.position = ccp(winSize.width / 2 * offsetFraction, winSize.height/2);
            i++;
            [self addChild:sprite];
        }
        
        //display the animal name
        animalNameLabel = [CCLabelTTF labelWithString:@" " fontName:@"Arial" fontSize:30];
        animalNameLabel.position = ccp(winSize.width * 0.25, winSize.height * 0.25);
        [animalNameLabel setColor:ccBLACK];
        
        //set the animalCount
        animalCount = animalName.count;
       
        //randomly select an animal
        randomAnimalIndex = arc4random() % animalName.count;
        [animalNameLabel setString:[animalName objectAtIndex:randomAnimalIndex]];
        [self addChild:animalNameLabel];
    }
	return self;
}

/*-(void) nextAnimal
{
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    [displayedName addObject:[NSNumber numberWithInt:randomAnimalIndex]];
    [self removeChild:animalNameLabel cleanup:YES];
    animalNameLabel = nil;
    
    animalNameLabel = [CCLabelTTF labelWithString:[animalName objectAtIndex:randomAnimalIndex] fontName:@"Arial" fontSize:30];
    animalNameLabel.position = ccp(winSize.width * 0.25, winSize.height * 0.25);
    [self addChild:animalNameLabel];
}*/

//register touchDispatcher
-(void) registerWithTouchDispatcher
{
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    init_position = touchLocation;
    [self selectSpriteForTouch:touchLocation];
    return YES;
}

-(void) selectSpriteForTouch:(CGPoint) touchLocation
{
    CCSprite *newSprite = nil;
    for(CCSprite *sprite in _movableSprite){
        if(CGRectContainsPoint(sprite.boundingBox, touchLocation)){
            newSprite = sprite;
            break;
        }
    }
    if(newSprite != selSprite){
        selSprite = newSprite;
        [selSprite stopAllActions];
        [selSprite runAction:[CCRotateTo actionWithDuration:0.1 angle:0]];
        CCRotateTo * rotLeft = [CCRotateBy actionWithDuration:0.1 angle:-4.0];
        CCRotateTo * rotCenter = [CCRotateBy actionWithDuration:0.1 angle:0.0];
        CCRotateTo * rotRight = [CCRotateBy actionWithDuration:0.1 angle:4.0];
        CCSequence * rotSeq = [CCSequence actions:rotLeft, rotCenter, rotRight, rotCenter, nil];
        [newSprite runAction:[CCRepeatForever actionWithAction:rotSeq]];
    }
}

-(void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    
    CGPoint oldLocation = [touch previousLocationInView:touch.view];
    oldLocation = [[CCDirector sharedDirector] convertToGL:oldLocation];
    oldLocation = [self convertToNodeSpace:oldLocation];
    
    
    CGPoint translation = ccpSub(touchLocation, oldLocation);
    [self panForTranslation: translation];
}

-(void) panForTranslation:(CGPoint) translation
{
    CGPoint newPosition = ccpAdd(selSprite.position, translation);
    selSprite.position = newPosition;
}

-(void) gameOverBegine
{
    GameOverScene *gameOverScene = [GameOverScene node];
    [gameOverScene.layer.label setString:@"You Are Right"];
    [[CCDirector sharedDirector] replaceScene:gameOverScene];
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    
    if(CGRectContainsPoint(_zoo.boundingBox, selSprite.position) &&
       (randomAnimalIndex == selSprite.tag)){
        
        [selSprite stopAllActions];
        [selSprite runAction:[CCMoveTo actionWithDuration:0.5
                                                 position:selSprite.position]];
        
        //make the animal fixed
        [_movableSprite removeObject:selSprite];
        [self runAction:[CCSequence actions:
                         [CCDelayTime actionWithDuration:0.5],
                         [CCCallFunc actionWithTarget:self selector:@selector(gameOverBegine)],
                         nil]];
        
        //[[CCDirector sharedDirector] replaceScene:[HelloWorldLayer scene]];
        
       // [[CCDirector sharedDirector] replaceScene:[IntroLayer scene]];
        //display the next animalName
       /* while (TRUE) {
            randomAnimalIndex = 2;//arc4random() % animalName.count;
            for(NSNumber *number in displayedName){
                if (randomAnimalIndex != number.intValue) {
                    break;
                }
            }
            break;
        }
        [self nextAnimal];
        */
    }else{
        
        [selSprite stopAllActions];
        selSprite.position = ccp(winSize.width/2 * (float)(selSprite.tag + 1)/ (animalCount + 1) , winSize.height/2);
        [selSprite runAction:[CCMoveTo actionWithDuration:0.5 position:selSprite.position]];
    }
    
}
// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
   //  [animalName release];
   //  animalName = nil;
    [super dealloc];
}

#pragma mark GameKit delegate

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}
@end
