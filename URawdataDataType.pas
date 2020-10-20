unit URawdataDataType;

interface

type
DataType = (
    INVALID=-1,
    tdsTypeVoid=0,
    tdsTypeI8=1,
    tdsTypeI16=2,
    tdsTypeI32=3,
    tdsTypeI64=4,
    tdsTypeU8=5,
    tdsTypeU16=6,
    tdsTypeU32=7,
    tdsTypeU64=8,
    tdsTypeSingleFloat=9,
    tdsTypeDoubleFloat=10,
    tdsTypeExtendedFloat=11,
    tdsTypeSingleFloatWithUnit=$19,
    tdsTypeDoubleFloatWithUnit=13,
    tdsTypeExtendedFloatWithUnit=14,
    tdsTypeString=$20,
    tdsTypeBoolean=$21,
    tdsTypeTimeStamp=$44,
    tdsTypeFixedPoint=$4F,
    tdsTypeComplextSingleFloat=$08000c,
    tdsTypeComplextDoubleFloat=$10000d,
    tdsTypeDAQmxRawData=$FFFFFFFF);
  RawdataDataType = class
     private

     public
     type_name:DataType;
     constructor Create();
    function get(toc:Integer):DataType;
    function typeLength():Integer;
  end;

implementation

{ RawdataDataType }

constructor RawdataDataType.Create();
begin
  inherited;
end;

function RawdataDataType.get(toc: Integer): DataType;
begin
  case toc of
   0: Result := tdsTypeVoid;
   1: Result := tdsTypeI8;
   2: Result := tdsTypeI16;
   3: Result := tdsTypeI32;
   4: Result := tdsTypeI64;
   5: Result := tdsTypeU8;
   6: Result := tdsTypeU16;
   7: Result := tdsTypeU32;
   8: Result := tdsTypeU64;
   9: Result := tdsTypeSingleFloat;
   10: Result := tdsTypeDoubleFloat;
   11: Result := tdsTypeExtendedFloat;
   $19: Result := tdsTypeSingleFloatWithUnit;
   13: Result := tdsTypeDoubleFloatWithUnit;
   14: Result := tdsTypeExtendedFloatWithUnit;
   $20: Result := tdsTypeString;
   $21: Result := tdsTypeBoolean;
   $44: Result := tdsTypeTimeStamp;
   $4F: Result := tdsTypeFixedPoint;
   $08000c: Result := tdsTypeComplextSingleFloat;
   $10000d: Result := tdsTypeComplextDoubleFloat;
   $FFFFFFFF: Result := tdsTypeDAQmxRawData;
   else 		 Result := INVALID;
  end;
  type_name:=Result;
end;

function RawdataDataType.typeLength: Integer;
begin
  case type_name of
      tdsTypeVoid: 	Result:= 0;


        tdsTypeBoolean:Result:= 1;
        tdsTypeU8:    Result:= 1;
        tdsTypeI8: 		Result:= 1;


        tdsTypeU16:    	Result:= 2;
        tdsTypeI16: 		Result:= 2;


        tdsTypeSingleFloat:  Result:= 4;
        tdsTypeSingleFloatWithUnit:  Result:= 4;
        tdsTypeU32:   Result:= 4;
        tdsTypeI32:    Result:= 4;



        tdsTypeU64:   Result:= 8;
        tdsTypeDoubleFloat:   Result:= 8;
        tdsTypeDoubleFloatWithUnit:   Result:= 8;
        tdsTypeI64: 		Result:= 8;


        tdsTypeTimeStamp: 	Result:= 16;


        tdsTypeString: 	Result:= -1;

        tdsTypeExtendedFloat:   Result:= -1 ;
        tdsTypeExtendedFloatWithUnit:   Result:= -1 ;
        tdsTypeFixedPoint:   Result:= -1    ;
        tdsTypeComplextSingleFloat:  Result:= -1    ;
        tdsTypeComplextDoubleFloat: Result:= -1 ;
        tdsTypeDAQmxRawData:    Result:= -1;
            else
                	Result:= -1;
  end;
end;

end.
