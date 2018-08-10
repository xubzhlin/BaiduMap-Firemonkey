unit BaiduMapAPI.ViewService.iOS;
//author:Xubzhlin
//Email:371889755@qq.com

//百度地图API 地图服务 单元
//官方链接:http://lbsyun.baidu.com/
//TiOSBaiduMapViewService 百度地图 iOS地图服务

interface

uses
  System.Classes,  System.Generics.Collections, FMX.Maps, Macapi.ObjectiveC, FMX.Graphics,
  Macapi.ObjCRuntime, iOSapi.CoreLocation, iOSapi.Foundation, FMX.ZOrder.iOS, iOSapi.UIKit,
  iOSapi.CoreGraphics, iOSapi.CocoaTypes, iOSapi.BaiduMapAPI_Base, iOSapi.BaiduMapAPI_Map, BaiduMapAPI.ViewService;

type
  TiOSBaiduMapViewService = class;

  TBMKMapViewDelegate = class(TOCLocal, BMKMapViewDelegate)
  private
    [Weak] FViewService: TiOSBaiduMapViewService;
  public
    constructor Create(const ViewService: TiOSBaiduMapViewService);

    procedure mapViewDidFinishLoading(mapView: BMKMapView); cdecl;
    procedure mapViewDidFinishRendering(mapView: BMKMapView); cdecl;
    [MethodName('mapView:onDrawMapFrame:')]
    procedure mapViewOnDrawMapFrame(mapView: BMKMapView; onDrawMapFrame: BMKMapStatus); cdecl;
    [MethodName('mapView:regionWillChangeAnimated:')]
    procedure mapViewRegionWillChangeAnimated(mapView: BMKMapView; regionWillChangeAnimated: Boolean); cdecl;
    [MethodName('mapView:regionDidChangeAnimated:')]
    procedure mapViewRegionDidChangeAnimated(mapView: BMKMapView; regionDidChangeAnimated: Boolean); cdecl;
    [MethodName('mapView:viewForAnnotation:')]
    function mapViewViewForAnnotation(mapView: BMKMapView; viewForAnnotation: Pointer): BMKAnnotationView; cdecl;
    [MethodName('mapView:didAddAnnotationViews:')]
    procedure mapViewDidAddAnnotationViews(mapView: BMKMapView; didAddAnnotationViews: NSArray); cdecl;
    [MethodName('mapView:didSelectAnnotationView:')]
    procedure mapViewDidSelectAnnotationView(mapView: BMKMapView; didSelectAnnotationView: BMKAnnotationView); cdecl;
    [MethodName('mapView:didDeselectAnnotationView:')]
    procedure mapViewDidDeselectAnnotationView(mapView: BMKMapView; didDeselectAnnotationView: BMKAnnotationView); cdecl;
    [MethodName('mapView:annotationView:didChangeDragState:fromOldState:')]
    procedure mapViewAnnotationViewDidChangeDragStateFromOldState
      (mapView: BMKMapView; annotationView: BMKAnnotationView;
      didChangeDragState: BMKAnnotationViewDragState;
      fromOldState: BMKAnnotationViewDragState); cdecl;
    [MethodName('mapView:annotationViewForBubble:')]
    procedure mapViewAnnotationViewForBubble(mapView: BMKMapView;
      annotationViewForBubble: BMKAnnotationView); cdecl;
    [MethodName('mapView:viewForOverlay:')]
    function mapViewViewForOverlay(mapView: BMKMapView; viewForOverlay: Pointer) : BMKOverlayView; cdecl;
    [MethodName('mapView:didAddOverlayViews:')]
    procedure mapViewDidAddOverlayViews(mapView: BMKMapView;
      didAddOverlayViews: NSArray); cdecl;
    [MethodName('mapView:onClickedBMKOverlayView:')]
    procedure mapViewOnClickedBMKOverlayView(mapView: BMKMapView;
      onClickedBMKOverlayView: BMKOverlayView); cdecl;
    [MethodName('mapView:onClickedMapPoi:')]
    procedure mapViewOnClickedMapPoi(mapView: BMKMapView;
      onClickedMapPoi: BMKMapPoi); cdecl;
    [MethodName('mapView:onClickedMapBlank:')]
    procedure mapViewOnClickedMapBlank(mapView: BMKMapView;
      onClickedMapBlank: CLLocationCoordinate2D); cdecl;
    [MethodName('mapview:onDoubleClick:')]
    procedure mapviewOnDoubleClick(mapView: BMKMapView;
      onDoubleClick: CLLocationCoordinate2D); cdecl;
    [MethodName('mapview:onLongClick:')]
    procedure mapviewOnLongClick(mapView: BMKMapView;
      onLongClick: CLLocationCoordinate2D); cdecl;
    [MethodName('mapview:onForceTouch:force:maximumPossibleForce:')
      ]
    procedure mapviewOnForceTouchForceMaximumPossibleForce(mapView: BMKMapView;
      onForceTouch: CLLocationCoordinate2D; force: CGFloat;
      maximumPossibleForce: CGFloat); cdecl;
    procedure mapStatusDidChanged(mapView: BMKMapView); cdecl;
    [MethodName('mapview:baseIndoorMapWithIn:baseIndoorMapInfo:')
      ]
    procedure mapviewBaseIndoorMapWithInBaseIndoorMapInfo(mapView: BMKMapView;
      baseIndoorMapWithIn: Boolean;
      baseIndoorMapInfo: BMKBaseIndoorMapInfo); cdecl;
  end;

  TiOSBaiduMapViewService = class(TBaiduMapViewService)
  private
    FMapView:BMKMapView;
    FMapViewDelegate:TBMKMapViewDelegate;


    FMapObjects:TDictionary<Pointer, TMapObjectBase>;

    FLeftView:UIView;
    FTopView:UIView;
    FRightView:UIView;
    FBottomView:UIView;

    procedure InitInstance;
    procedure RealignView;
    procedure RealignImageView;

    function GetMapObject<T: TMapObjectBase>(const Key: Pointer): T;
    procedure PutMapObject<T: TMapObjectBase>(const Key: Pointer; const MapObject: T);
    procedure RemoveMapObject(const Key: Pointer);
  protected
    procedure DoShowBaiduMap; override;
    procedure DoUpdateBaiduMapFromControl; override;
    procedure DoSetVisible(const Value: Boolean); override;
    function DoAddMarker(const Descriptor: TMapMarkerDescriptor):TBaiduMapMarker;  override;
    function DoAddPolyline(const Descriptor: TMapPolylineDescriptor):TMapPolyline;  override;
    function DoAddPolygon(const Descriptor: TMapPolygonDescriptor):TMapPolygon;  override;
    function DoAddCircle(const Descriptor: TMapCircleDescriptor): TMapCircle; override;
    procedure DoSetCenterCoordinate(const Coordinate:TMapCoordinate); override;
    procedure DoSetZoomLevel(Level:Single); override;
    procedure DoSetBaseIndoorMapEnabled(const Value: Boolean); override;
    procedure DoShowPointsInBounds(Points:TArray<TMapCoordinate>); override;
    function DoGetMapBounds:TBaiduMapBounds; override;
    function DoGetSnapBitMap:TBitMap; override;
  public
    constructor Create(AKey:String); override;
    destructor Destroy; override;
    property MapView: BMKMapView read FMapView;
  end;

