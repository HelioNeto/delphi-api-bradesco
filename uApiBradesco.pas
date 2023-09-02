unit uApiBradesco;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls, System.JSON,
  System.DateUtils, synacode, ACBrDFeSSL, IpPeerClient, IdBaseComponent,
  IdComponent, IdTCPConnection, IdTCPClient, IdHTTP, IdIOHandler, IdIOHandlerSocket,
  IdIOHandlerStack, IdSSL, IdSSLOpenSSL,
  IdCookieManager, IdURI, IdZLibCompressorBase, IdCompressorZLib, System.NetEncoding;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Memo1: TMemo;
    btnGerarToken: TBitBtn;
    editToken: TEdit;
    Label1: TLabel;
    lblTokenExpira: TLabel;
    Label2: TLabel;
    procedure btnGerarTokenClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    DFeSSL: TDFeSSL;
    FHTTP: TIdHTTP;
    FIdSSLIOHandlerSocketOpenSSL : TIdSSLIOHandlerSocketOpenSSL;
    function calcularHash(AAut: TStream): string;
  public
    { Public declarations }
  end;

const

  URL_TOKEN = 'https://proxy.api.prebanco.com.br/auth/server/v1.1/token';
  CLIENT_ID = 'bc7ccf09-8a85-4be6-y67e-82bf11737994';

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.btnGerarTokenClick(Sender: TObject);
var
  jsonHeader, jsonPayload, objJson: TJsonObject;
  intSegundos, intSegundos1h, intMilisegundos: Int64;
  dataAtual: TDateTime;
  strHeaderBase64, strPayloadBase64, strResult: string;
  strAssinado, strJWS: WideString;
  streamHeaderPayload : TStringStream;
  xRequestBody : TStringList;
begin

  jsonHeader := TJSONObject.Create;
  jsonHeader.AddPair('alg','RS256');
  jsonHeader.AddPair('typ', 'JWT');

  strHeaderBase64 := EncodeBase64(AnsiString(jsonHeader.ToString));

{
 "aud" : "https://proxy.api.prebanco.com.br/auth/server/v1.1/token",
 "sub" : "bc7ccf09-8a85-4be6-y67e-82bf11737994", <id cliente fornecido pelo banco>
 "iat" : "1612899472", <data atual em segundos>
 "exp" : "1612903071", <data atual adicionando uma hora à frente, em segundos>
 "jti" : "1574094116000", <data atual em milissegundos>
 "ver" : "1.1"
}

  dataAtual := now;
  intSegundos := DateTimeToUnix(dataAtual, False);
  intSegundos1h := DateTimeToUnix(IncHour(dataAtual, 1), False);
  intMilisegundos := DateTimeToUnix(dataAtual, False) * 1000 + MilliSecondsBetween(dataAtual, Trunc(dataAtual));

  jsonPayload := TJSONObject.Create;
  jsonPayload.AddPair('aud', URL_TOKEN);
  jsonPayload.AddPair('sub', CLIENT_ID);
  jsonPayload.AddPair('iat', IntToStr(intSegundos));
  jsonPayload.AddPair('exp', IntToStr(intSegundos1h));
  jsonPayload.AddPair('jti', IntToStr(intMilisegundos));
  jsonPayload.AddPair('ver', '1.1');

  strPayloadBase64 := EncodeBase64(AnsiString(jsonPayload.ToString));

  streamHeaderPayload := TStringStream.Create(strHeaderBase64+'.'+strPayloadBase64);

  DFeSSL.SSLCryptLib      := cryOpenSSL;
  DFeSSL.ArquivoPFX       := 'certificado.pfx';
  DFeSSL.Senha            := '123456';
  DFeSSL.CarregarCertificado;

  strAssinado := calcularHash(streamHeaderPayload);

  strJWS := strHeaderBase64+'.'+strPayloadBase64+'.'+strAssinado;

  FHTTP.Request.Clear;
  FHTTP.Request.CustomHeaders.Clear;
  FHTTP.Request.UserAgent           := 'Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.0; Acoo Browser; GTB5; Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1) ; Maxthon; InfoPath.1; .NET CLR 3.5.30729; .NET CLR 3.0.30618)';
  FHTTP.Request.AcceptCharSet       := 'UTF-8, *;q=0.8';
  FHTTP.Request.AcceptEncoding      := 'gzip, deflate, br';
  FHTTP.Request.ContentType         := 'application/x-www-form-urlencoded';
  FHTTP.Request.BasicAuthentication := False;

  xRequestBody := TStringList.Create;
  xRequestBody.Add('grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer');
  xRequestBody.Add('assertion='+strJWS);

  try
    strResult := FHTTP.Post(URL_TOKEN, xRequestBody);
    Memo1.lines.add(strResult);
    objJson := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(strResult), 0) as TJSONObject;

    if Assigned(objJson.Values['access_token']) then
      if (objJson.Values['access_token'].ToString <> EmptyStr) then
        editToken.Text := TJSONString(objJson.Values['access_token']).Value;

    if Assigned(objJson.Values['expires_in']) then
      if (objJson.Values['expires_in'].ToString <> EmptyStr) then
        lblTokenExpira.Caption := DateTimeToStr(IncSecond(Now, StrToInt(objJson.Values['expires_in'].ToString)));
  except
    on E: EIdHTTPProtocolException do
    begin
      Memo1.Lines.add(E.ErrorMessage);
    end;
  end;

  FreeAndNil(xRequestBody);

end;

function TForm1.calcularHash(AAut: TStream): string;
begin
  Result := DFeSSL.CalcHash(AAut, dgstSHA256, outBase64, True);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  FHTTP                         := TIdHTTP.Create;
  FIdSSLIOHandlerSocketOpenSSL  := TIdSSLIOHandlerSocketOpenSSL.Create(FHTTP);
  FIdSSLIOHandlerSocketOpenSSL.SSLOptions.SSLVersions := [sslvTLSv1_2];
  FHTTP.IOHandler               := FIdSSLIOHandlerSocketOpenSSL;
  FHTTP.CookieManager           := TIdCookieManager.Create(FHTTP);
  FHTTP.ConnectTimeout          := 30000;
  FHTTP.HandleRedirects         := True;
  FHTTP.AllowCookies            := True;
  FHTTP.RedirectMaximum         := 10;
  FHTTP.HTTPOptions             := [hoForceEncodeParams];

  DFeSSL := TDFeSSL.Create();
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  DFeSSL.Free;
end;

end.
