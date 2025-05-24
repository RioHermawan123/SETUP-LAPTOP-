Set-Location -Path $PSScriptRoot
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

function Set-WindowStyle {
<#
.SYNOPSIS
    To control the behavior of a window
.DESCRIPTION
    To control the behavior of a window
.PARAMETER Style
    Describe parameter -Style.
.PARAMETER MainWindowHandle
    Describe parameter -MainWindowHandle.
.EXAMPLE
    (Get-Process -Name notepad).MainWindowHandle | foreach { Set-WindowStyle MAXIMIZE $_ }

#>

    [CmdletBinding(ConfirmImpact='Low')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions','')]
    param(
        [ValidateSet('FORCEMINIMIZE', 'HIDE', 'MAXIMIZE', 'MINIMIZE', 'RESTORE',
                    'SHOW', 'SHOWDEFAULT', 'SHOWMAXIMIZED', 'SHOWMINIMIZED',
                    'SHOWMINNOACTIVE', 'SHOWNA', 'SHOWNOACTIVATE', 'SHOWNORMAL')]
        [string] $Style = 'SHOW',

        $MainWindowHandle = (Get-Process -Id $pid).MainWindowHandle
    )

    begin {
        Write-Verbose -Message "Starting [$($MyInvocation.Mycommand)]"

        $WindowStates = @{
            FORCEMINIMIZE   = 11; HIDE            = 0
            MAXIMIZE        = 3;  MINIMIZE        = 6
            RESTORE         = 9;  SHOW            = 5
            SHOWDEFAULT     = 10; SHOWMAXIMIZED   = 3
            SHOWMINIMIZED   = 2;  SHOWMINNOACTIVE = 7
            SHOWNA          = 8;  SHOWNOACTIVATE  = 4
            SHOWNORMAL      = 1
        }
    }

    process {
        Write-Verbose -Message ('Set Window Style {1} on handle {0}' -f $MainWindowHandle, $($WindowStates[$style]))

        $Win32ShowWindowAsync = Add-Type -memberDefinition @'
[DllImport("user32.dll")]
public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
'@ -name 'Win32ShowWindowAsync' -namespace Win32Functions -passThru

        $Win32ShowWindowAsync::ShowWindowAsync($MainWindowHandle, $WindowStates[$Style]) | Out-Null
    }

    end {
        Write-Verbose -Message "Ending [$($MyInvocation.Mycommand)]"
    }
}

$filePath = "namateknisi.txt"  # Change this to your file path
    if (Test-Path $filePath) {
        $namateknisi = Get-Content $filePath 
    } else {
        $namateknisi = "Teknisi"  # Default name if file doesn't exist9
    }

# Create the main form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Tools Support - $($namateknisi)"
$form.Size = New-Object System.Drawing.Size(495, 565)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
$form.MaximizeBox = $false  # Disable the maximize button
$form.MinimizeBox = $false  # Disable the minimize button

# Create panels for differrent pages
$page1 = New-Object System.Windows.Forms.Panel
$page1.Dock = 'Fill'
$page1.BackColor = "#FA8B01"
#$page1.BackColor = [System.Drawing.Color]::DarkCyan

$page2 = New-Object System.Windows.Forms.Panel
$page2.Dock = 'Fill'
$page2.BackColor = [System.Drawing.Color]::Gray
$page2.Visible = $false  # Hide page 2 initially

#-------------------------------------------------------------------------------------------------------------------------


# Add controls to Page 1
$labelWelcome = New-Object System.Windows.Forms.Label
$labelWelcome.Text = "Welcome, $namateknisi"
$labelWelcome.Font = New-Object System.Drawing.Font('Segoe UI', 18, [System.Drawing.FontStyle]::Bold)
$labelWelcome.AutoSize = $true
$page1.Controls.Add($labelWelcome)
$labelWelcome.Location = New-Object System.Drawing.Point(
    [int](($form.ClientSize.Width - $labelWelcome.Width) / 2),  35  )
$page1.Controls.Add($labelWelcome)


$labelTeknisi = New-Object System.Windows.Forms.Label
$labelTeknisi.Text = "$namateknisi"
$labelTeknisi.Location = New-Object System.Drawing.Point(200, 20)
$labelTeknisi.Font = New-Object System.Drawing.Font('Segoe UI', 20, [System.Drawing.FontStyle]::Bold)
$labelTeknisi.Size = "150 , 40"
#$page1.Controls.Add($labelTeknisi)

$nextButton = New-Object System.Windows.Forms.Button
$nextButton.Text = ""
$nextButton.Location = New-Object System.Drawing.Point(3, 3)
$nextButton.Cursor = [System.Windows.Forms.Cursors]::Hand
$nextButton.Size = "20,20"
$nextButton.BackColor = [System.Drawing.Color]::Transparent
$nextButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$nextButton.FlatAppearance.BorderSize = 0 
$nextButton.UseVisualStyleBackColor = $false 
$nextButton.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::White
$nextButton.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::Red
$nextButton.Add_Click({
    # Switch to Page 2
    $page1.Visible = $false
    $page2.Visible = $true

})
$page1.Controls.Add($nextButton)


#----------------------------------------------------------------------------------------------------------------
# == CEK BRAND MODEL NAME ==================================

 function Get-Brand{
    $ComputerSystem = Get-CimInstance -ClassName Win32_ComputerSystem
    $Brand = $ComputerSystem.Manufacturer
    $FixBrand = switch -Regex ($Brand) {
        'Acer'    { 'Acer' }
        'ASUSTeK' { 'Asus' }
        'Dell'    { 'Dell' }
        'HP'      { 'HP' }
        'Lenovo'  { 'Lenovo' }
    'Micro-Star'  { 'MSI' }
        default   { $Brand }
    }
    return $FixBrand
}

function Get-Model{
    $ComputerSystem = Get-CimInstance -ClassName Win32_ComputerSystem
    $Model = $ComputerSystem.Model
    $SystemFamily = $ComputerSystem.SystemFamily

    $FixModel = switch (Get-Brand) {
    'HP' { 
            # Normalize the HP model
            $normalizedModel = $Model -replace "^HP ", "" -replace "_", " "
        
            # Process the model based on the provided examples
            if ($normalizedModel -match "Pavilion x360 .*") {
                return "Pavilion x360"  # Return "Pavilion x360"
            } 
            elseif ($normalizedModel -match "Pavilion Plus .*") {
                return "Pavilion Plus"  # Return "Pavilion Plus"
            } 
            elseif ($normalizedModel -match "Victus by HP Gaming Laptop (\d+)") {
                return "Victus $($matches[1])"  # Return "Victus 15"
            } 
            elseif ($normalizedModel -match "Envy x360 .*") {
                return "Envy x360"  # Return "Envy x360"
            } 
            elseif ($normalizedModel -match "Laptop (\d+[a-zA-Z]?)(?:-\w+)?") {
                return $matches[1]  # Extract the model number (e.g., "14s-dq5xxx" -> "14s")
            } 
            elseif ($normalizedModel -match "245 (\d+) inch G(\d+)") {
                return "245 G$($matches[2])"  # Return "245 G10"
            } 
            else {
                return $normalizedModel -replace "_.*", ""  # Remove everything after the first underscore
            }
        }
    'Lenovo' { $SystemFamily }
    'MSI'    { $Model }
    'Asus'   { 
                $normalizedModel = $Model -replace "ASUS ", "" -replace "_", " "
                $parts = $normalizedModel -split " "
        
                if ($parts[0] -eq "TUF" -and $parts[1] -eq "Gaming") {
                    return "TUF $($parts[2]) $($parts[-1])"
                } 
                elseif ($parts[0] -eq "ROG" -and $parts[1] -eq "Strix") {
                    return "ROG Strix $($parts[2])" 
                } 
                elseif ($parts[0] -eq "ROG" -and $parts[1] -eq "Zephyrus") {
                    return "ROG Zephyrus $($parts[2])" 
                } 
                elseif ($parts[0] -eq "ROG" -and $parts[1] -eq "Flow") {
                    return "ROG Flow $($parts[2])"
                } 
                elseif ($parts[0] -eq "Zenbook") {
                    return "Zenbook $($parts[1]) $($parts[-1])"
                } 
                elseif ($normalizedModel -match "^(Vivobook|VivoBook) (.*?)(\s+|_)(\w+)$") {
                    return "Vivobook $($matches[4])"
                } 
                # Default case for other models
                else {
                    return $normalizedModel -replace "_.*", ""  # Remove everything after the first underscore
                }
            }                 
    'Acer'   {
                $normalizedModel = $Model -replace "Acer ", "" -replace "_", " "
                if ($normalizedModel -eq "Lite 14") {
                return "Aspire Lite 14"  
                  } else {
                return $Model  
                 }
             }
    'Dell'   { $Model }
    default  { $Model }
}


    return $FixModel
}

$merkLaptop = Get-Brand
$typeLaptop = Get-Model

if ($merkLaptop -like "Lenovo"){
    $modeldetected = (Get-CimInstance -ClassName Win32_ComputerSystem).SystemFamily
}else{
    $modeldetected = (Get-CimInstance -ClassName Win32_ComputerSystem).Model
}

    $brandName = New-Object System.Windows.Forms.Label
    $brandName.Text = "$merkLaptop $typeLaptop"
    $brandName.AutoSize = $true
    $brandName.Font = New-Object System.Drawing.Font('Segoe UI', 20, [System.Drawing.FontStyle]::Bold)
    $brandName.ForeColor = "LightGray"
    #$brandName.BackColor = "white"
    $page1.Controls.Add($brandName)
    $brandName.Location = New-Object System.Drawing.Point(
    [int](($form.ClientSize.Width - $brandName.Width) / 2),  90  )
    $page1.Controls.Add($brandName)


    $modelName = New-Object System.Windows.Forms.Label
    $modelName.Text = "$TypeLaptop"
    $modelName.AutoSize = $true
    $modelName.Font = New-Object System.Drawing.Font('Segoe UI', 16, [System.Drawing.FontStyle]::Bold)
    $modelName.ForeColor = "BLACK"
    #$modelName.BackColor = "white"

    $modelName.Location = New-Object System.Drawing.Point(
    [int](($form.ClientSize.Width - $modelName.Width) / 2),  100  )
    #$page1.Controls.Add($modelName)

# RUN - GUI =====================================================================================
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


# ================================= A U T O C L I C K ==========================================

$Autoclick = New-Object System.Windows.Forms.GroupBox
$Autoclick.Text = "AutoClick"
$Autoclick.Size = New-Object System.Drawing.Size(440, 50)
$Autoclick.Location = New-Object System.Drawing.Point(20, 170)
$Autoclick.BackColor = "#E7D283"
# $Autoclick.BackColor = [System.Drawing.Color]::LightGray

function set-FolderOpt {
    $WshShell = New-Object -comObject WScript.Shell
    $WshShell.Run("control.exe folders")
    Start-Sleep -Milliseconds 1000
    $WshShell.SendKeys("{DOWN}") 
    1..3 | ForEach-Object { $WshShell.SendKeys("{TAB}") }
    $WshShell.SendKeys(" ")
    $WshShell.SendKeys("{TAB}") 
    $WshShell.SendKeys(" ")
    $WshShell.SendKeys("{TAB}") 
    $WshShell.SendKeys(" ")
    $WshShell.SendKeys("{ENTER}")
    start-sleep -seconds 1
}

$folderOpt = New-Object System.Windows.Forms.CheckBox
$folderOpt.Location = New-Object System.Drawing.Point(60,15)
$folderOpt.AutoSize = $true
$folderOpt.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$folderOpt.Text = 'Folder Option'
$folderOpt.FlatStyle = 'Flat'
$folderOpt.ForeColor = 'BLACK'
#$folderOpt.BackColor = '#cea7ee'
$folderOpt.Cursor = [System.Windows.Forms.Cursors]::Hand
$folderOpt.Checked = $true
$Autoclick.Controls.Add($folderOpt)


function set-DesktopIcon {
$WshShell = New-Object -comObject WScript.Shell
$WshShell.Run("rundll32.exe shell32.dll,Control_RunDLL desk.cpl,,0")
start-sleep -Milliseconds 700

$WshShell.SendKeys(" ") 
$WshShell.SendKeys("{DOWN}")
$WshShell.SendKeys(" ") 
$WshShell.SendKeys("{ENTER}")


}

$desktopIco = New-Object System.Windows.Forms.CheckBox
$desktopIco.Location = New-Object System.Drawing.Point(170,15)
$desktopIco.AutoSize = $true
$desktopIco.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$desktopIco.Text = 'Desktop Icon'
$desktopIco.FlatStyle = 'Flat'
$desktopIco.ForeColor = 'BLACK'
#$desktopIco.BackColor = '#cea7ee'
$desktopIco.Cursor = [System.Windows.Forms.Cursors]::Hand
$desktopIco.Checked = $true
$Autoclick.Controls.Add($desktopIco)

 function set-Taskbar {
    $shell = New-Object -ComObject Shell.Application
    $shell.minimizeall()
    Start-Sleep -Milliseconds 500
    $wsh = New-Object -ComObject Wscript.Shell
    $wsh.sendkeys('{F5}')

    $wshell = New-Object -ComObject WScript.Shell
    Start ms-settings:taskbar
    $wshell.AppActivate("Settings")
                Start-Sleep -second 3
                $wshell.SendKeys('{TAB}''{TAB}''{TAB}''{TAB}''{TAB}')
                Start-Sleep -Milliseconds 200
                $wshell.SendKeys('{ }''{TAB}''{ }''{TAB}''{ }')
                Start-Sleep -Seconds 2
                $wshell.SendKeys('%{F4}')
}


$taskbarIco = New-Object System.Windows.Forms.CheckBox
$taskbarIco.Location = New-Object System.Drawing.Point(275,15)
$taskbarIco.AutoSize = $true
$taskbarIco.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$taskbarIco.Text = 'Taskbar Icon'
$taskbarIco.FlatStyle = 'Flat'
$taskbarIco.ForeColor = 'BLACK'
#$taskbarIco.BackColor = '#cea7ee'
$taskbarIco.Cursor = [System.Windows.Forms.Cursors]::Hand
$taskbarIco.Checked = $true
$Autoclick.Controls.Add($taskbarIco)

$AutoclickAll = New-Object System.Windows.Forms.CheckBox
$AutoclickAll.Text = "ALL"
$AutoclickAll.Location = New-Object System.Drawing.Point(10, 15)
$AutoclickAll.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$AutoclickAll.FlatStyle = 'Flat'
$AutoclickAll.ForeColor = 'BLACK'
#$AutoclickAll.BackColor = '#cea7ee'
$AutoclickAll.Cursor = [System.Windows.Forms.Cursors]::Hand
$AutoclickAll.Checked = $true
$AutoclickAll.Add_CheckStateChanged({
    if ($AutoclickAll.Checkstate -eq $true) {
         $folderOpt.Checked = $true
         $desktopIco.Checked = $true
         $taskbarIco.Checked = $true
    }
    elseif ($AutoclickAll.Checkstate -eq $false) {
         $folderOpt.Checked = $false
         $desktopIco.Checked = $false
         $taskbarIco.Checked = $false
    }
})
$Autoclick.Controls.Add($AutoclickAll)

$runAutoclick = New-Object System.Windows.Forms.Button
$runAutoclick.Text = "GO"
$runAutoclick.Size = "50, 20"
$runAutoclick.Cursor = [System.Windows.Forms.Cursors]::Hand
$runAutoclick.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$runAutoclick.Location = New-Object System.Drawing.Point(380, 16)
$runAutoclick.FlatAppearance.BorderColor = [System.Drawing.Color]::Black
$runAutoclick.Add_Click({
   if($folderOpt.Checked) { set-FolderOpt }
   if($desktopIco.Checked) { set-DesktopIcon }
   if($taskbarIco.Checked) { set-Taskbar}
})
$Autoclick.Controls.Add($runAutoclick)

$page1.Controls.Add($Autoclick)
#------------------------ P A R T I S I --------------------------------------------------------------------------------------------------

$partisi = New-Object System.Windows.Forms.GroupBox
$partisi.Text = "Partisi"
$partisi.Size = New-Object System.Drawing.Size(440, 47)
$partisi.Location = New-Object System.Drawing.Point(20, 230)
$partisi.BackColor = "#E7D283"
# $partisi.BackColor = [System.Drawing.Color]::LightGray


#Detect Disk C Capacity

$Result = Get-WmiObject -Class Win32_LogicalDisk -Filter "DeviceID='C:'" | Select-Object -ExpandProperty Size
$ResultGB = [math]::Round($Result / 1GB, 0)

if ($ResultGB -lt 200) {
    $SSD = "128GB"
} elseif ($ResultGB -ge 200 -and $ResultGB -lt 400) {
    $SSD = "256GB"
} elseif ($ResultGB -ge 400 -and $ResultGB -lt 600) {
    $SSD = "512GB"
} else {
    $SSD = "1TB"
}


$checkboxPartisi = New-Object System.Windows.Forms.CheckBox
$checkboxPartisi.Location = New-Object System.Drawing.Point(10, 18)
$checkboxPartisi.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$checkboxPartisi.FlatStyle = 'Flat'
$checkboxPartisi.AutoSize = $true
$checkboxPartisi.Cursor = [System.Windows.Forms.Cursors]::Hand
$partisi.Controls.Add($checkboxPartisi)

$labelIsiPARTISI = New-Object System.Windows.Forms.Label
$labelIsiPARTISI.Location = New-Object System.Drawing.Point(187,15)
$labelIsiPARTISI.AutoSize = $true
$labelIsiPARTISI.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]::Bold)
$labelIsiPARTISI.Text = "-->         Partisi D :"

