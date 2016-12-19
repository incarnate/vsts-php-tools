[CmdletBinding()]
param()

# VSTS Task to run a PHP command
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

try {

    Write-Verbose 'Starting PHP Command'

    [string]$command = Get-VstsInput -Name 'command' -Require
    [string]$workingFolder = Get-VstsInput -Name 'workingFolder' -Require

    cd $workingFolder

    Find-PHP
    
    php $command

} catch {
    # Catching reliability issues and logging them here.
    Write-VstsTaskError $_.Exception.Message
    throw
} finally {
    Trace-VstsLeavingInvocation $MyInvocation
}

