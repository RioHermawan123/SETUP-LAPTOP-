Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = "AKUN AKTIVASI OFFICE ??"
$form.Size = New-Object System.Drawing.Size(410, 135)
$form.StartPosition = [System.Windows.Forms.FormStartPosition]::Manual
$form.Location = New-Object System.Drawing.Point(483, 1)
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::None
#$form.MaximizeBox = $false  # Disable the maximize button
#$form.MinimizeBox = $false  # Disable the minimize button
$form.Dock = 'Fill'
$form.BackColor = [System.Drawing.Color]::white
$form.ShowInTaskbar = $false
$form.TopMost = $true


$jsonContent = Get-Content -Path "$($env:TEMP)\DataAktivasi.json" -Raw

$importedVar = $jsonContent | ConvertFrom-Json

$brand = $importedVar.brand
$teknisi = $importedVar.teknisi
$modelprocessed = $importedVar.modelprocessed
$modeldetected = $importedVar.modeldetected
$serialnumber = $importedVar.serialnumber
$processor = $importedVar.processor
$ram = $importedVar.ram
$storage = $importedVar.storage
$akunoffice = $importedVar.akunoffice

$labelOffice = New-Object System.Windows.Forms.Label
$labelOffice.Text = "AKUN AKTIVASI OFFICE SUDAH SESUAI?"
$labelOffice.Font = New-Object System.Drawing.Font('Segoe UI', 15, [System.Drawing.FontStyle]::Bold)
$labelOffice.ForeColor =  [System.Drawing.Color]::Red
$labelOffice.AutoSize = $true
$form.Controls.Add($labelOffice)
$labelOffice.Location = New-Object System.Drawing.Point(
    [int](($form.Width - $labelOffice.Width) / 2 + 5),  5 )
$form.Controls.Add($labelOffice)

$officebox = New-Object System.Windows.Forms.TextBox
$officebox.Text = "$akunoffice"
$officebox.Size = New-Object System.Drawing.Size($form.Width)
$officebox.Font = New-Object System.Drawing.Font('Segoe UI', 14,  [System.Drawing.FontStyle]::Bold)
$officebox.Location = "0,40"
$officebox.TextAlign = [System.Windows.Forms.HorizontalAlignment]::Center
$form.Controls.Add($officebox)

$passwordbox = New-Object System.Windows.Forms.TextBox
$passwordbox.Text = "office2021"
$passwordbox.Size = New-Object System.Drawing.Size($form.Width)
$passwordbox.Font = New-Object System.Drawing.Font('Segoe UI', 12,  [System.Drawing.FontStyle]::Bold)
$passwordbox.Location = "0,75"
$passwordbox.TextAlign = [System.Windows.Forms.HorizontalAlignment]::Center
$form.Controls.Add($passwordbox)

$nextButton = New-Object System.Windows.Forms.Button
$nextButton.Text = "OKE"
$nextButton.Font = New-Object System.Drawing.Font('Segoe UI', 15, [System.Drawing.FontStyle]::Bold)
$nextButton.Location = New-Object System.Drawing.Point(3, 3)
$nextButton.Cursor = [System.Windows.Forms.Cursors]::Hand
$nextButton.Size = New-Object System.Drawing.Size($form.Width,35)
$nextButton.BackColor = [System.Drawing.Color]::WhiteSmoke
$nextButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$nextButton.FlatAppearance.BorderSize = 0
$nextButton.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::FloralWhite
$nextButton.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::Snow
$form.Controls.Add($nextButton)
$nextButton.Location = New-Object System.Drawing.Point(
    [int](($form.Width - $nextButton.Width) / 2),  100  )
$nextButton.Add_Click({
    # https://docs.google.com/forms/d/e/1FAIpQLSf8rBNxLD_s3EJrtajH_v_WE7DUxO5uA9_kkxMW4WnzW0036g/viewform?usp=pp_url&entry.1123239085=Teknisi&entry.1647863460=SerialNumber&entry.862978679=Brand&entry.942663444=ModelProcessed&entry.1915803962=ModelDetected&entry.490213951=Processor&entry.433477474=Ram&entry.551716795=Storage&entry.1305841159=AkunOffice&entry.434891167=Password
    
    $formUrl = "https://docs.google.com/forms/d/e/1FAIpQLSetEJsh0YeC8YRn-W6EMNmQfcYhLxCNkGpn5zf0SNr2XW0jqg/formResponse"
     $formData = @{
            "entry.80679584" = "$teknisi"   #teknisi
            "entry.1221910596" = "$serialnumber" #sn
            "entry.1477663918" = "$brand" #brand
            "entry.1219257192" = "$modelprocessed" #modelprocessd
            "entry.2013583334" = "$modeldetected" #modeldtcted
            "entry.985676516" = "$processor" #processor
            "entry.1024081183" = "$($ram)GB"   #ram
            "entry.642883361" = "$storage" #storage
            "entry.315707343" = "$($officebox.Text)" #akunoffice
            "entry.1851907708" = "$($passwordbox.Text)" #password
        }


        # =================== ENTRY FOR TRIAL CHECK FORM =========================
#     $formUrl = "https://docs.google.com/forms/u/0/d/e/1FAIpQLSfC_RJbfvVc6vb3-c4MrzOVEZTevy2-HFFvpVLMzs5-6E_W-w/formResponse"
#     $formData = @{
#     "entry.1615389212" = "$teknisi"
#     "entry.1331036153" = "$serialnumber"
#     "entry.1138861216" = "$brand"
#     "entry.193620070" = "$modelprocessed"
#     "entry.1733327904" = "$modeldetected"
#     "entry.1745697285" = "$processor"
#     "entry.413879700" = "$($ram)GB"
#     "entry.2105807562" = "$storage"
#     "entry.1353344334" = "$($officebox.Text)"
#     "entry.567943420" = "$($passwordbox.Text)"
# }

# ==========================================================================

     $response = Invoke-WebRequest -Uri $formUrl -Method POST -Body $formData
      if ($response.StatusCode -eq 200) {
        $form.close()
      } else {
        [System.Windows.Forms.MessageBox]::Show("Gagal Menyimpan Data. Pastikan Terkoneksi Internet", "No Internet")
        return
        }


})
$form.Controls.Add($nextButton)

$form.Add_Shown({
    # Set focus to the button instead of the form
    $nextButton.Focus()
})
$form.ShowDialog()
