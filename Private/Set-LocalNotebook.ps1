function Set-LocalNotebook ($DatabricksFile, $Language, $Region, $InternalBearerToken, $LocalOutputPath, $Format="SOURCE"){
    $uri = "https://$Region.azuredatabricks.net/api/2.0/workspace/export?path=" + $DatabricksFile + "&format=$Format&direct_download=true"
    
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
    $LocalExportPath = Join-Path $LocalOutputPath $LocalExportPath
    
    Try
    {
        # Databricks exports with a comment line in the header, remove this and ensure we have Windows line endings
        $Response = (Invoke-RestMethod -Method Get -Uri $uri -Headers @{Authorization = $InternalBearerToken}) -split '\n' | Select-Object -Skip 1
        
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