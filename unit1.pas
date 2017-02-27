unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls,uActor,fpjson_1, jsonparser1, dateutils;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Label1: TLabel;
    Label2: TLabel;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    Timer1: TTimer;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    indice:integer;
    pool:Tpool;
    lista:Tlista;
    listas: array[0..10] of Tlista;
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
var
  stl1: TStringList;

  cont, indice2, cont2: Integer;
  actor, actor1: TActor;
  json1: TJSONObject;
  time2: TDateTime;

begin
  //pool.clear;

    json1:=TJSONObject.Create;
    json1.Add('name','teste A');
    json1.Add('pool','direita');
    json1.Add('acept',TJSONObject.Create(['name','aaaa','pool','direita']));

  lista.add(TActor.Create(json1,pool));
  lista.add(TActor.Create(lista.itens[0],nil,nil,pool,'teste B'));
  lista.add(TActor.Create(lista.itens[0],nil,nil,pool,'teste C'));
  //lista.add(TActor.Create(pool.Items[pool.count-1],nil,nil,pool,'teste B'));
  //lista.add(TActor.Create(pool.Items[pool.count-1],nil,nil,pool,'teste C'));
  json1.free;
  try
  time2:=now;

  for cont := 0 to 1900000 do
  begin
    //lista.add(TActor.Create(pool.Items[pool.Count-1],
    //                       pool.Items[pool.Count-2],
    //                       pool.Items[pool.Count-3],
    //                       pool,'teste'+IntToStr(cont)));
    actor:=(TActor.Create(lista.itens[1],
                           lista.itens[2],
                           lista.itens[2],
                           pool,'teste'+IntToStr(cont)));
    if now > IncSecond(time2) then
    begin
    time2:=now;
    label2.Caption:=IntToStr(cont);
    label2.Update;
    end;
  end;

  except on e:Exception do
  begin
    ShowMessage(e.Message);
  end;
  end;
  sleep(3000);
  //if SaveDialog1.Execute then
  //pool.SaveToFile(SaveDialog1.FileName);
  //pool.Free;

end;

procedure TForm1.Button3Click(Sender: TObject);
var
  cont, cont2, cont3: Integer;  pools: Tpools; pool1:Tpool;
  json1: TJSONObject;
begin

  //for cont3:=0 to 20 do
  begin
  pools:=Tpools.Create;
  for cont := 0 to 1 do
  begin
    pool1:=pools.addnew('lista'+IntToStr(cont));
    json1:=TJSONObject.Create;
    json1.Add('name','objeto1');
    json1.Add('pool',pool1.name);
    json1.Add('acept',TJSONObject.Create(['name','aaaa','pool',pool.name]));
    pool1.add(TActor.Create(json1,pool1));
    pool1.add(TActor.Create(pool1.Items[0],nil,nil,pool1,'objeto2'));
    pool1.add(TActor.Create(pool1.Items[0],nil,nil,pool1,'objeto3'));
    for cont2:= 4 to 100000 do
    begin
      pool1.add(TActor.Create(pool1.Items[cont2-4],
                              pool1.Items[cont2-3],
                              pool1.Items[cont2-2],
                              pool1,'objeto'+IntToStr(cont2)));
    end;
    pool1.SaveToFile(ExtractFileDir(ParamStr(0))+'\json\'+pool1.name+'.json');
  end;
  Label2.Caption:=('apaga '+IntToStr(cont3));
  Sleep(2000);
  pools.free;

  end;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  pool.free;
  pool:=Tpool.create('direita');
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  cont: Integer;
begin
  pool:=Tpool.Create('direita');
  lista:=Tlista.Create;
  //for cont := 0 to 10 do
  //listas[cont]:=Tlista.Create;
end;

procedure TForm1.Button2Click(Sender: TObject);
Var
  F : TFileStream;
  P : TJSONParser;
  Root, jpool: TJSONData;
  cont: Integer;
  S:string;
begin
  if OpenDialog1.execute then
  begin
    F:=TFileStream.Create(OpenDialog1.FileName,fmOpenRead);
    try
      P:=TJSONParser.Create(F);
      try
        P.Strict:=true;
        Root:=P.Parse;
      finally
        P.Free;
      end;
    finally
      F.Free;
    end;
    S:=Root.AsjsonIdent();
   if SaveDialog1.Execute then
   begin
     F:=TFileStream.Create(SaveDialog1.FileName,fmCreate);
     If length(S)>0 then
      F.WriteBuffer(S[1],Length(S));
     F.Free;
   end;
   root.Free;
  end;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  //Label1.Caption:='currHeapSize = '+ FloatToStr((GetFPCHeapStatus.CurrHeapSize))+#13+
  //                'currHeapUsed = '+ FloatToStr((GetFPCHeapStatus.CurrHeapUsed))+#13+
  //                'currHeapFree = '+ FloatToStr((GetFPCHeapStatus.CurrHeapFree))+#13+
  //                'MaxHeapSize  = '+ FloatToStr((GetFPCHeapStatus.MaxHeapSize))+#13+
  //                'maxHeapused  = '+ FloatToStr((GetFPCHeapStatus.MaxHeapUsed))+#13+
  //                'indice = '+IntToStr(indice);
end;

end.

