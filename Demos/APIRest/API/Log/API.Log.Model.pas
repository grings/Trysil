(*

  Trysil
  Copyright � David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit API.Log.Model;

{$WARN UNKNOWN_CUSTOM_ATTRIBUTE ERROR}

interface

uses
  System.Classes,
  System.SysUtils,
  Trysil.Types,
  Trysil.Attributes,
  Trysil.Http.Log.Types;

type

{ TLogAction }

  [TTable('LogActions')]
  [TSequence('LogActionsID')]
  TLogAction = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TColumn('TaskID')]
    FTaskID: String;

    [TColumn('LogDate')]
    FLogDate: TDateTime;

    [TColumn('Action')]
    FAction: String;

    [TVersionColumn]
    [TColumn('VersionID')]
    FVersionID: TTVersion;
  public
    procedure SetValues(const AAction: TTHttpLogAction);

    property ID: TTPrimaryKey read FID;
    property TaskID: String read FTaskID;
    property LogDate: TDateTime read FLogDate;
    property Action: String read FAction;
    property VersionID: TTVersion read FVersionID;
  end;

{ TLogRequest }

  [TTable('LogRequests')]
  [TSequence('LogRequestsID')]
  TLogRequest = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TColumn('TaskID')]
    FTaskID: String;

    [TColumn('LogDate')]
    FLogDate: TDateTime;

    [TColumn('Uri')]
    FUri: String;

    [TColumn('Params')]
    FParams: String;

    [TColumn('MethodType')]
    FMethodType: String;

    [TColumn('Content')]
    FContent: String;

    [TColumn('Headers')]
    FHeaders: String;

    [TColumn('RemoteIP')]
    FRemoteIP: String;

    [TVersionColumn]
    [TColumn('VersionID')]
    FVersionID: TTVersion;
  public
    procedure SetValues(const ARequest: TTHttpLogRequest);

    property ID: TTPrimaryKey read FID;
    property TaskID: String read FTaskID;
    property LogDate: TDateTime read FLogDate;
    property Uri: String read FUri;
    property Params: String read FParams;
    property MethodType: String read FMethodType;
    property Content: String read FContent;
    property Headers: String read FHeaders;
    property RemoteIP: String read FRemoteIP;
    property VersionID: TTVersion read FVersionID;
  end;

{ TLogResponses }

  [TTable('LogResponses')]
  [TSequence('LogResponsesID')]
  TLogResponse = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TColumn('TaskID')]
    FTaskID: String;

    [TColumn('LogDate')]
    FLogDate: TDateTime;

    [TColumn('Username')]
    FUsername: String;

    [TColumn('UserAreas')]
    FUserAreas: String;

    [TColumn('StatusCode')]
    FStatusCode: Integer;

    [TColumn('ContentType')]
    FContentType: String;

    [TColumn('ContentEncoding')]
    FContentEncoding: String;

    [TColumn('Content')]
    FContent: String;

    [TVersionColumn]
    [TColumn('VersionID')]
    FVersionID: TTVersion;
  public
    procedure SetValues(const AResponse: TTHttpLogResponse);

    property ID: TTPrimaryKey read FID;
    property TaskID: String read FTaskID;
    property LogDate: TDateTime read FLogDate;
    property Username: String read FUsername;
    property UserAreas: String read FUserAreas;
    property StatusCode: Integer read FStatusCode;
    property ContentType: String read FContentType;
    property ContentEncoding: String read FContentEncoding;
    property Content: String read FContent;
    property VersionID: TTVersion read FVersionID;
  end;

implementation

{ TLogAction }

procedure TLogAction.SetValues(const AAction: TTHttpLogAction);
begin
  FTaskID := AAction.TaskID;
  FLogDate := AAction.DateTime;
  FAction := AAction.Action;
end;

{ TLogRequest }

procedure TLogRequest.SetValues(const ARequest: TTHttpLogRequest);
begin
  FTaskID := ARequest.TaskID.ToString;
  FLogDate := ARequest.DateTime;
  FUri := ARequest.Uri;
  FParams := ARequest.Params.ToString;
  FMethodType := ARequest.MethodType;;
  FContent := ARequest.Content;
  FHeaders := ARequest.Headers.ToString;
  FRemoteIP := ARequest.RemoteIP;
end;

{ TLogResponse }

procedure TLogResponse.SetValues(const AResponse: TTHttpLogResponse);
begin
  FTaskID := AResponse.TaskID.ToString;
  FLogDate := AResponse.DateTime;
  FUsername := AResponse.User.Username;
  FUserAreas := AResponse.User.Areas.ToString;
  FStatusCode := AResponse.StatusCode;
  FContentType := AResponse.ContentType;
  FContentEncoding := AResponse.ContentEncoding;
  FContent := AResponse.Content;
end;

end.