$TextBoxPARTISI = New-Object System.Windows.Forms.TextBox
$TextBoxPARTISI.Location = New-Object System.Drawing.Point(310,12)
$TextBoxPARTISI.Size = New-Object System.Drawing.Size(40,50)
$TextBoxPARTISI.Font = New-Object System.Drawing.Font('Segoe UI', 10,  [System.Drawing.FontStyle]::Bold)

#LOGIC TEXTBOX PARTISI========================================================================

function Update-TextBox {
    if ($ResultGB -ge 200 -and $ResultGB -le 300) {
        $TextBoxPARTISI.Text = "100"
    } elseif ($ResultGB -ge 400 -and $ResultGB -le 600) {
        $TextBoxPARTISI.Text = "300"
       } elseif ($ResultGB -gt 800) {
        $TextBoxPARTISI.Text = "700"
    }
}


function Update-TextBox-Gaming {
    if ($ResultGB -ge 100 -and $ResultGB -le 600) {
        $TextBoxPARTISI.Text = "250"
    } elseif ($ResultGB -gt 800) {
        $TextBoxPARTISI.Text = "600"
       } 
}
#====================================================================
$tipeunit = ""
$gamingLaptopTypes = @("TUF", "ROG", "Victus", "Omen", "LOQ", "Legion", "Nitro", "Predator", "Thin" ,"Cyborg", "Bravo", "Katana", "Sword", "Stealth","Pongo")
if ($gamingLaptopTypes | Where-Object { $typelaptop -like "*$_*" }) {
    Update-TextBox-Gaming
    $tipeunit = "GAMING"
} else {
    $tipeunit = "NON-GAMING"
    Update-TextBox
}

