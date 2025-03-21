unit TThreadA;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Types,
  Winapi.Windows,
  System.Win.ScktComp,
  System.SyncObjs;

type
  TThreadMousePosition=class(TThread)
  private
    NotTerminate: Boolean;
    FFormHandle: HWND;
    ServerSocket: TServerSocket;
    CriticalSection: TCriticalSection;
  protected
    procedure Execute; override;
  public
    constructor Create;
    destructor Destroy; override;
    procedure SetFormHandle(FormHandle: HWND);
  end;

implementation

uses TThreadB;

var MouseMove: TThreadMouseMove;

constructor TThreadMousePosition.Create;
begin
  inherited Create(False);
  ServerSocket:=TServerSocket.Create(nil);
  ServerSocket.Port:=55000;
  ServerSocket.Active:=True;
  NotTerminate:=True;
  FreeOnTerminate:=True;
  CriticalSection:=TCriticalSection.Create;
end;

procedure TThreadMousePosition.Execute;
var
  MousePosition: TPoint;
  FormRect: TRect;
  I: Integer;
begin
  MouseMove:=TThreadMouseMove.Create(CriticalSection);
  while NotTerminate do
  begin
    CriticalSection.Enter;
    GetWindowRect(FFormHandle,FormRect);
    GetCursorPos(MousePosition);
    MousePosition.X:=MousePosition.X-FormRect.Left;
    MousePosition.Y:=MousePosition.Y-FormRect.Top;
    MouseMove.MousePosition:=MousePosition;
    CriticalSection.Leave;
    if not MouseMove.Started then MouseMove.Started:=True;
    Sleep(10);
    CriticalSection.Enter;
    I:=0;
    while I < ServerSocket.Socket.ActiveConnections do
    begin
      ServerSocket.Socket.Connections[I].SendText(IntToStr(MouseMove.MousePosition.X)+'|'+IntToStr(MouseMove.MousePosition.Y));
      Inc(I);
    end;
    CriticalSection.Leave;
  end;
end;

destructor TThreadMousePosition.Destroy;
begin
  NotTerminate:=False;
  Sleep(500);
  ServerSocket.Free;
end;

procedure TThreadMousePosition.SetFormHandle(FormHandle: HWND);
begin
  FFormHandle:=FormHandle;
end;

end.
