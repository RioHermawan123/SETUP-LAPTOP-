Set-Location -Path $PSScriptRoot
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = 'FREEWARE v2.0'
$form.Size = New-Object System.Drawing.Size(286,360)
$form.StartPosition = [System.Windows.Forms.FormStartPosition]::Manual
$form.Location = New-Object System.Drawing.Point(1, 1)
$form.BackColor = '#FF6500'

$labelC = New-Object System.Windows.Forms.Label
$labelC.Text = ' FREEWARE'
$labelC.Height = 30
$labelC.Width = 121
$labelC.Font = New-Object System.Drawing.Font('Segoe UI', 15, [System.Drawing.FontStyle]::Bold)
$labelC.ForeColor = "#FF6500"
$labelC.BackColor = "White"
$labelC.Location = New-Object System.Drawing.Point(70, 10)
$form.Controls.Add($labelC)

$appChrome = New-Object Windows.Forms.CheckBox
$appChrome.Text = "CHROME"
$appChrome.Location = New-Object Drawing.Point(25, 60)
$appChrome.BackColor = "White"
$appChrome.Checked = $True

$appAimp = New-Object Windows.Forms.CheckBox
$appAimp.Text = "AIMP"
$appAimp.Location = New-Object Drawing.Point(25, 100)
$appAimp.BackColor = "White"
$appAimp.Checked = $True

$appVlc = New-Object Windows.Forms.CheckBox
$appVlc.Text = "VLC"
$appVlc.Location = New-Object Drawing.Point(140, 100)
$appVlc.BackColor = "White"
$appVlc.Checked = $True

$appWinrar = New-Object Windows.Forms.CheckBox
$appWinrar.Text = "7ZIP"
$appWinrar.Location = New-Object Drawing.Point(25, 140)
$appWinrar.BackColor = "White"
$appWinrar.Checked = $True

$appZoom = New-Object Windows.Forms.CheckBox
$appZoom.Text = "ZOOM"
$appZoom.Location = New-Object Drawing.Point(140, 140)
$appZoom.BackColor = "White"
$appZoom.Checked = $True

$appWps = New-Object Windows.Forms.CheckBox
$appWps.Text = "WPS OFFICE"
$appWps.Location = New-Object Drawing.Point(25, 180)
$appWps.BackColor = "White"

$appPdf = New-Object Windows.Forms.CheckBox
$appPdf.Text = "PDFGEAR"
$appPdf.Location = New-Object Drawing.Point(140, 180)
$appPdf.BackColor = "White"


$labelProgress = New-Object System.Windows.Forms.Label
$labelProgress.Text = "Installation Progress: 0 of 0"
$labelProgress.Location = New-Object System.Drawing.Point(60, 220)
$labelProgress.BackColor = "WHITE"
$labelProgress.Size = New-Object System.Drawing.Size(150, 16)
$form.Controls.Add($labelProgress)

$progressInstall = New-Object System.Windows.Forms.ProgressBar
$progressInstall.Location = New-Object System.Drawing.Point(25, 242)
$progressInstall.Size = New-Object System.Drawing.Size(220, 20)
$progressInstall.Minimum = 0
$progressInstall.Maximum = 100
$form.Controls.Add($progressInstall)

$buttonInstall = New-Object Windows.Forms.Button
$ButtonInstall.BackColor = "#FF6500"
$ButtonInstall.ForeColor = "white"
$buttonInstall.Text = "INSTALL"
$ButtonInstall.Cursor = [System.Windows.Forms.Cursors]::Hand
$buttonInstall.Location = New-Object Drawing.Point(25, 270)
$buttonInstall.Size = New-Object Drawing.Size(220, 30)

$tempDir = $env:TEMP
$workpath = Join-Path -Path $tempDir -ChildPath "finishing_project"
$appFolder = Join-Path -Path $workpath -ChildPath "app"

