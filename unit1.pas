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

uses uActor,fpjson;
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
    json1.Add('name','aaaa');
    json1.Add('pool','direita');
    json1.Add('acept',TJSONObject.Create(['name','aaaa','pool','direita']));

  pool.add(TActor.Create(json1,pool));
  pool.add(TActor.Create(pool.Items[0],nil,nil,pool,'testea'));
  pool.add(TActor.Create(pool.Items[0],nil,nil,pool,'testeb'));
  for cont := 0 to 5 do
  begin
    pool.add(TActor.Create(pool.Items[pool.Count-1],
                           pool.Items[pool.Count-2],
                           pool.Items[pool.Count-3],pool,'teste'+IntToStr(cont)));
  end;
  if SaveDialog1.Execute then
  pool.SaveToFile(SaveDialog1.FileName);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    //tjs
  end;
end;

end.

