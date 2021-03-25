Function Get-Notebooks ($FolderContents, $OriginalPath, $LocalOutputPath, $Format = "SOURCE" ) {

    $threadJobs = @()
    $throttleLimit = GetCpuCount

    $scriptBlock = { param($DatabricksFile, $Format = "SOURCE", $Headers, $uri, $LocalExportPath, $tempLocalExportPath)         
        Try {
            New-Item -Force -path $tempLocalExportPath -Type File | Out-Null
            Invoke-RestMethod -Method Get -Uri $uri -Headers $Headers -OutFile $tempLocalExportPath  
            $Response = @()
            $Response = Get-Content $tempLocalExportPath -Encoding UTF8
            $NewResponse = $Response #| Where-Object { $_ -ne "# Databricks notebook source" }
            Remove-Item $tempLocalExportPath 
            if ($Format -eq "SOURCE" -and $null -ne $NewResponse) { 
                $ResponseString = ($NewResponse -Join [Environment]::NewLine)
            } 
            else {
                $ResponseString = $NewResponse
            }
            $UTF8_NO_BOM = New-Object System.Text.UTF8Encoding $False
            [system.io.file]::WriteAllText($LocalExportPath, $ResponseString, $UTF8_NO_BOM)
        }
        Catch {
            Write-Error $_.ErrorDetails.Message
            Throw
        }
    }

    if ($Format -eq "DBC") {
        Set-LocalNotebook $OriginalPath "dbc" $LocalOutputPath "DBC"
        return
    }

    $Headers = GetHeaders $null

    $FolderContent = $FolderContents.objects

    ForEach ($Object In $FolderContent) {
        if ($Object.object_type -eq "DIRECTORY") {
            $FolderName = ($Object.path).Replace($OriginalPath, "")
            Write-Verbose "Folder Name: $FolderName!"
            $SubfolderContents = Get-FolderContents $Object.path
            Get-Notebooks $SubfolderContents ($Object.path + "/") $LocalOutputPath $Format
        }
        elseif ($Object.object_type -eq "NOTEBOOK") {
            $Notebook = $Object.path
            $NotebookLanguage = $Object.language
            Write-Verbose "Calling Writing of $Notebook ($NotebookLanguage)"
            $DatabricksFileForUrl = Format-DataBricksFileName -DataBricksFile $Notebook 
            $uri = "$global:DatabricksURI/api/2.0/workspace/export?path=" + $DatabricksFileForUrl + "&format=$Format&direct_download=true"
            switch ($Format) {
                "SOURCE" {
                    $FileExtentions = @{"PYTHON" = ".py"; "SCALA" = ".scala"; "SQL" = ".sql"; "R" = ".r" }
                    $FileExt = $FileExtentions[$NotebookLanguage]
                }
                "HTML" {
                    $FileExt = ".html"
                }
                "JUPYTER" {
                    $FileExt = ".ipynb"
                }
                "DBC" {
                    $FileExt = ".dbc"
                }
            }
            $LocalExportPath = $Notebook.Replace($ExportPath + "/", "") + $FileExt
            $tempLocalExportPath = $Notebook.Replace($ExportPath + "/", "") + ".temp" + $FileExt
            $LocalExportPath = Join-Path $LocalOutputPath $LocalExportPath
            $tempLocalExportPath = Join-Path $LocalOutputPath $tempLocalExportPath
            $threadJobs += Start-ThreadJob -Name $Notebook -ScriptBlock $ScriptBlock -ThrottleLimit $throttleLimit -ArgumentList @($Notebook, $Format, $Headers, $uri, $LocalExportPath, $tempLocalExportPath)             #Set-LocalNotebook $Notebook $NotebookLanguage $LocalOutputPath $Format
        }
        else {
            Write-Warning "Unknown Type $Object.object_type"
        }
    }
    if ($threadJobs -ne 0) {
        Wait-Job -Job $threadJobs | Out-Null
        $toThrow = $null
        foreach ($threadJob in $threadJobs) {
            $getState = Get-Job $threadJob.Name | Select-Object -Last 1
            if ($getState.State -eq 'Failed') {
                $toThrow = 1

                Write-Host ($threadJob.JobStateInfo.Reason) -ForegroundColor DarkMagenta
            } 
            else {
                Write-Verbose "$($getState.Name) has $($getState.State)" 
            }
        }
        if ($null -ne $toThrow) {
            Write-Error "Oh dear one of the jobs has failed. Check the details of the jobs above."
            Throw
        }
    }
}