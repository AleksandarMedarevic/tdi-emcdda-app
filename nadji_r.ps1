Add-Type -AssemblyName System.Windows.Forms

$dialog = New-Object System.Windows.Forms.OpenFileDialog
$dialog.Title = "Odaberite Rscript.exe"
$dialog.Filter = "Rscript.exe|Rscript.exe|Svi fajlovi|*.*"
$dialog.InitialDirectory = "C:\Program Files\R"

$result = $dialog.ShowDialog()

if ($result -eq "OK") {
    $path = $dialog.FileName
    [System.IO.File]::WriteAllText($args[0], $path, [System.Text.Encoding]::Default)
    Write-Host "  Sacuvano: $path"
} else {
    Write-Host "  Otkazano."
}
