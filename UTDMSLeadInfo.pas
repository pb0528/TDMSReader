unit UTDMSLeadInfo;

interface
uses
  System.Classes,System.SysUtils;

type
    LeadInfo = class
      private
        startName:array [0..4] of AnsiChar;
        toc:Integer;
        versionInfo:Integer;
        nextSeg:LongInt;
        metaDataSize:LongInt;
      public
      constructor Create(buffer:TFileStream);
      procedure type_Info();
      function hasMetaData():Boolean;
      function hasRawData():Boolean;
      function  isDAQmxRawData():Boolean;
      function  hasIterleavedData():Boolean;
      function  isToBigEndian():Boolean;
      function  isTocNewObjlist():Boolean;
      function  getFileze():LongInt;
      function  getRawSize():LongInt;
    end;

implementation

{ LeadInfo }

constructor LeadInfo.Create(buffer:TFileStream);
var
  bytes:array [0..4] of Byte;
  byt:array [0..8] of Byte;
begin
  inherited create;
  startName:='    ';
  buffer.Read(startName[0],4);
   buffer.Read(bytes,4);
   toc := Pinteger(@bytes)^;
   buffer.Read(bytes,4);
  versionInfo := Pinteger(@bytes)^;
   buffer.Read(byt,8);
   nextSeg := Pint64(@byt)^;
   buffer.Read(byt,8);
   metaDataSize := Pint64(@byt)^;
end;

function LeadInfo.getFileze: LongInt;
begin
  result := Self.metaDataSize;
end;

function LeadInfo.getRawSize: LongInt;
begin
  result:= self.nextSeg-self.metaDataSize;
end;

function LeadInfo.hasIterleavedData: Boolean;
begin
  Result:= ((toc and (1 shl 5)) <> 0);
end;

function LeadInfo.hasMetaData: Boolean;
begin
  Result:= ((toc and (1 shl 1)) <> 0);
end;

function LeadInfo.hasRawData: Boolean;
begin
  Result:= ((toc and (1 shl 3)) <> 0);
end;

function LeadInfo.isDAQmxRawData: Boolean;
begin
  Result:= ((toc and (1 shl 7)) <> 0);
end;

function LeadInfo.isToBigEndian: Boolean;
begin
  Result:= ((toc and (1 shl 6)) <> 0);
end;

function LeadInfo.isTocNewObjlist: Boolean;
begin
  Result:= ((toc and (1 shl 2)) <> 0);
end;

procedure LeadInfo.type_Info;
begin
  Writeln('segMent Name: ' + startName );
  Writeln('toc Size: ' + IntToStr(toc) );
  Writeln('version_Num: ' + IntToStr(versionInfo) );
  Writeln('Next seg: ' + IntToStr(nextSeg) );
  Writeln('metaSize : ' + IntToStr(metaDataSize) );
end;

end.
