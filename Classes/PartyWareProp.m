//
//  PartyWareProp.m
//  PartyWare
//
//  Created by Alexander Favaro on 8/12/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import "PartyWareProp.h"
#import "JXDictionaryWrapper.h"
#import "JXCategoryDummy.h"

@implementation PartyWareProp

- (id)initWithName:(NSString *)name {
	return [self initWithName:name
						state:[[[PartyWareState alloc] init] autorelease]
				  replicaName:[NSString stringWithFormat:@"%@%d", name, arc4random()]];
}

- (NSArray *)objectsWithType:(NSString *)type {
	@synchronized (self) {
		return [(PartyWareState *)[self _state] objectsWithType:type];
	}
}

- (NSString *)partyName {
	return ((PartyWareState *)[self _state]).partyName;
}

- (void)addImageWithUserID:(NSString *)userID url:(NSString *)url
				  thumbURL:(NSString *)thumbURL caption:(NSString *)caption time:(long)time {
	[self _addObj:[self _HTTPResourceObjWithType:@"image" userID:userID
											 url:url thumbURL:thumbURL
										 caption:caption time:time]];
}

- (void)addYouTubeVideoWithUserID:(NSString *)userID videoID:(NSString *)videoID url:(NSString *)url
						 thumbURL:(NSString *)thumbURL caption:(NSString *)caption time:(long)time {
	NSMutableDictionary *obj = [self _HTTPResourceObjWithType:@"youtube"
													   userID:userID
														  url:url
													 thumbURL:thumbURL
													  caption:caption time:time];
	[obj setObject:videoID forKey:@"videoId"];
	[obj setObject:[NSNumber numberWithInt:0] forKey:@"votes"];
	[self _addObj:obj];
}

- (void)upvoteVideoWithItemID:(NSString *)itemID {
	[self addOperation:[self _voteOpForItem:itemID count:1]];
}

- (void)downvoteVideoWithItemID:(NSString *)itemID {
	[self addOperation:[self _voteOpForItem:itemID count:-1]];
}

- (void)updateUserWithID:(NSString *)userID name:(NSString *)name
				   email:(NSString *)email imageURL:(NSString *)imageURL {
	[self _addObj:[self _userObjWithID:userID name:name email:email imageURL:imageURL]];
}

- (NSMutableDictionary *)_HTTPResourceObjWithType:(NSString *)type userID:(NSString *)userID
							 url:(NSString *)url thumbURL:(NSString *)thumbURL
						 caption:(NSString *)caption time:(long)time {
	NSArray *keys = [NSArray arrayWithObjects:@"id", @"type",
					 @"url", @"thumbUrl", @"time", @"caption", @"owner", nil];
	NSArray *values = [NSArray arrayWithObjects:[NSString stringWithUUID],
					   type, url, thumbURL, [NSNumber numberWithLong:time], caption,
					   userID, nil];
	return [NSMutableDictionary dictionaryWithObjects:values forKeys:keys];
}

- (NSDictionary *)_userObjWithID:(NSString *)userID name:(NSString *)name
						   email:(NSString *)email imageURL:(NSString *)imageURL {
	NSArray *keys = [NSArray arrayWithObjects:@"id", @"type", @"name",
					 @"email", nil];
	NSArray *values = [NSArray arrayWithObjects:userID, @"user", name,
					   email, nil];
	NSMutableDictionary *obj = [NSMutableDictionary dictionaryWithObjects:values forKeys:keys];
	if (imageURL) {
		[obj setObject:imageURL forKey:@"imageUrl"];
	}
	return obj;
}

- (NSDictionary *)_addObjOp:(NSDictionary *)item {
	return [NSDictionary dictionaryWithObjectsAndKeys:@"addObj", @"type", item, @"item", nil];
}

- (void)_addObj:(NSDictionary *)item {
	[self addOperation:[self _addObjOp:item]];
}

- (NSDictionary *)_voteOpForItem:(NSString *)itemID count:(int)count {
	NSArray *keys = [NSArray arrayWithObjects:@"type", @"itemId", @"count", nil];
	NSArray *values = [NSArray arrayWithObjects:@"vote", itemID, [NSNumber numberWithInt:count], nil];
	return [NSMutableDictionary dictionaryWithObjects:values forKeys:keys];
}

- (id<JXIPropState>)_reifyState:(NSDictionary *)dic {
	return [[[PartyWareState alloc] initWithDictionary:dic] autorelease];
}

@end

static NSComparator const TIME_DESC_COMPARATOR = ^(id img1, id img2) {
	long t1 = [[img1 objectForKey:@"time"] longValue];
	long t2 = [[img2 objectForKey:@"time"] longValue];
	
	if (t1 < t2)
		return NSOrderedDescending;
	else if (t1 > t2)
		return NSOrderedAscending;
	else 
		return NSOrderedSame;
};