implementation

uses System.SysUtils, FMX.Forms, FMX.Controls, System.Types, FMX.Platform.iOS,
  FMX.Helpers.iOS, Macapi.Helpers, FMX.Surfaces, System.Math;

type
  TiOSBMKMarker = class(TBaiduMapMarker)
  private
    FAnnotation: BMKPointAnnotation;
    FVisible: Boolean;
    [Weak] FViewService: TiOSBaiduMapViewService;
    FAnnotationView: BMKAnnotationView;
  public
    constructor Create(const Descriptor: TMapMarkerDescriptor; const ViewService: TiOSBaiduMapViewService); reintroduce;
    function Id: Pointer;
    destructor Destroy; override;
    procedure Remove; override;
    procedure SetVisible(const Value: Boolean); override;
    procedure BringToFront; override;
    function AnnotationView: BMKAnnotationView;
  end;

  TiOSBMKPolyline = class(TMapPolyline)
  private
    FPolyline: BMKPolyline;
    FVisible: Boolean;
    [Weak] FViewService: TiOSBaiduMapViewService;
  public
    constructor Create(const Descriptor: TMapPolylineDescriptor; const ViewService: TiOSBaiduMapViewService); reintroduce;
    destructor Destroy; override;
    function Id: Pointer;
    procedure Remove; override;
    procedure SetVisible(const Value: Boolean); override;
    function ToString: string; override;
    function PolylineView:BMKPolylineView;
  end;

  TiOSBMKPolygon = class(TMapPolygon)
  private
    FPolygon: BMKPolygon;
    FVisible: Boolean;
    [Weak] FViewService: TiOSBaiduMapViewService;
  public
    constructor Create(const Descriptor: TMapPolygonDescriptor; const ViewService: TiOSBaiduMapViewService); reintroduce;
    destructor Destroy; override;
    function Id: Pointer;
    procedure Remove; override;
    procedure SetVisible(const Value: Boolean); override;
    function PolygonView:BMKPolygonView;
  end;

  TiOSBMKCircle = class(TMapCircle)
  private
    FCircle: BMKCircle;
    FVisible: Boolean;
    [Weak] FViewService: TiOSBaiduMapViewService;
  public
    constructor Create(const Descriptor: TMapCircleDescriptor; const ViewService: TiOSBaiduMapViewService); reintroduce;
    destructor Destroy; override;
    function Id: Pointer;
    procedure Remove; override;
    procedure SetVisible(const Value: Boolean); override;
    function CircleView: BMKCircleView;
  end;

procedure StateSwitch(var State: Boolean; const NewValue: Boolean; SetProc: TProc; ResetProc: TProc);
var
  OldState: Boolean;
