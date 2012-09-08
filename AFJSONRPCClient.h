//
//  AFJSONRPCClient.h
//  Japancar
//
//  Created by wiistriker@gmail.com on 27.03.12.
//  Copyright (c) 2012 JustCommunication. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperation.h"
#import "AFJSONRequestOperation.h"

@interface AFJSONRPCClient : NSObject {
@private
    NSURL *_endpointURL;
    NSOperationQueue *_operationQueue;
}

@property (nonatomic, retain) NSURL *endpointURL;
@property (nonatomic, retain) NSOperationQueue *operationQueue;

- (id)initWithURL:(NSURL *)url;

- (void)invokeMethod:(NSString *)method;
- (void)invokeMethod:(NSString *)method
      withParameters:(id)parameters;

- (void)invokeMethod:(NSString *)method
             success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void)invokeMethod:(NSString *)method
      withParameters:(id)parameters
             success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void)invokeMethod:(NSString *)method 
      withParameters:(id)parameters
       withRequestId:(NSString *)requestId
             success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void)invokeNotification:(NSString *)notification;
- (void)invokeNotification:(NSString *)notification withParameters:(id)parameters;
- (void)invokeNotification:(NSString *)notification
            withParameters:(id)parameters
                   success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
@end
