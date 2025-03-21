unit TThreadB;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Types,
  System.SyncObjs,
  MouseUnit;

type
  TThreadMouseMove=class(TThread)
  private
    NotTerminate: Boolean;
    FMousePosition: TPoint;
    FStarted: Boolean;
    CriticalSection: TCriticalSection;
  protected
    procedure Execute; override;
  public
    constructor Create(ACriticalSection: TCriticalSection);
    destructor Destroy; override;
    property MousePosition: TPoint read FMousePosition write FMousePosition;
    property Started: Boolean read FStarted write FStarted;
  end;

implementation

constructor TThreadMouseMove.Create(ACriticalSection: TCriticalSection);
begin
  inherited Create(False);
  FreeOnTerminate:=True;
  NotTerminate:=True;
  FMousePosition:=TPoint.Zero;
  CriticalSection:=ACriticalSection;
  FStarted:=False;
end;

procedure TThreadMouseMove.Execute;
begin
  while NotTerminate do
  begin
    if FStarted then
    begin
      CriticalSection.Enter;
      MouseForm.MouseImage.Left:=FMousePosition.X-8;
      MouseForm.MouseImage.Top:=FMousePosition.Y-33;
      MouseForm.Label2.Caption:='X: '+IntToStr(FMousePosition.X);
      MouseForm.Label3.Caption:='Y: '+IntToStr(FMousePosition.Y);
      CriticalSection.Leave;
    end;
    Sleep(1);
  end;
end;

destructor TThreadMouseMove.Destroy;
begin
  NotTerminate:=False;
end;

end.
