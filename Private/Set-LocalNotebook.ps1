function Set-LocalNotebook ($DatabricksFile, $Language, $LocalOutputPath, $Format="SOURCE"){
    $DatabricksFileForUrl = Format-DataBricksFileName -DataBricksFile $DatabricksFile
    $uri = "https://$Region.azuredatabricks.net/api/2.0/workspace/export?path=" + $DatabricksFileForUrl + "&format=$Format&direct_download=true"
    
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
    $Headers = GetHeaders $null
    
    Try
    {
        # Databricks exports with a comment line in the header, remove this and ensure we have Windows line endings
        $Response = (Invoke-RestMethod -Method Get -Uri $uri -Headers $Headers) -split '\n' | Select-Object -Skip 1
       
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