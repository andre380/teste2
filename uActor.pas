unit uActor;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpjson, jsonparser, jsonConf;
type

  TChoiceOption = (loDissonant, loConsonant);
  TChoiceOptions = set of TChoiceOption;
  Tstatus = (stNone,stAcept,stRefuse,stcompliance);

  { TActor }
  TActor = class
  protected
    FjsonOBJ: TJSONObject;
    Facept: TActor;
    Fcompliance: TActor;
    Fname: string;
    Fpool: TList;
    Frefuse: TActor;
    Fchoice: TActor;
    Fstatus: Tstatus;
    function getjsonOBJ: TJSONObject;
    procedure Setname(AValue: string);
    procedure Setpool(AValue: TList);
  public
    constructor Create( Aacept, Acompliance, Arefuse: TActor;Apool:TList;name:string);
    constructor create(AjsonOBJ:TJSONObject;Apool:TList);
    function choose(TendencyOptions:TChoiceOptions):Tstatus;

  published
    property name :string read Fname write Setname ;
    property pool:TList read Fpool write Setpool;
    property acept : TActor read Facept ;
    property refuse : TActor read Frefuse ;
    property compliance : TActor read Fcompliance ;
    property choice  : TActor read Fchoice;
    property status : Tstatus read Fstatus;
    property jsonOBJ:TJSONObject read getjsonOBJ;
 end;

  { Tpool }

  Tpool = class(TList)
  private
    Fname: string;
    function GetItems(Index: integer): TActor;
    procedure SetItems(Index: integer; AValue: TActor);
  public
    property name :string read Fname;
    function SaveToFile(FileName: string):Boolean;
    function LoadFromFile(AFilename:string):Boolean;
    property Items[Index: integer]: TActor read GetItems write SetItems;
    function add(item:TActor):integer;
    constructor create(aName:string);
  end;

  { Tpools }

  Tpools= class(TList)
  private
    function GetItems(Index: integer): Tpool;
    procedure SetItems(Index: integer; AValue: Tpool);
  public
    property Items[Index: integer]: Tpool read GetItems write SetItems;
    function addnew(aName:string):Tpool;
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

function Tpools.addnew(aName:string): Tpool;
begin
  result:=Tpool.Create(aName);
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



function Tpool.SaveToFile(FileName: string): Boolean;
var
  //FRoot:TJSONObject;
  indiceObjeto, cont:integer;
  S , nome: String;
  F : TFileStream;
  FRoot: TJSONArray;
  item, jpool: TJSONObject;
  objeto: TActor;
begin
  FRoot:=TJSONArray.Create;
  FRoot.add(TJSONObject.Create);
  nome:=self.name;
  TJSONObject(FRoot.Items[0]).Add(nome,TJSONObject.create);
  jpool:=TJSONObject(FRoot.Items[0].Items[0]);
  for cont:=0 to self.Count-1 do
  begin
    objeto:=self.Items[cont];
    jpool.Add(IntToStr(cont),objeto.jsonOBJ);
  end;
  F:=TFileStream.Create(FileName,fmCreate);
  try
    If Assigned(FRoot) then
      S:=FRoot.AsJSON;
      FRoot.Free;
    If length(S)>0 then
      F.WriteBuffer(S[1],Length(S));
//    FModified:=False;
  finally
    F.Free;
  end;
  Result:=true;
end;

function Tpool.LoadFromFile(AFilename: string): Boolean;
Var
  S : TFileStream;
  P : TJSONParser;
  Root, jpool: TJSONData;
  cont: Integer;
begin
  S:=TFileStream.Create(AFileName,fmOpenRead);
  try
    P:=TJSONParser.Create(S);
    try
      P.Strict:=true;
      Root:=P.Parse;
    finally
      P.Free;
    end;
  finally
    S.Free;
  end;
  jpool:= Root.Items[0].Items[0];
  for cont:=0 to jpool.Count - 1 do
  begin
    //actor:=TActor.Create();
    jpool.Items[cont].FindPath('name').AsString;
    //item.Add('acept',objeto.acept.name);
    //item.Add('compliance','');
    //item.Add('refuse','');
    //item.Add('choice','');
    //jpool.Add('Actor');
  end;
end;

function Tpool.add(item: TActor): integer;
begin
  inherited add(pointer(item));
