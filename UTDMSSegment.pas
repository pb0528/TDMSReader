unit UTDMSSegment;

interface
uses
  UTDMSLeadInfo,URawdataDataType, System.SysUtils,
  System.Generics.Collections,UTDMSChannel,System.Classes,UROWDataInfo;

type
    MetaData = class;
    RawData = class;
    TDMSSegment = class
      private
      ledInfo:LeadInfo;
      self_metaData:MetaData;
      self_rawData:RawData;
      channelMap:TList<TChannel>;
      public
      constructor Create();
      procedure adderChannel(Channel:TChannel);
      function getChannels():TList<TChannel>;
      function fileSize():LongInt;
      procedure read(buffer:TFileStream);
     // function getSameRawDataInfo(channelName:string): RawDataInfo;
    end;
    MetaData = class
      private
      ObjNum:Integer;
      public
      constructor Create(buffer:TFileStream;adder:TDMSSegment);
      procedure read(buffer:TFileStream;adder:TDMSSegment);
    end;
    RawData = class
      public
       constructor Create(ledInfo:LeadInfo;self_metaData:MetaData;seg:TDMSSegment;buffer:TFileStream);
       procedure addInt32ToObject( buffer : TFileStream; o: TChannel);
       procedure addFloatToObject( buffer : TFileStream; o: TChannel);
       procedure addDoublesToObject( buffer : TFileStream; o: TChannel);
       //procedure read(buffer:TFileStream);
    end;
implementation
{ TDMSSegment }


procedure TDMSSegment.adderChannel(Channel: TChannel);
begin
  channelMap.add(Channel);
end;

constructor TDMSSegment.Create();
begin
  inherited Create();
  channelMap := TList<TChannel>.create;
end;

function TDMSSegment.fileSize: LongInt;
begin

end;

function TDMSSegment.getChannels: TList<TChannel>;
begin
  Result:= channelMap;
end;

procedure TDMSSegment.read(buffer: TFileStream);
begin
  self.ledInfo := LeadInfo.create(buffer);


  if ledInfo.hasMetaData then
  begin
    Writeln('############读取元数据###############');
    self_metaData := MetaData.create(buffer,Self);
    self_metaData.read(buffer,self);
  end;

  if ledInfo.hasRawData then
  begin
    Writeln('###########读取原始数据###############');

    self_rawData := RawData.create(ledInfo,self_metaData,self,buffer);
   // Writeln('第一段------------------');
  end;
end;

//--------------------------------
constructor MetaData.Create(buffer:TFileStream;adder:TDMSSegment);
//var
//    i:Integer;
//    pin:PInteger;
//    Channel : TChannel;
//    bytes:array [0..4] of Byte;
//    num:Integer;
begin
  inherited create;
//  buffer.Read(bytes,4);
//  num:= Pinteger(@bytes)^;
// // Self.ObjNum := num;  问题:无法使用成员变量
//  for I := 0 to num-1 do
//     begin
//       Channel := TChannel.create();
//       Channel.read(buffer);
//       adder.adderChannel(Channel);  //问题：无法传递类自身
//     end;
end;
//--------------------------------------------

procedure RawData.addDoublesToObject(buffer: TFileStream; o: TChannel);
var
  nbOfValues:LongInt;
   i:Integer;
   val:Double;
  bytes:array [0..7] of Byte;
begin
   nbOfValues  := o.getRawDataInfo().getNumOfValue();
   for I := 0 to nbOfValues-1 do
    begin
     buffer.read(bytes,8);
     val := Pdouble(@bytes)^;
      o.addObj(val);
    end;
end;

procedure RawData.addFloatToObject(buffer: TFileStream; o: TChannel);
var
  nbOfValues:LongInt;
   i:Integer;
   val:Single;
  bytes:array [0..3] of Byte;
begin
   nbOfValues  := o.getRawDataInfo().getNumOfValue();
   for I := 0 to nbOfValues-1 do
    begin
     buffer.read(bytes,4);
     val := PSingle(@bytes)^;
      o.addObj(val);
    end;
end;

procedure RawData.addInt32ToObject(buffer: TFileStream; o: TChannel);
var
  nbOfValues:LongInt;
   i,val:Integer;
  bytes:array [0..3] of Byte;
begin
   nbOfValues  := o.getRawDataInfo().getNumOfValue();
   for I := 0 to nbOfValues-1 do
    begin
     buffer.read(bytes,4);
     val := PInteger(@bytes)^;
      o.addObj(val);
    end;