begin
  OldState := State;
  State := NewValue;
  if NewValue and not OldState then
    SetProc
  else if not NewValue and OldState then
    ResetProc;
end;

{ TiOSBaiduMapViewService }

constructor TiOSBaiduMapViewService.Create(AKey: String);
begin
  inherited Create(AKey);
  FMapObjects:= TDictionary<Pointer, TMapObjectBase>.Create;
end;

destructor TiOSBaiduMapViewService.Destroy;
var
  Form:TCommonCustomForm;
  ZOrderManager:TiOSZOrderManager;
begin
  if (Control<>nil) and (Control.Root is TCommonCustomForm) then
  begin
    Form := TCommonCustomForm(Control.Root);
  {$IFDEF IOS}
    ZOrderManager := WindowHandleToPlatform(Form.Handle).ZOrderManager;
    if (ZOrderManager <> nil) and (Control <> nil) then
    begin
      ZOrderManager.UpdateOrderAndBounds(Control, FMapView);
      ZOrderManager.RemoveLink(Control);
    end;
  {$ENDIF}
  end;
  FLeftView:=nil;
  FTopView:=nil;
  FRightView:=nil;
  FBottomView:=nil;
  FMapView.setDelegate(nil);
  FMapView.removeFromSuperview;
  FMapView:=nil;
  FMapObjects.DisposeOf;
  inherited;
end;

function TiOSBaiduMapViewService.DoAddCircle(
  const Descriptor: TMapCircleDescriptor): TMapCircle;
begin
  Result := TiOSBMKCircle.Create(Descriptor, Self);
  PutMapObject<TMapCircle>(TiOSBMKCircle(Result).Id, Result);
  Result.SetVisible(True);
end;

function TiOSBaiduMapViewService.DoAddMarker(
  const Descriptor: TMapMarkerDescriptor): TBaiduMapMarker;
begin
  Result := TiOSBMKMarker.Create(Descriptor, Self);
  PutMapObject<TBaiduMapMarker>(TiOSBMKMarker(Result).Id, Result);
  Result.SetVisible(True);
end;

function TiOSBaiduMapViewService.DoAddPolygon(
  const Descriptor: TMapPolygonDescriptor): TMapPolygon;
begin
  Result := TiOSBMKPolygon.Create(Descriptor, Self);
  PutMapObject<TMapPolygon>(TiOSBMKPolygon(Result).Id, Result);
  Result.SetVisible(True);
end;

function TiOSBaiduMapViewService.DoAddPolyline(
  const Descriptor: TMapPolylineDescriptor): TMapPolyline;
begin
  Result := TiOSBMKPolyline.Create(Descriptor, Self);
  PutMapObject<TMapPolyline>(TiOSBMKPolyline(Result).Id, Result);
  Result.SetVisible(True);
end;


function TiOSBaiduMapViewService.DoGetMapBounds: TBaiduMapBounds;
var
  CenterCoordinate:CLLocationCoordinate2D;
  Delta:CLLocationCoordinate2D;
begin
  Result:=TBaiduMapBounds.Zero;
  if FMapView<>nil then
  begin
    //当前屏幕中心点的经纬度
    CenterCoordinate := FMapView.region.center;

    //当前屏幕显示范围的经纬度
    Delta.longitude := FMapView.region.span.longitudeDelta;
    Delta.latitude := FMapView.region.span.latitudeDelta;

    //计算四角坐标
    Result.Left:=CenterCoordinate.latitude - Delta.latitude/2.0;
    Result.Top:=CenterCoordinate.longitude - Delta.longitude/2.0;
    Result.Rigth:= CenterCoordinate.latitude + Delta.latitude/2.0;
    Result.Bottom:= CenterCoordinate.longitude + Delta.longitude/2.0;
  end;
end;

function TiOSBaiduMapViewService.DoGetSnapBitMap: TBitMap;
var
  Image:UIImage;
begin
  Image := FMapView.takeSnapshot;
  Result := UIImageToBitmap(Image, 0, TSize.Create(trunc(Image.size.width), trunc(Image.size.height)));
end;

procedure TiOSBaiduMapViewService.DoShowBaiduMap;
begin
  InitInstance;

end;

procedure TiOSBaiduMapViewService.DoShowPointsInBounds(
  Points: TArray<TMapCoordinate>);
var
  MaxCoordinate, MinCoordinate, CenterCoordinate, Point:TMapCoordinate;
  Span:BMKCoordinateSpan;
  Region:BMKCoordinateRegion;
  FitRect:CGRect;
  R:TRectF;
