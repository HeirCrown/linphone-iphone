/*
 * Copyright (c) 2010-2020 Belledonne Communications SARL.
 *
 * This file is part of linphone-iphone
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

#import "UIPauseButton.h"
#import "LinphoneManager.h"
#import "Utils.h"

@implementation UIPauseButton

#pragma mark - Lifecycle Functions

- (void)initUIPauseButton {
	type = UIPauseButtonType_CurrentCall;
}

- (id)init {
	self = [super init];
	if (self) {
		[self initUIPauseButton];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
	self = [super initWithCoder:decoder];
	if (self) {
		[self initUIPauseButton];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self initUIPauseButton];
	}
	return self;
}

#pragma mark - Static Functions

+ (bool)isInConference:(LinphoneCall *)call {
	if (!call)
		return false;
	return linphone_call_params_get_local_conference_mode(linphone_call_get_current_params(call));
}

+ (LinphoneCall *)getCall {
	LinphoneCall *currentCall = linphone_core_get_current_call(LC);
	if (currentCall == nil && linphone_core_get_calls_nb(LC) == 1) {
		currentCall = (LinphoneCall *)linphone_core_get_calls(LC)->data;
	}
	return currentCall;
}

#pragma mark -

- (void)setType:(UIPauseButtonType)atype call:(LinphoneCall *)acall {
	type = atype;
	call = acall;
}

#pragma mark - UIToggleButtonDelegate Functions

- (void)onOn {
	switch (type) {
		case UIPauseButtonType_Call: {
			if (call != nil) {
				if ([CallManager callKitEnabled]) {
					[CallManager.instance setHeldWithCall:call hold:true];
				} else {
					CallManager.instance.speakerBeforePause = [CallManager.instance isSpeakerEnabled];
					linphone_call_pause(call);
				}
			} else {
				LOGW(@"Cannot toggle pause buttton, because no current call");
			}
			break;
		}
		case UIPauseButtonType_Conference: {
			linphone_conference_leave(CallManager.instance.getConference);
			// Fake event
			[NSNotificationCenter.defaultCenter postNotificationName:kLinphoneCallUpdate object:self];
			break;
		}
		case UIPauseButtonType_CurrentCall: {
			LinphoneCall *currentCall = [UIPauseButton getCall];
			if (currentCall != nil) {
				if ([CallManager callKitEnabled]) {
					[CallManager.instance setHeldWithCall:currentCall hold:true];
				} else {
					CallManager.instance.speakerBeforePause = [CallManager.instance isSpeakerEnabled];
					linphone_call_pause(currentCall);
				}
			} else {
				LOGW(@"Cannot toggle pause buttton, because no current call");
			}
			break;
		}
	}
}

- (void)onOff {
	switch (type) {
		case UIPauseButtonType_Call: {
			if (call != nil) {
				if ([CallManager callKitEnabled]) {
					[CallManager.instance setHeldWithCall:call hold:false];
				} else {
					linphone_call_resume(call);
				}
			} else {
				LOGW(@"Cannot toggle pause buttton, because no current call");
			}
			break;
		}
		case UIPauseButtonType_Conference: {
			linphone_conference_enter(CallManager.instance.getConference);
			// Fake event
			[NSNotificationCenter.defaultCenter postNotificationName:kLinphoneCallUpdate object:self];
			break;
		}
		case UIPauseButtonType_CurrentCall: {
			LinphoneCall *currentCall = [UIPauseButton getCall];
			if ([CallManager callKitEnabled]) {
				[CallManager.instance setHeldWithCall:currentCall hold:false];
			} else {
				linphone_call_resume(currentCall);
			}
			break;
		}
	}
}

- (bool)onUpdate {
	bool ret = false;
	LinphoneCall *c = call;
	switch (type) {
		case UIPauseButtonType_Conference: {
			self.enabled = CallManager.instance.getConference && (linphone_conference_get_participant_count(CallManager.instance.getConference)> 0);
			if (self.enabled) {
				ret = (!CallManager.instance.isInConference);
			}
			break;
		}
		case UIPauseButtonType_CurrentCall:
			c = [UIPauseButton getCall];
		case UIPauseButtonType_Call: {
			if (c != nil) {
				LinphoneCallState state = linphone_call_get_state(c);
				ret = (state == LinphoneCallPaused || state == LinphoneCallPausing);
				self.enabled = !linphone_core_sound_resources_locked(LC) &&
				(state == LinphoneCallPaused || state == LinphoneCallPausing ||
				 state == LinphoneCallStreamsRunning);
			} else {
				self.enabled = FALSE;
			}
			break;
		}
	}
	return ret;
}

@end
