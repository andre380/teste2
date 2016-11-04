unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
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
begin
  pool:=Tpool.Create;
  pool.add(TActor.Create());
  stl1:=TStringList.Create;
  //stl1.SaveToFile();

end;

end.

