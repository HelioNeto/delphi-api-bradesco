program ApiBradesco;

uses
  Vcl.Forms,
  uApiBradesco in 'uApiBradesco.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
