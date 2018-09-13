< envPaths
errlogInit(5000)

cd $(TOP)

 ## Register all support components
dbLoadDatabase("dbd/zebra.dbd",0,0)
zebra_registerRecordDeviceDriver(pdbbase) 

 ## Connect to Zebra via Moxa on port 4
drvAsynIPPortConfigure("ty_zebra","10.4.130.53:4004")

 ## zebraConfig(Port, SerialPort, MaxPosCompPoints)
#zebraConfig("XF:04BMC-ES:ZEBRA", "ty_zebra", 100000)
zebraConfig("ZEBRA", "ty_zebra", 100000)

 ## Load record instances
dbLoadTemplate("db/zebra.substitutions")

 ## autosave/restore machinery
save_restoreSet_Debug(0)
save_restoreSet_IncompleteSetsOk(1)
save_restoreSet_DatedBackupFiles(1)

set_savefile_path("${TOP}/as","/save")
set_requestfile_path("${TOP}/as","/req")

set_pass0_restoreFile("info_positions.sav")
set_pass0_restoreFile("info_settings.sav")
set_pass1_restoreFile("info_settings.sav")

iocInit()

 ## more autosave/restore machinery
cd ${TOP}/as/req
makeAutosaveFiles()
create_monitor_set("info_positions.req", 5 , "")
create_monitor_set("info_settings.req", 15 , "")

 ## Start any sequence programs
#seq snczebra,"user=domitto"
