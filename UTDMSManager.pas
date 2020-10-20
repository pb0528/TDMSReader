unit UTDMSManager;

interface
uses
  System.SysUtils,System.Generics.Collections,UTDMSSegment,System.Classes,UROWDataInfo,
  UTDMSChannel;
type
  TDMSManager = class
  private
    fileSize:Integer;
    segNum:Integer;
    buffer:TFilestream;
  public
    segmenList:TList<TDMSSegment>;
   constructor Create();
   procedure read(filePath:string);
   function getSameRawDataInfo(channelName:string): RawDataInfo;
  // function read(filename:string):Tlist<TDMSChannel>;
  end;

implementation

{ TDMSManager }

constructor TDMSManager.Create;
begin
  inherited;
  segmenList := TList<TDMSSegment>.Create;
  segNum:=0;
  Writeln('TDMSManager is created!');
end;

function TDMSManager.getSameRawDataInfo(channelName: string): RawDataInfo;
var
  I,j:Integer;
  list:Tlist<TChannel>;
begin
 if segNum = 0 then
    result := nil
 else
 begin
    for I := 0 to segmenList.count-1 do
    begin
      list := segmenList[i].getChannels;
      for j := 0 to list.count-1 do
      begin
        if list[i].getObjPath = channelName then
        begin
          result:=list[i].getRawDataInfo;
          break;
        end;
      end;
    end;
 end;
end;

procedure TDMSManager.read(filePath: string);
var
  seg:TDMSSegment ;
  fileLegth:Int64;
begin
  Writeln(filePath);
  buffer := TFileStream.Create(filePath, fmOpenRead or fmShareDenyNone);
  fileLegth:=buffer.Size;
   repeat
     seg:=TDMSSegment.create();
     seg.read(buffer);
     segmenList.Add(seg);
     Inc(segNum);
     Writeln('number of segment is:  ' + IntToStr(segNum));
     Writeln('--------------------------------------------------');
   until (buffer.Position = fileLegth);
   buffer.Free;
end;

end.
