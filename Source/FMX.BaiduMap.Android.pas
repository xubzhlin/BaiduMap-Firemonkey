//Android BaiduMap API
unit FMX.BaiduMap.Android;

interface

uses
  System.Types, FMX.Helpers.Android, Androidapi.Helpers, FMX.Platform, FMX.Platform.Android,
  FMX.Forms, Androidapi.JNIBridge, FMX.BaiduMap,
  Androidapi.JNI.Embarcadero,
  Androidapi.JNI.GraphicsContentViewText,
  Androidapi.JNI.com.baidu.mapapi.SDKInitializer,
  Androidapi.JNI.com.baidu.mapapi.map.MapView,
  Androidapi.JNI.com.baidu.mapapi.map.BaiduMap,
  Androidapi.JNI.com.baidu.location.BDLocationListener,
  Androidapi.JNI.com.baidu.location.BDLocation,
  Androidapi.JNI.com.baidu.location.LocationClient,
  Androidapi.JNI.com.baidu.mapapi.map.MyLocationConfiguration,
  Androidapi.JNI.com.baidu.mapapi.map.MyLocationData,
  Androidapi.JNI.com.baidu.mapapi.map.MyLocationData_Builder,
  Androidapi.JNI.com.baidu.mapapi.map.MyLocationConfiguration_LocationMode,
  Androidapi.JNI.com.baidu.mapapi.map.Marker,
  Androidapi.JNI.com.baidu.mapapi.map.BitmapDescriptor,
  Androidapi.JNI.com.baidu.mapapi.map.BitmapDescriptorFactory;
type

  TAndroidBaiduMapView = class;

  TAndroidLocation = class(TBaiduMapLocationService)
  private
    type
      TBDLocationListenner = class(TJavaLocal, JBDLocationListener)
      private
        [weak]FLocationService: TAndroidLocation;
      public
        procedure onReceiveLocation(P1: JBDLocation);
      end;
  private
    FLocationService:JLocationClient;
    FLocationListenner:TBDLocationListenner;
    CurrentMarker:JMarker;
    LocationParam:JMyLocationConfiguration;
  protected
    procedure InitLocation; override;
    procedure StarLocation; override;
    procedure StopLocation; override;
  public
    constructor Create; override;
    destructor Destroy; override;
  end;

  TAndroidBaiduMapView = class(TBaiduMapViewService)
  private
    FScale: Single;
    FMapView:JMapView;
    FBMMap:JBaiduMap;
    FJNativeLayout:JNativeLayout;
    procedure SDKInitializer;
    procedure InitInstance;
    procedure RealignView;
    procedure UpdateBaiduMapFromControl; override;
  protected
    procedure DoShowBaiduMap; override;
  public
    constructor Create; override;
    destructor Destroy; override;
  end;

implementation

{ TAndroidBaiduMapView }

constructor TAndroidBaiduMapView.Create;
begin
  inherited;
  SDKInitializer;
end;

destructor TAndroidBaiduMapView.Destroy;
begin
  FBMMap:=nil;
  FMapView:=nil;
  FJNativeLayout := nil;
  inherited;
end;

procedure TAndroidBaiduMapView.DoShowBaiduMap;
begin
  InitInstance;
end;

procedure TAndroidBaiduMapView.InitInstance;
var
  Rect: JRect;
begin
  CallInUIThread(
    procedure
    begin
      FJNativeLayout := TJNativeLayout.JavaClass.init(SharedActivity,
        MainActivity.getWindow.getDecorView.getWindowToken);
      FMapView := TJMapView.JavaClass.init(SharedActivity);
      {
      MapLoadedCallBak := TOnMapLoadedCallback.Create;
      MapLoadedCallBak.FBaiduMap := Self;
      }
      FBMMap := FMapView.getMap;
      //FBMMap.setOnMapLoadedCallback(MapLoadedCallBak);
      Rect := TJRect.JavaClass.init(0, 0, Round(Control.Size.Height),
        Round(Control.Size.Width));
      FMapView.requestFocus(0, Rect);
      FJNativeLayout.setPosition(0, 0);
      FJNativeLayout.setSize(Round(Control.Size.Height), Round(Control.Size.Width));
      FJNativeLayout.setControl(FMapView);
      RealignView;
    end);

