unit UTDMSChannel;

interface
uses
  System.SysUtils,System.Classes,System.Generics.Collections,UProperty,UROWDataInfo
  ;
type
    TChannel = class
      private
      objPath:AnsiString;
      rawDataIndex:Integer;
      lrawDataInfo:RawDataInfo;
      propertyMap :TDictionary<string,TDMSropertys>;
      dataList:TList<Variant>;
      public
      constructor Create();
      function getObjPath() :string;
      procedure addObj(o:Variant);
      function isFull():Boolean;
      procedure TypeInfo();
       function  getRawDataInfo:RawDataInfo;
      procedure read(buffer:TFileStream);
    end;

implementation

{ Channel }
uses
  UTDMSSegment;

constructor TChannel.Create();

begin
  inherited create;
  dataList:=TList<Variant>.Create;
end;

procedure TChannel.addObj(o:Variant);
begin
  dataList.add(o);
end;

function TChannel.getObjPath: string;
begin
   Result:= objPath;
end;

function TChannel.getRawDataInfo: RawDataInfo;
begin
  result := lrawDataInfo;
end;

function TChannel.isFull: Boolean;
begin
  result := (datalist.count = lrawDataInfo.getNumOfValue);
end;

procedure TChannel.read(buffer: TFileStream;adder:TDMSSegment);
var
  length:Integer;
  nProperty:Integer;
  i: Integer;
  proper:TDMSropertys ;
  bytes:array [0..4] of Byte;
  Chars:array of AnsiChar;
begin
   buffer.Read(bytes,4);
  length := Pinteger(@bytes)^;
  SetLength(Chars,length);
   buffer.Read(Chars[0],length);
   setlength(objpath,length);
   Move(Chars[0], objpath[1], length);
   Writeln('channel string name is '+objpath);

    buffer.Read(bytes,4);
    rawDataIndex := Pinteger(@bytes)^;
   if rawDataIndex =-1 then   //$FFFFFFFF
   begin
      Writeln('0xFFFFFFFF');
   end
   else if rawDataIndex = $00000000 then
        begin
          Writeln('0x00000000');
          //lrawDataInfo :=
        end
        else if (rawDataIndex = $69130000) or (rawDataIndex = $69120000) then
              begin
               Writeln('(DAMQ ,this format is not supported!');
              end
               else begin
                     Writeln('rawDataIndex = ' + inttostr(rawDataIndex));
                       lrawDataInfo := RawDataInfo.Create();
                       lrawDataInfo.read(buffer);
                     end;

   //get property
   buffer.read(bytes,4);
    nProperty:=Pinteger(@bytes)^;
   propertyMap := TDictionary<string,TDMSropertys>.create;
   for i := 0 to nProperty-1 do
     begin
       proper := TDMSropertys.create();
       proper.read(buffer);
       propertyMap.add( proper.getName,proper);
     end;

end;

procedure TChannel.TypeInfo;
begin

end;

end.
