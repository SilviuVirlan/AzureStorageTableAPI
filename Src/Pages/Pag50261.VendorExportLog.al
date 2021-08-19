page 50261 "Vendor Export Logs"
{

    ApplicationArea = All;
    Caption = 'Vendor Export Log Table';
    PageType = List;
    SourceTable = "Vendor Export Log Table";
    UsageCategory = Administration;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    Editable = false;
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the value of the Entry No. field';
                    ApplicationArea = All;
                }
                field("File Created"; Rec."AZ Storage Table Rec. Created")
                {
                    ToolTip = 'Specifies the value of the File Created field';
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }
                field(Error; Rec.Error)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(DeleteAll)
            {
                ApplicationArea = All;
                Caption = 'Delete all logs';
                ToolTip = 'Delete all logs';
                Image = RefreshLines;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                trigger OnAction()
                var
                begin
                    Rec.DeleteAll(true);
                end;
            }
            action(WriteFileInAzureTable)
            {
                ApplicationArea = All;
                Caption = 'Write File In Azure Table';
                ToolTip = 'Write File In Azure Table';
                Image = RefreshLines;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                trigger OnAction()
                var
                    client: HttpClient;
                    response: HttpResponseMessage;
                    requestContent: HttpContent;
                    contentHeaders: HttpHeaders;
                    _azureStorageSetup: Record "Azure Storage Table Setup";
                    _vendor: Record Vendor;
                    _jsonObject: JsonObject;
                    _fileName: Text;
                    _fullURL: Text;
                    _status: Enum "Vendor Log Status";
                    _error: Boolean;
                begin
                    _azureStorageSetup.Get();
                    _fullURL := StrSubstNo('%1%2/?%3', _azureStorageSetup."Account URL",
                                                          _azureStorageSetup."Azure Table Name",
                                                          _azureStorageSetup."SAS Token");
                    if _vendor.Findset() then
                        repeat
                            JSonVendor(_vendor, _jsonObject);
                            client.DefaultRequestHeaders().Add('Accept', 'application/json');
                            requestContent.WriteFrom(Format(_jsonObject));
                            requestContent.GetHeaders(contentHeaders);
                            contentHeaders.Remove('Content-Type');
                            contentHeaders.Add('Content-Type', 'application/json');
                            if not client.Post(_fullURL, requestContent, response) then begin
                                Rec.InsertLog(StrSubstNo('Vendor: %1', _vendor."No."), _fullURL, _status::Failed, GetLastErrorCode);
                                _error := true;
                            end;
                            if not response.IsSuccessStatusCode() then begin
                                Rec.InsertLog(StrSubstNo('Vendor: %1', _vendor."No."), _fullURL, _status::Failed, response.ReasonPhrase);
                                _error := true;
                            end;
                            if not _error then begin
                                Rec.InsertLog(StrSubstNo('Vendor: %1', _vendor."No."), _fullURL, _status::Sent, '');
                            end;
                            CurrPage.Update(false);
                            Clear(_jsonObject);
                            client.Clear();
                            requestContent.Clear();
                        until _vendor.Next() = 0;
                end;
            }
        }
    }

    local procedure JSonVendor(_vendor: Record Vendor; var _jsonObject: JsonObject)
    begin
        _vendor.Get(_vendor."No.");
        _jsonObject.Add('PartitionKey', '');
        _jsonObject.Add('RowKey', StrsubstNo('"%1"', _vendor.SystemId));
        _jsonObject.Add('Name', Format(_vendor.Name));
        _jsonObject.Add('No', Format(_vendor."No."));
    end;
}
