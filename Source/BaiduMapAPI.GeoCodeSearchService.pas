unit BaiduMapAPI.GeoCodeSearchService;
//author:Xubzhlin
//Email:371889755@qq.com

//百度地图API 地址编码、反编码 单元
//TGeoCodeOption 搜索配置
//TAddressComponent 地址结果的层次化信息
//TGeoCodeResult 地址编码结果
//TReverseGeoCodeResult 反地址编码结果

interface

uses
  System.Generics.Collections, FMX.Maps, BaiduMapAPI.Search.CommTypes;

type
  TGeoCodeOption = record
    Address:string;
    City:string;
  end;

  TAddressComponent = record
    StreetNumber:string;  //街道号码
    StreetName:string;    //街道名称
    District:string;      //区县名称
    City:string;          //城市名称
    Province:string;      //省份名称
    Country:string;       //国家
    CountryCode:String;   //国家代码
    AdCode:string;        //行政区域编码
  end;

  TGeoCodeResult = class(TSearchResult)
    Location:TMapCoordinate;
    Address:string;
  end;

  TReverseGeoCodeResult = class(TSearchResult)
    AddressDetail:TAddressComponent;
    Address:string;
    BusinessCircle:string;
    SematicDescription:string;
    CityCode:string;
    Location:TMapCoordinate;
    PoiList:TList<TPoiInfo>;

    constructor Create;
    destructor Destroy; override;
  end;

  TOnGetGeoCodeResult = procedure(Sender:TObject; GeoCodeResult:TGeoCodeResult) of object;
  TOnGetReverseGeoCodeResult = procedure(Sender:TObject; ReverseResult:TReverseGeoCodeResult) of object;

  IBaiduMapGeoCodeSearchService = interface
    ['{141DD987-D594-4DA5-952B-6FD6546E1CCF}']
    function GeoCode(GeoCodeOption:TGeoCodeOption):Boolean;
    //根据地址名称返回地理信息
    function ReverseGeoCode(Coordinate:TMapCoordinate):Boolean;
    //根据地理坐标返回地理信息
  end;

  TBaiduMapGeoCodeSearchService = class(TInterfacedObject, IBaiduMapGeoCodeSearchService)
  private
    FOnGetGeoCodeResult:TOnGetGeoCodeResult;
    FOnGetReverseGeoCodeResult:TOnGetReverseGeoCodeResult;
  protected
    function DoGeoCode(GeoCodeOption:TGeoCodeOption):Boolean;  virtual;  abstract;
    function DoReverseGeoCode(Coordinate:TMapCoordinate):Boolean; virtual;  abstract;

    procedure GetGeoCodeResult(GeoCodeResult:TGeoCodeResult);
    procedure GetReverseGeoCodeResult(ReverseResult:TReverseGeoCodeResult);
  public
    function GeoCode(GeoCodeOption:TGeoCodeOption):Boolean;
    function ReverseGeoCode(Coordinate:TMapCoordinate):Boolean;
    property OnGetGeoCodeResult:TOnGetGeoCodeResult read FOnGetGeoCodeResult write FOnGetGeoCodeResult;
    property OnGetReverseGeoCodeResult:TOnGetReverseGeoCodeResult read FOnGetReverseGeoCodeResult write FOnGetReverseGeoCodeResult;
  end;

  TBaiduMapGeoCodeSearch = class(TObject)
  private
    FGeoCodeSearchService:TBaiduMapGeoCodeSearchService;
  public
    constructor Create;
    destructor Destroy; override;

    property GeoCodeSearchService:TBaiduMapGeoCodeSearchService read FGeoCodeSearchService;
  end;

implementation

{$IFDEF IOS}
uses
  BaiduMapAPI.GeoCodeSearchService.iOS;
{$ENDIF}
{$IFDEF ANDROID}
uses
  BaiduMapAPI.GeoCodeSearchService.Android;
{$ENDIF ANDROID}

{ TGeoCodeSearchService }

function TBaiduMapGeoCodeSearchService.GeoCode(GeoCodeOption: TGeoCodeOption): Boolean;
begin
  Result:=DoGeoCode(GeoCodeOption);
end;

procedure TBaiduMapGeoCodeSearchService.GetGeoCodeResult(
  GeoCodeResult: TGeoCodeResult);
begin
  if Assigned(FOnGetGeoCodeResult) then
    FOnGetGeoCodeResult(Self, GeoCodeResult);
end;

procedure TBaiduMapGeoCodeSearchService.GetReverseGeoCodeResult(
  ReverseResult: TReverseGeoCodeResult);
begin
  if Assigned(FOnGetReverseGeoCodeResult) then
    FOnGetReverseGeoCodeResult(Self, ReverseResult);
end;

function TBaiduMapGeoCodeSearchService.ReverseGeoCode(
  Coordinate: TMapCoordinate): Boolean;
begin
  Result:=DoReverseGeoCode(Coordinate);
end;

{ TBaiduMapGeoCodeSearch }

constructor TBaiduMapGeoCodeSearch.Create;
begin
  inherited Create;
  {$IFDEF IOS}
    FGeoCodeSearchService:=TiOSBaiduMapGeoCodeSearchService.Create;
  {$ENDIF}
  {$IFDEF ANDROID}
    FGeoCodeSearchService:=TAndroidBaiduMapGeoGodeearchService.Create;
  {$ENDIF ANDROID}
end;

destructor TBaiduMapGeoCodeSearch.Destroy;
begin
  if FGeoCodeSearchService<>nil then
    FGeoCodeSearchService.Free;
  inherited;
end;

{ TReverseGeoCodeResult }

constructor TReverseGeoCodeResult.Create;
begin
  inherited Create;
  PoiList:=TList<TPoiInfo>.Create;
end;

destructor TReverseGeoCodeResult.Destroy;
begin
  PoiList.Free;
  inherited;
end;

end.
