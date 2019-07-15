/*
 Copyright (C) AC SOFTWARE SP. Z O.O.
 
 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 2
 of the License, or (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 */

#import <Foundation/Foundation.h>
#import "Database.h"
@import Charts;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ChartType) {
    Bar_Minutely,
    Bar_Hourly,
    Bar_Daily,
    Bar_Monthly,
    Bar_Yearly,
    Bar_Comparsion_MinMin,
    Bar_Comparsion_HourHour,
    Bar_Comparsion_DayDay,
    Bar_Comparsion_MonthMonth,
    Bar_Comparsion_YearYear,
    Pie_HourRank,
    Pie_WeekdayRank,
    Pie_MonthRank,
    Pie_PhaseRank
};

@interface SAChartHelper : NSObject <IChartAxisValueFormatter>

- (NSDateFormatter *) dateFormatterForCurrentChartType;
- (NSString *) stringForValue:(double)value axis:(nullable ChartAxisBase *)axis;
- (BarChartDataSet *) newBarDataSetWithEntries:(NSArray *)entries;
- (id<IChartMarker>) getMarker;
- (GroupingDepth) getGroupungDepthForCurrentChartType;
- (void) load;

@property (nonatomic, weak) CombinedChartView *combinedChart;
@property (nonatomic, weak) PieChartView *pieChart;
@property (nonatomic) ChartType chartType;
@property (nonatomic, weak) NSDate *dateFrom;
@property (nonatomic, weak) NSDate *dateTo;
@property (nonatomic, weak) NSString *unit;
@property (nonatomic) int channelId;
@end

NS_ASSUME_NONNULL_END