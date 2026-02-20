; Demon Synth Windows Installer Script
; Requires Inno Setup 6.x (https://jrsoftware.org/isinfo.php)
;
; © 2024 Nolan Griffis p/k/a Nully Beats
; Nully Beats LLC / Producer Tour Publishing LLC

#define MyAppName "Demon Synth"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "Nully Beats LLC"
#define MyAppURL "https://producertour.com"
#define MyAppCopyright "© 2024 Nolan Griffis p/k/a Nully Beats - Nully Beats LLC / Producer Tour Publishing LLC"

[Setup]
AppId={{8F4B3A2E-1D5C-4E7F-9A8B-2C3D4E5F6A7B}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
AppCopyright={#MyAppCopyright}
DefaultDirName={autopf}\{#MyAppPublisher}\{#MyAppName}
DefaultGroupName={#MyAppPublisher}
DisableProgramGroupPage=yes
LicenseFile=..\LICENSE.txt
OutputDir=..\Output
OutputBaseFilename=DemonSynth_v{#MyAppVersion}_Windows
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=admin
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
UninstallDisplayName={#MyAppName}

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Messages]
WelcomeLabel1=Welcome to the {#MyAppName} Setup
WelcomeLabel2=This will install {#MyAppName} {#MyAppVersion} on your computer.%n%n{#MyAppCopyright}%n%nTo activate the plugin and download sound banks, sign in with your%nProducer Tour account when you first load the plugin in your DAW.%n%nIt is recommended that you close all other applications before continuing.
FinishedHeadingLabel=Completing the {#MyAppName} Setup
FinishedLabelNoIcons=Setup has finished installing {#MyAppName} on your computer.%n%nOpen your DAW, load Demon Synth, and sign in with your Producer Tour account to activate.%n%nDownload your sound banks from producertour.com/account/purchases.
FinishedLabel=Setup has finished installing {#MyAppName} on your computer.%n%nOpen your DAW, load Demon Synth, and sign in with your Producer Tour account to activate.%n%nDownload your sound banks from producertour.com/account/purchases.

[Types]
Name: "full"; Description: "Full installation (VST3 + Standalone)"
Name: "vst3only"; Description: "VST3 plugin only"
Name: "custom"; Description: "Custom installation"; Flags: iscustom

[Components]
Name: "vst3"; Description: "VST3 Plugin (for FL Studio, Ableton, etc.)"; Types: full vst3only custom; Flags: fixed
Name: "standalone"; Description: "Standalone Application"; Types: full custom

[Tasks]
Name: "desktopicon"; Description: "Create desktop shortcut"; GroupDescription: "Additional options:"; Components: standalone
Name: "startmenuicon"; Description: "Create Start Menu shortcut"; GroupDescription: "Additional options:"; Components: standalone

[Files]
; VST3 Plugin - Install to Common Files VST3 folder
Source: "..\..\build\NulyBeatsPlugin_artefacts\Release\VST3\Demon Synth.vst3\*"; DestDir: "{commoncf64}\VST3\Demon Synth.vst3"; Components: vst3; Flags: ignoreversion recursesubdirs createallsubdirs

; Standalone Application
Source: "..\..\build\NulyBeatsPlugin_artefacts\Release\Standalone\Demon Synth.exe"; DestDir: "{app}"; Components: standalone; Flags: ignoreversion

; License file
Source: "..\LICENSE.txt"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\Demon Synth.exe"; Components: standalone
Name: "{group}\Uninstall {#MyAppName}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\Demon Synth.exe"; Components: standalone; Tasks: desktopicon
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\Demon Synth.exe"; Components: standalone; Tasks: startmenuicon

[Registry]
Root: HKCU; Subkey: "Software\NullyBeats\Demon Synth"; ValueType: string; ValueName: "Version"; ValueData: "{#MyAppVersion}"; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\NullyBeats\Demon Synth"; ValueType: string; ValueName: "InstallDate"; ValueData: "{code:GetCurrentDate}"; Flags: uninsdeletekey

[Run]
Filename: "{app}\Demon Synth.exe"; Description: "Launch {#MyAppName}"; Flags: nowait postinstall skipifsilent; Components: standalone

[UninstallDelete]
Type: filesandordirs; Name: "{commoncf64}\VST3\Demon Synth.vst3"

; Clean up FL Studio plugin database cache (if FL Studio is installed)
Type: files; Name: "{userdocs}\Image-Line\FL Studio\Presets\Plugin database\Installed\Generators\VST3\Demon Synth.fst"
Type: files; Name: "{userdocs}\Image-Line\FL Studio\Presets\Plugin database\Installed\Generators\VST3\Demon Synth.nfo"
Type: files; Name: "{userdocs}\Image-Line\FL Studio\Presets\Plugin database\Installed\Generators\VST3\NulyBeats Synth.fst"
Type: files; Name: "{userdocs}\Image-Line\FL Studio\Presets\Plugin database\Installed\Generators\VST3\NulyBeats Synth.nfo"
Type: files; Name: "{userdocs}\Image-Line\FL Studio\Presets\Plugin database\Installed\Generators\VST3\Nuly Beats.fst"
Type: files; Name: "{userdocs}\Image-Line\FL Studio\Presets\Plugin database\Installed\Generators\VST3\Nuly Beats.nfo"
Type: files; Name: "{userdocs}\Image-Line\FL Studio\Presets\Plugin database\Installed\Generators\New\Demon Synth.fst"
Type: files; Name: "{userdocs}\Image-Line\FL Studio\Presets\Plugin database\Installed\Generators\New\Demon Synth.nfo"
Type: files; Name: "{userdocs}\Image-Line\FL Studio\Presets\Plugin database\Installed\Generators\New\NulyBeats Synth.fst"
Type: files; Name: "{userdocs}\Image-Line\FL Studio\Presets\Plugin database\Installed\Generators\New\NulyBeats Synth.nfo"
Type: files; Name: "{userdocs}\Image-Line\FL Studio\Presets\Plugin database\Installed\Effects\VST3\Demon Synth.fst"
Type: files; Name: "{userdocs}\Image-Line\FL Studio\Presets\Plugin database\Installed\Effects\VST3\Demon Synth.nfo"
Type: files; Name: "{userdocs}\Image-Line\FL Studio\Presets\Plugin database\Generators\Demon Synth.fst"
Type: files; Name: "{userdocs}\Image-Line\FL Studio\Presets\Plugin database\Generators\Demon Synth.nfo"
Type: files; Name: "{userdocs}\Image-Line\FL Studio\Presets\Plugin database\Generators\NulyBeats Synth.fst"
Type: files; Name: "{userdocs}\Image-Line\FL Studio\Presets\Plugin database\Generators\NulyBeats Synth.nfo"
Type: files; Name: "{userdocs}\Image-Line\FL Studio\Presets\Plugin database\Generators\Nuly Beats.fst"
Type: files; Name: "{userdocs}\Image-Line\FL Studio\Presets\Plugin database\Generators\Nuly Beats.nfo"
Type: files; Name: "{userdocs}\Image-Line\FL Studio\Presets\Plugin database\Effects\Demon Synth.fst"
Type: files; Name: "{userdocs}\Image-Line\FL Studio\Presets\Plugin database\Effects\Demon Synth.nfo"

[Code]
var
  SamplesDirPage: TInputDirWizardPage;
  SamplesDir: String;

function GetSamplesDir(Param: String): String;
begin
  if SamplesDir = '' then
    SamplesDir := ExpandConstant('{userappdata}\NullyBeats\Demon Synth\Samples');
  Result := SamplesDir;
end;

function GetCurrentDate(Param: String): String;
begin
  Result := GetDateTimeString('yyyy-mm-dd', '-', ':');
end;

function EscapeBackslashes(const S: String): String;
var I: Integer;
begin
  Result := '';
  for I := 1 to Length(S) do
  begin
    if S[I] = '\' then Result := Result + '\\'
    else Result := Result + S[I];
  end;
end;

procedure InitializeWizard;
begin
  // Custom page: let user choose where they'll put their downloaded sound banks
  SamplesDirPage := CreateInputDirPage(
    wpSelectComponents,
    'Sound Banks Location',
    'Where will you store your Demon Synth sound banks?',
    'After installing, download your sound banks from producertour.com/account/purchases' + #13#10 +
    'and extract them to the folder selected here.' + #13#10 + #13#10 +
    'Choose a drive with at least 10 GB of free space.',
    False,
    'New Folder'
  );
  SamplesDirPage.Add('');
  SamplesDirPage.Values[0] := ExpandConstant('{userappdata}\NullyBeats\Demon Synth\Samples');
end;

function ShouldSkipPage(PageID: Integer): Boolean;
begin
  Result := False;
end;

function NextButtonClick(CurPageID: Integer): Boolean;
begin
  Result := True;
  if CurPageID = SamplesDirPage.ID then
  begin
    SamplesDir := SamplesDirPage.Values[0];
    if SamplesDir = '' then
    begin
      MsgBox('Please select a folder for the sound banks.', mbError, MB_OK);
      Result := False;
    end;
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  ConfigDir, ConfigFile, ConfigContent: String;
begin
  if CurStep = ssPostInstall then
  begin
    // Write config.json so the plugin knows where to look for samples
    ConfigDir := ExpandConstant('{userappdata}\NullyBeats\Demon Synth');
    ForceDirectories(ConfigDir);
    ConfigFile := ConfigDir + '\config.json';
    ConfigContent :=
      '{' + #13#10 +
      '    "version": "' + ExpandConstant('{#MyAppVersion}') + '",' + #13#10 +
      '    "samplesPath": "' + EscapeBackslashes(GetSamplesDir('')) + '",' + #13#10 +
      '    "installedDate": "' + GetCurrentDate('') + '",' + #13#10 +
      '    "licenseAccepted": true,' + #13#10 +
      '    "authToken": "",' + #13#10 +
      '    "email": ""' + #13#10 +
      '}';
    SaveStringToFile(ConfigFile, ConfigContent, False);
  end;
end;

procedure CurPageChanged(CurPageID: Integer);
begin
  if CurPageID = SamplesDirPage.ID then
    if SamplesDir <> '' then
      SamplesDirPage.Values[0] := SamplesDir;
end;

function UpdateReadyMemo(Space, NewLine, MemoUserInfoInfo, MemoDirInfo, MemoTypeInfo, MemoComponentsInfo, MemoGroupInfo, MemoTasksInfo: String): String;
var S: String;
begin
  S := 'Installation Summary:' + NewLine + NewLine;

  if WizardIsComponentSelected('vst3') then
    S := S + Space + 'VST3 Plugin: ' + ExpandConstant('{commoncf64}\VST3\Demon Synth.vst3') + NewLine;

  if WizardIsComponentSelected('standalone') then
    S := S + Space + 'Standalone App: ' + ExpandConstant('{app}\Demon Synth.exe') + NewLine;

  S := S + Space + 'Sound Banks folder: ' + GetSamplesDir('') + NewLine;
  S := S + NewLine;
  S := S + 'After installation:' + NewLine;
  S := S + Space + '1. Restart your DAW' + NewLine;
  S := S + Space + '2. Load Demon Synth and sign in with your Producer Tour account' + NewLine;
  S := S + Space + '3. Download sound banks from producertour.com/account/purchases' + NewLine;

  Result := S;
end;
