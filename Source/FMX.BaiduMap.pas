//BaiduMap SDK API interface
//Email:371889755@qq.com

unit FMX.BaiduMap;

interface

uses System.Classes, FMX.Controls;

type
  TBaiduMapViewControl = class;
  TBaiduMapViewService = class;

  TBaseBaiduMapService = class abstract
  private
    [weak]FControl: TBaiduMapViewControl;
  protected
    procedure SetControl(const Value: TBaiduMapViewControl); virtual;
  public
    constructor Create; virtual; abstract;
    property Control: TBaiduMapViewControl read FControl write SetControl;
  end;a

  TBaiduMapLocationService = class(TBaseBaiduMapService)
  private
    FLocationViewImgName:string;
    FisRotateAngleValid:Boolean;
  protected
    procedure InitLocation; virtual;  abstract;
    procedure StarLocation; virtual;  abstract;
    procedure StopLocation; virtual;  abstract;
  public
    property LocationViewImgName:string read  FLocationViewImgName write FLocationViewImgName;
    property isRotateAngleValid:Boolean read  FisRotateAngleValid write FisRotateAngleValid;
  end;

  TBaiduMapViewService = class(TBaseBaiduMapService)
  private
    FAppKey:string;
  protected
    procedure SetControl(const Value: TBaiduMapViewControl); override;
    procedure DoShowBaiduMap; virtual;  abstract;
    procedure UpdateBaiduMapFromControl; virtual;  abstract;
    procedure IsShowsUserLocation(Value:Boolean); virtual;  abstract;
  public
    constructor Create(AppKey:String); virtual;
    procedure ShowBaiduMap;
    property AppKey:string read FAppKey;
  end;

  TBaiduMapViewControl = class(TControl)
  private
    FBaiduMapView:TBaiduMapViewService;
    FBaiduMapLocation:TBaiduMapLocationService;
    procedure SetBaiduMapViewService(const Value: TBaiduMapViewService);
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
    procedure InitLocation(LocationViewImgName:string; isRotateAngleValid:Boolean);
    procedure StarLocation;
    procedure StopLocation;
    procedure IsShowsUserLocation(Value:Boolean);
    constructor Create(AOwner: TComponent; AppKey:string);
    destructor Destroy; override;
  published
    property Size;
    property Align;
    property Anchors;
    property Height;
    property Padding;
    property BaiduMapView: TBaiduMapViewService read FBaiduMapView write SeTBaiduMapViewService;
    property Margins;
    property Position;
    property Visible default True;
    property Width;
  end;

implementation
uses
{$IFDEF IOS}
  FMX.BaiduMap.iOS;
{$ENDIF IOS}
{$IFDEF ANDROID}
  FMX.BaiduMap.Android;
{$ENDIF ANDROID}

{ TBaiduMapViewService }

constructor TBaiduMapViewService.Create(AppKey:String);
begin
  FAppKey:=AppKey;
end;

procedure TBaiduMapViewService.SetControl(const Value: TBaiduMapViewControl);
begin
  inherited;
  if Control<>nil then
    UpdateBaiduMapFromControl;
end;

procedure TBaiduMapViewService.ShowBaiduMap;
begin
  DoShowBaiduMap;
end;

{ TBaiduMapViewControl }

procedure TBaiduMapViewControl.AncestorVisibleChanged(const Visible: Boolean);
begin
  inherited;
  UpdateBaiduMapView;
end;

constructor TBaiduMapViewControl.Create(AOwner: TComponent; AppKey:string);
begin
  inherited Create(AOwner);
  {$IFDEF IOS}
    FBaiduMapView:=TiOSBaiduMapView.Create(AppKey);
  {$ENDIF}
  {$IFDEF ANDROID}
    FBaiduMapView:=TAndroidBaiduMapView.Create(AppKey);
  {$ENDIF ANDROID}
  BaiduMapView.SetControl(Self);
end;

destructor TBaiduMapViewControl.Destroy;
begin
  if FBaiduMapView <> nil then
    FBaiduMapView.SetControl(nil);
  FBaiduMapView.Free;
  inherited;
end;

procedure TBaiduMapViewControl.DoAbsoluteChanged;
begin
  inherited;
  UpdateBaiduMapView;
end;

procedure TBaiduMapViewControl.Hide;
begin
  inherited;
  UpdateBaiduMapView;
end;

procedure TBaiduMapViewControl.InitLocation(LocationViewImgName:string; isRotateAngleValid:Boolean);
begin
  if (FBaiduMapLocation = nil) then
  begin
    {$IFDEF IOS}
      FBaiduMapLocation:=TiOSLocastion.Create;
    {$ENDIF}
    {$IFDEF ANDROID}
      FBaiduMapLocation:=TAndroidLocastion.Create;
    {$ENDIF ANDROID}
    FBaiduMapLocation.SetControl(Self);
  end;
  FBaiduMapLocation.LocationViewImgName:=LocationViewImgName;
  FBaiduMapLocation.isRotateAngleValid:=isRotateAngleValid;
  FBaiduMapLocation.InitLocation;
end;

procedure TBaiduMapViewControl.IsShowsUserLocation(Value: Boolean);
begin
  if FBaiduMapView <> nil then
  begin
    FBaiduMapView.IsShowsUserLocation(Value);
  end;
end;

procedure TBaiduMapViewControl.Move;
begin
  inherited;
  UpdateBaiduMapView;
end;

procedure TBaiduMapViewControl.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  {
  if (Operation = opRemove) and (AComponent = FBaiduMapView) then
    BaiduMapView := nil;
  }
end;

procedure TBaiduMapViewControl.Paint;
begin
  inherited;
  if (csDesigning in ComponentState) and not Locked and not FInPaintTo then
    DrawDesignBorder;
end;

procedure TBaiduMapViewControl.ParentChanged;
begin
  inherited;
  UpdateBaiduMapView;
end;

procedure TBaiduMapViewControl.Resize;
begin
  inherited;
  UpdateBaiduMapView;
end;

procedure TBaiduMapViewControl.SeTBaiduMapViewService(const Value: TBaiduMapViewService);
begin
  if FBaiduMapView <> Value then
  begin
    if FBaiduMapView <> nil then
      FBaiduMapView.SetControl(nil);
    FBaiduMapView := Value;
    if FBaiduMapView <> nil then
      FBaiduMapView.SetControl(Self);
  end;
end;

procedure TBaiduMapViewControl.Show;
begin
  inherited;
  UpdateBaiduMapView;
end;

procedure TBaiduMapViewControl.ShowBaiduMap;
begin
  FBaiduMapView.ShowBaiduMap;
end;

procedure TBaiduMapViewControl.StarLocation;
begin
  if FBaiduMapLocation<>nil then
    FBaiduMapLocation.StarLocation;
end;

procedure TBaiduMapViewControl.StopLocation;
begin
  if FBaiduMapLocation<>nil then
    FBaiduMapLocation.StopLocation;
end;

procedure TBaiduMapViewControl.UpdateBaiduMapView;
begin
  if (FBaiduMapView <> nil) then
    FBaiduMapView.UpdateBaiduMapFromControl;
end;

{ TBaseBaiduMapService }

procedure TBaseBaiduMapService.SetControl(const Value: TBaiduMapViewControl);
begin
  if FControl <> Value then
  begin
    FControl := Value;
  end;
end;

end.