end;

constructor Tpool.create(aName:string);
begin
  inherited create;
  self.Fname:=aName;
end;

{ TActor }

procedure TActor.Setpool(AValue: TList);
begin
  if Fpool=AValue then Exit;
  if AValue.ClassNameIs('Tpool') then
    Fpool:=AValue
  else raise Exception.create('Invalid class for pool. Tpool is required');
end;

function TActor.getjsonOBJ: TJSONObject;
var
  str1: String;
begin
  if FjsonOBJ<> nil then
  result:=FjsonOBJ
  else
  begin
    Result:=TJSONObject.Create;
    Result.Add('name',name);
    Result.Add('pool',Tpool(pool).name);
    if Assigned(acept) then
    str1:=acept.name;
    str1:=Tpool(acept.pool).name;
    Result.Add('acept',TJSONObject.Create(['name',Facept.name,'pool',Tpool(Facept.pool).name]));
    if Assigned(refuse) then
    Result.Add('refuse',TJSONObject.Create(['name',refuse.name,'pool',Tpool(refuse.pool).name]));
    if Assigned(compliance) then
    Result.Add('compliance',TJSONObject.Create(['name',compliance.name,'pool',Tpool(compliance.pool).name]));
    if Assigned(choice) then
    Result.Add('choice',TJSONObject.Create(['name',choice.name,'pool',Tpool(choice.pool).name]));
  end;
end;



procedure TActor.Setname(AValue: string);
begin
  if Fname=AValue then Exit;
  if status = stNone then
    Fname:=AValue;
end;

constructor TActor.Create(Aacept, Acompliance, Arefuse: TActor;Apool:TList;name:string);
begin
  Facept:= Aacept;
  Fcompliance:= Acompliance;
  Frefuse:= Arefuse;
  //Fchoice:=self;
  Fname:=name;
  if Length(name) = 0 then raise Exception.create('TActorError no name defined');
  if (Facept = nil)and(Frefuse = nil)and(Fcompliance = nil)then raise Exception.Create('TActorError not choices defined, at last one is required');
  if (Facept <> nil)and (Facept = fcompliance) then raise Exception.Create('TActorError acept and refuse must be diferent');
  if Apool = nil then
  begin
    raise Exception.create('TActorError not pool defined');
  end
  else pool:=Apool;
end;

constructor TActor.create(AjsonOBJ: TJSONObject;Apool:TList);
begin
  FjsonOBJ:=AjsonOBJ;
  Fname:=AjsonOBJ.Items[0].AsString;
  Fpool:=Apool;
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
    begin //acept null
      if Assigned(compliance) then
      begin
        Facept:=TActor.Create(self,compliance,refuse,pool,'acept-'+name);;
        Fchoice:=acept;
        Fstatus:=stAcept;
      end else
      begin//compliance acept null
        Fcompliance:=TActor.Create(acept,self,refuse,pool,'compliance-'+name);
        Fstatus:=stcompliance;
        Fchoice:=Fcompliance;
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
    begin//refuse null
      if Assigned(Facept) then
      begin
        Fchoice:=Facept;
        Fstatus:=stAcept;
      end else
      begin//acept refuse null
        Facept:=TActor.Create(compliance,self,refuse,pool,'acept-'+name);
        Fchoice:=acept;
        Fstatus:=stAcept;
      end;
    end;
  end
  else
  if loConsonant in TendencyOptions then
  begin
    if compliance = nil then
    begin
      Fcompliance:= TActor.Create(acept,self,refuse,pool,'compliance-'+name);
      pool.Add(pointer(Fcompliance));
      Fchoice:=Fcompliance;
      Fstatus:= stcompliance;
    end else
    begin
      Fchoice:=Fcompliance;
      Fstatus:=stcompliance;
    end;
  end
  else
  begin // no mood
    if Assigned(compliance) then
    begin
      Fchoice:=Fcompliance;
      Fstatus:=stcompliance;
    end else
    begin //compliance null
      if Assigned(Facept) then
      begin
        Fchoice:=Facept;
        Fstatus:=stAcept;
      end else
      begin //compliance acept null
      Fchoice:= Frefuse;
      Fstatus:= stRefuse;
      end;
    end;
  end;
  result:=status;
end;

end.

