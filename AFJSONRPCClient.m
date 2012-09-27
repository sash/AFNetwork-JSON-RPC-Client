//
//  AFJSONRPCClient.m
//  Japancar
//
//  Created by wiistriker@gmail.com on 27.03.12.
//  Copyright (c) 2012 JustCommunication. All rights reserved.
//

#import "AFJSONRPCClient.h"

NSString * const AFJSONRPCErrorDomain = @"org.json-rpc";

@implementation AFJSONRPCClient

@synthesize endpointURL = _endpointURL;
@synthesize operationQueue = _operationQueue;

- (id)initWithURL:(NSURL *)url
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.endpointURL = url;
    
    self.operationQueue = [[[NSOperationQueue alloc] init] autorelease];
	[self.operationQueue setMaxConcurrentOperationCount:4];
    
    return self;
}

#pragma mark - Method invocation

- (void)invokeMethod:(NSString *)method {
    [self invokeMethod:method withParameters:nil];
}

- (void)invokeMethod:(NSString *)method
      withParameters:(id)parameters {
    [self invokeMethod:method withParameters:parameters withRequestId:@"1" success:nil failure:nil];
}

- (void)invokeMethod:(NSString *)method
             success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [self invokeMethod:method withParameters:nil withRequestId:@"1" success:success failure:failure];
}

- (void)invokeMethod:(NSString *)method
      withParameters:(id)parameters
             success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [self invokeMethod:method withParameters:parameters withRequestId:@"1" success:success failure:failure];
}


- (void)invokeMethod:(NSString *)method
      withParameters:(id)parameters
       withRequestId:(NSString *)requestId
             success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSURLRequest *request = [self requestWithMethod:method parameters:parameters requestId:requestId];
    
    AFJSONRequestOperation *operation = [[[AFJSONRequestOperation alloc] initWithRequest:request] autorelease];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            id result = [responseObject objectForKey:@"result"];
            id error = [responseObject objectForKey:@"error"];
            
            if (result && result != [NSNull null]) {
                [self handleSuccess:success withOperation:operation result:result];
            } else if (error && error != [NSNull null]) {
                if (failure) {
                    NSInteger errorCode = 0;
                    NSString *errorMessage;
                
                    if ([error isKindOfClass:[NSDictionary class]] && [error objectForKey:@"code"] && [error objectForKey:@"message"]) {
                        errorCode = [[error objectForKey:@"code"] intValue];
                        errorMessage = [error objectForKey:@"message"];
                    } else {
                        errorMessage = @"Unknown error";
                    }
                    
                    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:errorMessage, NSLocalizedDescriptionKey, nil];
                    NSError *error = [NSError errorWithDomain:AFJSONRPCErrorDomain code:errorCode userInfo:userInfo];
                    
                    [self handleFailure:failure withOperation:operation error:error];
                }
            } else {
                if (failure) {
                    NSInteger errorCode = 0;
                    NSString *errorMessage = @"Unknown json-rpc response";
                    
                    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:errorMessage, NSLocalizedDescriptionKey, nil];
                    NSError *error = [NSError errorWithDomain:AFJSONRPCErrorDomain code:errorCode userInfo:userInfo];
                    
                    [self handleFailure:failure withOperation:operation error:error];
                }
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleFailure:failure withOperation:operation error:error];
    }];
    
    [self.operationQueue addOperation:operation];
}

#pragma mark - Notification invocation

- (void)invokeNotification:(NSString *)notification {
    [self invokeNotification:notification withParameters:nil];
}

- (void)invokeNotification:(NSString *)notification withParameters:(id)parameters {
    [self invokeNotification:notification withParameters:parameters success:nil failure:nil];
}

- (void)invokeNotification:(NSString *)notification
            withParameters:(id)parameters
                   success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSURLRequest *request = [self requestWithMethod:notification parameters:parameters requestId:nil];

    AFHTTPRequestOperation *operation = [[[AFHTTPRequestOperation alloc] initWithRequest:request] autorelease];

    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self handleSuccess:success withOperation:operation result:nil];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleFailure:failure withOperation:operation error:error];
    }];
    [self.operationQueue addOperation:operation];
}

#pragma mark -

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                parameters:(id)parameters
                                 requestId:(NSString *)requestId
{
    if (method == nil || [method length] == 0)
        [NSException raise:NSInvalidArgumentException format:@"Invalid method specified: %@", method];

	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] initWithURL:self.endpointURL] autorelease];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];

    NSMutableDictionary *JSONRPCStruct = [NSMutableDictionary dictionaryWithCapacity:4];
    [JSONRPCStruct setObject:@"2.0" forKey:@"jsonrpc"];
    [JSONRPCStruct setObject:method forKey:@"method"];

    if (parameters != nil)
        [JSONRPCStruct setObject:parameters forKey:@"params"];

    if (requestId != nil)
        [JSONRPCStruct setObject:requestId forKey:@"id"];

    NSError *error = nil;
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:JSONRPCStruct options:0 error:&error];
    if (!error) {
        [request setHTTPBody:JSONData];
    }
    
	return request;
}
- (void)handleSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success withOperation:(AFHTTPRequestOperation *)operation result:(id) result{
    if (success) {
        success(operation, result);
    }
}
- (void)handleFailure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure withOperation:(AFHTTPRequestOperation *) operation error:(NSError *)error{
    if (failure) {
        failure(operation, error);
    }
}

- (void)dealloc
{
    [_endpointURL release];
    [_operationQueue release];
    [super dealloc];
}

@end
