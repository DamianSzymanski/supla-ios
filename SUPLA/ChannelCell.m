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

#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>
#import "ChannelCell.h"
#import "MGSwipeButton.h"
#import "SAChannel+CoreDataClass.h"
#import "SuplaApp.h"
#include "proto.h"

#define CLEFT_MARGIN     5
#define CRIGHT_MARGIN    5
#define CTOP_MARGIN      5
#define CBOTTOM_MARGIN   5


@implementation MGSwipeTableCell (SUPLA)

-(void) prepareForReuse
{
    [super prepareForReuse];
};

@end

@implementation MGSwipeButton (SUPLA)

-(void) setBackgroundColor:(UIColor *)backgroundColor withDelay:(NSTimeInterval) delay {
    [self performSelector:@selector(setBackgroundColor:) withObject:backgroundColor afterDelay:delay];
}

@end

@implementation SAChannelCell {
    SAChannelBase *_channelBase;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if ( self ) {
         self.leftSwipeSettings.transition = MGSwipeTransitionRotate3D;
         self.rightSwipeSettings.transition = MGSwipeTransitionRotate3D;

    }
    return self;
}

- (void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
    self.channelBase = _channelBase;
}

-(SAChannelBase*)channelBase {
    return _channelBase;
}

-(void)btn:(UIButton *)btn SetAction:(SEL)sel {
    
    [btn addTarget:self action:sel forControlEvents:UIControlEventTouchDown];
    [btn addTarget:self action:@selector(rlTouchCancel:) forControlEvents:UIControlEventTouchCancel];
    [btn addTarget:self action:@selector(rlTouchCancel:) forControlEvents:UIControlEventTouchUpInside];
    [btn addTarget:self action:@selector(rlTouchCancel:) forControlEvents:UIControlEventTouchUpOutside];
    
}

