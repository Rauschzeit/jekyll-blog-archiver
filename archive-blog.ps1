Import-Module powershell-yaml                     # Has to be installed via "Install-Module powershell-yaml"

class MarkdownFile {
    
    [System.IO.FileSystemInfo]$File
    [System.Object]$FrontMatter
    [string[]]$Markdown

    MarkdownFile($file) {
        $this.File = $file        
        $this.FrontMatter = $this.GetFrontMatter()
        $this.Markdown = $this.GetMarkdown()
    }

    hidden [System.Object]GetFrontMatter() {
        [string[]]$content = Get-Content -Path $this.File.FullName -Encoding UTF8
        [string[]]$yamlLines = @()       
        if("---" -ne $content[0]) {
            return $null
        }

        for ($i=2; $i -le ($content.Length - 1); $i += 1) {
            if("---" -eq $content[$i]) {
                $yamlLines = $content[1 .. ($i -1)]
                break;
            }
        }

        if(0 -lt $yamlLines.Length) {            
            return ConvertFrom-Yaml ($yamlLines -join "`r`n")
        }

        return $null
    }

    hidden [string[]]GetMarkdown() {
        [string[]]$content = Get-Content -Path $this.File.FullName -Encoding UTF8
        if("---" -ne $content[0]) {
            return $content
        }

        for ($i=2; $i -le ($content.Length - 1); $i += 1) {
            if("---" -eq $content[$i] -and $content.Length -gt $i +1) {
                return $content[($i +1) .. ($content.Length -1)]                
            }
        }

        return $content
    }

}

$files = Get-ChildItem -Path C:\Users\TWerner\Projekte\architektur-doc\docs\07-verteilungssicht -Recurse -Filter "*.md"
foreach ($file in $files) {
    $mdFile = [MarkdownFile]::new($file)    
}