$totalC = New-Object System.Windows.Forms.Label
$totalC.Location = New-Object System.Drawing.Point(25,15)
$totalC.AutoSize = $true
$totalC.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]::Bold)
$totalC.Text = "$SSD $tipeunit"

$labeldisk128 = New-Object System.Windows.Forms.Label
$labeldisk128.Text = " STORAGE 128GB "
$labeldisk128.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]::Bold)
$labeldisk128.AutoSize = $true
$labeldisk128.Location = New-Object System.Drawing.Point(
    [int](($partisi.Width - $labeldisk128.Width) / 2 - 15), 15)


$labelSudahPartisi = New-Object System.Windows.Forms.Label
$labelSudahPartisi.Text = "SUDAH ADA PARTISI"
$labelSudahPartisi.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]::Bold)
$labelSudahPartisi.AutoSize = $true
$labelSudahPartisi.Location = New-Object System.Drawing.Point(
    [int](($partisi.Width - $labelSudahPartisi.Width) / 2 - 20), 15)

function ResizeAndCreatePartition {
    param (
        [double]$partitionSizeGB
    )

    # Validate input
    if ($partitionSizeGB -le 0) {
        [System.Windows.Forms.MessageBox]::Show("Partisi harus lebih dari 0.", "Invalid Input")
        return
    }

    if ($partitionSizeGB -lt 1) {
        [System.Windows.Forms.MessageBox]::Show("Minimal Partisi adalah 1 GB.", "Invalid Input")
        return
    }

    $cDrivePartition = Get-Partition -DriveLetter C
    $currentSize = $cDrivePartition.Size
    $freeSpace = (Get-Volume -DriveLetter C).FreeSpace

    # Add a buffer of 150MB to the requested partition size
    $bufferSizeMB = 150
    $totalPartitionSizeGB = $partitionSizeGB + ($bufferSizeMB / 1024)  # Convert MB to GB

    if ($totalPartitionSizeGB * 1GB > $freeSpace) {
        [System.Windows.Forms.MessageBox]::Show("Ukuran partisi yang diminta melebihi ruang yang tersedia untuk penyusutan.", "Error")
        diskmgmt.msc
        return
    }

    $newCSize = $currentSize - ($totalPartitionSizeGB * 1GB)

    $disk = Get-Disk | Where-Object { $_.OperationalStatus -eq 'Online' -and $_.PartitionStyle -ne 'Raw' } | Select-Object -First 1

    if ($null -eq $disk) {
        [System.Windows.Forms.MessageBox]::Show("Tidak ada disk yang tersedia untuk membuat partisi.", "Error")
        diskmgmt.msc
        return
    }

    $diskNumber = $disk.Number

    try {
        Resize-Partition -DriveLetter C -Size $newCSize -ErrorAction Stop
        $newPartition = New-Partition -DiskNumber 0 -Size ($totalPartitionSizeGB * 1GB) -DriveLetter D -ErrorAction Stop
        Format-Volume -DriveLetter D -FileSystem NTFS -NewFileSystemLabel "DATA" -Confirm:$false -ErrorAction Stop
        #[System.Windows.Forms.MessageBox]::Show("Partisi berhasil dibuat!", "Success")
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Terjadi kesalahan saat membuat Partisi: $_", "Error")
        diskmgmt.msc
    }
}

