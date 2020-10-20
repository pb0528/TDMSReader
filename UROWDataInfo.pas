unit UROWDataInfo;

interface
uses
  System.Classes,UProperty,URawdataDataType;

type
    RawDataInfo = class
      private
      sizeLength : LongInt;
      dataType : RawdataDataType;
      dimension : Integer;
      numofValue : LongInt;
      public
      constructor Create();
      destructor Destroy; override;
      function getNumOfValue:LongInt;
      function getDataType:RawdataDataType;
      function getDimension:Integer;
      procedure read(buffer:TFileStream);

    end;

implementation

{ RawDataInfo }

constructor RawDataInfo.Create();
begin
  inherited create;
end;

destructor RawDataInfo.Destroy;
begin
  dataType.Free;
end;
function RawDataInfo.getDataType: RawdataDataType;
begin
   Result:= dataType;
end;

function RawDataInfo.getDimension: Integer;
begin
  Result := dimension;
end;

function RawDataInfo.getNumOfValue: LongInt;
begin
  Result := numofValue;
end;

procedure RawDataInfo.read(buffer: TFileStream);
var
  bytes:array[0..4] of Byte;
  bys:array[0..8]of Byte;
  serNum:Integer;
begin
   dataType := RawdataDataType.Create;
   buffer.Read(bytes,4);
   serNum:=PInteger(@bytes)^;
  dataType.get(serNum);
  buffer.Read(bytes,4);
  dimension:=Pinteger(@bytes)^;
  buffer.Read(bys,8);
  numofValue:=PInt64(@bys)^;
  if dataType.type_name = tdsTypeString then
  begin
    buffer.Read(bys,8);
    sizeLength:=Pinteger(@bys)^;
  end;
end;

end.
