// Copyright 2013 Care Zone Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "ExampleTests.h"
#import "CZDateFormatterCache.h"

@implementation ExampleTests

- (NSLocale *)unitedStatesLocale
{
  return [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
}

- (NSLocale *)russianLocale
{
  return [[NSLocale alloc] initWithLocaleIdentifier:@"ru_RU"];
}

- (NSLocale *)unitedKingdomLocale
{
  return [[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"];
}

- (NSDate *)january1st2013WithHour:(NSUInteger)hour minute:(NSUInteger)minute
{
  NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
  dateComponents.day = 1;
  dateComponents.month = 1;
  dateComponents.year = 2013;
  dateComponents.hour = hour;
  dateComponents.minute = minute;

  NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
  NSDate *date = [gregorian dateFromComponents:dateComponents];

  return date;
}

- (void)setUp
{
  [super setUp];
}

- (void)tearDown
{
  [super tearDown];
}

- (void)testCacheExists
{
  STAssertNotNil([CZDateFormatterCache mainThreadCache], @"Couldn't access cache");
}

- (void)testCacheForAllDateAndTimeStyles
{
  NSDate *date = [NSDate date];

  for (int dateStyle = kCFDateFormatterNoStyle; dateStyle <= kCFDateFormatterFullStyle; dateStyle++) {
    for (int timeStyle = kCFDateFormatterNoStyle; timeStyle <= kCFDateFormatterFullStyle; timeStyle++) {
      NSString *s = [[CZDateFormatterCache mainThreadCache] localizedStringFromDate:date dateStyle:dateStyle timeStyle:timeStyle];
      NSLog(@"%d %d has %@ %d", dateStyle, timeStyle, s, s.length);
      if (dateStyle == kCFDateFormatterNoStyle && timeStyle == kCFDateFormatterNoStyle)
        STAssertTrue(s.length == 0, @"String should be blank");
      else
        STAssertTrue(s.length > 0, @"String shouldn't be empty");
    }
  }
}

- (void)testCacheAccessFromDifferentDispatchQueue
{
  dispatch_queue_t alt_dispatch_queue = dispatch_queue_create("test dispatch queue", DISPATCH_QUEUE_SERIAL);

  dispatch_semaphore_t sem = dispatch_semaphore_create(0);

  dispatch_async(alt_dispatch_queue, ^{
    STAssertThrows([CZDateFormatterCache mainQueueCache], @"Should only allow access from the main dispatch queue");
    dispatch_semaphore_signal(sem);
  });

  dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
}

#pragma mark - localizedSimpleTimeStringForDate:

- (void)testSimpleTimeFormatterInEnglish
{
  [CZDateFormatterCache mainThreadCache].currentLocale = [self unitedStatesLocale];

  NSString *s;
  NSDate *date;

  date = [self january1st2013WithHour:01 minute:23];
  s = [[CZDateFormatterCache mainThreadCache] localizedSimpleTimeStringForDate:date];
  STAssertEqualObjects(s, @"1:23 AM", nil);

  date = [self january1st2013WithHour:01 minute:00];
  s = [[CZDateFormatterCache mainThreadCache] localizedSimpleTimeStringForDate:date];
  STAssertEqualObjects(s, @"1 AM", nil);

  date = [self january1st2013WithHour:12 minute:23];
  s = [[CZDateFormatterCache mainThreadCache] localizedSimpleTimeStringForDate:date];
  STAssertEqualObjects(s, @"12:23 PM", nil);

  date = [self january1st2013WithHour:12 minute:00];
  s = [[CZDateFormatterCache mainThreadCache] localizedSimpleTimeStringForDate:date];
  STAssertEqualObjects(s, @"Noon", nil);

  date = [self january1st2013WithHour:14 minute:23];
  s = [[CZDateFormatterCache mainThreadCache] localizedSimpleTimeStringForDate:date];
  STAssertEqualObjects(s, @"2:23 PM", nil);
}

- (void)testSimpleTimeFormatterInRussian
{
  [CZDateFormatterCache mainThreadCache].currentLocale = [self russianLocale];

  NSString *s;
  NSDate *date;

  date = [self january1st2013WithHour:01 minute:23];
  s = [[CZDateFormatterCache mainThreadCache] localizedSimpleTimeStringForDate:date];
  STAssertEqualObjects(s, @"1:23", nil);

  date = [self january1st2013WithHour:01 minute:00];
  s = [[CZDateFormatterCache mainThreadCache] localizedSimpleTimeStringForDate:date];
  STAssertEqualObjects(s, @"1:00", nil);

  date = [self january1st2013WithHour:12 minute:23];
  s = [[CZDateFormatterCache mainThreadCache] localizedSimpleTimeStringForDate:date];
  STAssertEqualObjects(s, @"12:23", nil);

  date = [self january1st2013WithHour:12 minute:00];
  s = [[CZDateFormatterCache mainThreadCache] localizedSimpleTimeStringForDate:date];
  STAssertEqualObjects(s, @"12:00", nil);

  date = [self january1st2013WithHour:14 minute:23];
  s = [[CZDateFormatterCache mainThreadCache] localizedSimpleTimeStringForDate:date];
  STAssertEqualObjects(s, @"14:23", nil);
}

- (void)testSimpleTimeFormatterInUnitedKingdom
{
  [CZDateFormatterCache mainThreadCache].currentLocale = [self unitedKingdomLocale];

  NSString *s;
  NSDate *date;

  date = [self january1st2013WithHour:01 minute:23];
  s = [[CZDateFormatterCache mainThreadCache] localizedSimpleTimeStringForDate:date];
  STAssertEqualObjects(s, @"01:23", nil);

  date = [self january1st2013WithHour:01 minute:00];
  s = [[CZDateFormatterCache mainThreadCache] localizedSimpleTimeStringForDate:date];
  STAssertEqualObjects(s, @"01:00", nil);

  date = [self january1st2013WithHour:12 minute:23];
  s = [[CZDateFormatterCache mainThreadCache] localizedSimpleTimeStringForDate:date];
  STAssertEqualObjects(s, @"12:23", nil);

  date = [self january1st2013WithHour:12 minute:00];
  s = [[CZDateFormatterCache mainThreadCache] localizedSimpleTimeStringForDate:date];
  STAssertEqualObjects(s, @"12:00", nil);

  date = [self january1st2013WithHour:14 minute:23];
  s = [[CZDateFormatterCache mainThreadCache] localizedSimpleTimeStringForDate:date];
  STAssertEqualObjects(s, @"14:23", nil);
}

#pragma mark - localizedCompactTimeStringForDate:

- (void)testCompactTimeFormatterInEnglish
{
  [CZDateFormatterCache mainThreadCache].currentLocale = [self unitedStatesLocale];

  NSString *s;
  NSDate *date;

  date = [self january1st2013WithHour:00 minute:00];
  s = [[CZDateFormatterCache mainThreadCache] localizedCompactTimeStringForDate:date];
  STAssertEqualObjects(s, @"12a", nil);

  date = [self january1st2013WithHour:03 minute:00];
  s = [[CZDateFormatterCache mainThreadCache] localizedCompactTimeStringForDate:date];
  STAssertEqualObjects(s, @"3a", nil);

  date = [self january1st2013WithHour:11 minute:30];
  s = [[CZDateFormatterCache mainThreadCache] localizedCompactTimeStringForDate:date];
  STAssertEqualObjects(s, @"11:30a", nil);

  date = [self january1st2013WithHour:12 minute:00];
  s = [[CZDateFormatterCache mainThreadCache] localizedCompactTimeStringForDate:date];
  STAssertEqualObjects(s, @"noon", nil);

  date = [self january1st2013WithHour:14 minute:00];
  s = [[CZDateFormatterCache mainThreadCache] localizedCompactTimeStringForDate:date];
  STAssertEqualObjects(s, @"2p", nil);

  date = [self january1st2013WithHour:15 minute:45];
  s = [[CZDateFormatterCache mainThreadCache] localizedCompactTimeStringForDate:date];
  STAssertEqualObjects(s, @"3:45p", nil);
}

- (void)testCompactTimeFormatterInRussian
{
  [CZDateFormatterCache mainThreadCache].currentLocale = [self russianLocale];

  NSString *s;
  NSDate *date;

  date = [self january1st2013WithHour:00 minute:00];
  s = [[CZDateFormatterCache mainThreadCache] localizedCompactTimeStringForDate:date];
  STAssertEqualObjects(s, @"0:00", nil);

  date = [self january1st2013WithHour:03 minute:00];
  s = [[CZDateFormatterCache mainThreadCache] localizedCompactTimeStringForDate:date];
  STAssertEqualObjects(s, @"3:00", nil);

  date = [self january1st2013WithHour:11 minute:30];
  s = [[CZDateFormatterCache mainThreadCache] localizedCompactTimeStringForDate:date];
  STAssertEqualObjects(s, @"11:30", nil);

  date = [self january1st2013WithHour:12 minute:00];
  s = [[CZDateFormatterCache mainThreadCache] localizedCompactTimeStringForDate:date];
  STAssertEqualObjects(s, @"12:00", nil);

  date = [self january1st2013WithHour:14 minute:00];
  s = [[CZDateFormatterCache mainThreadCache] localizedCompactTimeStringForDate:date];
  STAssertEqualObjects(s, @"14:00", nil);

  date = [self january1st2013WithHour:15 minute:45];
  s = [[CZDateFormatterCache mainThreadCache] localizedCompactTimeStringForDate:date];
  STAssertEqualObjects(s, @"15:45", nil);
}

- (void)testCompactTimeFormatterInUnitedKingdom
{
  [CZDateFormatterCache mainThreadCache].currentLocale = [self unitedKingdomLocale];

  NSString *s;
  NSDate *date;

  date = [self january1st2013WithHour:00 minute:00];
  s = [[CZDateFormatterCache mainThreadCache] localizedCompactTimeStringForDate:date];
  STAssertEqualObjects(s, @"00:00", nil);

  date = [self january1st2013WithHour:03 minute:00];
  s = [[CZDateFormatterCache mainThreadCache] localizedCompactTimeStringForDate:date];
  STAssertEqualObjects(s, @"03:00", nil);

  date = [self january1st2013WithHour:11 minute:30];
  s = [[CZDateFormatterCache mainThreadCache] localizedCompactTimeStringForDate:date];
  STAssertEqualObjects(s, @"11:30", nil);

  date = [self january1st2013WithHour:12 minute:00];
  s = [[CZDateFormatterCache mainThreadCache] localizedCompactTimeStringForDate:date];
  STAssertEqualObjects(s, @"12:00", nil);

  date = [self january1st2013WithHour:14 minute:00];
  s = [[CZDateFormatterCache mainThreadCache] localizedCompactTimeStringForDate:date];
  STAssertEqualObjects(s, @"14:00", nil);

  date = [self january1st2013WithHour:15 minute:45];
  s = [[CZDateFormatterCache mainThreadCache] localizedCompactTimeStringForDate:date];
  STAssertEqualObjects(s, @"15:45", nil);
}

@end