static NSComparator const VOTES_DESC_COMPARATOR = ^(id vid1, id vid2) {
	int votes1 = [[vid1 objectForKey:@"votes"] intValue];
	int votes2 = [[vid2 objectForKey:@"votes"] intValue];
	
	if (votes1 < votes2)
		return NSOrderedDescending;
	else if (votes1 > votes2)
		return NSOrderedAscending;
	else { // sort by time ascending
		if (TIME_DESC_COMPARATOR(vid1, vid2) == NSOrderedDescending)
			return NSOrderedAscending;
		else if (TIME_DESC_COMPARATOR(vid1, vid2) == NSOrderedAscending)
			return NSOrderedDescending;
		else 
			return NSOrderedSame;
	}
};

static NSComparator const NAME_COMPARATOR = ^(id user1, id user2) {
	NSString *name1 = [user1 objectForKey:@"name"];
	NSString *name2 = [user2 objectForKey:@"name"];
	return [name1 compare:name2];
};

@implementation PartyWareState

@synthesize partyName;

- (id)initWithDictionary:(NSDictionary *)dic {
	if (self = [super init]) {
		objects = [[NSMutableDictionary allocWithZone:[self zone]] init];
		NSDictionary *otherObjects = [dic objectForKey:@"objects"];
		if (otherObjects) {
			for (NSString *key in otherObjects) {
				NSDictionary *obj = [otherObjects objectForKey:key];
				NSString *objID = [obj objectForKey:@"id"];
				[objects setObject:[(JXDictionaryWrapper *)[obj copy] autorelease]
							forKey:objID];
			}
		}
		partyName = [[dic objectForKey:@"name"] copy];
	}
	return self;
}

- (id)initWithState:(PartyWareState *)state {
	return [self initWithDictionary:[state toDictionary]];
}

- (id)init {
	return [self initWithState:nil];
}

- (void)dealloc {
	[objects release];
	[partyName release];
	[super dealloc];
}

- (id<JXIPropState>)applyOperation:(NSDictionary *)operation {
	NSString *type = [operation objectForKey:@"type"];
	if ([type isEqualToString:@"addObj"]) {
		NSDictionary *item = [operation objectForKey:@"item"];
		NSString *itemID = [item objectForKey:@"id"];
		[objects setObject:item forKey:itemID];
	} else if ([type isEqualToString:@"deleteObj"]) {
		NSString *objID = [operation objectForKey:@"itemId"];
		[objects removeObjectForKey:objID];
	} else if ([type isEqualToString:@"setName"]) {
		[partyName release];
		partyName = [[operation objectForKey:@"name"] retain];
	} else if ([type isEqualToString:@"vote"]) {
		NSString *itemID = [operation objectForKey:@"itemId"];
		int count = [[operation objectForKey:@"count"] intValue];
		NSMutableDictionary *obj = [objects objectForKey:itemID];
		if (obj) {
			int cur = [[obj objectForKey:@"votes"] intValue];
			[obj setObject:[NSNumber numberWithInt:cur + count] forKey:@"votes"];
		} else {
			NSLog(@"Couldn't find object for id: %@", itemID);
		}
	} else {
		NSLog(@"Unrecognized operation: %@", type);
	}
	return self;
}

- (NSDictionary *)toDictionary {
	NSDictionary *objectsCopy = [NSDictionary dictionaryWithDictionary:objects];
	return [NSDictionary dictionaryWithObjectsAndKeys:objectsCopy, @"objects",
			partyName, @"name", nil];
}

- (NSArray *)objectsWithType:(NSString *)type {
	NSMutableArray *objs = [NSMutableArray array];
	for (NSString *key in objects) {
		NSDictionary *obj = [objects objectForKey:key];
		NSString *objType = [obj objectForKey:@"type"];
		if ([objType isEqualToString:type]) {
			[objs addObject:obj];
		}
	}
	
	if ([type isEqualToString:@"image"]) {
		return [objs sortedArrayUsingComparator:TIME_DESC_COMPARATOR];
	} else if ([type isEqualToString:@"youtube"]) {
		return [objs sortedArrayUsingComparator:VOTES_DESC_COMPARATOR];
	} else if ([type isEqualToString:@"user"]) {
		return [objs sortedArrayUsingComparator:NAME_COMPARATOR];
	} else {
		NSLog(@"prop asked for unrecognized type: %@", type);
		return [NSArray array];
	}
}

- (id)copyWithZone:(NSZone *)zone {
	return [[PartyWareState allocWithZone:zone] initWithState:self];
}
	
@end