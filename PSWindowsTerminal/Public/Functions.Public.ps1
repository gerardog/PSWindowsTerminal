Function Set-WTBackgroundImage {
    [Alias("wtimg")]
    Param(
        [Parameter(Mandatory)]
        [string]$ImagePath
    )

    $CurrentExec = [System.IO.Path]::GetFileNameWithoutExtension([Environment]::GetCommandLineArgs())
    CheckPath -Path $ImagePath
    $ProfilePath = $Script:CommonConfig.ProfilePath.Replace('LOCALAPPDATA',$env:LOCALAPPDATA)
    $Config = Get-CurrentAppConfig -ProfilePath $global:CommonConfig.ProfilePath.Replace('LOCALAPPDATA',$env:LOCALAPPDATA)
    $CurrentAppConfig = $Config.Profiles | Where-Object -FilterScript {[System.IO.Path]::GetFileNameWithoutExtension($_.CommandLine) -eq $CurrentExec }

    if($CurrentAppConfig.BackgroundImage){
        $CurrentAppConfig.BackgroundImage = $ImagePath
    }
    else{
        $CurrentAppConfig | Add-Member -MemberType NoteProperty -Name backgroundImage -Value $ImagePath -Force
    }

    $Config | ConvertTo-Json -Depth 99 | Out-File -FilePath $ProfilePath -Force -Encoding utf8
}

function Get-ConsoleHostProcessId {
  
    # Save Original ConsoleHost title	
    $oldTitle=$host.ui.RawUI.WindowTitle; 
    # Set unique console title.
    $r=(New-Guid); 
    $host.ui.RawUI.WindowTitle = "$r"; 
    #Find console window by title, then find console PID.
    $result = (tasklist.exe /FO LIST /FI "WINDOWTITLE eq $r") | Select-String -Pattern  "PID:*" -Raw
    
    if ($null -ne $result) {
        $consolePid = [int]($result.SubString(5).Trim());
    } else {
        $consolePid = 0;
    }        
    # Restore original ConsoleHost title.
    $host.ui.RawUI.WindowTitle=$oldTitle;

    return [int]$consolePid;
}
  
function Test-IsWindowsTerminal {
    $consolePid = Get-ConsoleHostProcessId;
    if ($consolePid -gt 0) {
        return (Get-Process -PID (Get-ConsoleHostProcessId)).ProcessName -eq "WindowsTerminal";
    }
    return $false;
}
