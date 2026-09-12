$srcDir = 'C:\Users\lukax\.gemini\antigravity\brain\fe16c74a-e7ee-4cf4-adb7-00f7e25efeab\.user_uploaded'
$destDir = 'c:\Users\lukax\OneDrive\Documents\Portefolios\assets'

[Windows.Data.Pdf.PdfDocument, Windows.Data.Pdf, ContentType = WindowsRuntime] | Out-Null
[Windows.Storage.StorageFile, Windows.Storage, ContentType = WindowsRuntime] | Out-Null

$files = Get-ChildItem -Path $srcDir -Filter '*.pdf'
$i = 1
foreach ($file in $files) {
    $storageFile = [Windows.Storage.StorageFile]::GetFileFromPathAsync($file.FullName).GetResults()
    $pdfDoc = [Windows.Data.Pdf.PdfDocument]::LoadFromFileAsync($storageFile).GetResults()
    $page = $pdfDoc.GetPage(0)
    $outputPath = Join-Path $destDir ("lvmh_cert_$i.png")
    
    if (-not (Test-Path $outputPath)) {
        New-Item -ItemType File -Path $outputPath -Force | Out-Null
    }
    
    $outputFile = [Windows.Storage.StorageFile]::GetFileFromPathAsync((Get-Item $outputPath).FullName).GetResults()
    $stream = $outputFile.OpenAsync([Windows.Storage.FileAccessMode]::ReadWrite).GetResults()
    $options = New-Object Windows.Data.Pdf.PdfPageRenderOptions
    $options.DestinationWidth = 1920
    $page.RenderToStreamAsync($stream, $options).GetResults() | Out-Null
    $stream.FlushAsync().GetResults() | Out-Null
    $stream.Dispose()
    Write-Host "Successfully rendered $outputPath"
    $i++
}
