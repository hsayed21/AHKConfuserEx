/*
 * @description AHKConfuserEx For Visual Studio
 * @version 1.0
 * @date 2023-02-19
 * @author x00h
*/

#SingleInstance Force
#NoEnv
SetWorkingDir %A_ScriptDir%
SetBatchLines -1

Gui Add, Button, gApply x80 y167 w114 h42, Apply
Gui Add, Edit, vConfuserPath x21 y42 w240 h21, 
Gui Add, Edit, vcsprojPath x22 y119 w240 h21, 
Gui Font, s10 Bold
Gui Add, Text, x21 y12 w145 h23 +0x200, ConfuserExCLI Path:
Gui Font
Gui Font, s10 Bold
Gui Add, Text, x20 y88 w120 h23 +0x200, csproj Path:
Gui Font
Gui Add, Button, gBroweConfuser x275 y40 w80 h23, Browse
Gui Add, Button, gBrowseCsproj x278 y118 w80 h23, Browse
Gui Font, s12 Bold, Segoe UI
Gui Add, Link, x270 y181 w100 h23, <a href="https://github.com/hsayed21">@hsayed21</a>
Gui Font
Gui Font, s12 Bold, Segoe UI
Gui Add, Text, x242 y179 w28 h23 +0x200, By:
Gui Font

Gui Show, w381 h223, AHKConfuserEx For Visual Studio
Return

BroweConfuser:
FileSelectFile, SelectedFile, 3, , Open ConfuserCLI, Confuser exe (*.exe)
if (SelectedFile != "")
{
    GuiControl,,ConfuserPath, %SelectedFile%
}
Return

BrowseCsproj:
FileSelectFile, SelectedFile, 3, , Open csproj, csproj (*.csproj)
if (SelectedFile != "")
{
    GuiControl,,csprojPath, %SelectedFile%
}
Return


Apply:
Gui, Submit, NoHide

if (ConfuserPath = "" || csprojPath = "")
{
    MsgBox, Please fill all the fields
    return
}

rootPath := SubStr(csprojPath, 1, InStr(csprojPath, "\", 0, -1) - 1)
outputDirPath := rootPath . "\bin\Release\Confused"
baseDirPath := rootPath . "\bin\Release"
exeName := SubStr(csprojPath, InStr(csprojPath, "\", 0, -1) + 1)
exeFileName := SubStr(exeName, 1, InStr(exeName, ".") - 1) . ".exe"

csrproj = 
(
<project outputDir="%outputDirPath%" baseDir="%baseDirPath%" xmlns="http://confuser.codeplex.com">
  <rule pattern="true" preset="maximum" inherit="false" />
  <module path="%exeFileName%" />
</project>
)
maximumFilePath := A_MyDocuments . "\maximum.crproj"
file := FileOpen(maximumFilePath, "w") 
file.write(csrproj)
file.close()

FileRead, csprojContent, % csprojPath

postBuild = 
(
  <!--StartPostCommand-->
  <PropertyGroup>
    <PostBuildEvent>if $(ConfigurationName) == Release ( "%ConfuserPath%" -n "%maximumFilePath%" )</PostBuildEvent>
  </PropertyGroup>
  <!--EndPostCommand-->`n
)

; check if post build command already exists
if (InStr(csprojContent, "<!--StartPostCommand-->") > 0)
{
    ; remove old post build command get start and end index
    start := InStr(csprojContent, "<!--StartPostCommand-->")
    end := InStr(csprojContent, "<!--EndPostCommand-->") + StrLen("<!--EndPostCommand-->")
    ; remove old post build command
    csprojContent := SubStr(csprojContent, 1, start - 1) . SubStr(csprojContent, end + 1)
}

csprojNewContent := StrReplace(csprojContent, "</Project>", postBuild . "</Project>")

file := FileOpen(csprojPath, "r")
cprojContent := file.read()
file.close()
; after add command to csproj file
file := FileOpen(csprojPath, "w")
file.write(csprojNewContent)
file.close()

MsgBox, Operation completed successfully
return


GuiEscape:
GuiClose:
    ExitApp







