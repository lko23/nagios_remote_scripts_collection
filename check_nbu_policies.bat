REM needs:
REM C:\Program Files\NSClient++\nsclient.ini: check_netbackup_policies=check_netbackup\check_nbu_policies.bat


@echo off

SETLOCAL ENABLEDELAYEDEXPANSION
SET count=0
SET c=0
SET basedir=E:\VERITAS\NetBackup\db\class

cacls %basedir% > NUL
IF NOT %ERRORLEVEL% == 0 (
  ECHO UNKNOWN: base directory does not exist or can not be accessed
  exit 3
)

FOR /F "tokens=* USEBACKQ" %%F IN (`findstr /S /M /C:"ACTIVE 1" C:\Path\to\nbu\db\class\ info`) DO (
  IF NOT "%%F" == "%basedir%\ora-ksl-db-backup-w2k\info" (
  IF NOT "%%F" == "%basedir%\sql-ksl-logs-backup\info" ( 
  IF NOT "%%F" == "%basedir%\user-archive\info" ( 
  IF NOT "%%F" == "%basedir%\user-backup\info" ( 
  IF NOT "%%F" == "%basedir%\vmw-DC2-NoQuery\info" ( 
  IF NOT "%%F" == "%basedir%\vmw-DCX\info" ( 
  IF NOT "%%F" == "%basedir%\vmw-DCX-NoQuiesce\info" ( 
  IF NOT "%%F" == "%basedir%\_All_Clients\info" ( 

  SET var!count!=%%F
  SET /a count=!count!+1

  ) ) ) ) ) ) ) )
)

IF NOT %ERRORLEVEL% == 0 (
  ECHO UNKNOWN: Error while searching with findstr
  exit 3
)

IF %count% == 0 (
  ECHO OK: No unallowed disabled policies
  exit 0
) ELSE (
  ECHO WARNING: %count% unallowed disabled policies
  FOR /L %%A in (1,1,%count%) do (
    ECHO !var%c%!
    SET /a c=!c!+1
  )
  exit 1
)

ENDLOCAL
