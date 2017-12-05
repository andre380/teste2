unit uActor;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpjson_1, jsonparser1, jsonConf,contnrs;
type

  TChoiceOption = (loDissonant, loConsonant);
  TChoiceOptions = set of TChoiceOption;
  Tstatus = (stNone,stAcept,stRefuse,stcompliance);
  TActor = class;
  Tpools= class;
  { Tpool }

  Tpool = class(TList)//(TObjectList)
  private
    dissonantvalue:integer;
    consonantvalue:integer;
    Fname: string;
    Ftendency: TChoiceOptions;
    function GetItems(Index: integer): TActor;
    procedure SetItems(Index: integer; AValue: TActor);
  public
    Owner:Tpools;
    property name :string read Fname;
    function SaveToFile(FileName: string):Boolean;
    function LoadFromFile(AFilename:string):Boolean;
    property Items[Index: integer]: TActor read GetItems write SetItems;
    property tendency:TChoiceOptions read Ftendency;
    procedure adjustTendency(status:tstatus);
    function add(item:TActor):integer;
    constructor create(aName:string);
    destructor destroy;override;
    function getActor(aName:string):TActor;
  end;

 { Tpools }

  Tpools= class(TList)
  private
    function GetItems(Index: integer): Tpool;
    procedure SetItems(Index: integer; AValue: Tpool);
  public
    property Items[Index: integer]: Tpool read GetItems write SetItems;
    destructor destroy;override;
    function getPool(name:string):Tpool;
  end;


  { TActor }
  TActor = class
  protected
    Fnacept: String;
    Fnchoice: String;
    Fncompliance: String;
    Fnrefuse: String;
    Facept: TActor;
    Fcompliance: TActor;
    Fname: string;
    Fpool: Tpool;
    Frefuse: TActor;
    Fchoice: TActor;
    Fstatus: Tstatus;
    Fparsed:boolean;
    procedure Setname(AValue: string);
    procedure Setpool(AValue: Tpool);
  public
    constructor Create( Aacept, Acompliance, Arefuse: TActor;Apool:Tpool;name:string);
    constructor create(AjsonOBJ:TJSONObject;ApoolList:Tpools);
    function choose(TendencyOptions:TChoiceOptions):Tstatus;
    function getjsonOBJ: TJSONObject;
    function parse:boolean;
  published
    property name :string read Fname write Setname ;
    property pool:Tpool read Fpool write Setpool;
    property acept : TActor read Facept ;
    property refuse : TActor read Frefuse ;
    property compliance : TActor read Fcompliance ;
    property choice  : TActor read Fchoice;
    property nacept : String read Fnacept ;
    property nrefuse : String read Fnrefuse;
    property ncompliance : String read Fncompliance ;
    property nchoice  : String read Fnchoice ;
    property status : Tstatus read Fstatus;
    property parsed:boolean read Fparsed;
 end;



  procedure teste;



implementation

procedure teste;
var pool, pool2, pool3:Tpool; pools :Tpools;
  cont: Integer;
  json1: TJSONObject;
begin
  pools:=Tpools.Create;
  pool:=pools.getPool('predict');
  pool2:=Tpool.create('act');
  pool3:=Tpool.create('check');

  json1:=TJSONObject.Create;
  json1.Add('name','talvez');
  json1.Add('pool',pool.name);
  json1.Add('acept',TJSONObject.Create(['name','sim','pool',pool.name]));
  pool.add(TActor.Create(json1,pools));
  pool.add(TActor.Create(pool.Items[0],nil,nil,pool,'sim'));
  pool.add(TActor.Create(pool.Items[0],nil,nil,pool,'nao'));
  pool.SaveToFile('teste1.json');

  cont:=0;
  while cont < pool.Count do
  begin
    pool.Items[cont].choose(pool.tendency);
    pool.adjustTendency(pool.Items[cont].status);
    inc(cont);
  end;
  pool.SaveToFile('teste2.json');
end;




{ Tpools }

function Tpools.GetItems(Index: integer): Tpool;
begin
  Result:= Tpool(Inherited Items[Index]);
end;

