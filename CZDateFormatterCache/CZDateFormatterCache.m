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

#import "CZDateFormatterCache.h"

@implementation CZDateFormatterCache
{
  NSDateFormatter *_dateFormatters[5][5];
}

#pragma mark - Class methods

+ (CZDateFormatterCache *)mainQueueCache
{
  static dispatch_once_t onceToken;
  static CZDateFormatterCache *instance = nil;

  NSAssert(dispatch_get_current_queue() == dispatch_get_main_queue(), @"Must access on the main dispatch queue");

  dispatch_once(&onceToken, ^{
    instance = [[CZDateFormatterCache alloc] init];
  });

  return instance;
}

#pragma mark - Lifecycle

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [self releaseDateFormatters];
}

- (id)init
{
  self = [super init];

  if (self) {
    [self allocDateFormatters];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localeDidChangeNotification:) name:NSCurrentLocaleDidChangeNotification object:nil];
  }

  return self;
}

#pragma mark - Methods

- (void)allocDateFormatters
{
  NSAssert(kCFDateFormatterNoStyle == 0, @"CFDateFormatterStyle has changed");
  NSAssert(kCFDateFormatterFullStyle == 4, @"CFDateFormatterStyle has changed");

  for (int dateStyle = kCFDateFormatterNoStyle; dateStyle <= kCFDateFormatterFullStyle; dateStyle++) {
    for (int timeStyle = kCFDateFormatterNoStyle; timeStyle <= kCFDateFormatterFullStyle; timeStyle++) {
      NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
      [formatter setLocale:[NSLocale currentLocale]];
      [formatter setCalendar:[NSCalendar currentCalendar]];
      [formatter setDateStyle:dateStyle];
      [formatter setTimeStyle:timeStyle];
      _dateFormatters[dateStyle][timeStyle] = formatter;
    }
  }
}

- (void)localeDidChangeNotification:(NSNotification *)notification
{
  [self allocDateFormatters];
}

- (NSString *)localizedStringFromDate:(NSDate *)date dateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle
{
  NSAssert(dateStyle <= kCFDateFormatterFullStyle, @"CFDateFormatterStyle has changed");
  NSAssert(timeStyle <= kCFDateFormatterFullStyle, @"CFDateFormatterStyle has changed");

  NSDateFormatter *dateFormatter = _dateFormatters[dateStyle][timeStyle];
  return [dateFormatter stringFromDate:date];
}

- (void)releaseDateFormatters
{
  for (int dateStyle = kCFDateFormatterNoStyle; dateStyle <= kCFDateFormatterFullStyle; dateStyle++) {
    for (int timeStyle = kCFDateFormatterNoStyle; timeStyle <= kCFDateFormatterFullStyle; timeStyle++) {
      _dateFormatters[dateStyle][timeStyle] = nil;
    }
  }
}

@end
