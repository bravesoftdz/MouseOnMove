unit UMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Imaging.pngimage,
  Vcl.ExtCtrls, Vcl.Menus;

type
  TForm1 = class(TForm)
    btnStart: TButton;
    btnStop: TButton;
    Image1: TImage;
    Timer1: TTimer;
    Label1: TLabel;
    editInterval: TEdit;
    Label2: TLabel;
    TrayIcon1: TTrayIcon;
    PopupMenu1: TPopupMenu;
    ShowApplication1: TMenuItem;
    Exit1: TMenuItem;
    Label3: TLabel;
    Label4: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Timer1Timer(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure ShowApplicationClick(Sender: TObject);
    procedure TrayIcon1DblClick(Sender: TObject);
    procedure WMSysCommand(var Msg: TWMSysCommand); message WM_SYSCOMMAND;

  private
    { Private declarations }
    procedure hotkey(var msg:TMessage);message WM_HOTKEY;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  aatom:ATOM;
function GetLastInput: integer; //��ȡ����ʱ��(��)


implementation
const
  default_seconds: string = '20';
{$R *.dfm}

procedure TForm1.btnStartClick(Sender: TObject);
begin
  timer1.Interval := 1000; // ÿ����һ��
  timer1.Enabled := true;
  editInterval.ReadOnly := timer1.Enabled;
  btnStart.Enabled := not timer1.Enabled;
  btnStop.Enabled := timer1.Enabled;
  Hide;
end;

procedure TForm1.btnStopClick(Sender: TObject);
begin
  timer1.Enabled := false;
  editInterval.ReadOnly := timer1.Enabled;
  btnStart.Enabled := not timer1.Enabled;
  btnStop.Enabled := timer1.Enabled;
  Caption := 'Mouse On Move';

  ShowApplicationClick(Sender);

end;

{ Exit menu item click}
procedure TForm1.Exit1Click(Sender: TObject);
begin
  Close();
end;

{ End application. }
procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  UnregisterHotKey(Handle, aatom);
  GlobalDeleteAtom(aatom);
end;

{ Create form. }
procedure TForm1.FormCreate(Sender: TObject);
begin
  TrayIcon1.Visible := true;

  editInterval.Text := default_seconds;
  btnStop.Enabled := false;
  if FindAtom('ZWXhotKey')=0 then
  begin
    aatom:=GlobalAddAtom('ZWXhotKey');
  end;
  if RegisterHotKey(Handle, aatom, MOD_ALT, $51) then
  begin
    ;
  end;
  if RegisterHotKey(Handle, aatom, MOD_ALT, $53) then
  begin
    ;
  end;
end;

{ ע��ϵͳ�ȼ� }
procedure TForm1.hotkey(var msg: TMessage);
begin
  if TWMHotKey(msg).HotKey = aatom then
  begin
    //ShowMessage('s');
  end;
  if (msg.LParamHi=$51) and (msg.LParamLo=MOD_ALT) then
  begin
    // ��ݼ���Ӧ ALT + Q  Stop
    btnStop.Click;
  end;
  if (msg.LParamHi=$53) and (msg.LParamLo=MOD_ALT) then
  begin
    // ��ݼ���Ӧ Alt + S  Start
    btnStop.Click;
    btnStart.Click;
  end;
end;

{ Show Window Menu item. }
procedure TForm1.ShowApplicationClick(Sender: TObject);
begin
  if IsIconic(Application.Handle) = True then  // �����Ƿ���С��
    Application.Restore              // �ָ�����
  else
    Application.BringToFront;        // �ᵽǰ����ʾ
  Show;
  Application.BringToFront;          // �ᵽǰ����ʾ
end;

{ Double Click TrayIcon. }
procedure TForm1.TrayIcon1DblClick(Sender: TObject);
begin
  ShowApplicationClick(Sender);
end;

{ Timer event. }
procedure TForm1.Timer1Timer(Sender: TObject);
var
  offset: Integer;
  seconds: Integer;
begin
  try
    seconds := StrToInt(editInterval.Text);
  except
    editInterval.Text := default_seconds; // default value;
    seconds := StrToInt(editInterval.Text);
  end;

  Caption := 'Mouse On Move' + ' [' + IntToStr(seconds - GetLastInput) + ']';
  if GetLastInput > seconds then
  begin
    // ���û���κ�����
    offset := Random(1); // 0 - 10 �����������
    //mouse_event(1, offset, offset, 0, 0);
    mouse_event(1, 0, 0, 0, 0);
    //Caption := 'Mouse On Move' + ' [' + IntToStr(seconds - GetLastInput) + ']';
  end;
end;

{ ��ȡ����ʱ��(��) }
function GetLastInput: integer;
var
  LInput: TLastInputInfo;
begin
  Result := 0;
  try
    LInput.cbSize := SizeOf(TLastInputInfo);
    GetLastInputInfo(LInput);
    Result := ((GetTickCount - LInput.dwTime) div 1000);
  except
  end;
end;

{ ��С����ť ����¼�}
procedure TForm1.WMSysCommand(var Msg: TWMSysCommand);
begin
  inherited;
  if Msg.CmdType = SC_MINIMIZE then
  begin
    Application.Minimize;                    // ��С������
    ShowWindow(Application.Handle, SW_HIDE); // ����������ͼ��
  end;
end;

end.