procedure Tpools.SetItems(Index: integer; AValue: Tpool);
begin
 Inherited Items[Index]:=Pointer(AValue);
end;

destructor Tpools.destroy;
var
  cont: Integer;
begin
  for cont:= 0 to self.Count-1 do
    self.Items[cont].Free;
  inherited destroy;
end;

function Tpools.getPool(name: string): Tpool;
var
  cont: Integer;
begin
  for cont:=0 to self.Count -1 do
  begin
    if name = self.Items[cont].name then
    begin
      result:=self.Items[cont];
      exit;
    end;
  end;
  //else
  result:=Tpool.Create(name);
  result.Owner:=self;
  self.add(Result);
end;

{ Tpool }

function Tpool.GetItems(Index: integer): TActor;
begin
  Result:= TActor(Inherited Items[Index]);
end;

procedure Tpool.SetItems(Index: integer; AValue: TActor);
begin
  inherited Items[Index]:=(AValue);
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
  S:='';
  for cont:=0 to self.Count-1 do
  begin
    objeto:=self.Items[cont];
    jpool.Add(IntToStr(cont),objeto.getjsonOBJ);
    //S:=S+'    '+self.items[cont].jsonOBJ.AsjsonIdent('   ')+#13;
  end;
  F:=TFileStream.Create(FileName,fmCreate);
  try
    If Assigned(FRoot) then
      S:=FRoot.AsjsonIdent;
      //S:=FRoot.Items[0].AsjsonIdent();
      FRoot.Free;
    If length(S)>0 then
      F.WriteBuffer(S[1],Length(S));
//    FModified:=False;
  finally
    f.Destroy;
    f:=nil;
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

procedure Tpool.adjustTendency(status: tstatus);
begin
  if (loConsonant in Ftendency) and ( loDissonant in Ftendency) then
  begin
    case status of
    stAcept     : inc(consonantvalue);
    //stRefuse    : inc(consonantvalue);// no refuse relevant
    stcompliance: inc(dissonantvalue);
    end;
  end else
  if loDissonant in Ftendency then
  begin
    case status of
    stAcept     : inc(consonantvalue);
    stRefuse    : inc(dissonantvalue);
    //stcompliance: inc(consonantvalue); no comliance relevant
    end;
  end else
  if loConsonant in Ftendency then
  begin
    case status of
    stAcept     : inc(dissonantvalue);
    stRefuse    : inc(dissonantvalue);
    stcompliance: inc(consonantvalue);
    end;
  end
  else
  begin
    case status of
    stAcept     : inc(dissonantvalue);
    stRefuse    : inc(dissonantvalue);
    stcompliance: inc(consonantvalue);
    end;
  end;
  //if dissonantvalue >0 ;
end;

function Tpool.add(item: TActor): integer;
var
  cont: Integer;
begin
  for cont:=0 to self.Count -1 do
  begin
   if self.Items[cont].name = item.name then
   begin
     result:=cont;
     if self.Items[cont] <> item then
       raise Exception.Create('tpoolexception actor '+item.name+' already exists in'+self.name);
     Break;
   end;
  end;
    inherited add((item));
end;

constructor Tpool.create(aName:string);
begin
  inherited create;
  self.Fname:=aName;
  dissonantvalue:=0;
  consonantvalue:=0;
end;

destructor Tpool.destroy;
var
  cont: Integer;
begin
 // temp.Clear;
  for cont:= 0 to self.Count-1 do
    self.Items[cont].free;
 inherited Destroy;
end;

function Tpool.getActor(aName: string): TActor;
var
  cont: Integer;
begin
  result:=nil;
  for cont:=0 to self.Count -1 do
  begin
   if self.Items[cont].name = aName then
   begin
     result:=self.Items[cont];
     Break;
   end;
  end;
  if not Assigned(result) then
  Raise Exception.Create('TpoolExcepion Actor ['+aName+'] not found in '+self.name);
end;

{ TActor }

procedure TActor.Setpool(AValue: Tpool);
begin
  if Fpool=AValue then Exit;
    Fpool:=AValue
end;

function TActor.getjsonOBJ: TJSONObject;
var
  str1: String;
