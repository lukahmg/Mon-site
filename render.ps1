$csharp = @"
using System;
using System.IO;
using System.Threading.Tasks;
using Windows.Data.Pdf;
using Windows.Storage;

public class PdfRenderer {
    public static async Task RenderPdf(string pdfPath, string outputPath) {
        StorageFile file = await StorageFile.GetFileFromPathAsync(pdfPath);
        PdfDocument pdfDoc = await PdfDocument.LoadFromFileAsync(file);
        PdfPage page = pdfDoc.GetPage(0);
        
        string fullOutPath = Path.GetFullPath(outputPath);
        string dir = Path.GetDirectoryName(fullOutPath);
        if (!Directory.Exists(dir)) Directory.CreateDirectory(dir);
        
        StorageFolder outFolder = await StorageFolder.GetFolderFromPathAsync(dir);
        StorageFile outFile = await outFolder.CreateFileAsync(Path.GetFileName(fullOutPath), CreationCollisionOption.ReplaceExisting);
        
        using (var stream = await outFile.OpenAsync(FileAccessMode.ReadWrite)) {
            PdfPageRenderOptions options = new PdfPageRenderOptions();
            options.DestinationWidth = 1920;
            await page.RenderToStreamAsync(stream, options);
            await stream.FlushAsync();
        }
    }
}
"@

Add-Type -TypeDefinition $csharp -Language CSharp -ReferencedAssemblies "C:\Windows\System32\WinMetadata\Windows.Data.Pdf.winmd", "C:\Windows\System32\WinMetadata\Windows.Storage.winmd"

$srcDir = 'C:\Users\lukax\.gemini\antigravity\brain\fe16c74a-e7ee-4cf4-adb7-00f7e25efeab\.user_uploaded'
$destDir = 'c:\Users\lukax\OneDrive\Documents\Portefolios\assets'

$files = Get-ChildItem -Path $srcDir -Filter '*.pdf'
$i = 1
foreach ($f in $files) {
    $out = Join-Path $destDir "lvmh_cert_$i.png"
    [PdfRenderer]::RenderPdf($f.FullName, $out).GetAwaiter().GetResult()
    Write-Host "Rendered: $out"
    $i++
}