$runPartisi = New-Object System.Windows.Forms.Button
$runPartisi.Text = "GO"
$runPartisi.Size = "50, 20"
$runPartisi.Cursor = [System.Windows.Forms.Cursors]::Hand
$runPartisi.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$runPartisi.Location = New-Object System.Drawing.Point(380, 16)
$runPartisi.FlatAppearance.BorderColor = [System.Drawing.Color]::Black
$runPartisi.Add_Click({
    $partitionSize = $TextBoxPARTISI.Text

    if (-not ([double]::TryParse($partitionSize, [ref]$null))) {
        [System.Windows.Forms.MessageBox]::Show("Partisi harus diisi angka Valid.", "Invalid Input")
        return
    }

    $partitionSizeGB = [double]$partitionSize 
    ResizeAndCreatePartition -partitionSizeGB $partitionSizeGB
})

# Cek DISK D terpakai \ tdk
if (Test-Path -Path "D:\") {
    $drive = Get-WmiObject -Class Win32_LogicalDisk -Filter "DeviceID='D:'"
    if ($drive.DriveType -eq 2 -and $ResultGB -gt 200) {
        # Ganti Letter D ke H
       Get-Partition -DriveLetter D | Set-Partition -NewDriveLetter H
            $checkboxPartisi.Checked = $true
            $partisi.Controls.Add($totalC)
            $partisi.Controls.Add($labelIsiPARTISI)
            $partisi.Controls.Add($TextBoxPARTISI)
            $partisi.Controls.Add($runPartisi)

        } elseif ($drive.DriveType -eq 2 -and $ResultGB -lt 200) {
            $partisi.Controls.Add($labeldisk128)
            $checkboxPartisi.Hide()
        } else {
            $partisi.Controls.Add($labelSudahPartisi)
            $checkboxPartisi.Hide()
        
            }
} elseif ($ResultGB -lt 200) {
            $partisi.Controls.Add($labeldisk128)
            $checkboxPartisi.Hide()
  
 } else {
            $checkboxPartisi.Checked = $true
            $partisi.Controls.Add($totalC)
            $partisi.Controls.Add($labelIsiPARTISI)
            $partisi.Controls.Add($TextBoxPARTISI)
            $partisi.Controls.Add($runPartisi)
      }


$page1.Controls.Add($partisi)

# FREEWARE ====================================================

$freeware = New-Object System.Windows.Forms.GroupBox
$freeware.Text = "Freeware"
$freeware.Size = New-Object System.Drawing.Size(440, 47)
$freeware.Location = New-Object System.Drawing.Point(20, 287)
$freeware.BackColor = "#E7D283"
# $freeware.BackColor = [System.Drawing.Color]::LightGray

$freewareAUTO = New-Object System.Windows.Forms.CheckBox
$freewareAUTO.Location = New-Object System.Drawing.Point(10,13)
$freewareAUTO.AutoSize = $true
$freewareAUTO.Font = New-Object System.Drawing.Font("Segoe UI", 12,[System.Drawing.FontStyle]::Bold)
$freewareAUTO.Text = 'FREEWARE'
$freewareAUTO.FlatStyle = 'Flat'
$freewareAUTO.Cursor = [System.Windows.Forms.Cursors]::Hand
$freewareAUTO.Checked = $true


$freewareWPS = New-Object System.Windows.Forms.CheckBox
$freewareWPS.Location = New-Object System.Drawing.Point(155, 13)
$freewareWPS.AutoSize = $true
$freewareWPS.Font = New-Object System.Drawing.Font("Segoe UI", 12,[System.Drawing.FontStyle]::Bold)
$freewareWPS.Text = 'FW WPS'
$freewareWPS.FlatStyle = 'Flat'
$freewareWPS.Cursor = [System.Windows.Forms.Cursors]::Hand


$freewareMANUAL = New-Object System.Windows.Forms.CheckBox
$freewareMANUAL.Location = New-Object System.Drawing.Point(280,13)
$freewareMANUAL.AutoSize = $true
$freewareMANUAL.Font = New-Object System.Drawing.Font("Segoe UI", 12,[System.Drawing.FontStyle]::Bold)
$freewareMANUAL.Text = 'MANUAL'
$freewareMANUAL.FlatStyle = 'Flat'
$freewareMANUAL.Cursor = [System.Windows.Forms.Cursors]::Hand
$freewareMANUAL.Checked = $false



$freewareAUTO.Add_CheckStateChanged({
    if ($freewareAUTO.Checked) {
        $freewareMANUAL.Checked = $false
        $freewareWPS.Checked = $false
    }
})

$freewareWPS.Add_CheckStateChanged({
    if ($freewareWPS.Checked) {
        $freewareMANUAL.Checked = $false
        $freewareAUTO.Checked = $false
    }
})

$freewareMANUAL.Add_CheckStateChanged({
    if ($freewareMANUAL.Checked) {
        $freewareAUTO.Checked = $false
        $freewareWPS.Checked = $false
    }
})

