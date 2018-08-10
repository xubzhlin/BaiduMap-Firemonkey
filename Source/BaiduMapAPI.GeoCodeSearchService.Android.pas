unit BaiduMapAPI.GeoCodeSearchService.Android;
//author:Xubzhlin
//Email:371889755@qq.com

//百度地图API 地址编码、反编码 单元
//官方链接:http://lbsyun.baidu.com/
//TAndroidBaiduMapGeoGodeearchService 百度地图 安卓 地址编码、反编码

interface

uses
  System.Classes, System.Types, FMX.Maps, Androidapi.JNI.JavaTypes,
  Androidapi.JNI.Embarcadero, Androidapi.JNI.GraphicsContentViewText,
  Androidapi.JNIBridge, System.Generics.Collections,
  Androidapi.JNI.baidu.mapapi.search, Androidapi.JNI.baidu.mapapi.model,
  BaiduMapAPI.Search.CommTypes, BaiduMapAPI.GeoCodeSearchService;

type
  TAndroidBaiduMapGeoGodeearchService = class;

  TOnGetGeoCoderResultListener = class(TJavaLocal, JOnGetGeoCoderResultListener)
  private
    [weak]FGeoGodeearchService:TAndroidBaiduMapGeoGodeearchService;
    function JPoiInfoToPoiInfo(Info:JPoiInfo):TPoiInfo;
  public
    procedure onGetGeoCodeResult(P1: JGeoCodeResult); cdecl;
    procedure onGetReverseGeoCodeResult(P1: JReverseGeoCodeResult); cdecl;

    constructor Create(GeoGodeearchService: TAndroidBaiduMapGeoGodeearchService);
  end;

  TAndroidBaiduMapGeoGodeearchService = class(TBaiduMapGeoCodeSearchService)
  private
    FGeoCoder:JGeoCoder;
    FListener:TOnGetGeoCoderResultListener;
  protected
    function DoGeoCode(GeoCodeOption:TGeoCodeOption):Boolean;  override;
    function DoReverseGeoCode(Coordinate:TMapCoordinate):Boolean; override;
  public
    constructor Create;
    destructor Destroy; override;
  end;

implementation

uses
  Androidapi.Helpers;

{ TAndroidBaiduMapGeoGodeearchService }

constructor TAndroidBaiduMapGeoGodeearchService.Create;
begin
  inherited Create;
  FGeoCoder:=TJGeoCoder.JavaClass.newInstance;
  FListener:=TOnGetGeoCoderResultListener.Create(Self);
  FGeoCoder.setOnGetGeoCodeResultListener(FListener);
end;

destructor TAndroidBaiduMapGeoGodeearchService.Destroy;
begin
  FListener.Free;
  FGeoCoder:=nil;
  inherited;
end;

function TAndroidBaiduMapGeoGodeearchService.DoGeoCode(
  GeoCodeOption: TGeoCodeOption): Boolean;
var
  CodeOption:JGeoCodeOption;
begin
  CodeOption:=TJGeoCodeOption.JavaClass.init;
  CodeOption.city(StringToJString(GeoCodeOption.City)).address(StringToJString(GeoCodeOption.Address));
  Result:=FGeoCoder.geocode(CodeOption);
end;

function TAndroidBaiduMapGeoGodeearchService.DoReverseGeoCode(
  Coordinate: TMapCoordinate): Boolean;
var
  Location:JLatLng;
  ReverseOption:JReverseGeoCodeOption;
begin
  Location:=TJLatLng.JavaClass.init(Coordinate.Latitude, Coordinate.Longitude);
  ReverseOption:=TJReverseGeoCodeOption.JavaClass.init;
  ReverseOption.location(Location);
  Result:=FGeoCoder.reverseGeoCode(ReverseOption);
end;

{ TOnGetGeoCoderResultListener }

constructor TOnGetGeoCoderResultListener.Create(
  GeoGodeearchService: TAndroidBaiduMapGeoGodeearchService);
begin
  inherited Create;
  FGeoGodeearchService := GeoGodeearchService;
end;

function TOnGetGeoCoderResultListener.JPoiInfoToPoiInfo(
  Info: JPoiInfo): TPoiInfo;
begin
  Result.name:=JStringToString(Info.name);
  Result.uid:=JStringToString(Info.uid);
  Result.address:=JStringToString(Info.address);
  Result.city:=JStringToString(Info.city);
  Result.phoneNum:=JStringToString(Info.phoneNum);
  Result.postCode:=JStringToString(Info.postCode);
  Result.&type:=CreatePoiType(Info.&type);
  Result.location:=TMapCoordinate.Create(Info.location.latitude, Info.location.longitude);
  Result.isPano:=Info.isPano;
end;

procedure TOnGetGeoCoderResultListener.onGetGeoCodeResult(P1: JGeoCodeResult);
var
  GeoCodeResult:TGeoCodeResult;
begin
  if FGeoGodeearchService<>nil then
  begin
    GeoCodeResult:=TGeoCodeResult.Create;
    GeoCodeResult.error:=CreateErrorNo(P1.error);
    case GeoCodeResult.error of
      TSearchResult_ErrorNo.NO_ERROR:
        begin
          GeoCodeResult.Location:=TMapCoordinate.Create(P1.getLocation.latitude, P1.getLocation.longitude);
          GeoCodeResult.Address:=JStringToString(P1.getAddress);
        end;
    end;

    FGeoGodeearchService.GetGeoCodeResult(GeoCodeResult);
  end;
end;

procedure TOnGetGeoCoderResultListener.onGetReverseGeoCodeResult(
  P1: JReverseGeoCodeResult);
var
  i:Integer;
  ReverseResult:TReverseGeoCodeResult;
  AddressDetail:TAddressComponent;
  List:JList;
  PoiInfo:JPoiInfo;
begin
  if FGeoGodeearchService<>nil then
  begin
    ReverseResult:=TReverseGeoCodeResult.Create;

    ReverseResult.error:=CreateErrorNo(P1.error);
    case ReverseResult.error of
      TSearchResult_ErrorNo.NO_ERROR:
        begin
          AddressDetail.StreetNumber:=JStringToString(P1.getAddressDetail.streetNumber);
          AddressDetail.StreetName:=JStringToString(P1.getAddressDetail.street);
          AddressDetail.District:=JStringToString(P1.getAddressDetail.district);
          AddressDetail.City:=JStringToString(P1.getAddressDetail.city);
          AddressDetail.Province:=JStringToString(P1.getAddressDetail.province);
          AddressDetail.Country:=JStringToString(P1.getAddressDetail.countryName);
          //AddressDetail.CountryCode:=InttoStr(P1.getAddressDetail.countryCode);

          ReverseResult.AddressDetail:=AddressDetail;
          ReverseResult.Address:=JStringToString(P1.getAddress);
          ReverseResult.BusinessCircle:=JStringToString(P1.getBusinessCircle);
          ReverseResult.SematicDescription:=JStringToString(P1.getSematicDescription);
          ReverseResult.Location:=TMapCoordinate.Create(P1.getLocation.latitude, P1.getLocation.longitude);

          List:=P1.getPoiList;
          for i := 0 to List.size - 1 do
          begin
            PoiInfo:=TJPoiInfo.Wrap(List.get(i));
            ReverseResult.PoiList.Add(JPoiInfoToPoiInfo(PoiInfo));
          end;
        end;
    end;

    FGeoGodeearchService.GetReverseGeoCodeResult(ReverseResult);
  end;
end;

end.
