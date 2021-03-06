< envPaths
 ## Start errlog Task before any possible error messsage to prevent
 ## erroneous "Interrupted system call" message on Linux OS.
errlogInit(5000)

dbLoadDatabase("../../dbd/CARSLinux.dbd")
CARSLinux_registerRecordDeviceDriver(pdbbase)

 ################################################################################
 ## XPS Setup
 ## asyn port, IP address, IP port, number of axes, 
 ## active poll period (ms), idle poll period (ms), 
 ## enable set position, set position settling time (ms)
XPSCreateController("XPS2", "10.4.130.102", 5001, 8, 10, 500, 0, 500)
asynSetTraceIOMask("XPS2", 0, 2)
#asynSetTraceMask("XPS2", 0, 255)

 ## asynPort, IP address, IP port, poll period (ms)
XPSAuxConfig("XPS_AUX2", "10.4.130.102", 5001, 50)
#asynSetTraceIOMask("XPS_AUX2", 0, 2)
#asynSetTraceMask("XPS_AUX2", 0, 255)

 ## XPS asyn port,  axis, groupName.positionerName, stepSize
 ## card,  axis, groupName.positionerName, stepsPerUnit
 ## Note: XPSCreateAxis errors are due to old C8 driver
XPSCreateAxis("XPS2", 0, "MONO.THETA",     "131111.111111111")
XPSCreateAxis("XPS2", 2, "MONO.HEIGHT",           "5000")
XPSCreateAxis("XPS2", 1, "MONOX.POSITIONER",      "2560")
XPSCreateAxis("XPS2", 3, "PITCH.POSITIONER",      "9800")
XPSCreateAxis("XPS2", 4, "ROLL.POSITIONER",       "5600")
XPSCreateAxis("XPS2", 7, "VIEWER.POSITIONER",     "1600")

 ## XPS asyn port,  max points, FTP username, FTP password
 ## Note: this must be done after configuring axes
XPSCreateProfile("XPS2", 8192, "Administrator", "Administrator")

 ## Disable setting position
XPSEnableSetPosition(0)
 ################################################################################
 ## Motors
dbLoadTemplate("motors.template")

 ## Auxillary I/O records
dbLoadTemplate("XPSAux.substitutions")

 ## asyn record for debugging
drvAsynIPPortConfigure("xps", "10.4.130.102:5001", 0, 0, 0)
asynSetTraceIOMask("xps",0,2)
asynSetTraceMask("xps",0,9)
dbLoadRecords("$(ASYN)/db/asynRecord.db", "P=XF:04BM-BMB:1, R=trajAsyn2, PORT=xps, ADDR=0, OMAX=300, IMAX=32000")

 ## Debug-output level
save_restoreSet_Debug(0)

 ## Ok to save/restore save sets with missing values (no CA connection to PV)?
save_restoreSet_IncompleteSetsOk(1)

 ## Save dated backup files?
save_restoreSet_DatedBackupFiles(1)

 ## Number of sequenced backup files to write
save_restoreSet_NumSeqFiles(3)

 ## Time interval between sequenced backups
save_restoreSet_SeqPeriodInSeconds(300)

 ## specify where save files should be
 ## set_savefile_path(".", "autosave")
set_savefile_path("/home/epics/support/CARS/iocBoot/iocDCM", "autosave")

 ## specify what save files should be restored.  Note these files must be
 ## in the directory specified in set_savefile_path(), or, if that function
 ## has not been called, from the directory current when iocInit is invoked
set_pass0_restoreFile("auto_positions.sav")
set_pass0_restoreFile("auto_settings.sav")
set_pass1_restoreFile("auto_settings.sav")
set_pass1_restoreFile("crystal_settings.sav")

 ## specify directories in which to to search for included request files
set_requestfile_path("./")
set_requestfile_path("$(CARS)",          "CARSApp/Db")
set_requestfile_path("$(AREA_DETECTOR)",  "ADApp/Db")
set_requestfile_path("$(AUTOSAVE)",      "asApp/Db")
set_requestfile_path("$(CALC)",          "calcApp/Db")
set_requestfile_path("$(MCA)",           "mcaApp/Db")
set_requestfile_path("$(MOTOR)",         "motorApp/Db")
set_requestfile_path("$(SSCAN)",         "sscanApp/Db")
set_requestfile_path("$(STD)",           "stdApp/Db")

 ## save_restoreSet_status_prefix("XF:04BM-BMB:1:")
dbLoadRecords("$(AUTOSAVE)/asApp/Db/save_restoreStatus.db", "P=XF:04BM-BMB:1:")
dbLoadRecords("$(AUTOSAVE)/asApp/Db/save_restoreStatus.db", "P=XF:04BM-BMB:En:")

 ## A set of scan parameters for each positioner. This is a convenience for
 ## the user. It can contain an entry for each scannable thing in the crate
dbLoadTemplate("scanParms.template")

 ## motorUtil - for allstop, moving, etc.
dbLoadRecords("$(MOTOR)/motorApp/Db/motorUtil.db","P=XF:04BM-BMB:1")

dbLoadTemplate("mono_energy.template")

 ## Free-standing user string/number calculations (sCalcout records)
dbLoadRecords("$(CALC)/calcApp/Db/userStringCalcs10.db", "P=XF:04BM-BMB:1:")

 ## Free-standing user transforms (transform records)
dbLoadRecords("$(CALC)/calcApp/Db/userTransforms10.db", "P=XF:04BM-BMB:1")
 ################################################################################

 ## devIocStats
epicsEnvSet("ENGINEER","Alvin Acerbo")
epicsEnvSet("LOCATION","04BM")
epicsEnvSet("GROUP","XFM/GSECARS")
dbLoadRecords("$(DEVIOCSTATS)/db/iocAdminSoft.db","IOC=XF:04BM-BMB:1")

iocInit

 ## save positions every five seconds
create_monitor_set("auto_positions.req",5,"P=XF:04BM-BMB:1:")
 ## save other things every thirty seconds
create_monitor_set("auto_settings.req",30,"P=XF:04BM-BMB:1:")
 ## save crystal parameters every thirty seconds
create_monitor_set("crystal_settings.req",30,"P=XF:04BM-BMB:En:")

 ## run MonoEnergy sequence program here
seq(&GSE_MonoEnergy, "MONO=XF:04BM-BMB:En, MTH=XF:04BM-BMB:1:m1, MY=XF:04BM-BMB:1:m3")
