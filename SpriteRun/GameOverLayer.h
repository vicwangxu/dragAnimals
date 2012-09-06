//
//  GameOverLayer.h
//  SpriteRun
//
//  Created by xu wang on 8/31/12.
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface GameOverLayer : CCLayerColor
{
    CCLabelTTF *_label;
}
@property (nonatomic, retain) CCLabelTTF *label;
@end


@interface GameOverScene : CCScene {
    GameOverLayer *_layer;
}
@property (nonatomic, retain) GameOverLayer *layer;
@end


