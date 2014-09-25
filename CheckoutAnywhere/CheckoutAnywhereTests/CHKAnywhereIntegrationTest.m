//
//  CHKAnywhereIntegrationTest.m
//  CheckoutAnywhere
//
//  Created by Joshua Tessier on 2014-09-19.
//  Copyright (c) 2014 Shopify Inc. All rights reserved.
//

@import UIKit;
@import XCTest;

//Data
#import "CHKDataProvider.h"
#import "MERDataProvider.h"

//Models
#import "CHKCart.h"
#import "MERProduct.h"
#import "MERProductVariant.h"
#import "CHKCheckout.h"
#import "CHKCreditCard.h"

@interface CHKAnywhereIntegrationTest : XCTestCase

@end

@implementation CHKAnywhereIntegrationTest {
	CHKDataProvider *_checkoutDataProvider;
	MERDataProvider *_storefrontDataProvider;
	
	MERShop *_shop;
	NSArray *_collections;
	NSArray *_products;
}

- (void)setUp
{
	[super setUp];
	
	_checkoutDataProvider = [[CHKDataProvider alloc] initWithShopDomain:@"dinobanana.myshopify.com"];
	_storefrontDataProvider = [[MERDataProvider alloc] initWithShopDomain:@"dinobanana.myshopify.com"];
}

#pragma mark - Helpers

- (void)fetchShop
{
	dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	[_storefrontDataProvider fetchShop:^(MERShop *shop, NSError *error) {
		XCTAssertNil(error);
		XCTAssertNotNil(shop);
		
		_shop = shop;
		dispatch_semaphore_signal(semaphore);
	}];
	dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

- (void)fetchCollections
{
	dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	[_storefrontDataProvider fetchCollections:^(NSArray *collections, NSError *error) {
		XCTAssertNil(error);
		XCTAssertNotNil(collections);
		
		_collections = collections;
		dispatch_semaphore_signal(semaphore);
	}];
	dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

- (void)fetchProducts
{
	dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	[_storefrontDataProvider fetchProducts:^(NSArray *products, NSError *error) {
		XCTAssertNil(error);
		XCTAssertNotNil(products);
		
		_products = products;
		dispatch_semaphore_signal(semaphore);
	}];
	dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

#pragma mark - Tests

- (CHKAddress *)testBillingAddress
{
	CHKAddress *address = [[CHKAddress alloc] init];
	address.address1 = @"150 Elgin Street";
	address.address2 = @"8th Floor";
	address.city = @"Ottawa";
	address.company = @"Shopify Inc.";
	address.firstName = @"Tobi";
	address.lastName = @"Lütke";
	address.phone = @"1-555-555-5555";
	address.countryCode = @"CA";
	address.provinceCode = @"ON";
	address.zip = @"K1N5T5";
	return address;
}

- (CHKAddress *)testShippingAddress
{
	CHKAddress *address = [[CHKAddress alloc] init];
	address.address1 = @"126 York Street";
	address.address2 = @"2nd Floor";
	address.city = @"Ottawa";
	address.company = @"Shopify Inc.";
	address.firstName = @"Tobi";
	address.lastName = @"Lütke";
	address.phone = @"1-555-555-5555";
	address.countryCode = @"CA";
	address.provinceCode = @"ON";
	address.zip = @"K1N5T5";
	return address;
}

- (void)testCheckoutAnywhereFlow
{
	[self fetchShop];
	[self fetchCollections];
	[self fetchProducts];
	
	//1) Create the base cart
	CHKCart *cart = [[CHKCart alloc] init];
	[cart addVariant:[_products[0] variants][0]];
	
	//2) Create the checkout with Shopify
	__block CHKCheckout *checkout;
	dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	[_checkoutDataProvider createCheckoutWithCart:cart completion:^(CHKCheckout *returnedCheckout, NSError *error) {
		XCTAssertNil(error);
		checkout = returnedCheckout;
		dispatch_semaphore_signal(semaphore);
	}];
	dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
	XCTAssertNotNil(checkout);
	
	//3) Add some information to it
	checkout.email = @"banana@testasaurus.com";
	checkout.shippingAddress = [self testShippingAddress];
	checkout.billingAddress = [self testBillingAddress];
	
	[_checkoutDataProvider updateCheckout:checkout completion:^(CHKCheckout *returnedCheckout, NSError *error) {
		XCTAssertNil(error);
		
		checkout = returnedCheckout;
		dispatch_semaphore_signal(semaphore);
	}];
	
	XCTAssertEqualObjects(checkout.shippingAddress.address1, @"126 York Street");
	XCTAssertEqualObjects(checkout.billingAddress.address1, @"150 Elgin Street");
	XCTAssertEqualObjects(checkout.email, @"banana@testasaurus.com");
	dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
	
	//4) Store a credit card on the secure server
	CHKCreditCard *creditCard = [[CHKCreditCard alloc] init];
	creditCard.number = @"4242424242424242";
	creditCard.expiryMonth = @"12";
	creditCard.expiryYear = @"20";
	creditCard.cvv = @"123";
	creditCard.nameOnCard = @"Dinosaur Banana";
	[_checkoutDataProvider storeCreditCard:creditCard checkout:checkout completion:^(CHKCheckout *returnedCheckout, NSString *paymentSessionId, NSError *error) {
		XCTAssertNil(error);
		XCTAssertNotNil(paymentSessionId);
		
		checkout = returnedCheckout;
		dispatch_semaphore_signal(semaphore);
	}];
	dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
	
	//5) Complete the checkout
	[_checkoutDataProvider completeCheckout:checkout block:^(CHKCheckout *returnedCheckout, NSError *error) {
		
		checkout = returnedCheckout;
		dispatch_semaphore_signal(semaphore);
	}];
	dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
	
	//6) Poll for job status
	[_checkoutDataProvider getCompletionStatusOfCheckout:checkout block:^(CHKCheckout *checkout, CHKStatus status, NSError *error) {
		
	}];
	
	//7) Fetch the checkout again
	
	//8) Fetch the order
}

@end