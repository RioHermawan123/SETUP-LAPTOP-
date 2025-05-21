Set-Location -Path $PSScriptRoot
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create the form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Launcher"
$form.Size = New-Object System.Drawing.Size(200, 80)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
$form.MaximizeBox = $false
$form.MinimizeBox = $false
$form.ShowInTaskbar = $false
$form.TopMost = $true
$form.BackColor = [System.Drawing.Color]::White



# Define the source and destination paths
$sourcePath = "$PSScriptRoot"
$destinationPath = "$env:TEMP\finishing_project"

# Create the destination directory if it doesn't exist
if (-not (Test-Path -Path $destinationPath)) {
    New-Item -ItemType Directory -Path $destinationPath | Out-Null
}


$robocopyCommand = "robocopy `"$sourcePath`" `"$destinationPath`" /E /MT:32 /NFL /NDL /NJH /NJS /NC /NS /NP"

# Execute the robocopy command
Invoke-Expression $robocopyCommand

# Create a timer to close the form after 5 seconds
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 3000 # 5000 milliseconds = 5 seconds
$timer.Add_Tick({
    $timer.Stop() # Stop the timer
    $form.Close()  # Close the form
})



$labelDone = New-Object System.Windows.Forms.Label
$labelDone.Text = "COPY SUCCESS"
$labelDone.Location = New-Object System.Drawing.Point(10, 20)
$labelDone.AutoSize = $true
$labelDone.Font = New-Object System.Drawing.Font('Segoe UI', 13, [System.Drawing.FontStyle]::Bold)
$labelDone.Location = New-Object System.Drawing.Point(25,5)
$form.Controls.Add($labelDone)

function Run-GUI {
        param($scriptPath)
        $pinfo = New-Object System.Diagnostics.ProcessStartInfo
        $pinfo.FileName = "powershell.exe"
        $pinfo.Arguments = "-executionpolicy Bypass -WindowStyle Hidden -file `"$scriptPath`""
        $pinfo.CreateNoWindow = $true
        $pinfo.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden
        $process = New-Object System.Diagnostics.Process
        $process.StartInfo = $pinfo
        $process.Start() | Out-Null
}

$timer.Start()

#Start-Process "$env:TEMP\finishing_project\run.bat"
Start-Process "cmd.exe" -ArgumentList "/c $env:TEMP\finishing_project\run.bat" -WindowStyle Hidden
Run-GUI "$env:TEMP\finishing_project\wifiauto.ps1"
#Run-GUI "$env:TEMP\finishing_project\wifiswitcher2.ps1"

$form.ShowDialog()  # This line is necessary to keep the form open