Function Format-DataBricksFileName ($DatabricksFile) {
    if ($DatabricksFile.Contains("&")) {
        $DatabricksFile = $DatabricksFile.Replace("&", "%26")
    }
    $DatabricksFile
}