unit BaiduMapAPI.ViewService;
//author:Xubzhlin
//Email:371889755@qq.com

//百度地图API 服务 单元
//官方链接:http://lbsyun.baidu.com/

//TBaiduMapViewService 百度地图 地图服务

interface

uses System.Classes, System.SysUtils, System.Types, FMX.Types, System.UITypes,
   FMX.Platform, FMX.Controls, FMX.Maps, System.Generics.Collections, FMX.Graphics;

type
  //0.0000001 7位小数点
  TBaiduMapMarker = class(TMapMarker)
    Data:Pointer;
  {$IFDEF Android}
    procedure SetZIndex(const Value: Integer); virtual;  abstract;
  {$ENDIF}
  {$IFDEF iOS}
    procedure BringToFront; virtual;  abstract;
  {$ENDIF}
  end;

  TBaiduIndoorMapInfo = class(TObject)
    id:string;
    CurFloor:string;
    Floors:TList<string>;
    constructor Create;
    destructor Destroy; override;
  end;

  TBaiduMapBounds = record  //显示区域4个坐标
    Left:Double;
    Top:Double;
    Rigth:Double;
    Bottom:Double;
    class function Zero: TBaiduMapBounds; inline; static;
  end;

  TMapPoi = record
    Uid:string;
    Name:String;
    Position:TMapCoordinate;
  end;


  TOnBaiduMapClick = procedure(Sender:TObject; Position:TMapCoordinate) of object;
  TOnBaiduMapPoiClick = procedure(Sender:TObject; MapPoi:TMapPoi) of object;
  TOnBaiduMapMarkerClick = procedure(Sender:TObject; Marker:TBaiduMapMarker) of object;

  TOnBaiduMapIndoorMapEvent = procedure(B:Boolean; IndoorMapInfo:TBaiduIndoorMapInfo) of object;

  TBaiduMapView = class;

  IBaiduMapBaseService = interface
    ['{CFB73BF8-5A30-4D2B-AB0D-CC48656E36DA}']
    procedure SetControl(const Value: TBaiduMapView);
    function GetControl:TBaiduMapView;
  end;


  IBaiduMapViewService = interface(IBaiduMapBaseService)
    ['{2C200D6D-DA0B-469B-80A5-888EC1EDA415}']
    procedure ShowBaiduMap;
    procedure UpdateBaiduMapFromControl;
    //通过 增加 Maker
    function AddMarker(const Descriptor: TMapMarkerDescriptor): TBaiduMapMarker;
    //通过 绘制 轨迹
    function AddPolyline(const Descriptor: TMapPolylineDescriptor): TMapPolyline;
    //通过 绘制 轨迹
    function AddPolygon(const Descriptor: TMapPolygonDescriptor): TMapPolygon;
    //通过 绘制 圆形
    function AddCircle(const Descriptor: TMapCircleDescriptor): TMapCircle;
    //设置 地图的中心位置
    procedure SetCenterCoordinate(const Coordinate:TMapCoordinate);
    //设置 当前mapView缩放
    procedure SetZoomLevel(Level:Single);
  end;

  TBaiduMapBaseService = class(TInterfacedObject, IBaiduMapBaseService)
  private
    [weak]FControl: TBaiduMapView;
    procedure SetControl(const Value: TBaiduMapView);
    function GetControl:TBaiduMapView;
    procedure SetVisible(const Value: Boolean);
  protected
    procedure DoSetControl; virtual; abstract;
    procedure DoSetVisible(const Value: Boolean); virtual; abstract;
  public
    procedure DoMapClick(const Posiiton:TMapCoordinate);
    procedure DoMapPoiClick(const MapPoi:TMapPoi);
    procedure DoMarkerClick(const Marker: TBaiduMapMarker);
    procedure DoInDoorEvent(B:Boolean; IndoorMapInfo:TBaiduIndoorMapInfo);
    procedure DoBoundsChanged;
    procedure DoMapLoaded;
    property Control:TBaiduMapView read FControl;
    property Visible:Boolean write SetVisible;
  end;

  TBaiduMapViewService = class;

  TBaiduMapView = class(TControl)
  private
    FOnMapClick:TOnBaiduMapClick;
    FOnMapPoiClick:TOnBaiduMapPoiClick;
    FOnMarkerClick:TOnBaiduMapMarkerClick;
    FOnIndoorMapEvent:TOnBaiduMapIndoorMapEvent;
    FOnBoundsChanged:TNotifyEvent;
    FOnMapLoaded:TNotifyEvent;
    FBaiduMapViewService:TBaiduMapViewService;
    FBaiduMapMaskPadding:TBounds;  //地图蒙版
    FBaiduMapMaskColor:TAlphaColor;//蒙版颜色

    procedure MapMaskPaddingChanged(Sender:TObject);
    procedure UpdateBaiduMapView;

  protected
    procedure AncestorVisibleChanged(const Visible: Boolean); override;
    procedure ParentChanged; override;
    procedure DoAbsoluteChanged; override;
    procedure Move; override;
    procedure Resize; override;
    procedure Paint; override;
    procedure Show; override;
    procedure Hide; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    procedure ShowBaiduMap;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property ViewService: TBaiduMapViewService read FBaiduMapViewService;
    property OnMapClick:TOnBaiduMapClick read FOnMapClick write FOnMapClick;
    property OnMapPoiClick:TOnBaiduMapPoiClick read FOnMapPoiClick write FOnMapPoiClick;
    property OnMarkerClick:TOnBaiduMapMarkerClick read FOnMarkerClick write FOnMarkerClick;
    property OnIndoorMapEvent:TOnBaiduMapIndoorMapEvent read FOnIndoorMapEvent write FOnIndoorMapEvent;
    property OnBoundsChanged:TNotifyEvent read FOnBoundsChanged write FOnBoundsChanged;
    property OnMapLoaded:TNotifyEvent read FOnMapLoaded write FOnMapLoaded;
    property BaiduMapMaskPadding:TBounds read FBaiduMapMaskPadding write FBaiduMapMaskPadding;
    property BaiduMapMaskColor:TAlphaColor read FBaiduMapMaskColor write FBaiduMapMaskColor;
    property Size;
    property Align;
    property Anchors;
    property Height;
    property Padding;
    property Margins;
    property Position;
    property Visible default True;
    property Width;
  end;

  TBaiduMapViewService = class(TBaiduMapBaseService)
  private
    FAppKey:String;
    FScale: Single;
 private
    function GetMapBounds:TBaiduMapBounds;
    function GetSnapBitMap:TBitMap;
  protected
    procedure DoSetControl; override;
    procedure DoShowBaiduMap; virtual;  abstract;
    procedure DoUpdateBaiduMapFromControl; virtual;
    function DoAddMarker(const Descriptor: TMapMarkerDescriptor): TBaiduMapMarker;  virtual;  abstract;
    function DoAddPolyline(const Descriptor: TMapPolylineDescriptor):TMapPolyline; virtual;  abstract;
    function DoAddPolygon(const Descriptor: TMapPolygonDescriptor):TMapPolygon; virtual;  abstract;
    function DoAddCircle(const Descriptor: TMapCircleDescriptor): TMapCircle; virtual;  abstract;
    procedure DoSetCenterCoordinate(const Coordinate:TMapCoordinate); virtual;  abstract;
    procedure DoSetZoomLevel(Level:Single); virtual;  abstract;
    procedure DoSetBaseIndoorMapEnabled(const Value: Boolean); virtual;  abstract;
    procedure DoShowPointsInBounds(Points:TArray<TMapCoordinate>); virtual;  abstract;
    function DoGetMapBounds:TBaiduMapBounds; virtual;  abstract;
    function DoGetSnapBitMap:TBitMap; virtual;  abstract;
  public
    procedure ShowBaiduMap;
    procedure UpdateBaiduMapFromControl;

    function AddMarker(const Descriptor: TMapMarkerDescriptor): TBaiduMapMarker;
    function AddPolyline(const Descriptor: TMapPolylineDescriptor): TMapPolyline;
    function AddPolygon(const Descriptor: TMapPolygonDescriptor):TMapPolygon;
    function AddCircle(const Descriptor: TMapCircleDescriptor): TMapCircle;
    procedure SetCenterCoordinate(const Coordinate:TMapCoordinate);
    procedure SetZoomLevel(Level:Single);
    procedure SetBaseIndoorMapEnabled(const Value: Boolean);
    procedure ShowPointsInBounds(Points:TArray<TMapCoordinate>);

    constructor Create(AKey:String); virtual;
    destructor Destroy; override;

    property AppKey:String read FAppKey;
    property Scale:Single read FScale;
    property Bounds:TBaiduMapBounds read GetMapBounds;
    property SnapBitMap:TBitMap read GetSnapBitMap;
  end;

 
