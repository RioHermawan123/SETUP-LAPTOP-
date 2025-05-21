Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create a form
$form = New-Object Windows.Forms.Form
$form.Text = "Mixed Installer"
$form.Size = New-Object Drawing.Size(400, 150)
$form.StartPosition = [System.Windows.Forms.FormStartPosition]::Center

# Create a label to display the installation progress
$labelProgress = New-Object System.Windows.Forms.Label
$labelProgress.Text = "Installation Progress: 0 of 0"
$labelProgress.Location = New-Object System.Drawing.Point(20, 20)
$labelProgress.Size = New-Object System.Drawing.Size(350, 20)
$form.Controls.Add($labelProgress)

# Create a progress bar
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(20, 50)
$progressBar.Size = New-Object System.Drawing.Size(350, 20)
$progressBar.Minimum = 0
$progressBar.Maximum = 100
$form.Controls.Add($progressBar)

# Create a button to start the installation
$buttonInstall = New-Object Windows.Forms.Button
$buttonInstall.Text = "Start Installation"
$buttonInstall.Location = New-Object System.Drawing.Point(20, 80)
$form.Controls.Add($buttonInstall)

# Define the installations
$installations = @(
    @{ Name = "Example MSI"; Path = "H:\finishing_project\app\ZoomInstallerFull.msi"; Args = "/quiet /qn /norestart"; Type = "msi"; Progress = 50 },
    @{ Name = "Example EXE"; Path = "H:\finishing_project\app\7z2408-x64.exe"; Args = "/S"; Type = "exe"; Progress = 100 }
)

$buttonInstall.Add_Click({
    $labelProgress.Text = "Starting installations..."
    $progressBar.Value = 0

    $jobs = @()  # Array to hold job objects

    foreach ($install in $installations) {
        $labelProgress.Text = "Installing $($install.Name)..."
        
        # Start the installation as a job
        $job = Start-Job -ScriptBlock {
            param($path, $args, $type)
            try {
                if ($type -eq "msi") {
                    # Use msiexec for MSI files
                    Start-Process -FilePath "msiexec.exe" -ArgumentList "/i", $path, $args -Wait -PassThru | Out-Null
                } elseif ($type -eq "exe") {
                    # Directly run EXE files
                    Start-Process -FilePath $path -ArgumentList $args -Wait -PassThru | Out-Null
                }
                return $null  # Return null if successful
            } catch {
                return "Failed to install"  # Return the error message
            }
        } -ArgumentList $install.Path, $install.Args, $install.Type

        $jobs += $job  # Add the job to the array

        # Update progress bar
        $progressBar.Value = $install.Progress
    }

    # Wait for all jobs to complete
    while ($true) {
        $runningJobs = $jobs | Where-Object { $_.State -eq 'Running' }
        if ($runningJobs.Count -eq 0) {
            break
        }
        Start-Sleep -Seconds 1
    }

    # Check for errors in jobs
    foreach ($job in $jobs) {
        $errorMessage = Receive-Job -Job $job -ErrorAction SilentlyContinue
        if ($errorMessage) {
            $labelProgress.Text = $errorMessage  # Display the error message
            return  # Exit if there's an error
        }
    }

    $labelProgress.Text = "Installations Completed!"
})

$form.ShowDialog()