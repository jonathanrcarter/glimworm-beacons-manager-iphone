@import CoreLocation;
@import CoreBluetooth;
#import "BTDeviceModel.h"
#import "AppStatus.h"

@class GlimwormBeaconEdit;

@protocol GlimwormBeaconEditDelegate <NSObject>
- (void)GlimwormBeaconEdit:(GlimwormBeaconEdit *)controller sendMessage:(NSString *)item;
- (void)GlimwormBeaconEdit:(GlimwormBeaconEdit *)controller working:(NSString *)item;
- (void)GlimwormBeaconEdit:(GlimwormBeaconEdit *)controller writing:(NSString *)item;
- (void)GlimwormBeaconEdit:(GlimwormBeaconEdit *)controller done:(NSString *)item;
- (void)GlimwormBeaconEdit:(GlimwormBeaconEdit *)controller donewriting:(NSString *)item;
- (void)GlimwormBeaconEdit:(GlimwormBeaconEdit *)controller doneRedrawForm:(NSString *)item;
- (void)GlimwormBeaconEdit:(GlimwormBeaconEdit *)controller p_close_window:(NSString *)item;
- (void)GlimwormBeaconEdit:(GlimwormBeaconEdit *)controller connectingStringDisplay:(NSString *)item;
- (void)GlimwormBeaconEdit:(GlimwormBeaconEdit *)controller cancel_and_close_window:(NSString *)item;
@end

@interface GlimwormBeaconEdit : NSObject <
                    CLLocationManagerDelegate,
                    CBPeripheralManagerDelegate,
                    CBCentralManagerDelegate,
                    CBPeripheralDelegate >

@property  (nonatomic, strong) CBCharacteristic *currentChar;
@property  (nonatomic, strong) NSString *currentcommand;
@property  (nonatomic, strong) CBPeripheral *peripheral;



@property  (nonatomic) bool peripheralisconnected;
@property  (nonatomic) bool peripheralisconnecting;
@property  (nonatomic) bool peripheralisconnectedButNotRead;
@property  (nonatomic) bool connectActive;



@property  (nonatomic, weak) id <GlimwormBeaconEditDelegate> delegate;
@property  (nonatomic, strong) NSString *currentfirmware;
@property  (nonatomic, strong) NSString *incoming_uuid;
@property  (nonatomic, strong) NSString *BTYPE;
@property  (nonatomic, strong) NSString *PDATE;
@property  (readwrite) long PDATELONG;
@property  (readwrite) bool q_error;

@property  (nonatomic, strong) NSMutableArray *Queue;

@property  (nonatomic, strong) NSString *p_firmware_text, *p_pdate_text, *p_major_text;
@property  (nonatomic, strong) NSString *p_minor_text, *p_uuid_text, *p_name_text;
@property  (nonatomic, strong) NSString *p_pincode_text, *p_measuredpower_text, *p_battlevel_text;
@property  (readwrite) int p_rangeslider_value, p_advintslider_value, p_modeslider_value,p_battslider_value;
@property  (nonatomic, strong) NSString *currentInterval, *currentRange, *currentMode, *currentBatt;



+ (GlimwormBeaconEdit *)sharedInstance;
- (BOOL)connect;
- (void)q_readall;
- (void)q_readall_auto;
- (void)q_next;
- (void)working;
- (void)done;
- (void)cleanupconnection;
- (void)cleacupcancelledconnection;
- (void)p_writeall;
- (BOOL) isUSBBeacon;
- (BOOL) isCapableOfSettingModes;
- (BOOL) isCapableOfSettingBatteryLevel;



@end