begin
  if Length(Points) = 0 then  Exit;
  //计算 点里面的 最大值 最小值 中间点
  FMapView.showAnnotations(FMapView.annotations, True);

  MaxCoordinate:=TMapCoordinate.Create(0, 0);
  MinCoordinate:=TMapCoordinate.Create(MaxDouble, MaxDouble);
  for Point in Points do
  begin
    MaxCoordinate.Latitude:=Max(MaxCoordinate.Latitude, Point.Latitude);
    MaxCoordinate.Longitude:=Max(MaxCoordinate.Longitude, Point.Longitude);

    MinCoordinate.Latitude:=Min(MinCoordinate.Latitude, Point.Latitude);
    MinCoordinate.Longitude:=Min(MinCoordinate.Longitude, Point.Longitude);
  end;

  CenterCoordinate.Latitude:= (MaxCoordinate.Latitude + MinCoordinate.Latitude) / 2;
  CenterCoordinate.Longitude:= (MaxCoordinate.Longitude + MinCoordinate.Longitude) / 2;

  Span.latitudeDelta:=(MaxCoordinate.Latitude - MinCoordinate.Latitude)*1.5;
  Span.longitudeDelta:=(MaxCoordinate.Longitude - MinCoordinate.Longitude)*1.5;
  Region.center:=CLLocationCoordinate2D(CenterCoordinate);
  Region.span:=Span;

  FMapView.setRegionAnimated(Region, True);
end;

procedure TiOSBaiduMapViewService.InitInstance;
begin

  FMapView:=TBMKMapView.Wrap(TBMKMapView.Alloc.init);
  FMapView.SetMapType(BMKMapTypeStandard);
  //FMapView.setUserTrackingMode(BMKUserTrackingModeFollow);
  FMapView.setHidden(False);
  FMapViewDelegate:=TBMKMapViewDelegate.Create(Self);
  FMapView.setDelegate(FMapViewDelegate.GetObjectID);
  //FMapView.retain;
  //SharedApplication.keyWindow.rootViewController.View.addSubview(FMapView);
  RealignView;
end;

procedure TiOSBaiduMapViewService.PutMapObject<T>(const Key: Pointer;
  const MapObject: T);
var
  MObject: TMapObjectBase;
begin
  if FMapObjects.TryGetValue(Key, MObject) then
    FMapObjects[Key] := MapObject
  else
    FMapObjects.Add(Key, MapObject);
end;

procedure TiOSBaiduMapViewService.RealignImageView;
var
  Form: TCommonCustomForm;
  View:UIView;
  Bounds:TRectF;
  ARect:TRectF;
begin
  if FMapView<>nil then
  begin
    //Left
    Bounds := TRectF.Create(0, 0, Control.BaiduMapMaskPadding.Left, Control.Height);
    if (Control.BaiduMapMaskPadding.Left <> 0) and (FLeftView = nil) then
    begin
      FLeftView:=TUIView.Wrap(TUIView.Wrap(TUIView.OCClass.alloc).initWithFrame(CGRectFromRect(Bounds)));
      FLeftView.setUserInteractionEnabled(False);
      FLeftView.layer.setBackgroundColor(AlphaColorToUIColor(Control.BaiduMapMaskColor).CGColor);
      FMapView.addSubview(FLeftView);
    end
    else
    begin
      if FLeftView<>nil then
        FLeftView.setFrame(CGRectFromRect(Bounds));
    end;

    //Right
    Bounds := TRectF.Create(Control.Width - Control.BaiduMapMaskPadding.Right, 0, Control.Width, Control.Height);
    if (Control.BaiduMapMaskPadding.Right <> 0) and (FRightView = nil) then
    begin
      FRightView:=TUIView.Wrap(TUIView.Wrap(TUIView.OCClass.alloc).initWithFrame(CGRectFromRect(Bounds)));
      FRightView.setUserInteractionEnabled(False);
      FRightView.layer.setBackgroundColor(AlphaColorToUIColor(Control.BaiduMapMaskColor).CGColor);
      FMapView.addSubview(FRightView);
    end
    else
    begin
      if FRightView<>nil then
        FRightView.setFrame(CGRectFromRect(Bounds));
    end;

    //Top
    Bounds := TRectF.Create(Control.BaiduMapMaskPadding.Left, 0, Control.Width - Control.BaiduMapMaskPadding.Right, Control.BaiduMapMaskPadding.Top);
    if (Control.BaiduMapMaskPadding.Top <> 0) and (FTopView = nil) then
    begin
      FTopView:=TUIView.Wrap(TUIView.Wrap(TUIView.OCClass.alloc).initWithFrame(CGRectFromRect(Bounds)));
      FTopView.setUserInteractionEnabled(False);
      FTopView.layer.setBackgroundColor(AlphaColorToUIColor(Control.BaiduMapMaskColor).CGColor);
      FMapView.addSubview(FTopView);
    end
    else
    begin
      if FTopView<>nil then
        FTopView.setFrame(CGRectFromRect(Bounds));
    end;

    //Bottom
    Bounds := TRectF.Create(Control.BaiduMapMaskPadding.Left , Control.Height - Control.BaiduMapMaskPadding.Bottom,
      Control.Width - Control.BaiduMapMaskPadding.Right, Control.Height);
    if (Control.BaiduMapMaskPadding.Bottom <> 0) and (FBottomView = nil) then
    begin
      FBottomView:=TUIView.Wrap(TUIView.Wrap(TUIView.OCClass.alloc).initWithFrame(CGRectFromRect(Bounds)));
      FBottomView.setUserInteractionEnabled(False);
      FBottomView.layer.setBackgroundColor(AlphaColorToUIColor(Control.BaiduMapMaskColor).CGColor);
      FMapView.addSubview(FBottomView);
    end
    else
    begin
      if FBottomView<>nil then
        FBottomView.setFrame(CGRectFromRect(Bounds));
    end;
  end;
