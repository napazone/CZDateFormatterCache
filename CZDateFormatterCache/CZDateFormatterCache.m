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
  NSLocale *_currentLocale;
  NSDateFormatter *_dateFormatters[5][5];
  NSDateFormatter *_simpleTimeFormatter;
}

#pragma mark - Class methods

+ (CZDateFormatterCache *)mainQueueCache
{
  return [self mainThreadCache];
}

+ (CZDateFormatterCache *)mainThreadCache
{
  static dispatch_once_t onceToken;
  static CZDateFormatterCache *instance = nil;

  NSAssert([NSThread isMainThread], @"Must access on the main thread");

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

  // date formatters for all styles

  for (int dateStyle = kCFDateFormatterNoStyle; dateStyle <= kCFDateFormatterFullStyle; dateStyle++) {
    for (int timeStyle = kCFDateFormatterNoStyle; timeStyle <= kCFDateFormatterFullStyle; timeStyle++) {
      NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
      [formatter setLocale:self.currentLocale];
      [formatter setCalendar:[NSCalendar currentCalendar]];
      [formatter setDateStyle:dateStyle];
      [formatter setTimeStyle:timeStyle];
      _dateFormatters[dateStyle][timeStyle] = formatter;
    }
  }

  // date formatter for simple time formatter

  NSString *simpleTimeFormatTemplate = [NSDateFormatter dateFormatFromTemplate:@"j" options:0 locale:self.currentLocale];
  BOOL use12HourClock = ([simpleTimeFormatTemplate rangeOfString:@"a"].location != NSNotFound);
  if (use12HourClock) {
    _simpleTimeFormatter = [[NSDateFormatter alloc] init];
    _simpleTimeFormatter.dateFormat = simpleTimeFormatTemplate;
  }
  else {
    _simpleTimeFormatter = nil;
  }
}

- (NSLocale *)currentLocale
{
  if (_currentLocale == nil) {
    _currentLocale = [NSLocale currentLocale];
  }
  return _currentLocale;
}

- (void)localeDidChangeNotification:(NSNotification *)notification
{
  self.currentLocale = [NSLocale currentLocale];
}

- (NSString *)localizedCompactTimeStringForDate:(NSDate *)date
{
  NSString *result = [self localizedSimpleTimeStringForDate:date];

  result = [result stringByReplacingOccurrencesOfString:@"am" withString:@"a" options:NSCaseInsensitiveSearch range:NSMakeRange(0, result.length)];
  result = [result stringByReplacingOccurrencesOfString:@"pm" withString:@"p" options:NSCaseInsensitiveSearch range:NSMakeRange(0, result.length)];
  result = [result stringByReplacingOccurrencesOfString:@" " withString:@""];
  return result.lowercaseString;
}

- (NSString *)localizedStringFromDate:(NSDate *)date dateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle
{
  NSAssert(dateStyle <= kCFDateFormatterFullStyle, @"CFDateFormatterStyle has changed");
  NSAssert(timeStyle <= kCFDateFormatterFullStyle, @"CFDateFormatterStyle has changed");

  NSDateFormatter *dateFormatter = _dateFormatters[dateStyle][timeStyle];
  return [dateFormatter stringFromDate:date];
}

- (NSString *)localizedSimpleTimeStringForDate:(NSDate *)date
{
  if (_simpleTimeFormatter == nil) {
    return [self localizedStringFromDate:date dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
  }

  NSCalendar *calendar = [NSCalendar currentCalendar];
  NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:date];
  if (components.minute == 0) {
    if (components.hour == 12) {
      return NSLocalizedString(@"Noon", nil);
    }
    else {
      return [_simpleTimeFormatter stringFromDate:date];
    }
  }
  else {
    return [self localizedStringFromDate:date dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
  }
}

- (void)releaseDateFormatters
{
  for (int dateStyle = kCFDateFormatterNoStyle; dateStyle <= kCFDateFormatterFullStyle; dateStyle++) {
    for (int timeStyle = kCFDateFormatterNoStyle; timeStyle <= kCFDateFormatterFullStyle; timeStyle++) {
      _dateFormatters[dateStyle][timeStyle] = nil;
    }
  }
}

- (void)setCurrentLocale:(NSLocale *)currentLocale
{
  if (_currentLocale != currentLocale) {
    [self releaseDateFormatters];
    _currentLocale = currentLocale;
    [self allocDateFormatters];
  }
}

@end
