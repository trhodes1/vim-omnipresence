#Persistent
#SingleInstance, ignore     ;strange: if you change this to force, RunWait gvim doesn't return ever...
    GetParams()
    if (g_uninstall)
         Uninstall()
    else Install()

    g_traytip = Vim hotkey launcher (press %g_HotKey%).`nInstalled by vim plugin vim-omnipresence.
    if (!g_disabled)
        Hotkey, %g_HotKey%, Launch_vim
    else
        g_traytip = Vim hotkey launcher is DISABLED.`n`nTo enable it execute ':call omnipresence#toggle()' from within vim.

    Menu, Tray, Icon, vim.ico,,1
    Menu, Tray, Tip, % g_traytip

    SetTimer, CheckConfig, 2000
return

CheckConfig:
    FileGetTime, _, %g_config%, M
    if (_== g_cfgTime)
        return
    Reload
return

Launch_vim:
    g_activeHwnd := WinExist("A")
    fname := GetNewFileName()
    saved_clipboard := clipboard
    Send, ^a^c
    ClipWait, 1
    content := clipboard

    FileAppend, %content%, %fname%, UTF-8
    FileGetTime, ftime_pre, %fname%, M
    RunWait %g_path% %g_vimoptions% -- "%fname%"
    FileGetTime, ftime_post, %fname%, M
    if ( ftime_pre == ftime_post )
       return

    FileRead, content, %fname%
    FileDelete, %fname%                           ; delete for now, maybe save later
    content := RegExReplace(content, "`r`n$", "") ; remove ending new line because FileRead adds one
    clipboard := content

    WinActivate, ahk_id %g_activeHwnd%
    WinWaitActive, ahk_id %g_activeHwnd%
    Send, ^v

    clipboard := saved_clipboard
return

GetParams() {
    local cfgSection, i, k

    ; Default values
    g_config     := A_ScriptDir . "\..\..\config.ini"
    g_vimoptions  = "+set ff=dos fenc=utf-8 spell" "+$" "+startinsert!"
    g_vimoptions  = "+set ff=dos fenc=utf-8" "+$"
    g_hotkey     := "F12"
    g_path       := A_ProgramFiles "\vim\vim74\gvim.exe"

    ; Parse config
    IniRead, cfgSection, %g_config%, Config
    Loop, parse, cfgSection, `n, `r
        i := InStr(A_LoopField,"="), k := SubStr(A_LoopField, 1, i-1), g_%k% := SubStr(A_LoopField, i+1)

    FileGetTime, g_cfgTime, %g_config%, M
}

GetNewFileName() {
    EnvGet, TEMP, TEMP  ; grab TEMP folder location and put in TEMP variable
    FormatTime, time, , yyyyMMdd-HHmmss  ; grab current time

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
            fileName = "unsupported_program_" . fileName
    }

    return TEMP . "\vim_temp_" . time . "_" . fileName

    ; alternative to switch case
        ; if (WinActive("ahk_exe matlab.exe")){
        ;     WinGetActiveTitle, fileName
        ; }

}

Install() {
    lnk = %A_Startup%\%A_ScriptName%.lnk
    if !FileExist(lnk)
        FileCreateShortcut, %A_ScriptDir%\AutoHotkey.exe, %lnk% , %A_ScriptDir%, %A_ScriptFullPath%
}

Uninstall() {

    lnk = %A_Startup%\%A_ScriptName%.lnk
    if FileExist(lnk)
    {
        Msgbox Vim-omnipresence is going to be uninstalled.
        FileDelete, %lnk%
    }
    else Msgbox Vim-omnipresence is uninstalled.`n`nTo enable it delete 'Config.ini' file and enable vim plugin in your .vimrc .
    Exit
}