end;

procedure TiOSBaiduMapViewService.RealignView;
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
      Bounds := TRectF.Create(0,0,Control.Width,Control.Height);
      Bounds.Fit(Control.AbsoluteRect);
      View := WindowHandleToPlatform(Form.Handle).View;
      View.addSubview(FMapView);
      if SameValue(Bounds.Width, 0) or SameValue(Bounds.Height, 0) then
        FWebView.setHidden(True)
      else
      begin
        TNativeWebViewHelper.SetBounds(FMapView, Bounds, View.bounds.size.height);
        FMapView.setHidden(not FWebControl.ParentedVisible);
      end;
      {$ENDIF}

      RealignImageView;
    end
    else
      FMapView.setHidden(True);
  end;

end;

procedure TiOSBaiduMapViewService.RemoveMapObject(const Key: Pointer);
begin
  FMapObjects.Remove(Key);
end;

procedure TiOSBaiduMapViewService.DoUpdateBaiduMapFromControl;
begin
  RealignView;
end;

function TiOSBaiduMapViewService.GetMapObject<T>(const Key: Pointer): T;
var
  TmpResult: TMapObjectBase;
begin
  if FMapObjects.TryGetValue(Key, TmpResult) then
    try
      Result := TmpResult as T;
    except
      on EInvalidCast do
        Result := nil;
    end;

end;

procedure TiOSBaiduMapViewService.DoSetBaseIndoorMapEnabled(
  const Value: Boolean);
begin
  if FMapView<>nil then
  begin
    FMapView.setBaseIndoorMapEnabled(Value);
  end;

end;

procedure TiOSBaiduMapViewService.DoSetCenterCoordinate(
  const Coordinate: TMapCoordinate);
var
  Coordinate2D:CLLocationCoordinate2D;
begin
  if FMapView<>nil then
  begin
    FMapView.setCenterCoordinate(CLLocationCoordinate2D(Coordinate));
  end;
end;

procedure TiOSBaiduMapViewService.DoSetVisible(const Value: Boolean);
begin

end;

procedure TiOSBaiduMapViewService.DoSetZoomLevel(Level: Single);
begin
  if FMapView<>nil then
  begin
    FMapView.setZoomLevel(Level);
  end;

end;

{ TiOSBMKMaker }

function TiOSBMKMarker.AnnotationView: BMKAnnotationView;
var
  Pin: BMKPinAnnotationView;
  Image: UIImage;
begin
  if FAnnotationView <> nil then
    Exit(FAnnotationView);

  if Descriptor.Icon <> nil then
  begin
    Result := TBMKAnnotationView.Wrap(TBMKAnnotationView.Alloc.initWithAnnotation(Id,
      nil));
    Image := BitmapToUIImage(Descriptor.Icon);
    Result.setImage(Image);
    Result.setUserInteractionEnabled(True);
    Result.setDraggable(Descriptor.Draggable);
    Result.setCanShowCallout(False);
    Result.setCenterOffset(CGPointMake(Image.size.width * (Descriptor.Origin.X - 0.5),
      - Image.size.height * (Descriptor.Origin.Y - 0.5)));
  end
  else
  begin
    Pin := TBMKPinAnnotationView.Wrap(TBMKPinAnnotationView.Alloc.initWithAnnotation(Id,
      nil));
    Pin.setUserInteractionEnabled(True);
    Pin.setDraggable(Descriptor.Draggable);
    Pin.setCanShowCallout(False);
    Pin.setCenterOffset(CGPointMake(Image.size.width * (Descriptor.Origin.X - 0.5),
      - Image.size.height * (Descriptor.Origin.Y - 0.5)));
    Result := Pin;
  end;
  FAnnotationView := Result;
end;

procedure TiOSBMKMarker.BringToFront;
begin
  //删除了再添加 就会置顶
  SetVisible(False);
  SetVisible(True);
end;

constructor TiOSBMKMarker.Create(const Descriptor: TMapMarkerDescriptor;
  const ViewService: TiOSBaiduMapViewService);
begin
  inherited Create(Descriptor);
  FViewService := ViewService;
  FAnnotation := TBMKPointAnnotation.Wrap(TBMKPointAnnotation.Alloc.init);
  FAnnotation.setCoordinate(CLLocationCoordinate2D(Descriptor.Position));
  FAnnotation.setTitle(StrToNSStr(Descriptor.Title));
  FAnnotation.setSubtitle(StrToNSStr(Descriptor.Snippet));

end;

destructor TiOSBMKMarker.Destroy;
begin
  Remove;
  if Descriptor.Icon <> nil  then
    Descriptor.Icon.Free;
  inherited;
end;

function TiOSBMKMarker.Id: Pointer;
begin
  Result := (FAnnotation as ILocalObject).GetObjectId;
end;

