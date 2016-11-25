unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    SaveDialog1: TSaveDialog;
    procedure Button1Click(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

uses uActor;
{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
var
  stl1: TStringList;
  pool:Tpool;
  cont: Integer;
begin
  pool:=Tpool.Create('direita');
  pool.add(TActor.Create(TActor(stl1),nil,nil,pool,'teste'));
  for cont := 0 to 1000000 do
  begin
    pool.add(TActor.Create(pool.Items[pool.Count-1],nil,nil,pool,'teste'+IntToStr(cont)));
  end;
  //if SaveDialog1.Execute then
  //pool.SaveToFile(SaveDialog1.FileName);
  //stl1:=TStringList.Create;
  //stl1.SaveToFile();

end;

end.

