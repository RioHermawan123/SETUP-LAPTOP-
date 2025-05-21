Set-Location -Path $PSScriptRoot
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create the form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Launcher"
$form.Size = New-Object System.Drawing.Size(200, 80)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::None
$form.ShowInTaskbar = $false
$form.TopMost = $true
$form.BackColor = [System.Drawing.Color]::White



# Define the source and destination paths
$sourcePath = "C:\ProgramData\finishing_project"
$destinationPath = "$env:TEMP\finishing_project"

# Create the destination directory if it doesn't exist
if (-not (Test-Path -Path $destinationPath)) {
    New-Item -ItemType Directory -Path $destinationPath | Out-Null
}

$robocopyCommand = "robocopy `"$sourcePath`" `"$destinationPath`" /MOVE /E /MT:32 /NFL /NDL /NJH /NJS /NC /NS /NP"

# Execute the robocopy command
Invoke-Expression $robocopyCommand
Move-Item -path "C:\ProgramData\copier.bat" -Destination $destinationPath



# Create a timer to close the form after 5 seconds
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 3000 # 5000 milliseconds = 5 seconds
$timer.Add_Tick({
    $timer.Stop() # Stop the timer
    $form.Close()  # Close the form
})



$labelDone = New-Object System.Windows.Forms.Label
$labelDone.Text = "COPY COMPLETE"
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

# ==========================  AUTO MOUNT OFFICE =========================================================================
$filePathOHS = "C:\ProgramData\Home2024Retail.img"
$filePathProPlus = "C:\ProgramData\ProPlus2021Retail.img"
$destinationPathOHS = "$env:USERPROFILE\Downloads\Home2024Retail.img"
$destinationPathProPlus = "$env:USERPROFILE\Downloads\ProPlus2021Retail.img"
$driveLetter = "Z"  # You can choose a drive letter
$isHome2024Retail = $false  # Flag to check if the detected file is Home2024Retail.img

# Check for the existence of either IMG file
if (Test-Path $filePathOHS) {
    Move-Item $filePathOHS $destinationPathOHS -Force
    Write-Output "Detected Home2024Retail.img."
    $isHome2024Retail = $true  # Set the flag to true
} elseif (Test-Path $filePathProPlus) {
    Move-Item $filePathProPlus $destinationPathProPlus -Force
    Write-Output "Detected ProPlus2021Retail.img."
} else {
    Write-Output "No valid IMG file found."
    exit
}

# Determine the destination path based on the detected file
$destinationPath = if ($isHome2024Retail) { $destinationPathOHS } else { $destinationPathProPlus }

# Mount the IMG file
$diskImage = Mount-DiskImage -ImagePath $destinationPath -PassThru

# Wait for the mount process to complete (max 40 seconds)
$timeout = 40
$elapsed = 0
while (-not (Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DriveType -eq 5 }) -and $elapsed -lt $timeout) {
    Start-Sleep -Seconds 1
    $elapsed++
}

# Find the newly mounted virtual CD/DVD drive
$cdromDrive = Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DriveType -eq 5 -and $_.VolumeName -like "16.0*" }
write-host $cdromDrive
if ($cdromDrive) {
    $currentLetter = $cdromDrive.DeviceID.Replace(":", "")

    if ($currentLetter -ne $driveLetter) {
        # Change the drive letter to the correct one
        $obj = Get-WmiObject Win32_Volume | Where-Object { $_.DriveLetter -eq "$currentLetter`:" }
        if ($obj) {
            $obj | Set-WmiInstance -Arguments @{DriveLetter = "$driveLetter`:"}
            Write-Output "IMG file mounted successfully as drive $driveLetter."
            explorer.exe "Z:"
        } else {
            Write-Output "Failed to change drive letter. Drive might be in use."
        }
    } else {
        Write-Output "IMG file is already mounted as drive $driveLetter."
        explorer.exe "Z:"
    }

    # Copy the .diagcab file only if the detected file is Home2024Retail.img
    if ($isHome2024Retail) {
        $filePathCSS = "$env:TEMP\finishing_project\cssemerg97275.diagcab"
        $destinationPathCSS = "$env:USERPROFILE\Downloads\cssemerg97275.diagcab"

        if (Test-Path $filePathCSS) {
            Copy-Item $filePathCSS $destinationPathCSS -Force
            Write-Output "Copied cssemerg97275.diagcab to Downloads."
        } else {
            Write-Output "cssemerg97275.diagcab not found in TEMP."
        }
    }


} else {
    Write-Output "Mounting failed or took too long."
}




$form.ShowDialog()  # This line is necessary to keep the form open