unit UProperty;

interface
uses
  System.Classes,URawdataDataType;

type
    TDMSropertys = class
    private
      name :AnsiString;
      dataType:RawdataDataType;
      value :AnsiString;
    public
      constructor Create();
      destructor Destroy; override;
      function getName:string;
      function getDatatype:RawdataDataType;
      function getvalue:string;
      procedure read(buffer:TFileStream);
    end;

implementation

{ TDMSropertys }

constructor TDMSropertys.Create();
begin
  inherited Create();
end;

destructor TDMSropertys.Destroy;
begin
  dataType.Free;
end;

function TDMSropertys.getDatatype: RawdataDataType;
begin
  result:= Self.dataType;
end;

function TDMSropertys.getName: string;
begin
  result:= self.name;
end;

function TDMSropertys.getvalue: string;
begin
   Result:= self.value;
end;

procedure TDMSropertys.read(buffer: TFileStream);
var
  num,dataTypelength,typelen:Integer;
  bytes:array[0..4] of Byte;
  byteArray:array of Byte;
  poin:PChar;
  Chars,Chars1,Chars2:array of AnsiChar;
begin
  buffer.Read(bytes,4);
  num := Pinteger(@bytes)^;
  SetLength(Chars,num);
   buffer.Read(Chars[0],num);
   setlength(name,num);
   Move(Chars[0], name[1], num);

   dataType:=RawdataDataType.Create;
   buffer.Read(bytes,4);
   typelen := Pinteger(@bytes)^;
   dataType.get(typelen);
  if dataType.type_name = tdsTypeString then
  begin
    buffer.Read(bytes,4);
    num := Pinteger(@bytes)^;
    Setlength(value,num);
    SetLength(Chars1,num);
    buffer.Read(Chars1[0],num);
    Move(Chars1[0], value[1], num);
  end
  else
  begin
    dataTypelength := dataType.typeLength;
    SetLength(Chars2,dataTypelength);
    buffer.Read(Chars2[0],dataTypelength);
    Setlength(value,dataTypelength);
    Move(Chars2[0], value[1], dataTypelength);
  end;

end;

end.