implementation

{$IFDEF IOS}
uses
  BaiduMapAPI.SDKInitializer, BaiduMapAPI.ViewService.iOS;
{$ENDIF}
{$IFDEF ANDROID}
uses
  BaiduMapAPI.SDKInitializer, BaiduMapAPI.ViewService.Android;
{$ENDIF ANDROID}

{ TBaiduMapView }

procedure TBaiduMapView.AncestorVisibleChanged(const Visible: Boolean);
begin
  inherited;
  UpdateBaiduMapView;
end;

constructor TBaiduMapView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FBaiduMapMaskPadding:=TBounds.Create(TRectF.Empty);
  FBaiduMapMaskPadding.OnChange:=MapMaskPaddingChanged;
  FBaiduMapMaskColor := $2B000000;
  {$IFDEF IOS}
    FBaiduMapViewService:=TiOSBaiduMapViewService.Create(TSDKInitializer.AppKey);
  {$ENDIF}
  {$IFDEF ANDROID}
    FBaiduMapViewService:=TAndroidBaiduMapViewService.Create(TSDKInitializer.AppKey);
  {$ENDIF ANDROID}
  if FBaiduMapViewService<>nil then
    FBaiduMapViewService.SetControl(Self);

end;

destructor TBaiduMapView.Destroy;
begin
  if FBaiduMapViewService <> nil then
    FreeAndNil(FBaiduMapViewService);
  FBaiduMapMaskPadding.Free;
  inherited;
