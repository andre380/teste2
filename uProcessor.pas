unit uProcessor;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,uActor;
type

  { Tprocessor }

  Tprocessor = class(TThread)
  private
    runing:Boolean;
  public
    pool:Tpool;
    constructor create(CreateSuspended :boolean =false);
    destructor Destroy; override;
    procedure Execute; override;
  end;

implementation

{ Tprocessor }

constructor Tprocessor.create(CreateSuspended :boolean =false);
begin
  runing:=True;
  Inherited Create(CreateSuspended);
  pool:=nil;
end;

destructor Tprocessor.Destroy;
begin
  self.runing:=false;
  while not self.Suspended do;//wait
  inherited Destroy;
end;

procedure Tprocessor.Execute;
var
  cont: Integer;
begin
  while runing do
  begin
    if pool<>nil then
    begin
      cont:=0;
      while cont < pool.Count-1 do
      begin
        pool.Items[cont].choose(pool.tendency);
        pool.adjustTendency(pool.Items[cont].status);
        inc(cont);
      end;
    end;
  end;
end;

end.

