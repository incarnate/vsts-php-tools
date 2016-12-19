[CmdletBinding()]
param()

# VSTS Task to run a Composer command
# 
Trace-VstsEnteringInvocation $MyInvocation

function Find-PHP() {

    Trace-VstsEnteringInvocation $MyInvocation
    try {
        # Check if PHP is in path already
        if (Get-Command "php.exe" -ErrorAction SilentlyContinue) { 
            return
        }
        
        [string]$phpPath = Get-VstsTaskVariable -Name PHP_PATH

        if ($phpPath) {
            dir $phpPath
            $env:Path += ";"+$phpPath
            [Environment]::SetEnvironmentVariable
             ( "Path", $env:Path, [System.EnvironmentVariableTarget]::Machine )
            return
        }
        
        throw("PHP Path not found")
    } catch {
        Write-VstsTaskError $_.Exception.Message
        throw
    } finally {
        Trace-VstsLeavingInvocation $MyInvocation
    }
    
}

function Find-Composer() {

    Trace-VstsEnteringInvocation $MyInvocation
    try {
        # Check if PHP is in path already
        if (Get-Command "composer.phar" -ErrorAction SilentlyContinue) { 
            return "composer.phar"
        }
        
        [string]$composer = Get-VstsTaskVariable -Name COMPOSER_PHAR
        if ($composer) {
            return $composer
        }
        
        throw("Composer not found")
    } catch {
        # Catching reliability issues and logging them here.
        Write-VstsTaskError $_.Exception.Message
        throw
    } finally {
        Trace-VstsLeavingInvocation $MyInvocation
    }
    
}

try {

    Write-Verbose 'Starting Composer command'

    [string]$command = Get-VstsInput -Name 'command' -Default 'install'
    [string]$workingFolder = Get-VstsInput -Name 'workingFolder' -Require

    cd $workingFolder

    Find-PHP
    [string]$composer = Find-Composer
    
    Write-Verbose 'Test PHP'
    php -v

    Write-Verbose 'Run Composer'
    php $composer $command

} catch {
    # Catching reliability issues and logging them here.
    Write-VstsTaskError $_.Exception.Message
    throw
} finally {
    Trace-VstsLeavingInvocation $MyInvocation
}

