Set-Location -Path $PSScriptRoot
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create a form
$form = New-Object Windows.Forms.Form
$form.Text = "Auto Install + WPS 2.1"
$form.BackColor = [System.Drawing.Color]::White
$form.StartPosition = [System.Windows.Forms.FormStartPosition]::Manual
$form.Location = New-Object System.Drawing.Point(483, 1)
$form.Size = New-Object Drawing.Size(400, 90)
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::None
$form.ControlBox = $false

# Create a label to display the installation progress
$labelProgress = New-Object System.Windows.Forms.Label
$labelProgress.Text = "Installation Progress: 0 of 0"
$labelProgress.Location = New-Object System.Drawing.Point(80, 1)
$labelProgress.Size = New-Object System.Drawing.Size(300, 20)
$labelProgress.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($labelProgress)

# Create a progress bar
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(10, 25)
$progressBar.Size = New-Object System.Drawing.Size(360, 20)
$progressBar.Style = [System.Windows.Forms.ProgressBarStyle]::Continuous
$progressBar.Minimum = 0
$progressBar.Maximum = 100
$form.Controls.Add($progressBar)

$buttonInstall = New-Object Windows.Forms.Button
$ButtonInstall.BackColor = [System.Drawing.Color]::Orange
$ButtonInstall.ForeColor = [System.Drawing.Color]::White
$buttonInstall.Text = "INSTALL"
$ButtonInstall.Cursor = [System.Windows.Forms.Cursors]::Hand
$buttonInstall.Location = New-Object Drawing.Point(10, 25)
$buttonInstall.Size = New-Object Drawing.Size(250, 10)
$buttonInstall.Visible =$true
$form.Controls.Add($buttonInstall)


$tempDir = $env:TEMP
$workpath = Join-Path -Path $tempDir -ChildPath "finishing_project"
$appFolder = Join-Path -Path $workpath -ChildPath "app"

$chromePath = Join-Path -Path $appFolder -ChildPath "googlechromestandaloneenterprise64.msi"
$vlcPath = Join-Path -Path $appFolder -ChildPath "vlc-3.0.20-win64.exe"
$zipPath = Join-Path -Path $appFolder -ChildPath "7z2408-x64.exe"
$zoomPath = Join-Path -Path $appFolder -ChildPath "ZoomInstallerFull.msi"
$wpsofficePath = Join-Path -Path $appFolder -ChildPath "wpsoffice.exe"
$pdfgearPath = Join-Path -Path $appFolder -ChildPath "pdfgear.exe"



$checkedCount = 6
$installedCount = 0
$labelProgress.Text = "Installer not started"
$progressBar.Value = 0
$buttonInstall.Add_Click({

        #WPS
        $labelProgress.Text = "Installing WPS Office .Progress: $installedCount of $checkedCount"
        Start-Process -FilePath $wpsofficePath -Args "/S /ACCEPTEULA=1" -Verb RunAs -Wait  
        $installedCount++
        $progressBar.Value = 16

        #ZOOM
        $labelProgress.Text = "Installing Zoom .Progress: $installedCount of $checkedCount"
        Start-Process -FilePath "msiexec" -ArgumentList @("/i", $zoomPath, "/quiet", "/qn", "/norestart") -Verb RunAs -Wait
        $installedCount++
        $progressBar.Value = 29

        #CHROME
        $labelProgress.Text = "Installing CHROME.Progress: $installedCount of $checkedCount "
        Start-Process -FilePath "msiexec" -ArgumentList @("/i", $chromePath,"/qn") -Verb RunAs -Wait
        $installedCount++
        $progressBar.Value = 50

        #PDFGEAR
        $labelProgress.Text = "Installing PDFGEAR .Progress: $installedCount of $checkedCount"
        Start-Process -FilePath $pdfgearPath -Args "SP- /VERYSILENT /NORESTART" -Verb RunAs -Wait
        $installedCount++
        $progressBar.Value = 70

        #VLC
        $labelProgress.Text = "Installing VLC .Progress: $installedCount of $checkedCount"
        Start-Process -FilePath $vlcPath -Args "/L=1033 /S" -Verb RunAs -Wait 
        $installedCount++
        $progressBar.Value = 90

        #7ZIP
        $labelProgress.Text = "Installing 7ZIP .Progress: $installedCount of $checkedCount"
        Start-Process -FilePath $zipPath -ArgumentList @("/S") -Verb RunAs -Wait
        $installedCount++
        $progressBar.Value = 100
  

        $labelProgress.Text = "Install Completed .Progress: $installedCount of $checkedCount"

        start-sleep 2

        start-process -filepath "$($env:TEMP)\delete_finishing_temp.bat"

        $form.Close()
})

$form.Add_Shown({
    $buttonInstall.PerformClick()
})

$form.ShowDialog()