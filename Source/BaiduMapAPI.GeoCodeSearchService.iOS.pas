unit BaiduMapAPI.GeoCodeSearchService.iOS;
//author:Xubzhlin
//Email:371889755@qq.com

//百度地图API 地址编码、反编码 单元
//官方链接:http://lbsyun.baidu.com/
//TAndroidBaiduMapGeoGodeearchService 百度地图 地址编码、反编码 服务

interface

uses
  System.Classes, System.Types, Macapi.ObjectiveC, Macapi.Helpers, iOSapi.Foundation, iOSapi.BaiduMapAPI_Search,
  iOSapi.BaiduMapAPI_Base, BaiduMapAPI.Search.CommTypes, BaiduMapAPI.GeoCodeSearchService, FMX.Maps;

type
  TiOSBaiduMapGeoCodeSearchService = class;

  TBMKGeoCodeSearchDelegate = class(TOCLocal, BMKGeoCodeSearchDelegate)
  private
    [Weak] FGeoCodeSearchService: TiOSBaiduMapGeoCodeSearchService;
    function BMKPoiInfoToPoiInfo(Info:BMKPoiInfo):TPoiInfo;
  public
    procedure onGetGeoCodeResult(searcher: BMKGeoCodeSearch;
      result: BMKGeoCodeResult; errorCode: BMKSearchErrorCode); cdecl;
    procedure onGetReverseGeoCodeResult(searcher: BMKGeoCodeSearch;
      result: BMKReverseGeoCodeResult; errorCode: BMKSearchErrorCode); cdecl;
    constructor Create(GeoCodeSearchService: TiOSBaiduMapGeoCodeSearchService);
  end;

  TiOSBaiduMapGeoCodeSearchService = class(TBaiduMapGeoCodeSearchService)
  private
    FGeoCodeSearch:BMKGeoCodeSearch;
    FDelegate:TBMKGeoCodeSearchDelegate;

  protected
    function DoGeoCode(GeoCodeOption:TGeoCodeOption):Boolean;  override;
    function DoReverseGeoCode(Coordinate:TMapCoordinate):Boolean; override;
  public
    constructor Create;
    destructor Destroy; override;
  end;

implementation


{ TiOSBaiduMapGeoCodeSearchService }

constructor TiOSBaiduMapGeoCodeSearchService.Create;
begin
  inherited Create;

  FGeoCodeSearch:=TBMKGeoCodeSearch.Create;
  FDelegate:=TBMKGeoCodeSearchDelegate.Create(Self);
  FGeoCodeSearch.setDelegate(FDelegate.GetObjectID);
end;

destructor TiOSBaiduMapGeoCodeSearchService.Destroy;
begin
  FGeoCodeSearch:=nil;
  FDelegate.Free;
  inherited;
end;

function TiOSBaiduMapGeoCodeSearchService.DoGeoCode(
  GeoCodeOption: TGeoCodeOption): Boolean;
var
  CodeOption:BMKGeoCodeSearchOption;
begin
  CodeOption:=TBMKGeoCodeSearchOption.Wrap(TBMKGeoCodeSearchOption.OCClass.alloc);
  CodeOption.setAddress(StrToNSStr(GeoCodeOption.Address));
  CodeOption.setCity(StrToNSStr(GeoCodeOption.City));
  Result:=FGeoCodeSearch.geoCode(CodeOption);
end;

function TiOSBaiduMapGeoCodeSearchService.DoReverseGeoCode(
  Coordinate: TMapCoordinate): Boolean;
var
  ReverseOption:BMKReverseGeoCodeOption;
begin
  ReverseOption:=TBMKReverseGeoCodeOption.Wrap(TBMKReverseGeoCodeOption.OCClass.alloc);
  ReverseOption.setReverseGeoPoint(CLLocationCoordinate2D(Coordinate));
  Result:=FGeoCodeSearch.reverseGeoCode(ReverseOption);
end;

{ TBMKGeoCodeSearchDelegate }

