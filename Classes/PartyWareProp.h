//
//  PartyWareProp.h
//  PartyWare
//
//  Created by Alexander Favaro on 8/12/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JXProp.h"
#import "JXIPropState.h"

@interface PartyWareProp : JXProp {

}

- (id)initWithName:(NSString *)name;

- (NSArray *)objectsWithType:(NSString *)type;
- (NSString *)partyName;

- (void)addImageWithUserID:(NSString *)userID url:(NSString *)url
				  thumbURL:(NSString *)thumbURL caption:(NSString *)caption time:(long)time;
- (void)addYouTubeVideoWithUserID:(NSString *)userID videoID:(NSString *)videoID url:(NSString *)url
						 thumbURL:(NSString *)thumbURL caption:(NSString *)caption time:(long)time;

- (void)upvoteVideoWithItemID:(NSString *)itemID;
- (void)downvoteVideoWithItemID:(NSString *)itemID;

- (void)updateUserWithID:(NSString *)userID name:(NSString *)name
				   email:(NSString *)email imageURL:(NSString *)imageURL;

//protected
- (NSMutableDictionary *)_HTTPResourceObjWithType:(NSString *)type userID:(NSString *)userID
									   url:(NSString *)url thumbURL:(NSString *)thumbURL
								   caption:(NSString *)caption time:(long)time;
- (NSDictionary *)_userObjWithID:(NSString *)userID name:(NSString *)name
								  email:(NSString *)email imageURL:(NSString *)imageURL;

- (NSDictionary *)_addObjOp:(NSDictionary *)item;
- (void)_addObj:(NSDictionary *)item;

- (NSDictionary *)_voteOpForItem:(NSString *)itemID count:(int)count;

@end

@interface PartyWareState : NSObject <JXIPropState> {
	NSMutableDictionary *objects;
	NSString *partyName;
}

@property (nonatomic, readonly) NSString *partyName;

- (id)initWithState:(PartyWareState *)state;
- (id)initWithDictionary:(NSDictionary *)dic;

- (NSArray *)objectsWithType:(NSString *)type;

@end