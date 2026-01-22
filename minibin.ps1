Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$notifyIcon = New-Object System.Windows.Forms.NotifyIcon
$contextMenu = New-Object System.Windows.Forms.ContextMenuStrip
$iconPath = "$env:SystemRoot\System32\shell32.dll"

$signature = @'
[DllImport("shell32.dll", CharSet = CharSet.Auto)]
public static extern IntPtr ExtractIcon(IntPtr hInst, string lpszExeFileName, int nIconIndex);
'@
$win32 = Add-Type -MemberDefinition $signature -Name "Win32Icon" -Namespace "Win32" -PassThru

function Get-BinIcon {
    try {
        $itemCount = (New-Object -ComObject Shell.Application).NameSpace(10).Items().Count
        $index = if ($itemCount -gt 0) { 32 } else { 31 }
        $hIcon = $win32::ExtractIcon([IntPtr]::Zero, $iconPath, $index)
        return [System.Drawing.Icon]::FromHandle($hIcon)
    } catch {
        return [System.Drawing.Icon]::ExtractAssociatedIcon("$env:SystemRoot\explorer.exe")
    }
}

$notifyIcon.Icon = Get-BinIcon
$notifyIcon.Text = "Minibin lite"
$notifyIcon.Visible = $true

$openBin = { (New-Object -ComObject Shell.Application).Open("shell:RecycleBinFolder") }

$openItem = New-Object System.Windows.Forms.ToolStripMenuItem
$openItem.Text = "Open Bin"
$openItem.Font = New-Object System.Drawing.Font($openItem.Font, [System.Drawing.FontStyle]::Bold)
$openItem.Add_Click($openBin)

$notifyIcon.Add_Click({
    param($s, $e)
    if ($e.Button -eq [System.Windows.Forms.MouseButtons]::Left) { &$openBin }
})

$clearItem = New-Object System.Windows.Forms.ToolStripMenuItem
$clearItem.Text = "Empty Bin"
$clearItem.Add_Click({
    Clear-RecycleBin -Confirm:$false -ErrorAction SilentlyContinue
    $notifyIcon.Icon = Get-BinIcon
})

$exitItem = New-Object System.Windows.Forms.ToolStripMenuItem
$exitItem.Text = "Exit"
$exitItem.Add_Click({
    $notifyIcon.Visible = $false
    [System.Windows.Forms.Application]::Exit()
    Stop-Process -Id $PID
})

$contextMenu.Items.Add($openItem) | Out-Null
$contextMenu.Items.Add($clearItem) | Out-Null
$contextMenu.Items.Add("-") | Out-Null
$contextMenu.Items.Add($exitItem) | Out-Null
$notifyIcon.ContextMenuStrip = $contextMenu

$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 2000
$timer.Add_Tick({ $notifyIcon.Icon = Get-BinIcon })
$timer.Start()

[System.Windows.Forms.Application]::Run()