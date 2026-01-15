# Caminhos base
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$build = Join-Path $root "build\windows\x64\runner\Release"
$inputExe = Join-Path $build "ip_set.exe"
$outputExe = Join-Path $root "IPSet.exe"
$evbFile = Join-Path $root "auto_projeto.evb"

# StringBuilder
$sb = New-Object -TypeName System.Text.StringBuilder

# Cabeçalho
$null = $sb.AppendLine('<?xml version="1.0" encoding="windows-1252"?>')
$null = $sb.AppendLine('<VirtualBox>')
$null = $sb.AppendLine("  <InputFile>$inputExe</InputFile>")
$null = $sb.AppendLine("  <OutputFile>$outputExe</OutputFile>")
$null = $sb.AppendLine('  <Files>')
$null = $sb.AppendLine('    <Enabled>True</Enabled>')
$null = $sb.AppendLine('    <DeleteExtractedOnExit>False</DeleteExtractedOnExit>')
$null = $sb.AppendLine('    <CompressFiles>False</CompressFiles>')
$null = $sb.AppendLine('    <Files>')
$null = $sb.AppendLine('      <File>')
$null = $sb.AppendLine('        <Type>3</Type>')
$null = $sb.AppendLine('        <Name>%DEFAULT FOLDER%</Name>')
$null = $sb.AppendLine('        <Action>0</Action>')
$null = $sb.AppendLine('        <OverwriteDateTime>False</OverwriteDateTime>')
$null = $sb.AppendLine('        <OverwriteAttributes>False</OverwriteAttributes>')
$null = $sb.AppendLine('        <HideFromDialogs>0</HideFromDialogs>')
$null = $sb.AppendLine('        <Files>')

# Função recursiva
function Add-FilesXmlRecursive {
    param (
        [string]$base,
        [string]$rel
    )
    $dir = Join-Path $base $rel
    $entries = Get-ChildItem -LiteralPath $dir | Sort-Object { -not $_.PSIsContainer }, Name

    foreach ($entry in $entries) {
        $relPath = if ($rel) { Join-Path $rel $entry.Name } else { $entry.Name }
        $fullPath = Join-Path $base $relPath

        if ($entry.PSIsContainer) {
            $null = $sb.AppendLine('          <File>')
            $null = $sb.AppendLine('            <Type>3</Type>')
            $null = $sb.AppendLine("            <Name>$($entry.Name)</Name>")
            $null = $sb.AppendLine('            <Action>0</Action>')
            $null = $sb.AppendLine('            <OverwriteDateTime>False</OverwriteDateTime>')
            $null = $sb.AppendLine('            <OverwriteAttributes>False</OverwriteAttributes>')
            $null = $sb.AppendLine('            <HideFromDialogs>0</HideFromDialogs>')
            $null = $sb.AppendLine('            <Files>')
            Add-FilesXmlRecursive -base $base -rel $relPath
            $null = $sb.AppendLine('            </Files>')
            $null = $sb.AppendLine('          </File>')
        }
        elseif ($fullPath -ne $inputExe) {
            $null = $sb.AppendLine('          <File>')
            $null = $sb.AppendLine('            <Type>2</Type>')
            $null = $sb.AppendLine("            <Name>$($entry.Name)</Name>")
            $null = $sb.AppendLine("            <File>$fullPath</File>")
            $null = $sb.AppendLine('            <ActiveX>False</ActiveX>')
            $null = $sb.AppendLine('            <ActiveXInstall>False</ActiveXInstall>')
            $null = $sb.AppendLine('            <Action>0</Action>')
            $null = $sb.AppendLine('            <OverwriteDateTime>False</OverwriteDateTime>')
            $null = $sb.AppendLine('            <OverwriteAttributes>False</OverwriteAttributes>')
            $null = $sb.AppendLine('            <PassCommandLine>False</PassCommandLine>')
            $null = $sb.AppendLine('            <HideFromDialogs>0</HideFromDialogs>')
            $null = $sb.AppendLine('          </File>')
        }
    }
}

# Adiciona arquivos
Add-FilesXmlRecursive -base $build -rel ""

# Finaliza XML
$null = $sb.AppendLine('        </Files>')
$null = $sb.AppendLine('      </File>')
$null = $sb.AppendLine('    </Files>')
$null = $sb.AppendLine('  </Files>')
$null = $sb.AppendLine('  <Registries><Enabled>False</Enabled><Registries/></Registries>')
$null = $sb.AppendLine('  <Packaging><Enabled>False</Enabled></Packaging>')
$null = $sb.AppendLine('  <Options>')
$null = $sb.AppendLine('    <ShareVirtualSystem>False</ShareVirtualSystem>')
$null = $sb.AppendLine('    <MapExecutableWithTemporaryFile>True</MapExecutableWithTemporaryFile>')
$null = $sb.AppendLine('    <TemporaryFileMask/>')
$null = $sb.AppendLine('    <AllowRunningOfVirtualExeFiles>True</AllowRunningOfVirtualExeFiles>')
$null = $sb.AppendLine('    <ProcessesOfAnyPlatforms>False</ProcessesOfAnyPlatforms>')
$null = $sb.AppendLine('  </Options>')
$null = $sb.AppendLine('  <Storage>')
$null = $sb.AppendLine('    <Files>')
$null = $sb.AppendLine('      <Enabled>False</Enabled>')
$null = $sb.AppendLine('      <Folder>%DEFAULT FOLDER%\</Folder>')
$null = $sb.AppendLine('      <RandomFileNames>False</RandomFileNames>')
$null = $sb.AppendLine('      <EncryptContent>False</EncryptContent>')
$null = $sb.AppendLine('    </Files>')
$null = $sb.AppendLine('  </Storage>')
$null = $sb.AppendLine('</VirtualBox>')

# Salvar EVB
$sb.ToString() | Set-Content -Encoding Default $evbFile

# Tenta localizar Enigma Virtual Box Console
$possiveis = @(
  "C:\Program Files\Enigma Virtual Box\enigmavbconsole.exe",
  "C:\Program Files (x86)\Enigma Virtual Box\enigmavbconsole.exe",
  "$root\enigmavbconsole.exe"
)

$enigma = $possiveis | Where-Object { Test-Path $_ } | Select-Object -First 1

if ($enigma) {
    & "$enigma" "$evbFile"
} else {
    Write-Host "❌ Enigma Virtual Box Console não encontrado. Verifique o caminho."
}