begin
    Result:=TJSONObject.Create;
    Result.Add('name',name);
    Result.Add('pool',Tpool(pool).name);
    if Assigned(acept) then
    begin
    str1:=acept.name;
    str1:=Tpool(acept.pool).name;
    Result.Add('acept',TJSONObject.Create(['name',Facept.name,'pool',Tpool(Facept.pool).name]));
    end;
    if Assigned(refuse) then
    Result.Add('refuse',TJSONObject.Create(['name',refuse.name,'pool',Tpool(refuse.pool).name]));
    if Assigned(compliance) then
    Result.Add('compliance',TJSONObject.Create(['name',compliance.name,'pool',Tpool(compliance.pool).name]));
    if Assigned(choice) then
    Result.Add('choice',TJSONObject.Create(['name',choice.name,'pool',Tpool(choice.pool).name]));
end;

function TActor.parse: boolean;
begin
  if parsed then result:=true
  else
  begin
    if (not Assigned(Facept)) and (Fnacept <>'') then
    begin
      Facept:= pool.getActor(Fnacept);
    end;
    if (not Assigned(Fcompliance)) and (Fncompliance <>'') then
    begin
      Fcompliance:= pool.getActor(Fncompliance);
    end;
    if (not Assigned(Frefuse)) and (Fnrefuse <>'') then
    begin
      Frefuse:= pool.getActor(Fnrefuse);
    end;
  end;
end;


procedure TActor.Setname(AValue: string);
begin
  if Fname=AValue then Exit;
  if status = stNone then
    Fname:=AValue;
end;

constructor TActor.Create(Aacept, Acompliance, Arefuse: TActor;Apool:Tpool;name:string);
begin
  Facept:= Aacept;
  Fcompliance:= Acompliance;
  Frefuse:= Arefuse;
  Fname:=name;
  if Length(name) = 0 then raise Exception.create('TActorError no name defined');
  if (Facept = nil)and(Frefuse = nil)and(Fcompliance = nil)then raise Exception.Create('TActorError not choices defined, at last one is required');
  if (Facept <> nil)and (Facept = Frefuse) then raise Exception.Create('TActorError acept and refuse must be diferent');
  if Apool = nil then
  begin
    raise Exception.create('TActorError not pool defined');
  end
  else pool:=Apool;
  Fparsed:=true;
  pool.add(self);
end;

constructor TActor.create(AjsonOBJ: TJSONObject;ApoolList:Tpools);
var s:string; var1:variant; str1:string; jsnOBJnull :TJSONObject;
begin
  jsnOBJnull:=TJSONObject.Create;
  jsnOBJnull.Add('name','');

  str1        :=AjsonOBJ.Get('pool','nope');
  Fpool       :=ApoolList.getPool(str1);
  var1        :=AjsonOBJ.AsJSON;
  Fname       :=AjsonOBJ.Get('name');;
  Fnacept     :=AjsonOBJ.Get('acept',jsnOBJnull).Get('name');
  Fncompliance:=AjsonOBJ.Get('compliance',jsnOBJnull).Get('name');
  Fnrefuse    :=AjsonOBJ.Get('refuse',jsnOBJnull).Get('name');
  Fnchoice    :=AjsonOBJ.Get('choice',jsnOBJnull).Get('name');
  Fparsed     :=false;
  AjsonOBJ.Free;
  jsnOBJnull.Free;

  if (Length(fname) = 0) then raise Exception.create('TActorError no name defined');
  if (Length(Fnacept)= 0) and (Length(Fnrefuse ) = 0) and (Length(Fncompliance)= 0) then raise Exception.Create('TActorError not choices defined, at last one is required');
  if (Fnacept <> '')and (Fnacept = Fnrefuse) then raise Exception.Create('TActorError acept and refuse must be diferent');
  pool.add(self);
end;

function TActor.choose(TendencyOptions: TChoiceOptions): Tstatus;
begin
  if not parse then
  begin
    exit;
  end;
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
        Facept:=TActor.Create(self,compliance,refuse,pool,'acept-'+name);
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
      pool.Add(Fcompliance);
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

