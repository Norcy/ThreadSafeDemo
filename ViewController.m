//
//  ViewController.m
//  LaunchTest
//
//  Created by Norcy on 2017/2/28.
//  Copyright © 2017年 Norcy. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, copy) NSArray *array;
@property (nonatomic, strong) NSMutableArray *mutableArray;
@property (nonatomic, strong) NSLock *lock;
@property (nonatomic, strong) dispatch_queue_t dispatch_queue;
@end

@implementation ViewController

- (void)viewDidLoad
{
	[super viewDidLoad];

	self.lock = [[NSLock alloc] init];

	self.dispatch_queue = dispatch_queue_create("NorcyQueue", DISPATCH_QUEUE_CONCURRENT);

	self.mutableArray = [NSMutableArray array];

	[self simulateMultiThreadEnv];
}

// 模拟多线程环境
- (void)simulateMultiThreadEnv
{
	for (int i = 0; i < 1000; ++i)
	{
	        // 只打开 if 和 else 的第一行的注释，模拟 NSArray 不加锁时的读写冲突
        	// 只打开 if 和 else 的第二行的注释，模拟 NSArray 加NSLock时的读写冲突
	        // 只打开 if 和 else 的第三行的注释，模拟 NSArray 加GCD锁时的读写冲突
       		// 只打开 if 和 else 的第四行的注释，模拟 NSMutableArray 不加锁时的读写冲突
	        // 只打开 if 和 else 的第五行的注释，模拟 NSMutableArray 加NSLock时的读写冲突
	        // 只打开 if 和 else 的第六行的注释，模拟 NSMutableArray 加GCD锁时的读写冲突
		if (arc4random() % 4) // 写的频率大于读的频率
		{
			dispatch_async(dispatch_queue_create("NorcyLock", DISPATCH_QUEUE_CONCURRENT), ^{
			    [self writeDirectlyForNSArray]; //crash
			    //[self writeUseLockForNSArray];         //ok, but not best, had better use atomic
			    //[self writeUseGCDForNSArray];          //ok, but not best, had better use atomic

			    //[self writeDirectlyForNSMutableArray]; //crash
			    //[self writeUseLockForNSMutableArray];  //ok
			    //[self writeUseGCDForNSMutableArray];   //ok
			});
		}
		else
		{
			dispatch_async(dispatch_queue_create("NorcyLock", DISPATCH_QUEUE_CONCURRENT), ^{
			    [self readDirectlyForNSArray]; //crash
			    //[self readUseLockForNSArray];         //ok, but not best, had better use atomic
			    //[self readUseGCDForNSArray];          //ok, but not best, had better use atomic

			    //[self readDirectlyForNSMutableArray]; //crash
			    //[self readUseLockForNSMutableArray];  //ok
			    //[self writeUseGCDForNSMutableArray];  //ok
			});
		}
	}
}

#pragma mark - Immutable Array
- (void)writeDirectlyForNSArray
{
	self.array = @[ @(1), @(2), @(3) ];
}

- (void)readDirectlyForNSArray
{
	self.array; // do nothing
}

- (void)writeUseLockForNSArray
{
	[self.lock lock];
	self.array = @[ @(1), @(2), @(3) ];
	[self.lock unlock];
}

- (void)readUseLockForNSArray
{
	[self.lock lock];
	[self readDirectlyForNSArray];
	[self.lock unlock];
}

- (void)writeUseGCDForNSArray
{
	dispatch_barrier_async(_dispatch_queue, ^{
	    self.array = @[ @(1), @(2), @(3) ];
	});
}

- (void)readUseGCDForNSArray
{
	dispatch_sync(_dispatch_queue, ^{
	    [self readDirectlyForNSArray];
	});
}

#pragma mark - Mutable Array
- (void)writeDirectlyForNSMutableArray
{
	[self.mutableArray addObject:@(1)];
}

- (void)readDirectlyForNSMutableArray
{
	for (id obj in self.mutableArray)
	{
        // do nothing
	}
}

- (void)writeUseLockForNSMutableArray
{
	[self.lock lock];
	[self.mutableArray addObject:@(1)];
	[self.lock unlock];
}

- (void)readUseLockForNSMutableArray
{
	[self.lock lock];
	[self readDirectlyForNSMutableArray];
	[self.lock unlock];
}

- (void)writeUseGCDForNSMutableArray
{
	dispatch_barrier_async(_dispatch_queue, ^{
	    [self.mutableArray addObject:@(1)];
	});
}

- (void)readUseGCDForNSMutableArray
{
	dispatch_sync(_dispatch_queue, ^{
	    [self readDirectlyForNSMutableArray];
	});
}

@end
