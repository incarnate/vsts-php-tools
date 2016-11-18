[CmdletBinding()]
param()

# VSTS Task to install PHP and Composer
# 
Trace-VstsEnteringInvocation $MyInvocation

try {

    Write-Verbose 'Starting PHP Install'

    [string]$work = Get-VstsTaskVariable -Name 'Agent.WorkFolder'

    [string]$phpDir = $work+'\php'
    [string]$phpVersion = Get-VstsTaskVariable -Name 'phpVersion' -Default 'php-7.0.13-Win32-VC14-x64'
    [string]$phpSource = 'http://windows.php.net/downloads/releases/'+$phpVersion+'.zip'
    [string]$phpZip = $work + '\php.zip'

    [string]$composerSource = 'https://getcomposer.org/composer.phar'
    [string]$composerDest = $work + '\composer.phar'

    Write-Verbose 'Download PHP'
    $client = New-Object System.Net.WebClient
    $client.DownloadFile($phpSource, $phpZip)

    New-Item -ItemType Directory -Force -Path $phpDir

    Write-Verbose 'Unzip PHP'
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($phpZip, $phpDir)
    Remove-Item -Force $phpZip

    Write-Verbose 'Set ENV'
    $env:Path += ";"+$phpDir
    [Environment]::SetEnvironmentVariable
     ( "Path", $env:Path, [System.EnvironmentVariableTarget]::Machine )

    Write-Verbose 'Test PHP'
    php -v

    Write-Verbose 'Download Composer'
    Invoke-WebRequest $composerSource -OutFile $composerDest

    Write-Verbose 'Test Composer'
    php $composerDest -V

    Set-VstsTaskVariable -Name PHP_PATH -Value $phpDir
    Set-VstsTaskVariable -Name COMPOSER_PHAR -Value $composerDest

} finally {
    Trace-VstsLeavingInvocation $MyInvocation
}