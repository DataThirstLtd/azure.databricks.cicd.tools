Function Get-Notebooks ($FolderContents, $OriginalPath, $LocalOutputPath ) {

    $FolderContent = $FolderContents.objects

    ForEach ($Object In $FolderContent)
    {
        if($Object.object_type -eq "DIRECTORY")
        {
            $FolderName = ($Object.path).Replace($OriginalPath,"")
            Write-Verbose "Folder Name: $FolderName!"
            $SubfolderContents = Get-FolderContents $Object.path
            Get-Notebooks $SubfolderContents ($Object.path + "/") $LocalOutputPath
        }
        elseif ($Object.object_type -eq "NOTEBOOK")
        {
            $Notebook = $Object.path
            $NotebookLanguage = $Object.language
            Write-Verbose "Calling Writing of $Notebook ($NotebookLanguage)"
            Set-LocalNotebook $Notebook $NotebookLanguage $LocalOutputPath
        }
        else {
            Write-Warning "Unknown Type $Object.object_type"
        }
    }
}