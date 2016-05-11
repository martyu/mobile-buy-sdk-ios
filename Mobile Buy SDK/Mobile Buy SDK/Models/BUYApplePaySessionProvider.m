//
//  BUYApplePaySessionProvider.m
//  Mobile Buy SDK
//
//  Created by Shopify.
//  Copyright (c) 2015 Shopify Inc. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#if __has_include(<PassKit/PassKit.h>)
#import <PassKit/PassKit.h>
#endif

#import "BUYApplePaySessionProvider.h"

@implementation BUYApplePaySessionProvider

#pragma mark - Init -

- (instancetype)initWithPaymentToken:(PKPaymentToken *)paymentToken
{
	self = [super init];
	if (self) {
		_paymentToken = paymentToken;
	}
	return self;
}

- (NSString *)paymentTokenString {
	return [[NSString alloc] initWithData:self.paymentToken.paymentData encoding:NSUTF8StringEncoding];
}

#pragma mark - BUYPaymentSessionProvider -

- (BOOL)hasPaymentSessionID
{
	return self.paymentToken.paymentData.length > 0;
}

- (NSDictionary *)jsonRepresentation
{
	return @{
			 @"payment_token" : @{
					 @"type"         : @"apple_pay",
					 @"payment_data" : [self paymentTokenString],
					 },
			 };
}

@end
