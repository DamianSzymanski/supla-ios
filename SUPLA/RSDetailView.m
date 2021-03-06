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

#import "RSDetailView.h"
#import "DetailView.h"
#import "UIHelper.h"
#import "SuplaApp.h"
#import "SAChannelGroup+CoreDataClass.h"

@implementation SARSDetailView {
    NSTimer *delayTimer1;
}

-(void)detailViewInit {
    
    if ( self.initialized == NO ) {
        self.backgroundColor = [UIColor rsDetailBackground];
        self.rollerShutter.markerColor = [UIColor rsMarkerColor];
        self.rollerShutter.gestureEnabled = YES;
        self.rollerShutter.delegate = self;
        self.rollerShutter.hidden = NO;
        
        self.roofWindow.delegate = self;
        self.roofWindow.hidden = NO;
        
        self.onlineStatus.onlineColor = [UIColor onLine];
        self.onlineStatus.offlineColor = [UIColor offLine];
        self.onlineStatus.borderColor = [UIColor statusBorder];
    }
    
    [super detailViewInit];
}

- (void)timer1FireMethod:(NSTimer *)timer {
    int percent = [timer.userInfo intValue];
    self.rollerShutter.percent = percent;
    self.rollerShutter.markers = nil;
    self.roofWindow.closingPercentage = percent;
    self.roofWindow.markers = nil;
    [self.labelPercent setText:[NSString stringWithFormat:@"%i%%", percent]];
    [timer invalidate];
}

-(void)dataToView {
    
    self.onlineStatus.hidden = YES;
    self.rollerShutter.hidden = YES;
    self.roofWindow.hidden = YES;
    
    if ( self.channelBase != nil ) {
        
        int percent = -1;
        
        if (self.channelBase.func == SUPLA_CHANNELFNC_CONTROLLINGTHEROOFWINDOW) {
            self.roofWindow.hidden = NO;
        } else {
            self.rollerShutter.hidden = NO;
        }
        
        if ([self.channelBase isKindOfClass: [SAChannelGroup class]]) {
            SAChannelGroup *cgroup = (SAChannelGroup*)self.channelBase;
            self.onlineStatus.hidden = NO;
            self.onlineStatus.percent = cgroup.onlinePercent;
            self.rollerShutter.percent = 0;
            self.roofWindow.closingPercentage = 0;
            
            NSMutableArray *positions = cgroup.positions;
            for(int a=0;a<positions.count;a++) {
                int p = [[positions objectAtIndex:a] intValue];
                if (p < 0) {
                    [positions removeObjectAtIndex:a];
                    a--;
                } else if (percent == -1) {
                    percent = p;
                } else if (percent != -2 && percent != p) {
                    percent = -2;
                }
            }
            
            if (delayTimer1!=nil) {
                [delayTimer1 invalidate];
                delayTimer1 = nil;
            }
            
            if (percent >= 0) {
                self.rollerShutter.markers = positions;
                self.roofWindow.markers = positions;
                 [self.labelPercent setText:NSLocalizedString(@"---", NULL)];
                delayTimer1 = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(timer1FireMethod:) userInfo:[NSNumber numberWithInt:percent] repeats:NO];
            } else if (percent == -1) {
                // All of RS wait for calibration
                self.rollerShutter.markers = nil;
                self.roofWindow.markers = nil;
                 [self.labelPercent setText:NSLocalizedString(@"[Calibration]", NULL)];
            } else {
                self.rollerShutter.markers = positions;
                self.roofWindow.markers = positions;
                [self.labelPercent setText:NSLocalizedString(@"---", NULL)];
            }
            
        } else {
            percent = self.channelBase.percentValue;
            
            if ( percent < 100 && [self.channelBase hiSubValue] > 0 ) {
                percent = 100;
            }
            
            self.rollerShutter.markers = nil;
            self.rollerShutter.percent = percent;
            self.roofWindow.markers = nil;
            self.roofWindow.closingPercentage = percent;
            
            if ( percent < 0 ) {
                [self.labelPercent setText:NSLocalizedString(@"[Calibration]", NULL)];
            } else {
                [self.labelPercent setText:[NSString stringWithFormat:@"%i%%", (int)percent]];
            }
        }
        
    }
    
}

-(void)updateView {
    [super updateView];
    [self dataToView];
};

-(void)setChannelBase:(SAChannelBase *)channelBase {
    [super setChannelBase:channelBase];
    
    if ( channelBase != nil && channelBase.isOnline == NO ) {
        [self.main_view detailShow:NO animated:NO];
    }
};

- (void)open:(int)value {
    SASuplaClient *client = [SAApp SuplaClient];
    if ( client != nil && self.channelBase != nil )  {
        [[SAApp SuplaClient] cg:self.channelBase.remote_id Open:value group:[self.channelBase isKindOfClass: [SAChannelGroup class]]];
    }
    
}

- (IBAction)upTouch:(id)sender {
    [self open:2];
}

- (IBAction)downTouch:(id)sender {
    [self open:1];
}

- (IBAction)stopTouch:(id)sender {
    [self open:0];
}

- (IBAction)openTouch:(id)sender {
    [self open:10];
}

- (IBAction)closeTouch:(id)sender {
    [self open:110];
}

-(void) rsChangeing:(id)rs withPercent:(float)percent {
    [self.labelPercent setText:[NSString stringWithFormat:@"%i%%", (int)percent]];
}

-(void) rsChanged:(id)rs withPercent:(float)percent {
    [self dataToView];
    [self open:percent+10];
}

- (void)roofWindowClosingPercentageChanged:(id)roofWindowController percent:(float)percent {
    [self dataToView];
    [self open:percent+10];
}

- (void)roofWindowClosingPercentageChangeing:(id)roofWindowController percent:(float)percent {
    [self.labelPercent setText:[NSString stringWithFormat:@"%i%%", (int)percent]];
}
@end
