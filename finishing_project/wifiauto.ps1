Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

Set-WinHomeLocation -GeoId 111
Set-Culture -CultureInfo (New-Object System.Globalization.CultureInfo('en-ID'))                           
tzutil /s "SE Asia Standard Time"  

# Create the form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Wifi Panel"
$form.Size = New-Object System.Drawing.Size(300, 150)
$form.StartPosition = [System.Windows.Forms.FormStartPosition]::Manual
$form.Location = New-Object System.Drawing.Point(1000, 20)
$form.BackColor = [System.Drawing.Color]::White
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::None
$form.ControlBox = $false

# Create a Panel to hold the Label
$panel = New-Object System.Windows.Forms.Panel
$panel.Dock = [System.Windows.Forms.DockStyle]::Fill
$panel.AutoScroll = $true  # Enable scrolling
$panel.BackColor = [System.Drawing.Color]::White

# Create a Label to display log messages
$label = New-Object System.Windows.Forms.Label
$label.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]::Bold)
$label.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter  # Align text to the center
$label.Dock = [System.Windows.Forms.DockStyle]::Fill
$label.AutoSize = $false  # Allow the label to resize based on text

# Add the Label to the Panel
$panel.Controls.Add($label)

# Add the Panel to the Form
$form.Controls.Add($panel)

# Function to log messages
function Log-Message {
    param (
        [string]$message
    )
    # Append the new message to the label's text
    $label.Text += "$message`r`n"
    
    # Scroll to the bottom of the panel
    $panel.VerticalScroll.Value = $panel.VerticalScroll.Maximum
}

$wifiProfile = "$($env:TEMP)\finishing_project\TEKNBC.xml"
$networkName = "TEKNBC" 
$wifiProfile2 = "$($env:TEMP)\finishing_project\Backup TEK_NB"
netsh.exe wlan add profile filename="$wifiProfile2" user=all 2>&1


$startButton = New-Object System.Windows.Forms.Button
$startButton.Text = "Connect"
$startButton.Dock = [System.Windows.Forms.DockStyle]::Bottom
$form.Controls.Add($startButton)


# Function to handle the Wi-Fi connection logic
function Connect-WiFi {
    $currentWiFi = (Get-NetConnectionProfile).Name
    if ($currentWiFi -eq $networkName) {
        Log-Message "Connected to '$networkName'"
        Start-Sleep -Seconds 3
        $form.Close()
    } else {
        if (-Not (Test-Path $wifiProfile)) {
            Log-Message "Wi-Fi profile not found."
            [System.Windows.Forms.MessageBox]::Show("Gagal Menghubungkan Wi-Fi,Silakan Hubungkan Manual: $_", "Failed to Connect")
            $form.Close()
        } else {
            Log-Message "Wi-Fi profile found."
            $result = netsh.exe wlan add profile filename="$wifiProfile" user=all 2>&1
            
            if ($result -like "*Failed*") {
                Start-Sleep -Seconds 1
                Log-Message "Failed to add Wi-Fi profile: $wifiProfile"
                return
            } else {
                Start-Sleep -Seconds 1
                Log-Message "Successfully added Wi-Fi profile: $networkName"
                Start-Sleep -Seconds 5
                }
                <#
                $maxRetries = 10
                $retryInterval = 5  # in seconds
                $retryCount = 0

                while ($retryCount -lt $maxRetries) {
                    $availableNetworks = netsh.exe wlan show networks
                    if ($availableNetworks -like "*$networkName*") {
                        Log-Message "Wi-Fi network '$networkName' is available"
                        break
                    }

                    Log-Message "'$networkName' is not available. Retry: $retryCount"
                    Start-Sleep -Seconds $retryInterval
                    $retryCount++
                }
                if ($retryCount -eq $maxRetries) {
                    Log-Message "Failed to connect to Wi-Fi network: $networkName after $maxRetries retries"

                }
            }
                #>
                netsh.exe wlan connect name=$networkName
                Start-Sleep -Seconds 5  # wait for the connection to establish
                $interface = netsh.exe wlan show interfaces
                if ($interface -like "*$networkName*") {
                    Log-Message "Successfully connected to Wi-Fi network: $networkName"
                    }
                    Start-Sleep -Seconds 5
                    
                    # Run misc-settings in the same session context
                    Log-Message "Activating Windows"                  
                    Start-Process -FilePath "cscript.exe" -ArgumentList "//nologo C:\Windows\System32\slmgr.vbs /ato" -WindowStyle Hidden -Wait
                    #Start-Process -FilePath "cscript.exe" -ArgumentList "//nologo C:\Windows\System32\slmgr.vbs /ato" -WindowStyle Hidden
                    Start-Sleep -Seconds 3                   
                    netsh.exe wlan set profileparameter name=$networkName cost=Fixed  
                    
                    # Close the form after running the commands
                    $form.Close()  
               <# } else {
                    Log-Message "Failed to connect to Wi-Fi network: $networkName"
                    [System.Windows.Forms.MessageBox]::Show("Gagal Menghubungkan Wi-Fi,Silakan Hubungkan Manual: $_", "Failed to Connect")
                    $form.Close()
                #>

                }
            }
        
    }


# Modify the button click event to call the new function
$startButton.Add_Click({
    Connect-WiFi
})
$processorName = (Get-CimInstance -ClassName Win32_Processor).Name
$form.Add_Shown({
    $form.Activate()
    if($processorName -like "*Celeron*" -or $processorName -like "*Athlon*"){
    Write-Host "MANUAL CONNECT WIFI"
    } else {
    $startButton.Visible = $false  # Hide the button immediately
    Connect-WiFi
    }                   # Call the function directly
})

[void]$form.ShowDialog()