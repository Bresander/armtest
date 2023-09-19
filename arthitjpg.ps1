# Define the path to the new wallpaper image
$WallpaperPath = "C:\Arthit-Saengsuriyachat-300x214.jpg"  # Replace with the path to your desired wallpaper image

# Set the Wallpaper
$SPI_SETDESKWALLPAPER = 0x0014
$SPIF_UPDATEINIFILE = 0x01
$SPIF_SENDCHANGE = 0x02

# Call the SystemParametersInfo function to set the wallpaper
Add-Type -TypeDefinition @"
    using System;
    using System.Runtime.InteropServices;
    public class Wallpaper {
        [DllImport("user32.dll", CharSet = CharSet.Auto)]
        public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
    }
"@
[Wallpaper]::SystemParametersInfo($SPI_SETDESKWALLPAPER, 0, $WallpaperPath, $SPIF_UPDATEINIFILE -bor $SPIF_SENDCHANGE)

# Check if the wallpaper was changed successfully
$currentWallpaper = (New-Object -ComObject "WScript.Shell").Wallpaper
if ($currentWallpaper -eq $WallpaperPath) {
    Write-Host "Wallpaper changed successfully to $WallpaperPath."
} else {
    Write-Host "Failed to change wallpaper."
}
