<#!
.SYNOPSIS
    Converts WoW UI PNG files to uncompressed 32-bit top-down TGA files.

.DESCRIPTION
    The reconstructed 3.3.5 texture loader accepts BLP and TGA, while the
    extracted wow-ui-textures repository contains PNG files. This helper keeps
    conversion on demand so the complete 10+ GB PNG tree is not duplicated.

    RelativePath may be repeated and is resolved below SourceRoot. When no
    RelativePath is supplied, Pattern is used for a recursive search.

.EXAMPLE
    .\Tools\Convert-WowUiTexturesToTga.ps1 `
      -SourceRoot 'E:\wowdecomp\wow素材\wow-ui-textures' `
      -OutputRoot '.\Interface\NativeUI\BundledAddOns\MaterialPreview\Textures' `
      -RelativePath 'ACHIEVEMENTFRAME\UI-Achievement-Header.PNG'
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string] $SourceRoot,

    [Parameter(Mandatory = $true)]
    [string] $OutputRoot,

    [string[]] $RelativePath,

    [string] $Pattern = '*.png',

    [int] $MaxCount = 0,

    [int] $MaxDimension = 0,

    [switch] $Force
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$sourceRootPath = (Resolve-Path -LiteralPath $SourceRoot).Path.TrimEnd('\')
$outputRootPath = [System.IO.Path]::GetFullPath($OutputRoot)
[System.IO.Directory]::CreateDirectory($outputRootPath) | Out-Null

function Get-PngCandidates {
    if ($RelativePath -and $RelativePath.Count -gt 0) {
        foreach ($relative in $RelativePath) {
            $candidate = Join-Path $sourceRootPath $relative
            if (!(Test-Path -LiteralPath $candidate -PathType Leaf)) {
                throw "PNG source does not exist: $candidate"
            }
            Get-Item -LiteralPath $candidate
        }
        return
    }

    Get-ChildItem -LiteralPath $sourceRootPath -Filter $Pattern -File -Recurse
}

function Write-Tga32 {
    param(
        [Parameter(Mandatory = $true)] [System.Drawing.Bitmap] $Bitmap,
        [Parameter(Mandatory = $true)] [string] $Destination
    )

    $width = $Bitmap.Width
    $height = $Bitmap.Height
    if ($width -gt [UInt16]::MaxValue -or $height -gt [UInt16]::MaxValue) {
        throw "TGA dimensions exceed 16-bit limits: ${width}x${height}"
    }

    # Drawing into a known 32-bit surface normalizes indexed PNGs and keeps the
    # byte order expected by TGA32Pixel (B, G, R, A).
    $surface = New-Object System.Drawing.Bitmap($width, $height, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $graphics = [System.Drawing.Graphics]::FromImage($surface)
    try {
        $graphics.DrawImageUnscaled($Bitmap, 0, 0)
    } finally {
        $graphics.Dispose()
    }

    $rect = New-Object System.Drawing.Rectangle(0, 0, $width, $height)
    $bits = $surface.LockBits($rect, [System.Drawing.Imaging.ImageLockMode]::ReadOnly, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    try {
        $rowBytes = $width * 4
        $pixels = New-Object byte[] ($rowBytes * $height)
        for ($row = 0; $row -lt $height; $row++) {
            $sourceOffset = $row * $bits.Stride
            if ($bits.Stride -lt 0) {
                $sourceOffset = ($height - 1 - $row) * (-$bits.Stride)
            }
            $sourcePtr = [IntPtr]::Add($bits.Scan0, $sourceOffset)
            [Runtime.InteropServices.Marshal]::Copy($sourcePtr, $pixels, $row * $rowBytes, $rowBytes)
        }
    } finally {
        $surface.UnlockBits($bits)
        $surface.Dispose()
    }

    # Descriptor 0x28 means 8 alpha bits and top-to-bottom row order. The
    # client calls CTgaFile::SetTopDown(1), so this avoids a second row flip.
    $stream = [System.IO.File]::Open($Destination, [System.IO.FileMode]::Create, [System.IO.FileAccess]::Write, [System.IO.FileShare]::None)
    $writer = New-Object System.IO.BinaryWriter($stream)
    try {
        $writer.Write([byte]0)       # ID length
        $writer.Write([byte]0)       # color map type
        $writer.Write([byte]2)       # uncompressed true color
        $writer.Write([UInt16]0)     # color map first entry
        $writer.Write([UInt16]0)     # color map length
        $writer.Write([byte]0)       # color map entry bits
        $writer.Write([UInt16]0)     # X origin
        $writer.Write([UInt16]0)     # Y origin
        $writer.Write([UInt16]$width)
        $writer.Write([UInt16]$height)
        $writer.Write([byte]32)
        $writer.Write([byte]0x28)
        $writer.Write($pixels)
    } finally {
        $writer.Dispose()
        $stream.Dispose()
    }
}

$items = @(Get-PngCandidates)
if ($MaxCount -gt 0) {
    $items = @($items | Select-Object -First $MaxCount)
}
if ($items.Count -eq 0) {
    throw "No PNG files matched the requested input."
}

$results = foreach ($item in $items) {
    $relative = $item.FullName.Substring($sourceRootPath.Length).TrimStart('\')
    $safeName = ($relative -replace '[\\/]', '__') -replace '\.[Pp][Nn][Gg]$', '.tga'
    $destination = Join-Path $outputRootPath $safeName

    if ((Test-Path -LiteralPath $destination) -and !$Force) {
        Write-Verbose "Skipping existing $destination"
        $bitmap = [System.Drawing.Bitmap]::new($item.FullName)
        try {
            $width = $bitmap.Width
            $height = $bitmap.Height
        } finally {
            $bitmap.Dispose()
        }
        [pscustomobject]@{ Source = $relative; Output = $safeName; Width = $width; Height = $height; Skipped = $true }
        continue
    }

    $bitmap = [System.Drawing.Bitmap]::new($item.FullName)
    try {
        $width = $bitmap.Width
        $height = $bitmap.Height
        if ($MaxDimension -gt 0 -and ($width -gt $MaxDimension -or $height -gt $MaxDimension)) {
            Write-Verbose "Skipping ${relative}: ${width}x${height} exceeds MaxDimension $MaxDimension"
            [pscustomobject]@{ Source = $relative; Output = $null; Width = $width; Height = $height; Skipped = $true }
            continue
        }
        Write-Tga32 -Bitmap $bitmap -Destination $destination
    } finally {
        $bitmap.Dispose()
    }

    [pscustomobject]@{ Source = $relative; Output = $safeName; Width = $width; Height = $height; Skipped = $false }
}

$results | Format-Table -AutoSize