end;

procedure TAndroidBaiduMapView.RealignView;
const
  VideoExtraSpace = 100;
  // To be sure that destination rect will fit to fullscreen
var
  MapRect: TRectF;
  RoundedRect: TRect;
  LSizeF: TPointF;
  LRealBounds: TRectF;
  LRealPosition, LRealSize: TPointF;
  i: Integer;
begin
  if (FJNativeLayout <> nil) then
  begin
    LRealPosition := Control.LocalToAbsolute(TPointF.Zero) * FScale;
    LSizeF := TPointF.Create(Control.Size.Size.cx, Control.Size.Size.cy);
    LRealSize := Control.LocalToAbsolute(LSizeF) * FScale;
    LRealBounds := TRectF.Create(LRealPosition, LRealSize);
    MapRect := TRectF.Create(0, 0, Control.Width * VideoExtraSpace,
      Control.Height * VideoExtraSpace);
    RoundedRect := MapRect.FitInto(LRealBounds).Round;

    if not Control.ParentedVisible then
      RoundedRect.Left := Round(Screen.Size.cx * FScale);

    FJNativeLayout.setPosition(RoundedRect.TopLeft.X, RoundedRect.TopLeft.Y);
    FJNativeLayout.setSize(RoundedRect.Width, RoundedRect.Height);
  end;
end;

procedure TAndroidBaiduMapView.SDKInitializer;
var
  ScreenSrv:IFMXScreenService;
begin
  CallInUIThreadAndWaitFinishing(
    procedure
    begin
      TJSDKInitializer.JavaClass.initialize
        (SharedActivity.getApplicationContext);
    end);
  if TPlatformServices.Current.SupportsPlatformService(IFMXScreenService,
    ScreenSrv) then
    FScale := ScreenSrv.GetScreenScale
  else
    FScale := 1;
end;

procedure TAndroidBaiduMapView.UpdateBaiduMapFromControl;
begin
  RealignView;
end;

{ TAndroidLocation }

constructor TAndroidLocation.Create;
begin
  FLocationService:=TJLocationClient.JavaClass.init(SharedActivityContext);
  FLocationListenner:=TBDLocationListenner.Create;
  FLocationListenner.FLocationService:=Self;
  FLocationService.registerNotifyLocationListener(FLocationListenner);
end;

destructor TAndroidLocation.Destroy;
begin

  inherited;
end;

procedure TAndroidLocation.InitLocation;
begin
  CurrentMarker := TJBitmapDescriptorFactory.JavaClass.fromPath(LocationViewImgName);
  LocationParam:=TJMyLocationConfiguration.JavaClass.init
    (TJMyLocationConfiguration_LocationMode.JavaClass.FOLLOWING, true,
    CurrentMarker);
  TAndroidBaiduMapView(Control).FBMMap.setMyLocationConfigeration(LocationParam);
end;

procedure TAndroidLocation.StarLocation;
begin
  FLocationService.start;
end;

procedure TAndroidLocation.StopLocation;
begin
  FLocationService.stop;
end;

{ TAndroidLocation.TBDLocationListenner }

procedure TAndroidLocation.TBDLocationListenner.onReceiveLocation(
  P1: JBDLocation);
var
  MyLocationData: JMyLocationData;
begin
  // 构造定位数据
  MyLocationData := TJMyLocationData_Builder.JavaClass.init.accuracy
    (P1.getRadius).latitude(P1.getLatitude)
    .longitude(P1.getLongitude).build;
  // 设置定位数据
  TAndroidBaiduMapView(FLocationService.Control).FBMMap.setMyLocationData(MyLocationData);
end;

end.
