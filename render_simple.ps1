[void][Windows.Data.Pdf.PdfDocument, Windows.Data.Pdf, ContentType = WindowsRuntime]
[void][Windows.Storage.StorageFile, Windows.Storage, ContentType = WindowsRuntime]

$srcDir = 'C:\Users\lukax\.gemini\antigravity\brain\fe16c74a-e7ee-4cf4-adb7-00f7e25efeab\.user_uploaded'
$destDir = 'c:\Users\lukax\OneDrive\Documents\Portefolios\assets'

$files = Get-ChildItem -Path $srcDir -Filter '*.pdf'
$i = 1
foreach ($f in $files) {
    $fileTask = [Windows.Storage.StorageFile]::GetFileFromPathAsync($f.FullName)
    while ($fileTask.Status -eq 'Started') { Start-Sleep -Milliseconds 50 }
    $file = $fileTask.GetResults()

    $pdfTask = [Windows.Data.Pdf.PdfDocument]::LoadFromFileAsync($file)
    while ($pdfTask.Status -eq 'Started') { Start-Sleep -Milliseconds 50 }
    $pdfDoc = $pdfTask.GetResults()

    $page = $pdfDoc.GetPage(0)

    $outPath = Join-Path $destDir "lvmh_cert_$i.png"
    if (-not (Test-Path $outPath)) {
        New-Item -ItemType File -Path $outPath -Force | Out-Null
    }

    $outFileTask = [Windows.Storage.StorageFile]::GetFileFromPathAsync((Get-Item $outPath).FullName)
    while ($outFileTask.Status -eq 'Started') { Start-Sleep -Milliseconds 50 }
    $outFile = $outFileTask.GetResults()

    $streamTask = $outFile.OpenAsync([Windows.Storage.FileAccessMode]::ReadWrite)
    while ($streamTask.Status -eq 'Started') { Start-Sleep -Milliseconds 50 }
    $stream = $streamTask.GetResults()

    $options = [Windows.Data.Pdf.PdfPageRenderOptions]::new()
    $options.DestinationWidth = 1920

    $renderTask = $page.RenderToStreamAsync($stream, $options)
    while ($renderTask.Status -eq 'Started') { Start-Sleep -Milliseconds 50 }

    $flushTask = $stream.FlushAsync()
    while ($flushTask.Status -eq 'Started') { Start-Sleep -Milliseconds 50 }

    $stream.Dispose()
    Write-Host "RENDERED SUCCESS: $outPath"
    $i++
}