if ($merkLaptop -in @("ASUS", "LENOVO", "ACER", "HP", "HUAWEI", "MSI","DELL")) {
    if ($merkLaptop -ieq "MSI"){
          if ($typeLaptop -like "*Thin*" -and $processorName -like "*intel*") {
                $freewareWPS.Checked = $true
          } else{
                $freewareAUTO.Checked = $true
            }
         
    }else{
          if ( $merkLaptop -ieq "HP" -and $typeLaptop -like "*G10*"){
                $freewareWPS.Checked = $true
          } else {
               $freewareAUTO.Checked = $true
          }
    }
    
} else {
    $freewareWPS.Checked = $true
}
$runFreeware = New-Object System.Windows.Forms.Button
$runFreeware.Text = "GO"
$runFreeware.Size = "50, 20"
$runFreeware.Cursor = [System.Windows.Forms.Cursors]::Hand
$runFreeware.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$runFreeware.Location = New-Object System.Drawing.Point(380, 16)
$runFreeware.FlatAppearance.BorderColor = [System.Drawing.Color]::Black
$runFreeware.Add_Click({
    if ($freewareAUTO.Checked) {
       Run-GUI "newfw.ps1"
       #start-process -filepath "$($env:TEMP)\finishing\autonew.exe"
       }
    if ($freewareWPS.Checked) { 
       Run-GUI "newfwwps.ps1"
       #start-process -filepath "$($env:TEMP)\finishing\autonewwps.exe"
       }
    if ($freewareMANUAL.Checked) {
       Run-GUI "fwmanual.ps1"
       }

})

$freeware.Controls.Add($freewareAUTO)
$freeware.Controls.Add($freewareWPS)
$freeware.Controls.Add($freewareMANUAL)
$freeware.Controls.Add($runFreeware)
$page1.Controls.Add($freeware)


#OFFICE =========================================================================================
$serialnumber = (Get-CimInstance -Class Win32_BIOS).SerialNumber
$processorName = (Get-CimInstance -ClassName Win32_Processor).Name
$ramGB = (Get-CimInstance -ClassName Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1GB


$office = New-Object System.Windows.Forms.GroupBox
$office.Text = "Office"
$office.Size = New-Object System.Drawing.Size(440, 48)
$office.Location = New-Object System.Drawing.Point(20, 345)
$office.BackColor = "#E7D283"
# $office.BackColor = [System.Drawing.Color]::LightGray

$checkboxOffice = New-Object System.Windows.Forms.CheckBox
$checkboxOffice.Location = New-Object System.Drawing.Point(10, 19)
$checkboxOffice.FlatStyle = 'Flat'
$checkboxOffice.AutoSize = $true
$checkboxOffice.Cursor = [System.Windows.Forms.Cursors]::Hand

$labelOffice = New-Object System.Windows.Forms.Label
$labelOffice.Location = New-Object System.Drawing.Point(25, 15)
$labelOffice.AutoSize = $true
$labelOffice.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]::Bold)
$labelOffice.Text = ""

$TextBoxAkunOffice = New-Object System.Windows.Forms.TextBox
$TextBoxAkunOffice.Location = New-Object System.Drawing.Point(95,13)
$TextBoxAkunOffice.Size = New-Object System.Drawing.Size(250,50)
$TextBoxAkunOffice.Font = New-Object System.Drawing.Font('Segoe UI', 10,  [System.Drawing.FontStyle]::Bold)

$snMSI = New-Object System.Windows.Forms.TextBox
$snMSI.Location = New-Object System.Drawing.Point(140,12)
$snMSI.Size = New-Object System.Drawing.Size(145,50)
$snMSI.Font = New-Object System.Drawing.Font('Segoe UI', 12,  [System.Drawing.FontStyle]::Bold)


function bikin-NoteAkunOffice {
  $outputFilePath = "D:\AKUN AKTIVASI OFFICE.txt"
    # Create or overwrite the output file
    @"
AKUN AKTIVASI OFFICE HOME STUDENT 2021

Email        : $($merkLaptop)_$($sntxt)@outlook.com
Password     : office2021

NOTE: 
Email ini harap disimpan jangan sampai hilang, berguna sebagai email Recovery Office Home Student 2021.
Digunakan apabila Office butuh aktivasi ulang misalnya sehabis Reset/Instal ulang
Els.id tidak bertanggung apabila terjadi perubahan data.

Jika saat login ke aplikasi Office(Word/Excel/PowerPoint) mengalami error "Oops, something went wrong", 
Itu Berarti Akun Terblokir sementara oleh Microsoft karena harus verifikasi Nomor handphone.

Untuk mengatasinya bisa ikuti langkah berikut :
- login ke web office dengan menggunakan browser di hp/ smartphone.
- ketik login.live.com lalu masukkan email dan password diatas untuk login
- pilih selanjutnya untuk memasukkan no telp yang masih aktif lalu klik next Untuk menerima kode SMS dari Microsoft.
. Jika muncul "Try another verification Method" silakan coba dengan Nomor Lain.
. Jika Tetap tidak bisa Silakan Coba secara berkala , kemungkinan Terjadi kendala di server Microsoft Sehingga Tidak bisa mengirim OTP.
- Jika Muncul Verifikasi Puzzle / CAPTCHA ,selesaikan puzzle lalu masukkan kode 4 digit yang diterima di sms, Maka Akun akan ter-UNBLOCK dan bisa digunakan untuk login di aplikasi Office.
"@ | Set-Content -Path $outputFilePath

    # Copy email to clipboard
    $email = "$($merkLaptop)_$($sntxt)@outlook.com"
    Set-Clipboard -Value $email

    # Open the output file
    Start-Process -FilePath $outputFilePath
}


function Create-ShorcutOffice {
        $publicDesktop = [System.Environment]::GetFolderPath("CommonDesktopDirectory")

        $officeApps = @{
            "Word" = "C:\Program Files\Microsoft Office\root\Office16\WINWORD.EXE"
            "Excel" = "C:\Program Files\Microsoft Office\root\Office16\EXCEL.EXE"
            "PowerPoint" = "C:\Program Files\Microsoft Office\root\Office16\POWERPNT.EXE"
        }

        foreach ($app in $officeApps.Keys) {
            $shortcutPath = Join-Path -Path $publicDesktop -ChildPath "$app.lnk"
            $shell = New-Object -ComObject WScript.Shell
            $shortcut = $shell.CreateShortcut($shortcutPath)
            $shortcut.TargetPath = $officeApps[$app]
            $shortcut.Save()
        }
}




