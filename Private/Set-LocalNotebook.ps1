function Set-LocalNotebook ($DatabricksFile, $Language, $LocalOutputPath, $Format="SOURCE"){	
    $DatabricksFileForUrl = Format-DataBricksFileName -DataBricksFile $DatabricksFile	
    $uri = "$global:DatabricksURI/api/2.0/workspace/export?path=" + $DatabricksFileForUrl + "&format=$Format&direct_download=true"	

    switch ($Format){	
        "SOURCE" {	
            $FileExtentions = @{"PYTHON"=".py"; "SCALA"=".scala"; "SQL"=".sql"; "R"=".r"}	
            $FileExt = $FileExtentions[$Language]	
        }	
        "HTML"{	
            $FileExt = ".html"	
        }	
        "JUPYTER"{	
            $FileExt = ".ipynb"	
        }	
        "DBC"{	
            $FileExt = ".dbc"	
        }	
    }	

    $LocalExportPath = $DatabricksFile.Replace($ExportPath + "/","") + $FileExt	
    $tempLocalExportPath = $DatabricksFile.Replace($ExportPath + "/", "") + ".temp" + $FileExt	
    $LocalExportPath = Join-Path $LocalOutputPath $LocalExportPath	
    $tempLocalExportPath = Join-Path $LocalOutputPath $tempLocalExportPath	
    New-Item -Force -path $tempLocalExportPath -Type File | Out-Null	
    $Headers = GetHeaders $null	

    Try	
    {	
        # Databricks exports with a comment line in the header, remove this and ensure we have Windows line endings	
        Invoke-RestMethod -Method Get -Uri $uri -Headers $Headers -OutFile $tempLocalExportPath	
        $Response = Get-Content $tempLocalExportPath -Encoding UTF8	
        $Response = $response.Replace("# Databricks notebook source", " ")	
        Remove-Item $tempLocalExportPath	
        if ($Format -eq "SOURCE"){	
            $Response = ($Response.replace("[^`r]`n", "`r`n") -Join "`r`n")	
        }	

        Write-Verbose "Creating file $LocalExportPath"	
        New-Item -force -path $LocalExportPath -value $Response -type file | out-null	
    }	
    Catch	
    {	
        Write-Error $_.ErrorDetails.Message	
        Throw	
    }	
}