$chromePath = Join-Path -Path $appFolder -ChildPath "googlechromestandaloneenterprise64.msi"
$vlcPath = Join-Path -Path $appFolder -ChildPath "vlc-3.0.20-win64.exe"
$aimpPath = Join-Path -Path $appFolder -ChildPath "aimp.exe"
$zipPath = Join-Path -Path $appFolder -ChildPath "7z2408-x64.exe"
$zoomPath = Join-Path -Path $appFolder -ChildPath "ZoomInstallerFull.msi"
$wpsofficePath = Join-Path -Path $appFolder -ChildPath "wpsoffice.exe"
$pdfgearPath = Join-Path -Path $appFolder -ChildPath "pdfgear.exe"


$buttonInstall.Add_Click({
    $appList = @($appChrome,$appFirefox,$appAimp,$appVlc,$appWinrar,$appZoom,$appWps,$appPdf)
    $checkedCount = ($appList | Where-Object { $_.Checked }).Count
    $installedCount = 0
    $labelProgress.Text = "Installation Progress: 0 of $checkedCount"
    $progressInstall.Value = 0

    if ($appChrome.Checked) {
        Start-Process -FilePath "msiexec" -ArgumentList @("/i", $chromePath,"/qn") -Verb RunAs -Wait
        $installedCount++
        $labelProgress.Text = "Installation Progress: $installedCount of $checkedCount"
        $progressInstall.Value = ($installedCount / $checkedCount) * 100
    }

    if ($appAimp.Checked) {
        $listBox1.Items.Add("Installing AIMP Music Player")
        Start-Process -FilePath $aimpPath -Verb RunAs -Args "/AUTO /SILENT" -Wait  
        $listBox1.Items.Add("AIMP Music Player Installed")
        $installedCount++
        $labelProgress.Text = "Installation Progress: $installedCount of $checkedCount"
        $progressInstall.Value = ($installedCount / $checkedCount) * 100
    }

    if ($appVlc.Checked) {
        Start-Process -FilePath $vlcPath -Args "/L=1033 /S" -Verb RunAs -Wait 
        $installedCount++
        $labelProgress.Text = "Installation Progress: $installedCount of $checkedCount"
        $progressInstall.Value = ($installedCount / $checkedCount) * 100
    }

    if ($appWinrar.Checked) {
        Start-Process -FilePath $zipPath -ArgumentList @("/S") -Verb RunAs -Wait
        
        $installedCount++
        $labelProgress.Text = "Installation Progress: $installedCount of $checkedCount"
        $progressInstall.Value = ($installedCount / $checkedCount) * 100
    }

    if ($appZoom.Checked) {
        Start-Process -FilePath "msiexec" -ArgumentList @("/i", $zoomPath , "/quiet", "/qn", "/norestart") -Verb RunAs -Wait
        $installedCount++
        $labelProgress.Text = "Installation Progress: $installedCount of $checkedCount"
        $progressInstall.Value = ($installedCount / $checkedCount) * 100
    }

    if ($appWps.Checked) {
        Start-Process -FilePath $wpsofficePath -Args "/S /EULA_ACCEPT=YES" -Verb RunAs -Wait  
        $installedCount++
        $labelProgress.Text = "Installation Progress: $installedCount of $checkedCount"
        $progressInstall.Value = ($installedCount / $checkedCount) * 100
    }

    if ($appPdf.Checked) {
        Start-Process -FilePath $pdfgearPath -Args "SP- /VERYSILENT /NORESTART" -Verb RunAs -Wait  
        $installedCount++
        $labelProgress.Text = "Installation Progress: $installedCount of $checkedCount"
        $progressInstall.Value = ($installedCount / $checkedCount) * 100
    }

    $progressBar.Value = 100
})

$form.Controls.AddRange(@($appChrome,$appFirefox,$appAimp,$appVlc,$appWinrar,$appZoom,$appWps,$appPdf,$progressInstall,$labelProgress,$buttonInstall))

$bg = New-Object System.Windows.Forms.Label
$bg.Height = 300# thickness of line
$bg.Width = 250 # length of line
$bg.BackColor = 'white'  # Replace 'Black' with the color you want
$bg.Location = New-Object System.Drawing.Point(10,10)
$form.Controls.Add($bg)

$form.Add_FormClosed({
    start-process -filepath "$($env:TEMP)\delete_finishing_temp.bat"
})

$form.ShowDialog()