function selenium-OHS {
    param (
        [string]$WebDriverPath = "WebDriver.dll",
        [string]$BrowserExecutableLocation = "C:\Program Files\Mozilla Firefox\firefox.exe",
        [string]$Password = "office2021",
        [string]$BirthMonth = "January",
        [int]$BirthDay = 1,
        [int]$BirthYear = 2000
    )

    Add-Type -Path $WebDriverPath

    $namaBrand = $merkLaptop
    $namaModel = $typeLaptop

    $snlaptop = (Get-CimInstance -ClassName Win32_BIOS).SerialNumber
    $emailOffice = "$($namaBrand)_$snlaptop@outlook.com"

    $options = New-Object OpenQA.Selenium.Firefox.FirefoxOptions
    $options.BrowserExecutableLocation = $BrowserExecutableLocation
    $driver = New-Object OpenQA.Selenium.Firefox.FirefoxDriver($options)

    # Navigate to signup page
    $Driver.Navigate().GoToUrl("https://signup.live.com/")
    Start-Sleep -Seconds 4

    # Fill in email
    $emailInput = $Driver.FindElementByXPath('//input[@placeholder="someone@example.com"]')
    $emailInput.SendKeys("$emailOffice")

    # Click submit button
    $xpathbutton = "//*[@id='iSignupAction'] | //*[@id='nextButton']"
    $Driver.FindElementByXPath($xpathbutton).Click()
    Start-Sleep -Seconds 4

    # Fill in password
    $passwordInput = $Driver.FindElementByXPath('//input[@placeholder="Create password"]')
    $passwordInput.SendKeys($Password)

    # Show password
    $checkBoxElement = $Driver.FindElementByXPath('//*[@id="ShowHidePasswordCheckbox"]')
    $checkBoxElement.Click()

    # Click submit button
    $Driver.FindElementByXPath($xpathbutton).Click()
    Start-Sleep -Seconds 4

    # Fill in first and last name
    $firstName = $Driver.FindElementByXPath('//input[@placeholder="First name"]')
    $firstName.SendKeys("$namaBrand")

    $lastName = $Driver.FindElementByXPath('//input[@placeholder="Last name"]')
    $lastName.SendKeys("$namaModel")

    # Click submit button
    $Driver.FindElementByXPath($xpathbutton).Click()
    Start-Sleep -Seconds 4

    # Fill in birth date
    $birthMonthElement = $Driver.FindElementByXPath('//*[@id="BirthMonth"]')
    $birthMonthElement.SendKeys($BirthMonth)
    $birthMonthElement.SendKeys("{Enter}")

    $birthDayElement = $Driver.FindElementByXPath('//*[@id="BirthDay"]')
    $birthDayElement.SendKeys($BirthDay.ToString())
    $birthDayElement.SendKeys("{Enter}")

    $birthYearElement = $Driver.FindElementByXPath('//*[@id="BirthYear"]')
    $birthYearElement.SendKeys($BirthYear.ToString())
}



function selenium-OHS-MSI {
    param (
        [string]$WebDriverPath = "WebDriver.dll",
        [string]$BrowserExecutableLocation = "C:\Program Files\Mozilla Firefox\firefox.exe",
        [string]$Password = "office2021",
        [string]$BirthMonth = "January",
        [int]$BirthDay = 1,
        [int]$BirthYear = 2000
    )

    Add-Type -Path $WebDriverPath

    $namaBrand = $merkLaptop
    $namaModel = $typeLaptop

 
    $emailOffice = "$($namaBrand)_$($snlaptopmsi)@outlook.com"

    $options = New-Object OpenQA.Selenium.Firefox.FirefoxOptions
    $options.BrowserExecutableLocation = $BrowserExecutableLocation
    $driver = New-Object OpenQA.Selenium.Firefox.FirefoxDriver($options)

    # Navigate to signup page
    $Driver.Navigate().GoToUrl("https://signup.live.com/")
    Start-Sleep -Seconds 4

    # Fill in email
    $emailInput = $Driver.FindElementByXPath('//input[@placeholder="someone@example.com"]')
    $emailInput.SendKeys("$emailOffice")

    # Click submit button
    $xpathbutton = "//*[@id='iSignupAction'] | //*[@id='nextButton']"
    $Driver.FindElementByXPath($xpathbutton).Click()
    Start-Sleep -Seconds 4

    # Fill in password
    $passwordInput = $Driver.FindElementByXPath('//input[@placeholder="Create password"]')
    $passwordInput.SendKeys($Password)

    # Show password
    $checkBoxElement = $Driver.FindElementByXPath('//*[@id="ShowHidePasswordCheckbox"]')
    $checkBoxElement.Click()

    # Click submit button
    $Driver.FindElementByXPath($xpathbutton).Click()
    Start-Sleep -Seconds 4

    # Fill in first and last name
    $firstName = $Driver.FindElementByXPath('//input[@placeholder="First name"]')
    $firstName.SendKeys("$namaBrand")

    $lastName = $Driver.FindElementByXPath('//input[@placeholder="Last name"]')
    $lastName.SendKeys("$namaModel")

    # Click submit button
    $Driver.FindElementByXPath($xpathbutton).Click()
    Start-Sleep -Seconds 4

    # Fill in birth date
    $birthMonthElement = $Driver.FindElementByXPath('//*[@id="BirthMonth"]')
    $birthMonthElement.SendKeys($BirthMonth)
    $birthMonthElement.SendKeys("{Enter}")

    $birthDayElement = $Driver.FindElementByXPath('//*[@id="BirthDay"]')
    $birthDayElement.SendKeys($BirthDay.ToString())
    $birthDayElement.SendKeys("{Enter}")

    $birthYearElement = $Driver.FindElementByXPath('//*[@id="BirthYear"]')
    $birthYearElement.SendKeys($BirthYear.ToString())
}






$runOffice = New-Object System.Windows.Forms.Button
$runOffice.Text = "GO"
$runOffice.Size = "50, 20"
$runOffice.Cursor = [System.Windows.Forms.Cursors]::Hand
$runOffice.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$runOffice.Location = New-Object System.Drawing.Point(380, 16)
$runOffice.FlatAppearance.BorderColor = [System.Drawing.Color]::Black
$runOffice.Add_Click({
            $snlaptopmsi = $snMSI.Text
              if ($merkLaptop -like "MSI") {
                   $sntxt = $snlaptopmsi
              } else {
                $sntxt = $serialnumber
                     }
             Create-ShorcutOffice 
             bikin-NoteAkunOffice
             if ( $merkLaptop -like "MSI"){
                start winword.exe
                (Get-Process -Name excel).MainWindowHandle | foreach { Set-WindowStyle MINIMIZE $_ }
                Invoke-Command -ScriptBlock {
                selenium-OHS-MSI | Out-Null
                }
            }else {
                start winword.exe
                (Get-Process -Name excel).MainWindowHandle | foreach { Set-WindowStyle MINIMIZE $_ }
                Invoke-Command -ScriptBlock {
                selenium-OHS | Out-Null
                }
            }
           <# if ($checkboxOffice.Checked = $true) {
                Run-GUI "$env:TEMP\finishing_project\wifiswitcher2.ps1"
                }
            #>
})



