unit uActor;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpjson, jsonparser, jsonConf;
type

  TChoiceOption = (loDissonant, loConsonant);
  TChoiceOptions = set of TChoiceOption;
  Tstatus = (stNone,stAcept,stRefuse,stcomplain);

  { TActor }
  TActor = class
  protected
    Facept: TActor;
    Fcomplain: TActor;
    Fname: string;
    Fpool: TList;
    Frefuse: TActor;
    Fchoice: TActor;
    Fstatus: Tstatus;
    procedure Setname(AValue: string);
    procedure Setpool(AValue: TList);
  public
    constructor Create( Aacept, Acomplain, Arefuse: TActor;Apool:TList;name:string);
    function choose(TendencyOptions:TChoiceOptions):Tstatus;

  published
    property name :string read Fname write Setname ;
    property acept : TActor read Facept ;
    property refuse : TActor read Frefuse ;
    property complain : TActor read Fcomplain ;
    property choice  : TActor read Fchoice;
    property status : Tstatus read Fstatus;
    property pool:TList read Fpool write Setpool;
 end;

  { Tpool }

  Tpool = class(TList)
  private
    function GetItems(Index: integer): TActor;
    procedure SetItems(Index: integer; AValue: TActor);
  public
    procedure SaveToFile(const FileName: string);
    property Items[Index: integer]: TActor read GetItems write SetItems;
    function add(item:TActor):integer;
  end;

  { Tpools }

  Tpools= class(TList)
  private
    function GetItems(Index: integer): Tpool;
    procedure SetItems(Index: integer; AValue: Tpool);
  public
    property Items[Index: integer]: Tpool read GetItems write SetItems;
    function addnew:Tpool;
  end;



implementation

{ Tpools }

function Tpools.GetItems(Index: integer): Tpool;
begin
  Result:= Tpool(Inherited Items[Index]);
end;

procedure Tpools.SetItems(Index: integer; AValue: Tpool);
begin
 Inherited Items[Index]:=Pointer(AValue);
end;

function Tpools.addnew: Tpool;
begin
  result:=Tpool.Create;
  Inherited add(Result);
end;

{ Tpool }

function Tpool.GetItems(Index: integer): TActor;
begin
  Result:= TActor(Inherited Items[Index]);
end;

procedure Tpool.SetItems(Index: integer; AValue: TActor);
begin
  inherited Items[Index]:=Pointer(AValue);
end;

procedure Tpool.SaveToFile(const FileName: string);
var
  FRoot:TJSONObject;
  indiceObjeto, cont:integer;
  S : String;
  F : TFileStream;
begin
  FRoot:=TJSONObject.Create;
  for cont:=0 to self.Count-1 do
  begin
    indiceObjeto:= FRoot.Add('actor',TJSONObject.Create);
    TJSONArray(FRoot.Items[0]).Add();
  end;
  F:=TFileStream.Create(FileName,fmCreate);
  try
    If Assigned(FRoot) then
      S:=FRoot.AsJSON;
    If length(S)>0 then
      F.WriteBuffer(S[1],Length(S));
//    FModified:=False;
  finally
    F.Free;
  end;
  //FFileName:=AFileName;
  //SetCaption;
end;

function Tpool.add(item: TActor): integer;
begin
  inherited add(pointer(item));
end;

{ TActor }

procedure TActor.Setpool(AValue: TList);
begin
  if Fpool=AValue then Exit;
  if Fpool.ClassNameIs('Tpool') then
    Fpool:=AValue
  else raise Exception.create('Invalid class for pool. Tpool is required');
end;

procedure TActor.Setname(AValue: string);
begin
  if Fname=AValue then Exit;
  if status = stNone then
    Fname:=AValue;
end;

constructor TActor.Create(Aacept, Acomplain, Arefuse: TActor;Apool:TList;name:string);
begin
  Facept:= Aacept;
  Fcomplain:= Acomplain;
  Frefuse:= Arefuse;
  Fchoice:=self;
  Fname:=name;
  if Length(name) = 0 then raise Exception.create('TActorError no name defined');
  if (Facept = nil)and(Frefuse = nil)and(Fcomplain = nil)then raise Exception.Create('TActorError not choices defined, at last one is required');
  if (Facept <> nil)and (Facept = fcomplain) then raise Exception.Create('TActorError acept and refuse must be diferent');
  if Apool = nil then
  begin
    raise Exception.create('TActorError not pool defined');
  end
  else pool:=Apool;
end;

function TActor.choose(TendencyOptions: TChoiceOptions): Tstatus;
begin
  if (loDissonant in  TendencyOptions)and
     (loConsonant in TendencyOptions) then
  begin
    if Assigned(Facept) then
    begin
      Fchoice:=Facept;
      Fstatus:=stAcept;
    end else
    begin
      if Assigned(complain) then
      begin
        Facept:=TActor.Create(self,complain,refuse,pool,'acept-'+name);;
        Fchoice:=acept;
        Fstatus:=stAcept;
      end else
      begin
        Fcomplain:=TActor.Create(acept,self,refuse,pool,'complain-'+name);
        Fstatus:=stcomplain;
        Fchoice:=Fcomplain;
      end;
    end ;
  end
  else
  if loDissonant in  TendencyOptions then
  begin
    if Assigned(Frefuse) then
    begin
      Fchoice:=Frefuse;
      Fstatus:=stRefuse;
    end else
    begin
      if Assigned(Facept) then
      begin
        Fchoice:=Facept;
        Fstatus:=stAcept;
      end else
      begin
        Facept:=TActor.Create(complain,self,refuse,pool,'acept-'+name);
        Fchoice:=acept;
        Fstatus:=stAcept;
      end;
    end;
  end
  else
  if loConsonant in TendencyOptions then
  begin
    if complain = nil then
    begin
      Fcomplain:= TActor.Create(acept,self,refuse,pool,'Complain-'+name);
      pool.Add(pointer(Fcomplain));
      Fchoice:=Fcomplain;
      Fstatus:= stcomplain;
    end else
    begin
      Fchoice:=Fcomplain;
      Fstatus:=stcomplain;
    end;
  end
  else
  begin // no mood
    if Assigned(complain) then
    begin
      Fchoice:=Fcomplain;
      Fstatus:=stcomplain;
    end else
    begin
      if Assigned(Facept) then
      begin
        Fchoice:=Facept;
        Fstatus:=stAcept;
      end else
      begin
      Fchoice:= Frefuse;
      Fstatus:= stRefuse;
      end;
    end;
  end;
  result:=status;
end;

end.

