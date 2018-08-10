unit BaiduMapAPI.FrameworkLoader.iOS;
// iOS link Framework

interface

{$IFDEF iOS}

uses
  iOSapi.BaiduMapAPI_Base,
  iOSapi.BaiduMapAPI_Location,
  BaiduMapAPI.ViewService,
  BaiduMapAPI.GeoCodeSearchService;

{$LINK libBaiduMapAPI_Base}
{$LINK libBaiduMapAPI_Location}

const
  libUserNotifications =
    '/System/Library/Frameworks/UserNotifications.framework/UserNotifications';
  libAudioToolbox =
    '/System/Library/Frameworks/AudioToolbox.framework/AudioToolbox';
  libImageIO = '/System/Library/Frameworks/ImageIO.framework/ImageIO';
  libCoreMotion = '/System/Library/Frameworks/CoreMotion.framework/CoreMotion';
  libCoreLocation =
    '/System/Library/Frameworks/CoreLocation.framework/CoreLocation';
  libCoreTelephony =
    '/System/Library/Frameworks/CoreTelephony.framework/CoreTelephony';
  libMediaPlayer =
    '/System/Library/Frameworks/MediaPlayer.framework/MediaPlayer';
  libAVFoundation =
    '/System/Library/Frameworks/AVFoundation.framework/AVFoundation';
  libSystemConfiguration =
    '/System/Library/Frameworks/SystemConfiguration.framework/SystemConfiguration';
  libSystemJavaScriptCore =
    '/System/Library/Frameworks/JavaScriptCore.framework/JavaScriptCore';
  libSecurity = '/System/Library/Frameworks/Security.framework/Security';
  libOpenGLES = '/System/Library/Frameworks/OpenGLES.framework/OpenGLES';
  libGLKit = '/System/Library/Frameworks/GLKit.framework/GLKit';
  libMobileCoreServices = '/System/Library/Frameworks/MobileCoreServices.framework/MobileCoreServices';
  libCoreData = '/System/Library/Frameworks/CoreData.framework/CoreData';

  //lib
  libcrypto = '/usr/lib/libcrypto.a';
  libssl = '/usr/lib/libssl.a';
  libstdc = '/usr/lib/libstdc++.dylib';
  libsqlite3 = '/usr/lib/libsqlite3.dylib';
  libz = '/usr/lib/libz.1.2.5.dylib';
  libc = '/usr/lib/libc++.dylib';

{$ENDIF}

implementation


{$IFDEF iOS}
//{$IF defined(CPUARM)}
//procedure libUserNotificationsLoader; cdecl; external libUserNotifications;
//procedure libAudioToolboxLoader; cdecl; external libAudioToolbox;
//procedure libImageIOLoader; cdecl; external libImageIO;
//procedure libCoreMotionLoader; cdecl; external libCoreMotion;
//procedure libCoreLocationLoader; cdecl; external libCoreLocation;
//procedure libCoreTelephonyLoader; cdecl; external libCoreTelephony;
//procedure libMediaPlayerLoader; cdecl; external libMediaPlayer;
//procedure libAVFoundationLoader; cdecl; external libAVFoundation;
//procedure libSystemConfigurationLoader; cdecl; external libSystemConfiguration;
//procedure libSystemJavaScriptCoreLoader; cdecl; external libSystemJavaScriptCore;
//procedure libSecurityLoader; cdecl; external libSecurity;
//procedure libOpenGLESLoader; cdecl; external libOpenGLES;
//procedure libGLKitCoreLoader; cdecl; external libGLKit;
//procedure libMobileCoreServicesLoader; cdecl; external libMobileCoreServices;
//procedure libCoreDataLoader; cdecl; external libCoreData;

//procedure libBaiduMapAPI_BaseLoader; cdecl; external libBaiduMapAPI_Base;
//procedure libBaiduMapAPI_LocationLoader; cdecl; external libBaiduMapAPI_Location;
//procedure libBaiduMapAPI_MapLoader; cdecl; external libBaiduMapAPI_Map;
//procedure libBaiduMapAPI_RadarLoader; cdecl; external libBaiduMapAPI_Radar;
//procedure libBaiduMapAPI_SearchLoader; cdecl; external libBaiduMapAPI_Search;
//procedure libBaiduMapAPI_UtilsLoader; cdecl; external libBaiduMapAPI_Utils;
//procedure libBaiduMapAPI_NaviLoader; cdecl; external libBaiduMapAPI_Navi;


//procedure libcryptoLoader; cdecl; external libcrypto;
//procedure libsslLoader; cdecl; external libssl;
//procedure libstdcLoader; cdecl; external libstdc;
//procedure libsqlite3Loader; cdecl; external libsqlite3;
//procedure libzLoader; cdecl; external libz;
//procedure libcLoader; cdecl; external libc;
//{$ENDIF}

{$ENDIF}


end.