-(void)setChannelBase:(SAChannelBase *)channelBase {
    
    _channelBase = channelBase;

    [self.caption setText:[channelBase getChannelCaption]];
    
    if ( channelBase.func == SUPLA_CHANNELFNC_THERMOMETER ) {
        
        [self.temp setText:[channelBase isOnline] && channelBase.temperatureValue > -273 ? [NSString stringWithFormat:@"%0.1f°", channelBase.temperatureValue] : @"----°"];
    
    } else if ( channelBase.func== SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE ) {
        
        [self.temp setText:[channelBase isOnline] && channelBase.temperatureValue > -273 ? [NSString stringWithFormat:@"%0.1f°", channelBase.temperatureValue] : @"----°"];
        
        [self.humidity setText:[channelBase isOnline] && channelBase.humidityValue > -1 ? [NSString stringWithFormat:@"%0.1f°", channelBase.humidityValue] : @"----°"];
        
    } else if ( channelBase.func == SUPLA_CHANNELFNC_DEPTHSENSOR
                || channelBase.func == SUPLA_CHANNELFNC_DISTANCESENSOR  ) {
        
        NSString *text = @"--- m";
        
        if ( [channelBase isOnline] && channelBase.doubleValue > -1 ) {
            
            double value = [channelBase doubleValue];
            
            if ( value >= 1000 ) {
                text = [NSString stringWithFormat:@"%0.2f km", value/1000.00];
            } else if ( value >= 1 ) {
                text = [NSString stringWithFormat:@"%0.2f m", value];
            } else {
                value *= 100;
                
                if ( value >= 1 ) {
                    text = [NSString stringWithFormat:@"%0.1f cm", value];
                } else {
                    value *= 10;
                    text = [NSString stringWithFormat:@"%i mm", (int)value];
                }
            }

        }
        
        [self.distance setText:text];
    
    } else {
    
        [self.image setImage:[channelBase getIcon]];
        

        self.rightDot.ring = NO;
        self.leftDot.ring = NO;
        
        self.rightDot.color = [channelBase isOnline] ? [UIColor circleOn] : [UIColor redColor];
        self.leftDot.color = self.rightDot.color;
        
        self.rightButtons = nil;
        self.leftButtons = nil;
        
        
        switch(channelBase.func) {
            case SUPLA_CHANNELFNC_CONTROLLINGTHEGATE:
            case SUPLA_CHANNELFNC_CONTROLLINGTHEGARAGEDOOR:
            case SUPLA_CHANNELFNC_CONTROLLINGTHEDOORLOCK:
            case SUPLA_CHANNELFNC_CONTROLLINGTHEGATEWAYLOCK:
            case SUPLA_CHANNELFNC_CONTROLLINGTHEROLLERSHUTTER:
                self.leftDot.hidden = YES;
                self.rightDot.hidden = NO;
                break;
            case SUPLA_CHANNELFNC_POWERSWITCH:
            case SUPLA_CHANNELFNC_LIGHTSWITCH:
                self.leftDot.hidden = NO;
                self.rightDot.hidden = NO;
                break;
            case SUPLA_CHANNELFNC_RGBLIGHTING:
            case SUPLA_CHANNELFNC_DIMMER:
            case SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING:
                self.leftDot.hidden = YES;
                self.rightDot.hidden = NO;
                break;
            case SUPLA_CHANNELFNC_NOLIQUIDSENSOR:
            case SUPLA_CHANNELFNC_OPENINGSENSOR_DOOR:
            case SUPLA_CHANNELFNC_OPENINGSENSOR_GARAGEDOOR:
            case SUPLA_CHANNELFNC_OPENINGSENSOR_GATE:
            case SUPLA_CHANNELFNC_OPENINGSENSOR_GATEWAY:
            case SUPLA_CHANNELFNC_OPENINGSENSOR_ROLLERSHUTTER:
            case SUPLA_CHANNELFNC_OPENINGSENSOR_WINDOW:
            case SUPLA_CHANNELFNC_MAILSENSOR:
                self.leftDot.hidden = NO;
                self.rightDot.hidden = NO;
                self.rightDot.ring = YES;
                self.leftDot.ring = YES;
                break;
            default:
                self.leftDot.hidden = YES;
                self.rightDot.hidden = YES;
                break;
        }
        
        if ( [channelBase isOnline] ) {
            
            MGSwipeButton *bl = nil;
            MGSwipeButton *br = nil;
            
            
            switch(channelBase.func) {
                case SUPLA_CHANNELFNC_CONTROLLINGTHEDOORLOCK:
                case SUPLA_CHANNELFNC_CONTROLLINGTHEGATEWAYLOCK:
                    br = [MGSwipeButton buttonWithTitle:NSLocalizedString(@"Open", nil) icon:nil backgroundColor:[UIColor blackColor]];
                    break;
                case SUPLA_CHANNELFNC_CONTROLLINGTHEGATE:
                case SUPLA_CHANNELFNC_CONTROLLINGTHEGARAGEDOOR:
                    br = [MGSwipeButton buttonWithTitle:NSLocalizedString(@"Open Close", nil) icon:nil backgroundColor:[UIColor blackColor]];
                    break;
                case SUPLA_CHANNELFNC_POWERSWITCH:
                case SUPLA_CHANNELFNC_LIGHTSWITCH:
                    br = [MGSwipeButton buttonWithTitle:NSLocalizedString(@"On", nil) icon:nil backgroundColor:[UIColor blackColor]];
                    bl = [MGSwipeButton buttonWithTitle:NSLocalizedString(@"Off", nil) icon:nil backgroundColor:[UIColor blackColor]];
                    break;
            }
            
            if ( br ) {
                [br setButtonWidth:105];
                [br.titleLabel setFont:[UIFont fontWithName:@"Quicksand" size:16]];
                //[br.titleLabel setFont:[UIFont fontWithName:@"OpenSens" size:10]];
                br.backgroundColor = [UIColor circleOn];
                [self btn:br SetAction:@selector(rightTouchDown:)];
                self.rightButtons = @[br];
            }
            
            if ( bl ) {
                [bl setButtonWidth:105];
                [bl.titleLabel setFont:[UIFont fontWithName:@"Quicksand" size:16]];
                //[bl.titleLabel setFont:[UIFont fontWithName:@"OpenSens" size:10]];
                bl.backgroundColor = [UIColor circleOn];
                [self btn:bl SetAction:@selector(leftTouchDown:)];
                self.leftButtons = @[bl];
            }
            
        }
        
    }


    
    [self refreshContentView];
    
}

- (void)vibrate {

    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);

}

- (IBAction)rightTouchDown:(id)sender {
    [sender setBackgroundColor: [UIColor btnTouched]];
    
    [self vibrate];
    [[SAApp SuplaClient] channel:self.channelBase.remote_id Open:self.channelBase.func == SUPLA_CHANNELFNC_CONTROLLINGTHEROLLERSHUTTER ? 2 : 1];
    [self hideSwipeAnimated:YES];
}

- (IBAction)leftTouchDown:(id)sender {
    [sender setBackgroundColor: [UIColor btnTouched]];
    
    [self vibrate];
    [[SAApp SuplaClient] channel:self.channelBase.remote_id Open:self.channelBase.func == SUPLA_CHANNELFNC_CONTROLLINGTHEROLLERSHUTTER ? 1 : 0];
    [self hideSwipeAnimated:YES];
}

- (IBAction)rlTouchCancel:(id)sender {
    
    [sender setBackgroundColor: [UIColor circleOn] withDelay:0.2];
    
    if ( self.channelBase.func == SUPLA_CHANNELFNC_CONTROLLINGTHEROLLERSHUTTER ) {
        
            [self vibrate];
            [[SAApp SuplaClient] channel:self.channelBase.remote_id Open: 0];
    }
    
}

@end
