Function Open-FileDialog {
  <#
    .Synopsis
       Forms dialog to open file.
    .DESCRIPTION
       Forms dialog to open file.
    .EXAMPLE
       $pathtofile = Open-FileDialog -title "Please select `"Some random file.xlsx`"" -filter "Excel workbook (*.xlsx)|*.xlsx"
    .PARAMETER title
      Title of dialog window.
    .PARAMETER filter
      Extension filter in dialog window.
    .FUNCTIONALITY
       Forms dialog to open file.
  #>
  param(
    [parameter(Mandatory = $true)][string]$title,
    [string]$filter="All files (*.*)|*.*"
  )

 [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null     

 $objForm = New-Object System.Windows.Forms.OpenFileDialog
 $objForm.Title = "$title"
 if ($filter) {
   $objForm.Filter = $filter
   $objForm.FilterIndex = 2
 }
 $Show = $objForm.ShowDialog()
 if ($Show -eq "OK") {
   return $objForm.FileName
 } else {
   return $null
 }
}

Function Open-InputBox {
  <#
    .Synopsis
       Forms dialog to input some string.
    .DESCRIPTION
       Forms dialog to input some string.
    .EXAMPLE
       $somestring = Open-InputBox -title "String input" -message "Please input some string"
    .EXAMPLE
       $somestring = Open-InputBox -title "Username input" -message "Please input your username" -string $env:username
    .PARAMETER title
      Title of dialog window.
    .PARAMETER message
      Some message to be shown in window.
    .PARAMETER width
      Forms window width.
    .PARAMETER height
      Forms window height.
    .PARAMETER string
      Some string to be shown in inputbox.
    .FUNCTIONALITY
       Forms dialog to input some string.
  #>
  param(
    [parameter(Mandatory = $true)][string]$title,
    [string]$message,
    [int]$width=300,
    [int]$height=170,
    [string]$string
  )
  
  [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
  [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") | Out-Null


  #buttons actions
  $OKButtonAction = {
    $script:x = $objTestBox.Text
    $objForm.Close()
  }
  $CancelButtonAction = {
    $script:x = $null
    $objForm.Close()
  }

  $objForm = New-Object System.Windows.Forms.Form
  $objForm.Text = $title
  $objForm.Size = New-Object System.Drawing.Size($width,$height)
  $objForm.MaximumSize = New-Object System.Drawing.Size($width,$height)
  $objForm.MinimumSize = New-Object System.Drawing.Size($width,$height)
  $objForm.MinimizeBox = $false
  $objForm.MaximizeBox = $false
  $objForm.ControlBox = $false
  $objForm.StartPosition = "CenterScreen"

  $objForm.KeyPreview = $True
  $objForm.Add_KeyDown({if ($_.KeyCode -eq "Enter") 
      {Invoke-Command -NoNewScope $OKButtonAction}})
  $objForm.Add_KeyDown({if ($_.KeyCode -eq "Escape") 
      {Invoke-Command -NoNewScope $CancelButtonAction}})

  $objLabel = New-Object System.Windows.Forms.Label
  $objLabel.Location = New-Object System.Drawing.Size(5,10) 
  $objLabel.Size = New-Object System.Drawing.Size(($width - 16),40) 
  $objLabel.Text = $message
  $objForm.Controls.Add($objLabel)

  $objTestBox = New-Object System.Windows.Forms.TextBox
  $objTestBox.Location = New-Object System.Drawing.Size(5,60)
  $objTestBox.Size = New-Object System.Drawing.Size(($width - 30),20)
  if ($string) {
    $objTestBox.Text = $string
  }
  $objForm.Controls.Add($objTestBox)

  $OKButton = New-Object System.Windows.Forms.Button
  $OKButton.Location = New-Object System.Drawing.Size((($width - 155) / 2),($height - 70))
  $OKButton.Size = New-Object System.Drawing.Size(75,23)
  $OKButton.Text = "OK"
  $OKButton.Add_Click($OKButtonAction)
  $objForm.Controls.Add($OKButton)
  
  $CancelButton = New-Object System.Windows.Forms.Button
  $CancelButton.Location = New-Object System.Drawing.Size((($width - 155) / 2 + 80),($height - 70))
  $CancelButton.Size = New-Object System.Drawing.Size(75,23)
  $CancelButton.Text = "Отмена"
  $CancelButton.Add_Click($CancelButtonAction)
  $objForm.Controls.Add($CancelButton)

  $objForm.ShowDialog()| Out-Null

  return $x
}

Function Show-MessageBox { 
  <#
    .Synopsis
       MessageBox dialog.
    .DESCRIPTION
       MessageBox dialog.
    .EXAMPLE
       $result = Show-MessageBox -Title "Infromation" -Msg "This is just an information window" -Informational
    .PARAMETER title
      Title of Message window.
    .PARAMETER Msg
      Some message to be shown in window.
    .PARAMETER OkCancel
      Set Message Box Style.
    .PARAMETER AbortRetryIgnore
      Set Message Box Style.
    .PARAMETER YesNoCancel
      Set Message Box Style.
    .PARAMETER YesNo
      Set Message Box Style.
    .PARAMETER RetryCancel
      Set Message Box Style.
    .PARAMETER Critical
      Set Message box Icon.
    .PARAMETER Question
      Set Message box Icon.
    .PARAMETER Warning
      Set Message box Icon.
    .PARAMETER Informational
      Set Message box Icon.
    .FUNCTIONALITY
       MessageBox dialog.
  #>
  Param( 
    [Parameter(Mandatory=$True)][Alias('M')][String]$Msg, 
    [Parameter(Mandatory=$False)][Alias('T')][String]$Title = "", 
    [Parameter(Mandatory=$False)][Alias('OC')][Switch]$OkCancel, 
    [Parameter(Mandatory=$False)][Alias('OCI')][Switch]$AbortRetryIgnore, 
    [Parameter(Mandatory=$False)][Alias('YNC')][Switch]$YesNoCancel, 
    [Parameter(Mandatory=$False)][Alias('YN')][Switch]$YesNo, 
    [Parameter(Mandatory=$False)][Alias('RC')][Switch]$RetryCancel, 
    [Parameter(Mandatory=$False)][Alias('C')][Switch]$Critical, 
    [Parameter(Mandatory=$False)][Alias('Q')][Switch]$Question, 
    [Parameter(Mandatory=$False)][Alias('W')][Switch]$Warning, 
    [Parameter(Mandatory=$False)][Alias('I')][Switch]$Informational
  ) 

  #Set Message Box Style 
  IF($OkCancel){$Type = 1} 
  Elseif($AbortRetryIgnore){$Type = 2} 
  Elseif($YesNoCancel){$Type = 3} 
  Elseif($YesNo){$Type = 4} 
  Elseif($RetryCancel){$Type = 5} 
  Else{$Type = 0} 
     
  #Set Message box Icon 
  If($Critical){$Icon = 16} 
  ElseIf($Question){$Icon = 32} 
  Elseif($Warning){$Icon = 48} 
  Elseif($Informational){$Icon = 64} 
  Else{$Icon = 0} 
     
  #Loads the WinForm Assembly, Out-Null hides the message while loading. 
  [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null 
 
  #Display the message with input 
  $Answer = [System.Windows.Forms.MessageBox]::Show($MSG , $TITLE, $Type, $Icon) 
     
  #Return Answer 
  Return $Answer 
}

Function Save-FileDialog {
  <#
    .Synopsis
       Forms dialog to save file.
    .DESCRIPTION
       Forms dialog to save  file.
    .EXAMPLE
       $pathtofile = Save-FileDialog -title "Choose where to save file" -filter "Excel workbook (*.xlsx)|*.xlsx"
    .PARAMETER title
      Title of dialog window.
    .PARAMETER filename
      Predefined file name.
    .PARAMETER filter
      Extension filter in dialog window.
    .FUNCTIONALITY
       Forms dialog to save  file.
  #>
  param(
    [string]$title,
    [string]$filename,
    [string]$filter="All files (*.*)|*.*"
  )

 [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null     

  $objForm = New-Object System.Windows.Forms.SaveFileDialog
  $objForm.Title = $title
  $objForm.FileName = $filename
  if ($filter) {
    $objForm.Filter = $filter
    $objForm.FilterIndex = 2
  }
  $Show = $objForm.ShowDialog()
  if ($Show -eq "OK")
  {
    return $objForm.FileName
  } else {
    return $null
  }
}

Export-ModuleMember -Function Open-FileDialog
Export-ModuleMember -Function Open-InputBox
Export-ModuleMember -Function Show-MessageBox
Export-ModuleMember -Function Save-FileDialog