procedure TiOSBMKMarker.Remove;
begin
  if FAnnotation <> nil then
  begin
    SetVisible(False);
    FViewService.RemoveMapObject(Id);
    FViewService.MapView.removeAnnotation(Id);
    if FAnnotationView <> nil then
    begin
      FAnnotationView.prepareForReuse;
      FAnnotationView.release;
    end;
    FAnnotation.release;
    FAnnotation := nil;
  end;
end;

procedure TiOSBMKMarker.SetVisible(const Value: Boolean);
begin
  StateSwitch(FVisible, Value,
    procedure begin
      if FViewService <> nil then
        FViewService.MapView.addAnnotation((FAnnotation as ILocalObject).GetObjectID);
    end,
    procedure begin
      // MKView can be nil when TMapView is being destroyed
      if FViewService <> nil then
        FViewService.MapView.removeAnnotation((FAnnotation as ILocalObject).GetObjectID);
    end);
end;

{ TBMKPolyline }

constructor TiOSBMKPolyline.Create(const Descriptor: TMapPolylineDescriptor;
  const ViewService: TiOSBaiduMapViewService);
var
  i:integer;
  P:Pointer;
begin
  inherited Create(Descriptor);
  FViewService := ViewService;
  FPolyline:=TBMKPolyline.OCClass.polylineWithCoordinatesCount(Descriptor.Points.Points, Length(Descriptor.Points.Points));
end;

destructor TiOSBMKPolyline.Destroy;
begin
  Remove;
  FPolyline.release;
  FPolyline := nil;
  inherited;
end;

function TiOSBMKPolyline.Id: Pointer;
begin
  Result := (FPolyline as ILocalObject).GetObjectID;
end;

procedure TiOSBMKPolyline.Remove;
begin
  inherited;
  SetVisible(False);
end;

procedure TiOSBMKPolyline.SetVisible(const Value: Boolean);
begin
  inherited;
  StateSwitch(FVisible, Value,
    procedure begin
      FViewService.MapView.addOverlay((FPolyline as ILocalObject).GetObjectID)
    end,
    procedure begin
      FViewService.MapView.removeOverlay((FPolyline as ILocalObject).GetObjectID);
    end);
end;

function TiOSBMKPolyline.ToString: string;
begin

end;

function TiOSBMKPolyline.PolylineView: BMKPolylineView;
begin
  Result := TBMKPolylineView.Wrap(TBMKPolylineView.Alloc.initWithPolyline(FPolyline));
  Result.setFillColor(AlphaColorToUIColor(Descriptor.StrokeColor));
  Result.setStrokeColor(AlphaColorToUIColor(Descriptor.StrokeColor));
  Result.setLineWidth(Descriptor.StrokeWidth / FViewService.Scale);
end;

{ TBMKMapViewDelegate }

constructor TBMKMapViewDelegate.Create(
  const ViewService: TiOSBaiduMapViewService);
begin
  inherited Create;
  FViewService:=ViewService;
end;

procedure TBMKMapViewDelegate.mapStatusDidChanged(mapView: BMKMapView);
begin
  //状态变化的时候触发
end;

procedure TBMKMapViewDelegate.mapViewAnnotationViewDidChangeDragStateFromOldState(
  mapView: BMKMapView; annotationView: BMKAnnotationView; didChangeDragState,
  fromOldState: BMKAnnotationViewDragState);
begin
  //拖动 状态变化
  //  BMKAnnotationViewDragStateNone = 0;
  //  BMKAnnotationViewDragStateStarting = 1;
  //  BMKAnnotationViewDragStateDragging = 2;
  //  BMKAnnotationViewDragStateCanceling = 3;
  //  BMKAnnotationViewDragStateEnding = 4;
  if (fromOldState = BMKAnnotationViewDragStateNone) and (didChangeDragState = BMKAnnotationViewDragStateStarting) then
  begin
    //开始拖动
  end else
  if (fromOldState = BMKAnnotationViewDragStateCanceling) and (didChangeDragState = BMKAnnotationViewDragStateCanceling) then
  begin
    //取消拖动
  end else
  if (fromOldState = BMKAnnotationViewDragStateCanceling) and (didChangeDragState = BMKAnnotationViewDragStateEnding) then
  begin
    //拖动结束
  end else
  begin
    //拖动
  end;

end;

procedure TBMKMapViewDelegate.mapViewAnnotationViewForBubble(
  mapView: BMKMapView; annotationViewForBubble: BMKAnnotationView);
begin
end;

procedure TBMKMapViewDelegate.mapviewBaseIndoorMapWithInBaseIndoorMapInfo(
  mapView: BMKMapView; baseIndoorMapWithIn: Boolean;
  baseIndoorMapInfo: BMKBaseIndoorMapInfo);
var
  i:Integer;
  MapInfo:TBaiduIndoorMapInfo;
