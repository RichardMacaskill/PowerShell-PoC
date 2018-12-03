$host.ui.RawUI.WindowTitle = 'Baking a bleeding cake.'
Add-WindowsPSModulePath
$block = @"
        ___,-----.___
    ,--'             `--.
   /                     \
  /                       \
 |                         |
|                           |
|        |~~~~~~~~~|        |
|        \         /        |
 |        \       /        |
  \        \     /        /
   \        |   |        /
    \       |   |       /
     \      |   |      /
      \     |   |     /
       \____|___| ___/
       )___,-----'___(
       )___,-----'___(
       )___,-----'___(
       )___,-----'___(
       \_____________/
            \___/

"@
 
Write-Host $block -ForegroundColor Green
function Prompt
{
    $promptString = "PS " + $(Get-Location) + ">"
    Write-Host $promptString -NoNewline -ForegroundColor Cyan
    return " "
}