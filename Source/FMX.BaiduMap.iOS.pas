//iOS Baidu API

unit FMX.BaiduMap.iOS;

interface

uses
  System.SysUtils, System.Classes, System.Types, FMX.Forms, Macapi.Helpers, FMX.Helpers.iOS, FMX.Platform.iOS,
  iOSapi.CoreGraphics, FMX.BaiduMap, iOS.BMKMapManager, iOS.BMKGeneralDelegate, iOS.BMKMapView,
  iOS.BMKType, iOS.BMKLocationService, iOS.BMKUserLocation, iOS.BMKLocationViewDisplayParam,
  iOSapi.Foundation, FMX.ZOrder.iOS, Macapi.ObjectiveC;

type
  TiOSBaiduMapView = class;
  //iOS Baidu API LocastionService
  TiOSLocastion = class(TBaiduMapLocationService)
  private
    type
      TLocationServiceDelegate = class(TOCLocal, BMKLocationServiceDelegate)
      private
        [weak]FLocationService:TBaiduMapLocationService;
      public
        procedure willStartLocatingUser; cdecl;
        procedure didStopLocatingUser; cdecl;
        procedure didUpdateUserHeading(userLocation:BMKUserLocation); cdecl;
        procedure didUpdateBMKUserLocation(userLocation:BMKUserLocation); cdecl;
        procedure didFailToLocateUserWithError(error:NSError); cdecl;
      end;
  private
    FLocationService:BMKLocationService;
    FLocationDelegate:TLocationServiceDelegate;
    LocationParam:BMKLocationViewDisplayParam;
  protected
    procedure InitLocation; override;
    procedure StarLocation; override;
    procedure StopLocation; override;
  public
    constructor Create; override;
    destructor Destroy; override;
  end;

  //iOS Baidu API MapViewService
  TiOSBaiduMapView = class(TBaiduMapViewService)
  private
    FScale: Single;
    FMapView:BMKMapView;
    FMapManager:BMKMapManager;
    FLocationInitBoolean:Boolean;
    procedure SDKInitializer;
    procedure InitInstance;
    procedure RealignView;
    procedure UpdateBaiduMapFromControl; override;
  protected
    procedure DoShowBaiduMap; override;
    procedure IsShowsUserLocation(Value:Boolean); override;
  public
    constructor Create(AppKey:String); override;
    destructor Destroy; override;
  end;

implementation

{ TiOSBaiduMapView }

constructor TiOSBaiduMapView.Create(AppKey:String);
begin
  inherited Create(AppKey);
  SDKInitializer;
end;

destructor TiOSBaiduMapView.Destroy;
begin
  FMapView.release;
  FMapView:=nil;
  FMapManager.release;
  FMapManager:=nil;
  inherited;
end;

procedure TiOSBaiduMapView.DoShowBaiduMap;
begin
  InitInstance;
end;

procedure TiOSBaiduMapView.InitInstance;
begin
  FMapView:=TBMKMapView.Wrap(TBMKMapView.Alloc.init);
  FMapView.SetMapType(BMKMapTypeStandard);
  FMapView.setUserTrackingMode(BMKUserTrackingModeFollow);
  FMapView.setHidden(False);
  SharedApplication.keyWindow.rootViewController.View.addSubview(FMapView);
  FMapView.retain;
  RealignView;
end;

procedure TiOSBaiduMapView.IsShowsUserLocation(Value: Boolean);
begin
  if FMapView.showsUserLocation<>Value then
  begin
    FMapView.setShowsUserLocation(Value);
  end;
end;

procedure TiOSBaiduMapView.RealignView;
var
  Form: TCommonCustomForm;
  {$IFDEF IOS}
  ZOrderManager: TiOSZOrderManager;
  {$ELSE}
  View: INativeView;
  Bounds: TRectF;
  {$ENDIF}
begin
  if FMapView <> nil then
  begin
    if (Control <> nil) and not (csDesigning in Control.ComponentState) and
       (Control.Root is TCommonCustomForm) then
    begin
      Form := TCommonCustomForm(Control.Root);
      {$IFDEF IOS}
      ZOrderManager := WindowHandleToPlatform(Form.Handle).ZOrderManager;
      ZOrderManager.UpdateOrderAndBounds(Control, FMapView);
      {$ELSE}
      Bounds := TRectF.Create(0,0,FWebControl.Width,FWebControl.Height);
      Bounds.Fit(FWebControl.AbsoluteRect);
      View := WindowHandleToPlatform(Form.Handle).View;
      View.addSubview(FWebView);
      if SameValue(Bounds.Width, 0) or SameValue(Bounds.Height, 0) then
        FWebView.setHidden(True)
      else
      begin
        TNativeWebViewHelper.SetBounds(FWebView, Bounds, View.bounds.size.height);
        FWebView.setHidden(not FWebControl.ParentedVisible);
      end;
      {$ENDIF}
    end
    else
      FMapView.setHidden(True);
  end;
end;

procedure TiOSBaiduMapView.SDKInitializer;
begin
  FMapManager:=TBMKMapManager.Create;
  FMapManager.start(StrToNSStr(AppKey),nil);
  FMapManager.retain;
end;

procedure TiOSBaiduMapView.UpdateBaiduMapFromControl;
begin
  RealignView;
end;

{ TiOSLocastion }

constructor TiOSLocastion.Create;
begin
  FLocationService:=TBMKLocationService.Wrap(TBMKLocationService.Alloc.init);
  FLocationService.retain;
  FLocationDelegate:=TLocationServiceDelegate.Create;
  FLocationDelegate.FLocationService:=Self;
  FLocationService.setDelegate(FLocationDelegate.GetObjectID);

  LocationParam:=TBMKLocationViewDisplayParam.Wrap(TBMKLocationViewDisplayParam.Alloc.init);
end;

destructor TiOSLocastion.Destroy;
begin
  FLocationService.release;
  FLocationService:=nil;
  FreeAndNil(FLocationDelegate);
  inherited;
end;

procedure TiOSLocastion.InitLocation;
begin
  if (LocationParam<>nil) then
  begin
    LocationParam.setIsRotateAngleValid(IsRotateAngleValid);
    LocationParam.setLocationViewImgName(StrToNSStr(LocationViewImgName));
    //TiOSBaiduMapView(Control.BaiduMapView).FMapView.updateLocationViewWithParam(LocationParam);
  end;
end;

procedure TiOSLocastion.StarLocation;
begin
  FLocationService.startUserLocationService;

end;

procedure TiOSLocastion.StopLocation;
begin
  FLocationService.stopUserLocationService;
end;

{ TiOSLocastion.TLocationServiceDelegate }

procedure TiOSLocastion.TLocationServiceDelegate.didFailToLocateUserWithError(
  error: NSError);
begin

end;

procedure TiOSLocastion.TLocationServiceDelegate.didStopLocatingUser;
begin

end;

procedure TiOSLocastion.TLocationServiceDelegate.didUpdateBMKUserLocation(
  userLocation: BMKUserLocation);
begin
  TiOSBaiduMapView(FLocationService.Control.BaiduMapView).FMapView.updateLocationData(userLocation);
end;

procedure TiOSLocastion.TLocationServiceDelegate.didUpdateUserHeading(
  userLocation: BMKUserLocation);
begin

end;

procedure TiOSLocastion.TLocationServiceDelegate.willStartLocatingUser;
begin

end;

end.