end;

constructor RawData.Create(ledInfo:LeadInfo;self_metaData:MetaData;seg:TDMSSegment;buffer:TFileStream);
var
  RawDataSize:Integer;
  checkSize:LongInt;
  i:Integer;
  list: TList<TChannel> ;
  numOfvalue,dimension,dataTypeValue,nChunck:Integer;
  k: Integer;
  temp :TChannel;
  dataType:RawdataDataType;
  bytes:array [0..7] of Byte;
begin
  inherited create;
  checkSize :=0;
  RawDataSize := ledInfo.getRawSize;
  list := seg.getChannels;
  for I := 0 to list.count-1 do
  begin
     if(list[i].getRawDataInfo = nil)then
      continue;
     numOfvalue := list[i].getRawDataInfo.getNumOfValue;
     dimension := list[i].getRawDataInfo.getDimension;
     dataTypeValue := list[i].getRawDataInfo.getDataType.typelength;
     checkSize := checkSize + numOfvalue * dimension *dataTypeValue;

  end;

  if checkSize =0 then
  begin
    writeln('error,there is no data read!');
    exit;
  end;

  if RawDataSize = 0 then
  begin
     nChunck := 0;
  end
  else
  begin
    nChunck :=trunc(RawDataSize / checkSize);
  end;

  Writeln('ChunkSize: '+IntToStr(checkSize));
  Writeln('totalChunks: ' 		+ IntToStr(RawDataSize));
  Writeln('nChunks: ' 		+ IntToStr(nChunck));
  if ledInfo.hasIterleavedData then
  begin
     Writeln('#############数据为交叉存储################ ' 	 );
     for i := 0  to nChunck-1 do
     begin
       for k := 0 to list.count -1 do
         begin
            temp := list[i];
           if temp.getRawDataInfo = nil then
              continue;
           dataType := temp.getRawDataInfo.getDataType;

           if dataType.type_name = tdsTypeI32 then
           begin
             if temp.isFull then  continue;
             buffer.read(bytes,4);
             temp.addObj(Pinteger(@bytes)^);
           end
           else if dataType.type_name = tdsTypeSingleFloat then
           begin
             if temp.isFull then  continue;
             buffer.read(bytes,4);
             temp.addObj(PSingle(@bytes)^);
           end
           else if dataType.type_name = tdsTypeDoubleFloat then
            begin
             if temp.isFull then  continue;
             buffer.read(bytes,8);
             temp.addObj(PDouble(@bytes)^);
            end
            else if dataType.type_name = INVALID then
            begin
              Writeln('datatype is null');
            end
            else
            begin
              Writeln('数据类型暂不支持');
            end;

         end;
     end;

  end
  else
  begin
     Writeln('#############数据为顺序存储################ ' 	 );
    for i := 0  to nChunck-1 do
     begin
       for k := 0 to list.count -1 do
       begin
          temp := list[i];
           if temp.getRawDataInfo = nil then
              continue;
          dataType := temp.getRawDataInfo.getDataType;
          if dataType.type_name = tdsTypeI32 then
          begin
            addInt32ToObject(buffer,temp);
          end
          else if dataType.type_name = tdsTypeSingleFloat then
          begin
                  addFloatToObject(buffer,temp);
          end
          else  if dataType.type_name = tdsTypeDoubleFloat then
          begin
              addDoublesToObject(buffer,temp);
          end
           else if dataType.type_name = INVALID then
            begin
              Writeln('datatype is null');
            end
            else
            begin
              Writeln('数据类型暂不支持');
            end;
       end;
     end;
  end;


end;

procedure MetaData.read(buffer: TFileStream; adder: TDMSSegment);
var
    i:Integer;
    pin:PInteger;
    Channel : TChannel;
    bytes:array [0..4] of Byte;
    num:Integer;
begin
  inherited create;
  buffer.Read(bytes,4);
  num:= Pinteger(@bytes)^;
  ObjNum:= num;
 // Self.ObjNum := num;  问题:无法使用成员变量
  if ObjNum = 0 then
      Writeln('Object num is zero ,please continue');
  for I := 0 to ObjNum-1 do
     begin
       Channel := TChannel.create();
       Channel.read(buffer);
       adder.adderChannel(Channel);  //问题：无法传递类自身
     end;
end;

end.