begin
  if (FViewService<>nil) and (baseIndoorMapInfo<>nil) then
  begin
    MapInfo:=TBaiduIndoorMapInfo.Create;
    MapInfo.id:=NSStrToStr(baseIndoorMapInfo.strID);
    MapInfo.CurFloor:=NSStrToStr(baseIndoorMapInfo.strFloor);
    for i := 0 to baseIndoorMapInfo.arrStrFloors.count -1 do
    begin
      MapInfo.Floors.Add(NSStrToStr(TNSString.Wrap(baseIndoorMapInfo.arrStrFloors.objectAtIndex(i))));
    end;
    FViewService.DoInDoorEvent(baseIndoorMapWithIn, MapInfo);
    MapInfo.Free;
  end;
end;

procedure TBMKMapViewDelegate.mapViewDidAddAnnotationViews(mapView: BMKMapView;
  didAddAnnotationViews: NSArray);
begin

end;

procedure TBMKMapViewDelegate.mapViewDidAddOverlayViews(mapView: BMKMapView;
  didAddOverlayViews: NSArray);
begin

end;

procedure TBMKMapViewDelegate.mapViewDidDeselectAnnotationView(
  mapView: BMKMapView; didDeselectAnnotationView: BMKAnnotationView);
begin

end;

procedure TBMKMapViewDelegate.mapViewDidFinishLoading(mapView: BMKMapView);
begin
  //地图加载完成
  if FViewService<>nil then
  begin
    FViewService.DoMapLoaded;
  end;
end;

procedure TBMKMapViewDelegate.mapViewDidFinishRendering(mapView: BMKMapView);
begin

end;

procedure TBMKMapViewDelegate.mapViewDidSelectAnnotationView(
  mapView: BMKMapView; didSelectAnnotationView: BMKAnnotationView);
var
  Marker:TBaiduMapMarker;
begin

  if (FViewService<>nil) and (didSelectAnnotationView<>nil) then
  begin
    mapView.deselectAnnotation((didSelectAnnotationView as ILocalObject).GetObjectID, False);
    Marker:=FViewService.GetMapObject<TBaiduMapMarker>(
      (TBMKPointAnnotation.Wrap(didSelectAnnotationView.annotation) as ILocalObject).GetObjectID);
    if Marker<>nil then
      FViewService.DoMarkerClick(Marker);
    didSelectAnnotationView.setSelected(False);
  end;
end;

procedure TBMKMapViewDelegate.mapViewOnClickedBMKOverlayView(
  mapView: BMKMapView; onClickedBMKOverlayView: BMKOverlayView);
begin

end;

procedure TBMKMapViewDelegate.mapViewOnClickedMapBlank(mapView: BMKMapView;
  onClickedMapBlank: CLLocationCoordinate2D);
begin
  if (FViewService<>nil)then
  begin
    FViewService.DoMapClick(TMapCoordinate(onClickedMapBlank));
  end;
end;

procedure TBMKMapViewDelegate.mapViewOnClickedMapPoi(mapView: BMKMapView;
  onClickedMapPoi: BMKMapPoi);
var
  MapPoi:TMapPoi;
begin
  if (FViewService<>nil) and (onClickedMapPoi<>nil) then
  begin
    MapPoi.Uid:=NSStrToStr(onClickedMapPoi.uid);
    MapPoi.Name:=NSStrToStr(onClickedMapPoi.text);
    MapPoi.Position:=TMapCoordinate(onClickedMapPoi.pt);
    FViewService.DoMapPoiClick(MapPoi);
  end;
end;

procedure TBMKMapViewDelegate.mapviewOnDoubleClick(mapView: BMKMapView;
  onDoubleClick: CLLocationCoordinate2D);
begin

end;

procedure TBMKMapViewDelegate.mapViewOnDrawMapFrame(mapView: BMKMapView;
  onDrawMapFrame: BMKMapStatus);
begin

end;

procedure TBMKMapViewDelegate.mapviewOnForceTouchForceMaximumPossibleForce(
  mapView: BMKMapView; onForceTouch: CLLocationCoordinate2D; force,
  maximumPossibleForce: CGFloat);
begin

end;

procedure TBMKMapViewDelegate.mapviewOnLongClick(mapView: BMKMapView;
  onLongClick: CLLocationCoordinate2D);
begin

end;

procedure TBMKMapViewDelegate.mapViewRegionDidChangeAnimated(
  mapView: BMKMapView; regionDidChangeAnimated: Boolean);
begin
  //地图区域发送变化
  if FViewService<>nil then
  begin
    FViewService.DoBoundsChanged;
  end;
end;

procedure TBMKMapViewDelegate.mapViewRegionWillChangeAnimated(
  mapView: BMKMapView; regionWillChangeAnimated: Boolean);
begin

end;

function TBMKMapViewDelegate.mapViewViewForAnnotation(mapView: BMKMapView;
  viewForAnnotation: Pointer): BMKAnnotationView;
var
  Marker: TiOSBMKMarker;
begin
  Result := nil;
  Marker := FViewService.GetMapObject<TiOSBMKMarker>((TBMKPointAnnotation.Wrap(viewForAnnotation) as ILocalObject).GetObjectID);
  if Marker <> nil then
    Result := Marker.AnnotationView;
end;

