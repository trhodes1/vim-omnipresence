^+!n::

asdf := GetNewFileName()
MsgBox, %asdf%

GetNewFileName() {
    EnvGet, TEMP, TEMP  ; grab TEMP folder location and put in TEMP variable
    FormatTime, time, , yyyy-MM-dd-HH-mm-ss  ; grab current time

    WinGet, ProcessNameVariable, ProcessName, A

    switch ProcessNameVariable
    {
    ; MATLAB
        case "matlab.exe":
            WinGetActiveTitle, fullPath    ; grab full path (Matlab's window title)
            SplitPath, fullPath, fileName  ; extract file name string to "fileName"

            ; ensure .m extension is in the file name
                if !InStr(fileName,".m")     ; check if current string doesn't have .m
                {
                    fileName = %fileName%.m   ; append .m file extension
                }

    ; VSCode
        case "code.exe":
            WinGetActiveTitle, fileName
            RegExMatch(fileName, "^\S*\s", fileName)

    ; Chrome
        case "chrome.exe":
            WinGetActiveTitle, fileName

    ; default case
        default:
            WinGetActiveTitle, fileName
            fileName = unsupported_program_%fileName%
    }

    return TEMP . "\vim_temp_" . time . "_" . fileName

    ; alternative to switch case
        ; if (WinActive("ahk_exe matlab.exe")){
        ;     WinGetActiveTitle, fileName
        ; }

}

Return