end;

procedure TBaiduMapView.DoAbsoluteChanged;
begin
  inherited;
  UpdateBaiduMapView;
end;

procedure TBaiduMapView.Hide;
begin
  inherited;
  UpdateBaiduMapView;
end;

procedure TBaiduMapView.MapMaskPaddingChanged(Sender: TObject);
begin
  if (FBaiduMapViewService <> nil) then
    FBaiduMapViewService.UpdateBaiduMapFromControl;
end;

procedure TBaiduMapView.Move;
begin
  inherited;
  UpdateBaiduMapView;
end;

procedure TBaiduMapView.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  {
  if (Operation = opRemove) and (AComponent = FBaiduMapView) then
    BaiduMapView := nil;
  }
end;

procedure TBaiduMapView.Paint;
begin
  inherited;
  if (csDesigning in ComponentState) and not Locked and not FInPaintTo then
    DrawDesignBorder;
end;

procedure TBaiduMapView.ParentChanged;
begin
  inherited;
  UpdateBaiduMapView;
end;

procedure TBaiduMapView.Resize;
begin
  inherited;
  UpdateBaiduMapView;
end;


procedure TBaiduMapView.Show;
begin
  inherited;
  UpdateBaiduMapView;
end;

procedure TBaiduMapView.ShowBaiduMap;
begin
  FBaiduMapViewService.ShowBaiduMap;
end;

procedure TBaiduMapView.UpdateBaiduMapView;
begin
  if (FBaiduMapViewService <> nil) then
    FBaiduMapViewService.UpdateBaiduMapFromControl;
end;


{ TBaiduMapBaseService }

procedure TBaiduMapBaseService.DoBoundsChanged;
begin
  //地图区域变化
  if (Control<>nil) and Assigned(Control.OnBoundsChanged) then
  begin
    Control.OnBoundsChanged(Self);
  end;
end;

procedure TBaiduMapBaseService.DoInDoorEvent(B: Boolean;
  IndoorMapInfo: TBaiduIndoorMapInfo);
begin
  if (Control<>nil) and Assigned(Control.OnIndoorMapEvent) then
  begin
    Control.OnIndoorMapEvent(B, IndoorMapInfo);
  end;
end;

procedure TBaiduMapBaseService.DoMapClick(const Posiiton: TMapCoordinate);
begin
  if (Control<>nil) and Assigned(Control.OnMapClick) then
  begin
    Control.OnMapClick(Self, Posiiton);
  end;
end;

