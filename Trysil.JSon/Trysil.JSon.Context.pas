(*

  Trysil
  Copyright � David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.JSon.Context;

interface

uses
  System.SysUtils,
  System.Classes,
  System.JSon,
  System.Generics.Collections,
  Trysil.Types,
  Trysil.Mapping,
  Trysil.Consts,
  Trysil.Exceptions,
  Trysil.Data,
  Trysil.Context,

  Trysil.JSon.Types,
  Trysil.JSon.Consts,
  Trysil.JSon.Exceptions,
  Trysil.JSon.Serializer,
  Trysil.JSon.Deserializer;

type

{ TTJSonContext }

  TTJSonContext = class(TTContext)
  strict private
    FInLoading: Boolean;
    FSerializer: TTJSonSerializer;
    FDeserializer: TTJSonDeserializer;
  strict protected
    function InLoading: Boolean; override;
  public
    constructor Create(const AConnection: TTConnection); overload; override;
    constructor Create(
      const AConnection: TTConnection;
      const AUseIdentityMap: Boolean); overload; override;

    destructor Destroy; override;

    procedure Delete<T: class>(
      const AID: TTPrimaryKey; const AVersionID: TTVersion); overload;

    function EntityToJSon<T: class>(
      const AEntity: T; const AConfig: TTJSonSerializerConfig): String;
    function EntityToJSonObject<T: class>(
      const AEntity: T; const AConfig: TTJSonSerializerConfig): TJSonObject;
    function ListToJSon<T: class>(
      const AList: TList<T>; const AConfig: TTJSonSerializerConfig): String;
    function ListToJSonArray<T: class>(
      const AList: TList<T>; const AConfig: TTJSonSerializerConfig): TJSonArray;

    function EntityFromJSon<T: class>(const AJSon: String): T;
    function EntityFromJSonObject<T: class>(const AJSon: TJSonValue): T;
    procedure ListFromJSon<T: class>(
      const AJSon: String; const AList: TList<T>);
    procedure ListFromJSonArray<T: class>(
      const AJSon: TJSonArray; const AList: TList<T>);
  end;

implementation

{ TTJSonContext }

constructor TTJSonContext.Create(const AConnection: TTConnection);
begin
  Create(AConnection, False);
end;

constructor TTJSonContext.Create(
  const AConnection: TTConnection; const AUseIdentityMap: Boolean);
begin
  inherited Create(AConnection, AUseIdentityMap);
  if AUseIdentityMap then
    raise ETJSonException.Create(SNoIdentityMap);

  FInLoading := False;

  FSerializer := TTJSonSerializer.Create;
  FDeserializer := TTJSonDeserializer.Create;
end;


destructor TTJSonContext.Destroy;
begin
  FDeserializer.Free;
  FSerializer.Free;
  inherited Destroy;
end;

procedure TTJSonContext.Delete<T>(
  const AID: TTPrimaryKey; const AVersionID: TTVersion);
var
  LTableMap: TTTableMap;
  LEntity: T;
  LVersionID: TTVersion;
begin

  LTableMap := TTMapper.Instance.Load<T>();
  LEntity := Get<T>(AID);
  if not Assigned(LEntity) then
    raise ETException.Create(SRecordChanged);
  try
    if Assigned(LTableMap.VersionColumn) then
      LTableMap.VersionColumn.Member.SetValue(LEntity, AVersionID);
    Delete<T>(LEntity);
  finally
    LEntity.Free;
  end;
end;

function TTJSonContext.InLoading: Boolean;
begin
  result := FInLoading;
end;

function TTJSonContext.EntityToJSon<T>(
  const AEntity: T; const AConfig: TTJSonSerializerConfig): String;
var
  LResult: TJSonObject;
begin
  LResult := EntityToJSonObject<T>(AEntity, AConfig);
  try
    result := LResult.ToJSon();
  finally
    LResult.Free;
  end;
end;

function TTJSonContext.EntityToJSonObject<T>(
  const AEntity: T; const AConfig: TTJSonSerializerConfig): TJSonObject;
begin
  result := TJSonObject.Create;
  try
    FSerializer.EntityToJSon(AEntity, result, AConfig);
  except
    result.Free;
    raise;
  end;
end;

function TTJSonContext.ListToJSon<T>(
  const AList: TList<T>; const AConfig: TTJSonSerializerConfig): String;
var
  LResult: TJSonArray;
begin
  LResult := ListToJSonArray<T>(AList, AConfig);
  try
    result := LResult.ToJSon();
  finally
    LResult.Free;
  end;
end;

function TTJSonContext.ListToJSonArray<T>(
  const AList: TList<T>; const AConfig: TTJSonSerializerConfig): TJSonArray;
var
  LEntity: T;
  LJSon: TJSonObject;
begin
  result := TJSonArray.Create;
  try
    for LEntity in AList do
    begin
      LJSon := EntityToJSonObject<T>(LEntity, AConfig);
      try
        result.Add(LJSon);
      except
        LJSon.Free;
        raise;
      end;
    end;
  except
    result.Free;
    raise;
  end;
end;

function TTJSonContext.EntityFromJSon<T>(const AJSon: String): T;
var
  LJSon: TJSonValue;
begin
  LJSon := TJSonObject.ParseJSonValue(AJSon, False, True);
  try
    if not (LJSon is TJSonObject) then
      raise ETJSonException.Create(SNotAJSonObject);
    result := EntityFromJSonObject<T>(TJSonObject(LJSon));
  finally
    LJSon.Free;
  end;
end;

function TTJSonContext.EntityFromJSonObject<T>(const AJSon: TJSonValue): T;
begin
  FInLoading := True;
  try
    result := CreateEntity<T>();
    try
      FDeserializer.EntityFromJSon(AJSon, result);
    except
      result.Free;
      raise;
    end;
  finally
    FInLoading := False;
  end;
end;

procedure TTJSonContext.ListFromJSon<T>(
  const AJSon: String; const AList: TList<T>);
var
  LJSon: TJSonValue;
begin
  LJSon := TJSonObject.ParseJSonValue(AJSon, False, True);
  try
    if not (LJSon is TJSonArray) then
      raise ETJSonException.Create(SNotAJSonArray);
    ListFromJSonArray<T>(TJSonArray(LJSon), AList);
  finally
    LJSon.Free;
  end;
end;

procedure TTJSonContext.ListFromJSonArray<T>(
  const AJSon: TJSonArray; const AList: TList<T>);
var
  LJSon: TJSonValue;
  LEntity: T;
begin
  FInLoading := True;
  try
    for LJSon in AJSon do
      if LJSon is TJSonObject then
      begin
        LEntity := EntityFromJSonObject<T>(TJSonObject(LJSon));
        try
          AList.Add(LEntity);
        except
          LEntity.Free;
          raise;
        end;
      end;
  finally
    FInLoading := False;
  end;
end;

end.