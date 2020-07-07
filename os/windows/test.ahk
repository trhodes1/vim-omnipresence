^+!n::

asdf := GetNewFileName()
MsgBox, %asdf%

GetNewFileName() {
    EnvGet, TEMP, TEMP  ; grab TEMP folder location and put in TEMP variable
    FormatTime, time, , yyyMMdd-HHmmss  ; grab current time

    WinGet, ProcessName, ProcessName, A

    switch ProcessName
    {
    ; MATLAB
        case "matlab.exe":
            WinGetActiveTitle, fullPath    ; grab full path (Matlab's window title)
            SplitPath, fullPath, fileName  ; extract file name

    ; VSCode
        case "code.exe":
            WinGetActiveTitle, fileName
            RegExMatch(fileName, "^\S*\s", fileName)

    ; Chrome
        case "chrome.exe":
            WinGetActiveTitle, fileName
            return TEMP . "\mm_vim_aw_chrome" . time

    ; default case
        default:
            return TEMP . "\mm_vim_aw" . time
        }

    return TEMP . "\" . fileName

    ; alternative to switch case
        ; if (WinActive("ahk_exe matlab.exe")){
        ;     WinGetActiveTitle, fileName
        ; }

}

Return