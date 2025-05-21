# Load Windows Forms assembly
Add-Type -AssemblyName System.Windows.Forms

# Create a form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Installer v3s"
$form.Size = New-Object System.Drawing.Size(400, 40)
$form.StartPosition = [System.Windows.Forms.FormStartPosition]::Manual
$form.Location = New-Object System.Drawing.Point(483, 1)
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::None
$form.ControlBox = $false

# Create a label to show the installation status
$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Location = New-Object System.Drawing.Point(10, 10)
$statusLabel.Size = New-Object System.Drawing.Size(350, 20)
$statusLabel.Text = "Starting installations..."
$statusLabel.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($statusLabel)


# Create a non-visible button
$button = New-Object System.Windows.Forms.Button
$button.Text = "Start Installations"
$button.Location = New-Object System.Drawing.Point(20, 120)
$button.Size = New-Object System.Drawing.Size(150, 30)
$button.Visible = $true  # Make the button invisible

Start-Process -FilePath "$($env:TEMP)\finishing_project\app\7z2408-x64.exe" -ArgumentList "/S" -Verb RunAs


# Define the installer logic
$button.Add_Click({
    # Get the processor name
    $processorName = (Get-WmiObject -Class Win32_Processor).Name

    # List of installers (both .msi and .exe)
    $installers = @(
    "$($env:TEMP)\finishing_project\app\ChromeStandaloneSetup64.exe",
    #"$($env:TEMP)\finishing_project\app\wpsoffice.exe",
    "$($env:TEMP)\finishing_project\app\ZoomInstallerFull.msi",
    "$($env:TEMP)\finishing_project\app\pdfgear.exe",
    "$($env:TEMP)\finishing_project\app\vlc-3.0.20-win64.exe"
    )

    # Define the processor types that require synchronous installation
    $synchronousProcessors = @("Celeron", "Athlon")

    # Check if the processor name matches any of the specified types
    $requiresSynchronous = $false
    foreach ($proc in $synchronousProcessors) {
        if ($processorName -like "*$proc*") {
            $requiresSynchronous = $true
            break
        }
    }

    if ($requiresSynchronous) {
        $statusLabel.Text = "Processor is one of the specified types. Running installations synchronously."
        
        # Loop through each installer and execute them synchronously
        for ($i = 0; $i -lt $installers.Count; $i++) {
            $installer = $installers[$i]
            $statusLabel.Text = "Installing $installer..."
            $form.Refresh()  # Refresh the form to update the label
            
            # Check the file extension and run the appropriate command
            if ($installer.EndsWith(".msi")) {
                Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$installer`" /quiet /qn /norestart" -Wait
            } elseif ($installer.EndsWith(".exe")) {
                Start-Process -FilePath $installer -ArgumentList "SP- /S /AUTO /SILENT /VERYSILENT /NORESTART  /L=1033 /ACCEPTEULA=1" -Wait
            } else {
                $statusLabel.Text = "Unsupported installer type: $installer"
                continue
            }

        }
    } else {
        $statusLabel.Text = "Processor is not one of the specified types. Running installations asynchronously."
        
        # Array to hold the process objects
        $processes = @()

        # Start each installer asynchronously
        for ($i = 0; $i -lt $installers.Count; $i++) {
            $installer = $installers[$i]
            $statusLabel.Text = "installation Started"
            $form.Refresh()  # Refresh the form to update the label
            
            # Check the file extension and run the appropriate command
            if ($installer.EndsWith(".msi")) {
                $process = Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$installer`" /quiet /qn /norestart" -PassThru
            } elseif ($installer.EndsWith(".exe")) {
                $process = Start-Process -FilePath $installer -ArgumentList "SP- /AUTO /SILENT /S /VERYSILENT /NORESTART /L=1033 /ACCEPTEULA=1" -PassThru
            } else {
                $statusLabel.Text = "Unsupported installer type: $installer"
                continue
            }
            
            $processes += $process  # Add the process to the array
        }

        # Monitor the asynchronous processes
        while ($processes.Count -gt 0) {
            foreach ($process in $processes) {
                if ($process.HasExited) {
                    $processes = $processes | Where-Object { $_.Id -ne $process.Id }  # Remove completed processes
                }
            }
            Start-Sleep -Seconds 1  # Wait before checking again
        }
    }

    $statusLabel.Text = "All installations completed."

    Start-Sleep -Seconds 2
    #start-process -filepath "$($env:TEMP)\delete_finishing_temp.bat"

    $form.Close()
})

$form.Controls.Add($button)


# Programmatically click the button when the form is shown
$form.Add_Shown({ $button.PerformClick() })

# Show the form
$form.ShowDialog()