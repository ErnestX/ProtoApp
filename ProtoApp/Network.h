//
//  Network.h
//  ProtoApp
//
//  Created by Jialiang Xiang on 2015-05-05.
//  Copyright (c) 2015 ElementsLab. All rights reserved.
//
#ifndef ProtoApp_Network_h
#define ProtoApp_Network_h

#import <UIKit/UIKit.h>
#import "ColorsEnumType.h"

/*
 indicate that the player is ready to go
 */
- (void) readyToStartGame;

/*
 returns false if the player is not the captain
 */
- (BOOL) sendColorPickenByCaptain: (Colors)c;

/*
 returns false if not in the defending team
 */
- (BOOL) sendPlayerScore: (NSInteger)s;

#endif