function TBMKGeoCodeSearchDelegate.BMKPoiInfoToPoiInfo(
  Info: BMKPoiInfo): TPoiInfo;
begin
  Result.name:=NSStrToStr(Info.name);
  Result.uid:=NSStrToStr(Info.uid);
  Result.address:=NSStrToStr(Info.address);
  Result.city:=NSStrToStr(Info.city);
  Result.phoneNum:=NSStrToStr(Info.phone);
  Result.postCode:=NSStrToStr(Info.postCode);
  Result.&type:=CreatePoiType(Info.epoitype);
  Result.location:=TMapCoordinate.Create(Info.pt.latitude, Info.pt.longitude);
  Result.isPano:=Info.panoFlag;
end;

constructor TBMKGeoCodeSearchDelegate.Create(
  GeoCodeSearchService: TiOSBaiduMapGeoCodeSearchService);
begin
  inherited Create;
  FGeoCodeSearchService := GeoCodeSearchService;
end;

procedure TBMKGeoCodeSearchDelegate.onGetGeoCodeResult(
  searcher: BMKGeoCodeSearch; result: BMKGeoCodeResult;
  errorCode: BMKSearchErrorCode);
var
  GeoCodeResult:TGeoCodeResult;
begin
  if FGeoCodeSearchService<>nil then
  begin
    GeoCodeResult:=TGeoCodeResult.Create;
    GeoCodeResult.error:=CreateErrorNo(errorCode);
    case GeoCodeResult.error of
      TSearchResult_ErrorNo.NO_ERROR:
        begin
          GeoCodeResult.Address:=NSStrToStr(result.address);
          GeoCodeResult.Location:=TMapCoordinate(result.location);
        end;
    end;

    FGeoCodeSearchService.GetGeoCodeResult(GeoCodeResult);
  end;

end;

procedure TBMKGeoCodeSearchDelegate.onGetReverseGeoCodeResult(
  searcher: BMKGeoCodeSearch; result: BMKReverseGeoCodeResult;
  errorCode: BMKSearchErrorCode);
var
  i:Integer;
  ReverseResult:TReverseGeoCodeResult;
  List:NSArray;
  AddressDetail:TAddressComponent;
  PoiInfo:BMKPoiInfo;
begin
  if FGeoCodeSearchService<>nil then
  begin
    ReverseResult:=TReverseGeoCodeResult.Create;
    ReverseResult.error:=CreateErrorNo(errorCode);
    case ReverseResult.error of
      TSearchResult_ErrorNo.NO_ERROR:
        begin
          if result.addressDetail<>nil then
          begin
            AddressDetail.StreetNumber:=NSStrToStr(result.addressDetail.streetNumber);
            AddressDetail.StreetName:=NSStrToStr(result.addressDetail.StreetName);
            AddressDetail.District:=NSStrToStr(result.addressDetail.District);
            AddressDetail.City:=NSStrToStr(result.addressDetail.City);
            AddressDetail.Province:=NSStrToStr(result.addressDetail.Province);
            AddressDetail.Country:=NSStrToStr(result.addressDetail.Country);
            AddressDetail.CountryCode:='';//NSStrToStr(result.addressDetail.CountryCode);
            ReverseResult.AddressDetail:=AddressDetail;
          end;

          ReverseResult.Address:=NSStrToStr(result.address);
          ReverseResult.BusinessCircle:=NSStrToStr(result.address);
          ReverseResult.SematicDescription:=NSStrToStr(result.SematicDescription);
          ReverseResult.Location:=TMapCoordinate(result.location);

          List:=result.poiList;
          for i := 0 to List.count -1 do
          begin
            PoiInfo := TBMKPoiInfo.Wrap(List.objectAtIndex(i));
            ReverseResult.PoiList.Add(BMKPoiInfoToPoiInfo(PoiInfo));
          end;
        end;
    end;

    FGeoCodeSearchService.GetReverseGeoCodeResult(ReverseResult);
  end;
end;

end.