function non-OHS{
              $checkboxOffice.Checked = $false
              $labelOffice.Text = "SERI INI TIDAK ADA OHS"
              $labelOffice.Location = New-Object System.Drawing.Point(140, 15)
              $office.Controls.Add($labelOffice)
              $checkboxOffice.Hide()
}



if ($merkLaptop -in @("ASUS", "LENOVO", "ACER", "HP", "HUAWEI", "MSI","DELL")) {
    if ($merkLaptop -ieq "MSI"){
          if ($typeLaptop -like "*Thin*" -and $processorName -like "*intel*") {
                non-OHS
          } else{
            $checkboxOffice.Checked = $true
            $labelOffice.Text = "MSI              SN :"
            $office.Controls.Add($snMSI)
            $office.Controls.Add($labelOffice)
            $office.Controls.Add($runOffice)
            }
         
    }else{
          if ( $merkLaptop -ieq "HP" -and $typeLaptop -like "*G10*"){
                non-OHS
          } else {
            
            $checkboxOffice.Checked = $true
            $labelOffice.Text = "OFFICE"
            $TextBoxAkunOffice.Text = "$($merkLaptop)_$($serialnumber)@outlook.com"
            $office.Controls.Add($TextBoxAkunOffice)
            $office.Controls.Add($labelOffice)
            $office.Controls.Add($runOffice)
          }
    }
    
} else {
    non-OHS
}

$office.Controls.Add($checkboxOffice)
$page1.Controls.Add($office)

# MCAFEE=======================================================================================
$mcafee = New-Object System.Windows.Forms.GroupBox
$mcafee.Text = "McAfee"
$mcafee.Size = New-Object System.Drawing.Size(440, 48)
$mcafee.Location = New-Object System.Drawing.Point(20, 403)
$mcafee.BackColor = "#E7D283"
# $mcafee.BackColor = [System.Drawing.Color]::LightGray

function Create-McafeeShortcut {
      $mcafeePath = "C:\Program Files\McAfee\WPS\mc-launch.exe"
      if (Test-Path $mcafeePath) {
                $publicDesktop = [System.Environment]::GetFolderPath("CommonDesktopDirectory")
                $shortcutPath = Join-Path $publicDesktop "McAfee.lnk"
                $shell = New-Object -ComObject WScript.Shell
                $shortcut = $shell.CreateShortcut($shortcutPath)
                $shortcut.TargetPath = $mcafeePath
                $shortcut.Save()
       } else {
                Write-Host "Mcafee tidak ada."
      }
}


$checkboxMcafee = New-Object System.Windows.Forms.CheckBox
$checkboxMcafee.Location = New-Object System.Drawing.Point(10, 14)
$checkboxMcafee.FlatStyle = 'Flat'
$checkboxMcafee.Text = "Buka Link Claim McAfee"
$checkboxMcafee.Font = New-Object System.Drawing.Font("Segoe UI", 12,[System.Drawing.FontStyle]::Bold)
$checkboxMcafee.AutoSize = $true
$checkboxMcafee.Cursor = [System.Windows.Forms.Cursors]::Hand

$runMcafee = New-Object System.Windows.Forms.Button
$runMcafee.Text = "GO"
$runMcafee.Size = "50, 20"
$runMcafee.Cursor = [System.Windows.Forms.Cursors]::Hand
$runMcafee.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$runMcafee.Location = New-Object System.Drawing.Point(380, 16)
$runMcafee.FlatAppearance.BorderColor = [System.Drawing.Color]::Black
$runMcafee.Add_Click({
      Create-McafeeShortcut

$urls = @(
            "https://accounts.google.com/v3/signin/identifier?continue=https%3A%2F%2Fmail.google.com%2Fmail%2F&ifkv=Ab5oB3oYWn4PHSsvg4PanheTvcPGkVBIYf7Lq6aTlurVk1nwKuF5FLeTUFGa6vUX2iVEw1NbaDwXYA&rip=1&sacu=1&service=mail&flowName=GlifWebSignIn&flowEntry=ServiceLogin&dsh=S-852715550%3A1723482172619675&ddm=0",
            "https://mcafee.com/kims",
            "https://mcafee.com/kims",
            "https://mcafee.com/kims"
        )

        Start-Process "msedge.exe" -ArgumentList $urls -WindowStyle Minimized
        Start-Sleep 1
        (Get-Process -Name msedge).MainWindowHandle | foreach { Set-WindowStyle MINIMIZE $_ }
})

$mcafee.Controls.Add($checkboxMcafee)
$mcafee.Controls.Add($runMcafee)
$page1.Controls.Add($mcafee)



$page1.Add_Paint({
    param($sender, $e)

    # Create a pen to draw the line
    $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::LightGray, 1) # Black color, 2 pixels width

    # Draw a vertical line
    $e.Graphics.DrawLine($pen, 232, 170, 232, 480) # (x1, y1, x2, y2)

    # Dispose of the pen
    $pen.Dispose()
})



$runALL = New-Object System.Windows.Forms.Button
$runALL.Text = "RUN"
$runALL.Size = "80, 40"
$runALL.Backcolor = "Snow"
$runALL.Cursor = [System.Windows.Forms.Cursors]::Hand
$runALL.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$runALL.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]::Bold)
$runALL.Location = New-Object System.Drawing.Point(192, 466)
$runALL.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::Green
$runALL.FlatAppearance.BorderColor = [System.Drawing.Color]::Black
$runALL.Add_Click({
    start-process -filepath "$($env:TEMP)\finishing_project\time.bat"
    (Get-Process -Name powershell).MainWindowHandle | foreach { Set-WindowStyle MINIMIZE $_ }
    $runAutoclick.PerformClick()
    if ($checkboxPartisi.Checked){
            $runPartisi.PerformClick()
        }
    $runFreeware.PerformClick()
    if ($checkboxOffice.Checked){
            $runOffice.PerformClick()
        } 
    if ($checkboxMcafee.Checked){
            $runMcafee.PerformClick()
        }
})
$page1.Controls.Add($runALL)

             

$testButton = New-Object System.Windows.Forms.Button
$testButton.Text = ""
$testButton.Size = "80, 40"
$testButton.Cursor = [System.Windows.Forms.Cursors]::Hand
$testButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$testButton.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]::Bold)
$testButton.Location = New-Object System.Drawing.Point(380, 466)
$testButton.FlatAppearance.BorderColor = [System.Drawing.Color]::LightGray
$testButton.BackColor = [System.Drawing.Color]::Transparent
$testButton.FlatAppearance.BorderSize = 0 
$testButton.Visible = $true
$testButton.UseVisualStyleBackColor = $false 
$testButton.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::White
$testButton.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::LightGreen
$testButton.Add_Click({
Run-GUI "fwauto.ps1"
})
$page1.Controls.Add($testButton)

