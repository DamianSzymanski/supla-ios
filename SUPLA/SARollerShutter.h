/*
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

#import <UIKit/UIKit.h>

@protocol SARollerShutterDelegate <NSObject>

@required
-(void) rsChangeing:(id)rs withPercent:(float)percent;
-(void) rsChanged:(id)rs withPercent:(float)percent;

@end

@interface SARollerShutter : UIView


@property(weak, nonatomic) UIColor *windowColor;
@property(weak, nonatomic) UIColor *sunColor;
@property(nonatomic, assign) CGFloat frameLineWidth;
@property(nonatomic, assign) CGFloat spaceing;
@property(nonatomic, assign) CGFloat louverSpaceing;
@property(nonatomic, assign) short louverCount;
@property(nonatomic, assign) float percent;
@property(nonatomic, assign) BOOL gestureEnabled;

@property(weak, nonatomic) id<SARollerShutterDelegate> delegate;

@end
