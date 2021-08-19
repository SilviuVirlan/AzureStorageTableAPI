table 50260 "Azure Storage Table Setup"
{
    Caption = 'Azure Storage Table Setup';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; PK; Code[1])
        {
            Caption = 'PK';
            DataClassification = SystemMetadata;
        }
        field(2; "Account URL"; Text[250])
        {
            Caption = 'Account URL';
            DataClassification = SystemMetadata;
        }
        field(3; "SAS Token"; Text[250])
        {
            Caption = 'SAS Token';
            DataClassification = SystemMetadata;
        }
        field(4; "Azure Table Name"; Text[250])
        {
            Caption = 'Container Name';
            DataClassification = SystemMetadata;
        }
    }
    keys
    {
        key(PK; PK)
        {
            Clustered = true;
        }
    }
}