procedure TBaiduMapBaseService.DoMapLoaded;
begin
  //地图加载完毕
  if (Control<>nil) and Assigned(Control.OnMapLoaded) then
  begin
    Control.OnMapLoaded(Self);
  end;
end;

procedure TBaiduMapBaseService.DoMapPoiClick(const MapPoi: TMapPoi);
begin
  if (Control<>nil) and Assigned(Control.OnMapPoiClick)then
  begin
    Control.OnMapPoiClick(Self, MapPoi);
  end;
end;

procedure TBaiduMapBaseService.DoMarkerClick(const Marker: TBaiduMapMarker);
begin
  if (Control<>nil) and Assigned(Control.OnMarkerClick) then
  begin
    Control.OnMarkerClick(Self, Marker);
  end;
end;

function TBaiduMapBaseService.GetControl: TBaiduMapView;
begin
  Result:=FControl;
end;

procedure TBaiduMapBaseService.SetControl(const Value: TBaiduMapView);
begin
  FControl:=Value;
  DoSetControl;
end;

procedure TBaiduMapBaseService.SetVisible(const Value: Boolean);
begin
  DoSetVisible(Value);
end;

{ TBaiduMapViewService }

function TBaiduMapViewService.AddCircle(
  const Descriptor: TMapCircleDescriptor): TMapCircle;
begin
  Result:=DoAddCircle(Descriptor);
end;

function TBaiduMapViewService.AddMarker(
  const Descriptor: TMapMarkerDescriptor): TBaiduMapMarker;
begin
  Result:=DoAddMarker(Descriptor);
end;

function TBaiduMapViewService.AddPolygon(
  const Descriptor: TMapPolygonDescriptor): TMapPolygon;
begin
  Result:=DoAddPolygon(Descriptor);
end;

function TBaiduMapViewService.AddPolyline(
  const Descriptor: TMapPolylineDescriptor): TMapPolyline;
begin
  Result:=DoAddPolyline(Descriptor);
end;

constructor TBaiduMapViewService.Create(AKey: String);
var
  ScreenSrv:IFMXScreenService;
begin
  inherited Create;
  FAppKey:=AKey;

  if TPlatformServices.Current.SupportsPlatformService(IFMXScreenService,
    ScreenSrv) then
    FScale := ScreenSrv.GetScreenScale
  else
    FScale := 1;
end;

destructor TBaiduMapViewService.Destroy;
begin
  inherited;
end;

procedure TBaiduMapViewService.DoSetControl;
begin
  if FControl<>nil then
    UpdateBaiduMapFromControl;
end;

procedure TBaiduMapViewService.DoUpdateBaiduMapFromControl;
begin

end;

function TBaiduMapViewService.GetMapBounds: TBaiduMapBounds;
begin
  Result:=DoGetMapBounds;
end;

function TBaiduMapViewService.GetSnapBitMap: TBitMap;
begin
  Result:=DoGetSnapBitMap;
end;

procedure TBaiduMapViewService.ShowBaiduMap;
begin
  DoShowBaiduMap;
end;


procedure TBaiduMapViewService.ShowPointsInBounds(
  Points: TArray<TMapCoordinate>);
begin
  DoShowPointsInBounds(Points);
end;

procedure TBaiduMapViewService.UpdateBaiduMapFromControl;
begin
  DoUpdateBaiduMapFromControl;
end;

procedure TBaiduMapViewService.SetBaseIndoorMapEnabled(const Value: Boolean);
begin
  DoSetBaseIndoorMapEnabled(Value);
end;

procedure TBaiduMapViewService.SetCenterCoordinate(
  const Coordinate: TMapCoordinate);
begin
  DoSetCenterCoordinate(Coordinate);
end;

procedure TBaiduMapViewService.SetZoomLevel(Level: Single);
begin
  DoSetZoomLevel(Level);
end;


{ TIndoorMapInfo }

constructor TBaiduIndoorMapInfo.Create;
begin
  id:='';
  CurFloor:='';
  Floors:=TList<string>.Create;
end;

destructor TBaiduIndoorMapInfo.Destroy;
begin
  Floors.Free;
  inherited;
end;

{ TBaiduMapBounds }

class function TBaiduMapBounds.Zero: TBaiduMapBounds;
begin
  Result.Left:=0;
  Result.Top:=0;
  Result.Rigth:=0;
  Result.Bottom:=0;
end;

end.
