unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

uses uActor,fpjson_1, jsonparser1;
{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
var
  stl1: TStringList;
  pool:Tpool;
  cont: Integer;
  actor: TActor;
  json1: TJSONObject;
begin
  pool:=Tpool.Create('direita');
    json1:=TJSONObject.Create;
    json1.Add('name','teste A');
    json1.Add('pool','direita');
    json1.Add('acept',TJSONObject.Create(['name','aaaa','pool','direita']));

  pool.add(TActor.Create(json1,pool));
  pool.add(TActor.Create(pool.Items[0],nil,nil,pool,'teste B'));
  pool.add(TActor.Create(pool.Items[0],nil,nil,pool,'teste C'));
  //for cont := 0 to 50000 do
  //begin
  //  pool.add(TActor.Create(pool.Items[pool.Count-1],
  //                         pool.Items[pool.Count-2],
  //                         pool.Items[pool.Count-3],
  //                         pool,'teste'+IntToStr(cont)));
  //end;
  if SaveDialog1.Execute then
  pool.SaveToFile(SaveDialog1.FileName);
  pool.Free;
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

end.

