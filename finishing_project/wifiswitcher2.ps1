# Load the required assembly for Windows Forms
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$profile1 = "TEKNBC"  
$profile2 = "Backup TEK_NB"


function Connect-WiFiProfile {
    param (
        [string]$profileName
    )
    netsh wlan connect name=$profileName
}


$form = New-Object System.Windows.Forms.Form
$form.Text = "WiFiSwitch"
$form.Size = New-Object System.Drawing.Size(240, 140)
$form.StartPosition = [System.Windows.Forms.FormStartPosition]::Manual
$form.Location = New-Object System.Drawing.Point(1000,300)
$form.BackColor = 'black'

$toggleButton = New-Object System.Windows.Forms.Button
$toggleButton.Text = "SWITCH"
$toggleButton.font = New-Object System.Drawing.Font('Segoe UI', 33, [System.Drawing.FontStyle]::Bold)
$toggleButton.Size = New-Object System.Drawing.Size(200, 50)
$toggleButton.Location = New-Object System.Drawing.Point(10, 10)
$toggleButton.Cursor = [System.Windows.Forms.Cursors]::Hand
$toggleButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$toggleButton.BackColor = [System.Drawing.Color]::Black
$toggleButton.ForeColor = [System.Drawing.Color]::White
$toggleButton.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::red

$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Size = New-Object System.Drawing.Size(250, 50)
$statusLabel.Location = New-Object System.Drawing.Point(10, 70)
$statusLabel.Text = "Status: Ready"
$statusLabel.AutoSize = $true
$statusLabel.ForeColor = "white"

$toggleButton.Add_Click({
    $currentProfile = (netsh wlan show interfaces | Select-String "SSID" | ForEach-Object { $_.ToString().Split(':')[1].Trim() })

    # Toggle logic
    if ($currentProfile -eq $profile1) {
        $statusLabel.Text = "Connected to $profile1. Switching to $profile2..."
        Connect-WiFiProfile -profileName $profile2
    } elseif ($currentProfile -eq $profile2) {
        $statusLabel.Text = "Connected to $profile2. Switching to $profile1..."
        Connect-WiFiProfile -profileName $profile1
    } else {
        $statusLabel.Text = "You are not connected to either profile. Connecting to $profile1..."
        Connect-WiFiProfile -profileName $profile1
    }

    Start-Sleep -Seconds 2
    $newProfile = (netsh wlan show interfaces | Select-String "SSID" | ForEach-Object { $_.ToString().Split(':')[1].Trim() })
    $statusLabel.Text = "Status: $newProfile"
})

# Add the button and label to the form
$form.Controls.Add($toggleButton)
$form.Controls.Add($statusLabel)

# Show the form
$form.Add_Shown({$form.Activate()})
[void]$form.ShowDialog()