function TBMKMapViewDelegate.mapViewViewForOverlay(mapView: BMKMapView;
  viewForOverlay: Pointer): BMKOverlayView;
  function CircleView(O: NSObject): BMKCircleView;
  var
    C: TiOSBMKCircle;
  begin
    Result := nil;

    C := TiOSBMKCircle(FViewService.GetMapObject<TMapCircle>((O as ILocalObject).GetObjectID));
    if (C <> nil) and C.FVisible then
      Result := C.CircleView;
  end;

  function PolygonView(O: NSObject): BMKPolygonView;
  var
    P: TiOSBMKPolygon;
  begin
    Result := nil;
    P := TiOSBMKPolygon(FViewService.GetMapObject<TMapPolygon>((O as ILocalObject).GetObjectID));
    if (P <> nil) and P.FVisible then
      Result := P.PolygonView;
  end;

  function PolylineView(O: NSObject): BMKPolylineView;
  var
    L: TiOSBMKPolyline;
  begin
    Result := nil;
    L := TiOSBMKPolyline(FViewService.GetMapObject<TMapPolyline>((O as ILocalObject).GetObjectID));
    if (L <> nil) and L.FVisible then
      Result := L.PolylineView;
  end;
var
  Ovl: NSObject;
begin
  Result := nil;
  Ovl := TNSObject.Wrap(viewForOverlay);
  if Ovl.isKindOfClass(objc_getClass('BMKCircle')) then
    Result := CircleView(Ovl)
  else if Ovl.isKindOfClass(objc_getClass('BMKPolygon')) then
    Result := PolygonView(Ovl)
  else if Ovl.isKindOfClass(objc_getClass('BMKPolyline')) then
    Result := PolylineView(Ovl);
end;


{ TiOSBMKPolygon }

constructor TiOSBMKPolygon.Create(const Descriptor: TMapPolygonDescriptor;
  const ViewService: TiOSBaiduMapViewService);
begin
  inherited Create(Descriptor);
  FViewService := ViewService;
  FPolygon := TBMKPolygon.OCClass.polygonWithCoordinates(Descriptor.Outline.Points,
    Length(Descriptor.Outline.Points));
end;

destructor TiOSBMKPolygon.Destroy;
begin
  Remove;
  FPolygon.release;
  FPolygon := nil;
  inherited;
end;

function TiOSBMKPolygon.Id: Pointer;
begin
  Result := (FPolygon as ILocalObject).GetObjectID;
end;

function TiOSBMKPolygon.PolygonView: BMKPolygonView;
begin
  Result := TBMKPolygonView.Wrap(TBMKPolygonView.Alloc.initWithPolygon(FPolygon));
  Result.setFillColor(AlphaColorToUIColor(Descriptor.FillColor));
  Result.setStrokeColor(AlphaColorToUIColor(Descriptor.StrokeColor));
  Result.setLineWidth(Descriptor.StrokeWidth / FViewService.Scale);
end;

procedure TiOSBMKPolygon.Remove;
begin
  inherited;
  SetVisible(False);
end;

procedure TiOSBMKPolygon.SetVisible(const Value: Boolean);
begin
  inherited;
  StateSwitch(FVisible, Value,
    procedure begin
      FViewService.MapView.addOverlay((FPolygon as ILocalObject).GetObjectID)
    end,
    procedure begin
      FViewService.MapView.removeOverlay((FPolygon as ILocalObject).GetObjectID);
    end);

end;

{ TiOSBMKCircle }

function TiOSBMKCircle.CircleView: BMKCircleView;
begin
  Result := TBMKCircleView.Wrap(TBMKCircleView.Alloc.initWithCircle(FCircle));
  Result.setFillColor(AlphaColorToUIColor(Descriptor.FillColor));
  Result.setStrokeColor(AlphaColorToUIColor(Descriptor.StrokeColor));
  Result.setLineWidth(Descriptor.StrokeWidth / FViewService.Scale);
end;

constructor TiOSBMKCircle.Create(const Descriptor: TMapCircleDescriptor;
  const ViewService: TiOSBaiduMapViewService);
begin
  inherited Create(Descriptor);
  FViewService := ViewService;
  FCircle := TBMKCircle.OCClass.circleWithCenterCoordinate(CLLocationCoordinate2D(Descriptor.Center), Descriptor.Radius);
end;

destructor TiOSBMKCircle.Destroy;
begin
  Remove;
  FCircle.release;
  FCircle := nil;
  inherited;
end;

function TiOSBMKCircle.Id: Pointer;
begin
  Result := (FCircle as ILocalObject).GetObjectID;
end;

procedure TiOSBMKCircle.Remove;
begin
  inherited;
  SetVisible(False);
end;

procedure TiOSBMKCircle.SetVisible(const Value: Boolean);
begin
  inherited;
  StateSwitch(FVisible, Value,
    procedure begin
      FViewService.MapView.addOverlay((FCircle as ILocalObject).GetObjectID)
    end,
    procedure begin
      FViewService.MapView.removeOverlay((FCircle as ILocalObject).GetObjectID);
    end);
end;

end.
