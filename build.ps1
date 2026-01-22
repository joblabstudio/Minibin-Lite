$scriptPath = if ($psISE) { $psISE.CurrentFile.FullPath } else { $MyInvocation.MyCommand.Path }
$scriptDir = Split-Path -Parent $scriptPath
if ([string]::IsNullOrEmpty($scriptDir)) { $scriptDir = Get-Location }

$sourcePs1 = [System.IO.Path]::Combine($scriptDir, "minibin.ps1")
if (!(Test-Path $sourcePs1)) {
    Write-Error "Error: minibin.ps1 not found in $scriptDir. Please place it there before compiling."
    return
}

$ps1Content = [System.IO.File]::ReadAllText($sourcePs1).Replace('"', '""')

$code = @"
using System;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.IO;
using System.Windows.Forms;
using System.Text;
using System.Reflection;

[assembly: AssemblyTitle("Minibin Lite")]
[assembly: AssemblyDescription("Lightweight Recycle Bin taskbar utility")]
[assembly: AssemblyConfiguration("")]
[assembly: AssemblyCompany("Minibin Project")]
[assembly: AssemblyProduct("Minibin Lite")]
[assembly: AssemblyCopyright("Copyright © 2024")]
[assembly: AssemblyTrademark("")]
[assembly: AssemblyCulture("")]
[assembly: AssemblyVersion("1.0.0.0")]
[assembly: AssemblyFileVersion("1.0.0.0")]

public class Program {
    [DllImport("kernel32.dll")]
    static extern IntPtr GetConsoleWindow();
    [DllImport("user32.dll")]
    static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);

    public static void Main() {
        ShowWindow(GetConsoleWindow(), 0);
        
        string scriptContent = @"$ps1Content";
        string tempScript = Path.Combine(Path.GetTempPath(), "minibin_runtime.ps1");
        
        try {
            File.WriteAllText(tempScript, scriptContent, Encoding.UTF8);
            ProcessStartInfo si = new ProcessStartInfo("powershell.exe", "-w hidden -ep bypass -f \"" + tempScript + "\"");
            si.UseShellExecute = false;
            si.CreateNoWindow = true;
            Process.Start(si);
        } catch (Exception ex) {
            MessageBox.Show("Error starting Minibin: " + ex.Message);
        }
    }
}
"@

$csc = Get-ChildItem -Path "$env:SystemRoot\Microsoft.NET\Framework64" -Filter "csc.exe" -Recurse | Sort-Object LastWriteTime -Descending | Select-Object -First 1 -ExpandProperty FullName
$out = [System.IO.Path]::Combine($scriptDir, "Minibin Lite.exe")
$tmp = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), "mlite_embedded.cs")
$icoTmp = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), "recycle.ico")

$signature = @"
[DllImport("shell32.dll", CharSet = CharSet.Auto)]
public static extern IntPtr ExtractIcon(IntPtr hInst, string lpszExeFileName, int nIconIndex);
"@
$type = Add-Type -MemberDefinition $signature -Name "IconExtractor" -Namespace "Win32" -PassThru

$shell32Path = [System.IO.Path]::Combine($env:SystemRoot, "System32", "shell32.dll")
$hIcon = $type::ExtractIcon([IntPtr]::Zero, $shell32Path, 32)

if ($hIcon -ne [IntPtr]::Zero) {
    $icon = [System.Drawing.Icon]::FromHandle($hIcon)
    $fs = New-Object System.IO.FileStream($icoTmp, [System.IO.FileMode]::Create)
    $icon.Save($fs)
    $fs.Close()
}

$code | Out-File -FilePath $tmp -Encoding UTF8
if ($csc) {
    $iconParam = if (Test-Path $icoTmp) { "/win32icon:""$icoTmp""" } else { "" }
    & $csc /target:winexe /out:"$out" $iconParam /reference:System.Windows.Forms.dll /nologo $tmp
}

if (Test-Path $tmp) { Remove-Item $tmp }
if (Test-Path $icoTmp) { Remove-Item $icoTmp }

if (Test-Path "$out") { Write-Host "Success! Portable Minibin Lite.exe with metadata created in: $out" -ForegroundColor Green }