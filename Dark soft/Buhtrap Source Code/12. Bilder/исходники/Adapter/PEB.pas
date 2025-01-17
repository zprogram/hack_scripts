unit PEB;

interface
uses
  Windows, SysUtils;


function PEBGetModuleHandle(szModule: LPCWSTR): HMODULE;

implementation

Type
  USHORT = DWORD;
  PVOID = Pointer;

  UNICODE_STRING = record
    Length : USHORT;
    MaximumLength : USHORT;
    Buffer : LPWSTR;
  end;

  _LDR_MODULE = record
    InLoadOrderModuleList : LIST_ENTRY;
    InMemoryOrderModuleList : LIST_ENTRY;
    InInitializationOrderModuleList : LIST_ENTRY;
    BaseAddress : PVOID;
    EntryPoint : PVOID;
    SizeOfImage : ULONG;
    FullDllName : UNICODE_STRING;
    BaseDllName : UNICODE_STRING;
    Flags : ULONG;
    LoadCount : SHORT;
    TlsIndex : SHORT;
    HashTableEntry : LIST_ENTRY;
    TimeDateStamp : ULONG;
  end;
  PLDR_MODULE = ^_LDR_MODULE;

function GET_LDR_MODULE(): PLDR_MODULE;
asm
  MOV EAX, FS:[18h]; // TEB (Thread Environment Block)
  MOV EAX, [ EAX + 30h ]; // PEB (Process Environment Block)
  MOV EAX, [ EAX + 0Ch ]; // pModule
  MOV EAX, [ EAX + 0Ch ]; // pModule->InLoadOrderModuleList.Flink
  MOV Result, EAX;
end;

function PEBGetModuleHandle(szModule: LPCWSTR): HMODULE;
var
  PModule : PLDR_MODULE;
begin
  Result := 0;
  PModule := GET_LDR_MODULE;
  while (PModule.BaseAddress <> nil) do
  begin
    if (lstrcmpiw(pModule.BaseDllName.Buffer, szModule) = 0) then
      begin
        Result := HMODULE(pModule.BaseAddress);
        Exit;
      end;
    pModule := PLDR_MODULE(pModule.InLoadOrderModuleList.Flink);
  end;
end;

end.