function REPORT-NONOHS {

    $formUrl = "https://docs.google.com/forms/d/e/1FAIpQLSetEJsh0YeC8YRn-W6EMNmQfcYhLxCNkGpn5zf0SNr2XW0jqg/formResponse"
        
     $formData = @{
        "entry.80679584" = "$namateknisi"   #teknisi
        "entry.1221910596" = "$serialnumber" #sn
        "entry.1477663918" = "$merkLaptop" #brand
        "entry.1219257192" = "$typeLaptop" #modelprocessd
        "entry.2013583334" = "$modeldetected" #modeldtcted
        "entry.985676516" = "$processorName" #processor
        "entry.1024081183" = "$($ramGB)GB"   #ram
        "entry.642883361" = "$SSD" #storage
        "entry.315707343" = "TIDAK INCLUDE OFFICE" #akunoffice
        "entry.1851907708" = "TIDAK INCLUDE OFFICE" #password
    }

        # =================== ENTRY FOR TRIAL CHECK FORM =========================

    #     $formUrl = "https://docs.google.com/forms/u/0/d/e/1FAIpQLSfC_RJbfvVc6vb3-c4MrzOVEZTevy2-HFFvpVLMzs5-6E_W-w/formResponse"
    # $formData = @{
    # "entry.1615389212" = "$namateknisi"  
    # "entry.1331036153" = "$serialnumber" 
    # "entry.1138861216" = "$brand"
    # "entry.193620070" = "$modelprocessed"
    # "entry.1733327904" = "$modeldetected"
    # "entry.1745697285" = "$processor"
    # "entry.413879700" = "$($ram)GB"
    # "entry.2105807562" = "$storage"
    # "entry.1353344334" = "TIDAK INCLUDE OFFICE" #akunoffice
    # "entry.567943420" = "TIDAK INCLUDE OFFICE" #password
    # }

    # ==========================================================================

    try {
    $response = Invoke-WebRequest -Uri $formUrl -Method POST -Body $formData
    }catch{
        Return
    }
}

# =================================== P A G E 2 =================================

$changeName = New-Object System.Windows.Forms.GroupBox
$changeName.Size = New-Object System.Drawing.Size(300, 130)
$changeName.Location = New-Object System.Drawing.Point(
    [int](($form.ClientSize.Width - $changeName.Width) / 2),
    [int](($form.ClientSize.Height - $changeName.Height) / 2))

$changeName.BackColor = [System.Drawing.Color]::White

$changeNameLabel = New-Object System.Windows.Forms.Label
$changeNameLabel.Text = "Masukkan Nama Baru :"
$changeNameLabel.AutoSize = $true
$changeNameLabel.Font = New-Object System.Drawing.Font('Segoe UI', 12, [System.Drawing.FontStyle]::Bold)
$changeName.Controls.Add($changeNameLabel)
$changeNameLabel.Location = New-Object System.Drawing.Point(
    [int](($changeName.Width - $changeNameLabel.Width) / 2),15 )
$changeName.Controls.Add($changeNameLabel)

$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Font = New-Object System.Drawing.Font('Segoe UI', 12, [System.Drawing.FontStyle]::Bold)
$textBox.size = "200, 20"
$textBox.TextAlign = [System.Windows.Forms.HorizontalAlignment]::Center
$changeName.Controls.Add($textBox)
$textBox.Location = New-Object System.Drawing.Point(
    [int](($changeName.Width - $textBox.Width) / 2),50 )
$changeName.Controls.Add($textBox)

$saveName = New-Object System.Windows.Forms.Button
$saveName.Text = "Save"
$saveName.Font = New-Object System.Drawing.Font('Segoe UI', 12, [System.Drawing.FontStyle]::Bold)

$saveName.Add_Click({
    # Save the new name to the variable and overwrite the text file
    $namateknisi = $textBox.Text
    Set-Content -Path "namateknisi.txt" -Value $namateknisi -ErrorAction Stop  # Change this to your file path

    # Switch back to Page 1
    $page2.Visible = $false
    $page1.Visible = $true

    # Update the label with the new name
    $labelWelcome.Text = "WELCOME, $namateknisi"
    $labelWelcome.Location = New-Object System.Drawing.Point(
    [int](($form.ClientSize.Width - $labelWelcome.Width) / 2),  35  )
    $page1.Controls.Add($labelWelcome)
    $form.Text = "Tools Support - $($namateknisi)"

})
$changeName.Controls.Add($saveName)
$saveName.Location = New-Object System.Drawing.Point(
    [int](($changeName.Width - $saveName.Width) / 2),90 )
$changeName.Controls.Add($saveName)

$page2.Controls.Add($changeName)

<#
$exportData = @{
    teknisi = $($namateknisi)
    brand = $merkLaptop
    modelprocessed = $typeLaptop
    modeldetected = $modeldetected
    serialnumber = $serialnumber
    processor = $processorName
    ram = $ramGB
    Storage = $SSD
    akunoffice = $snReport
}
#>

# Add panels to the form
$form.Controls.Add($page1)
$form.Controls.Add($page2)
function export-datajson {
                $exportData = @{
                teknisi = "$namateknisi"
                brand = $merkLaptop
                modelprocessed = $typeLaptop
                modeldetected = $modeldetected
                serialnumber = $serialnumber
                processor = $processorName
                ram = $ramGB
                storage = $SSD
                akunoffice = $snReport
                }
                $exportData | ConvertTo-Json | Out-File -FilePath "$($env:TEMP)\DataAktivasi.json"
}



$form.Add_FormClosed({
    
                $snMSIreport = "MSI_$($snMSI.Text)@outlook.com"
                $snALLreport = $TextBoxAkunOffice.Text
                if ($merkLaptop -like "MSI") {
                     $snReport = $snMSIreport
                } else {
                     $snReport = $snALLreport
                }

    if ($merkLaptop -in @("ASUS", "LENOVO", "ACER", "HP", "HUAWEI", "MSI","DELL")) {
        if ($merkLaptop -ieq "MSI"){
              if ($typeLaptop -like "*Thin*" -and $processorName -like "*intel*") {
                Start-Process -FilePath "systempropertiesprotection"
                REPORT-NONOHS
              } else{
                export-datajson
                start-process -filepath "runupload.bat"
                start ms-settings:emailandaccounts
                Start-Process -FilePath "systempropertiesprotection"
                }
         
        }else{
              if ( $merkLaptop -ieq "HP" -and $typeLaptop -like "*G10*"){
                        Start-Process -FilePath "systempropertiesprotection"
                        REPORT-NONOHS
              } else {
                export-datajson
                start-process -filepath "runupload.bat"
                start ms-settings:emailandaccounts
                Start-Process -FilePath "systempropertiesprotection"
              }
        }
    
    } else {
            Start-Process -FilePath "systempropertiesprotection"
            REPORT-NONOHS
    }  
})


#$ramGB = (Get-CimInstance -ClassName Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1GB
# Show the form
$form.Add_Shown({
    $form.Activate()
  #  Start-Process -FilePath "enc.bat" -WindowStyle Hidden
  #  Start-Process -FilePath "cmd.exe" -ArgumentList "/c enc.bat" -WindowStyle Hidden
})
[void]$form.ShowDialog()
