########
;Include
########
	!include "MUI2.nsh"
	!include "LogicLib.nsh"
;--------------------------------


########
;General
########
	XPStyle on
	Unicode true
	ShowInstDetails show ;Log window on MUI_PAGE_INSTFILES show or hide by default

	;Name of the program and output file path (relative to .nsi src code)
	Name "Patcher"
	OutFile "patcher.exe"

	;Default installation folder
	InstallDir "$EXEDIR" ;Take the current patcher .exe file location as working directory

	;Request application privileges for Windows Vista
	RequestExecutionLevel user ;user or admin (if the game is installed in programfiles)
;--------------------------------


###################
;Interface Settings
###################
	; !define MUI_ABORTWARNING
	BrandingText "Plants vs Zombies Patcher" ;Small text on the bottom by default : Nullsoft Install system...
	!define MUI_FINISHPAGE_NOAUTOCLOSE ;Don't skip to finish page automatically after patching is finished
	
	; !define MUI_ICON ""
	; !define MUI_WELCOMEFINISHPAGE_BITMAP "res\wizard-left.bmp"
	; !define MUI_FINISHPAGE_RUN ""
	; !define MUI_FINISHPAGE_RUN_TEXT "" 
;--------------------------------

######
;Pages
######
	; !define MUI_WELCOMEPAGE_TITLE "Welcome to Plants vs. Zombies main.pak patcher!"
	; !define MUI_WELCOMEPAGE_TEXT "This wizard will help you to unpack the main.pak file and thus make modding the game possible. Please note that although it may look like this is NOT an installer. It won't modify your registry, system files, etc."
	; !insertmacro MUI_PAGE_WELCOME
	
	!define MUI_COMPONENTSPAGE_TEXT_TOP "Check the components you want to apply to the game, then hit Next."
	!define MUI_COMPONENTSPAGE_TEXT_COMPLIST "Select components to apply:"
	!insertmacro MUI_PAGE_COMPONENTS
	
	!define MUI_DIRECTORYPAGE_TEXT_TOP "Wizard will patch the game in selected folder"
	!insertmacro MUI_PAGE_DIRECTORY
	!insertmacro MUI_PAGE_INSTFILES
	!insertmacro MUI_PAGE_FINISH
	
	!insertmacro MUI_UNPAGE_CONFIRM
    !insertmacro MUI_UNPAGE_INSTFILES
;--------------------------------

##########
;Languages
##########
	!insertmacro MUI_LANGUAGE "English" ;Default language
	;WARNING! Despite the fact we're not using any other languages this line is MANDATORY
;--------------------------------


Section "Patch" SecPatch ;Patching section. SecPatch is an ID
	;Detect if the game is already patched
	IfFileExists "$INSTDIR\properties\patch" 0 +3
	MessageBox MB_OK|MB_ICONSTOP "Game is already patched! Nothing to do!"
	Quit
	
	;Detect if there is something to process, if not - stop the patcher and show error
	IfFileExists "$INSTDIR\main.pak" +3 0
	MessageBox MB_OK|MB_ICONSTOP "Selected location does not contain main.pak file! No changes applied. Patcher will be closed."
	Quit
	
	;Set path and extract files
	SetOutPath "$INSTDIR"
	File /x "patch" "tools\*"
	
	;---------------------------------------------------------------------------------------------
	;Main game patcher commands
	;Using QuickBMS files extractor by Luigi Auriemma (http://aluigi.altervista.org/quickbms.htm)
	;Commandline options:
	;quickbms.exe 7x7m.bms main.pak .
	;---------------------------------------------------------------------------------------------
	;7x7m.bms - script to process .pak file (http://aluigi.altervista.org/bms/7x7m.bms)
	;main.pak - archive file to extract
	;. - .exe directory as output
	;---------------------------------------------------------------------------------------------
	
	DetailPrint "Patching..."
	nsExec::ExecToLog /TIMEOUT=2000 '"$INSTDIR\quickbms.exe" -o 7x7m.bms main.pak .'
	Pop $0 ;Pop the exit code from the stack to $0 variable
	Pop $1 ;Pop the out message from the stack to $1 variable (won't be used, but we like to keep stack clean)
	
	;Error handler
	StrCmp $0 0 +4 0 ;Check if executed application returned 0 (ended without errors). If not - abort patcher and show error message.
	MessageBox MB_OK|MB_ICONSTOP "Patching error. Try to run application again."
	Call cleanup
	Quit
	
	;Create backup of main.pak for further unpatching
	Rename "main.pak" "main.pak.bak"
	
	;Move dummy/marker file for indication that game is patched
	SetOutPath "$INSTDIR\properties"
	File "tools\patch"
	
	;Create "unpatcher"
	WriteUninstaller "$INSTDIR\unpatch.exe"
	
	;Make cleanup
	Call cleanup
	Return
SectionEnd

Section "Zombie Jackson" SecZombieJackson
	DetailPrint "Recovering Jackson Zombie from depths of the game files..."
	SetOverwrite on ;Turn overwrite on - we have to replace original game files with whose from primary version of the game
	SetOutPath "$INSTDIR\compiled\reanim" ;Set path as file output
	File "jacksonzombie\*" ;Move jacksonzombie files into above destination
	SetOverwrite off ;Turn overwrite off - we won't need it in future
SectionEnd

;Unpatcher section
Section "Uninstall"
	RMDir /r "$INSTDIR\compiled"
	RMDir /r "$INSTDIR\data"
	RMDir /r "$INSTDIR\images"
	RMDir /r "$INSTDIR\particles"
	RMDir /r "$INSTDIR\reanim"
	RMDir /r "$INSTDIR\sounds"
	
	Rename "$INSTDIR\main.pak.bak" "$INSTDIR\main.pak"
	Delete "$INSTDIR\properties\patch"
	Delete "$INSTDIR\unpatch.exe"
SectionEnd

Function cleanup ;Delete temporary files 
	Delete "$INSTDIR\quickbms.exe"
	Delete "$INSTDIR\7x7m.bms"
FunctionEnd

Function .onInit
	SectionSetSize ${SecPatch} 56 ;56KB for unpatcher
	SectionSetSize ${SecZombieJackson} 0
	
	IfFileExists "$EXEDIR\main.pak" continue 0
	MessageBox MB_YESNO|MB_ICONINFORMATION "File main.pak not found.$\r$\n\
	Do you want to set game directory manually?" IDYES +2 IDNO
	Abort

	continue:
	;Combine two flags (logical OR) to make Patch checkbox grayed out (SF_RO - Read Only = 16) and checked (SF_SELECTED = 1)
	IntOp $0 ${SF_RO} | ${SF_SELECTED} 			; 16 | 1 (16 OR 1) = 17  10000
	SectionSetFlags ${SecPatch} $0				; Set "17" as flag
	SectionSetFlags ${SecZombieJackson} 0		; Set "0" as flag
FunctionEnd

Function un.onInit
MessageBox MB_OK|MB_ICONINFORMATION "Warning! This will unpatch the game. Make sure you made a backup of your mods, translations, animations, particles, etc. All those directories will be removed. If you haven't made any changes simply ignore this message."
FunctionEnd

#############
;Descriptions
#############
  ;Assign descriptions to sections
	!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
	!insertmacro MUI_DESCRIPTION_TEXT ${SecPatch} "Patch the main.pak file to make modding available"
	!insertmacro MUI_DESCRIPTION_TEXT ${SecZombieJackson} "Replace regular Disco Zombie with sought-after Zombie Jackson!"
	!insertmacro MUI_FUNCTION_DESCRIPTION_END
;--------------------------------
