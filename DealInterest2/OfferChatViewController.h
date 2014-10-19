//
//  CommentViewController.h
//  chatting
//
//  Created by xiaoming on 19/7/14.
//  Copyright (c) 2014 xiaoming. All rights reserved.
//

#import "JSQMessagesViewController.h"
#import "JSQMessages.h"

@interface OfferChatViewController : JSQMessagesViewController

@property (strong, nonatomic) NSMutableArray *messages;
@property (copy, nonatomic) NSDictionary *avatars;

@property (strong, nonatomic) UIImageView *outgoingBubbleImageView;
@property (strong, nonatomic) UIImageView *incomingBubbleImageView;

@property NSString *itemID;
@property NSString * chatroomID;
@property NSString * role;

- (void)receiveMessagePressed;

@end
