table 50261 "Vendor Export Log Table"
{
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(2; "File Name"; Text[250])
        {
            DataClassification = SystemMetadata;
        }
        field(3; "AZ Storage Table Rec. Created"; DateTime)
        {
            DataClassification = ToBeClassified;
        }
        field(4; "URL"; Text[250])
        {
            DataClassification = SystemMetadata;
            ExtendedDatatype = URL;
        }
        field(5; Status; Enum "Vendor Log Status")
        {
            DataClassification = SystemMetadata;
        }
        field(6; Error; Text[250])
        {
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
    }

    var


    trigger OnInsert()
    var
        EntryNo: Integer;
    begin
        Rec."AZ Storage Table Rec. Created" := CurrentDateTime();
    end;

    procedure InsertLog(_fileName: Text[250]; _fullURL: Text[250]; _status: Enum "Vendor Log Status"; _error: Text)
    var
    begin
        Rec.Init();
        Rec."Entry No." := GetLastEntryNo() + 1;
        Rec.Insert(true);
        Rec."File Name" := CopyStr(_fileName, 1, MaxStrLen(Rec."File Name"));
        Rec.URL := CopyStr(_fullURL, 1, MaxStrLen(Rec.URL));
        Rec.Status := _status;
        Rec.Error := CopyStr(_error, 1, MaxStrLen(Rec.Error));
        Rec.Modify(true);
    end;

    procedure GetLastEntryNo(): Integer
    var
        _lastentryno: Integer;
        _rec2: Record "Vendor Export Log Table";
    begin
        if _rec2.FindLast() then
            exit(_rec2."Entry No.")
        else
            exit(0);
    end;

    procedure SendVendorsToBlob(_outSt: OutStream; var _inSt: InStream)
    var
        _blob: Codeunit "Temp Blob";
        _vendor: Record Vendor;
    begin
        _blob.CreateOutStream(_outSt);

        if _vendor.Findset() then
            repeat
                _outSt.WriteText(Format(_vendor));
            until _vendor.next() = 0;

        _blob.CreateInStream(_inSt);
    end;
}