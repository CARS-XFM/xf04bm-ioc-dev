< envPaths
errlogInit(5000)

 ## Tell EPICS all about the record types, device-support modules, drivers,
 ## etc. in this build from CARS
dbLoadDatabase("../../dbd/CARSLinux.dbd")
CARSLinux_registerRecordDeviceDriver(pdbbase)

 ################################################################################
 ## XPS Setup
 ## asyn port, IP address, IP port, number of axes, 
 ## active poll period (ms), idle poll period (ms), 
 ## enable set position, set position settling time (ms)
XPSCreateController("XPS3", "10.4.130.103", 5001, 6, 10, 500, 0, 500)
asynSetTraceIOMask("XPS3", 0, 2)
#asynSetTraceMask("XPS3", 0, 255)

 ## asynPort, IP address, IP port, poll period (ms)
XPSAuxConfig("XPS_AUX3", "10.4.130.103", 5001, 50)
#asynSetTraceIOMask("XPS_AUX3", 0, 2)
#asynSetTraceMask("XPS_AUX3", 0, 255)

 ## XPS asyn port,  axis, groupName.positionerName, stepSize
 ## card,  axis, groupName.positionerName, stepsPerUnit
XPSCreateAxis("XPS3", 0,    "XYZ.X",                  "100000") # VP-25XL
XPSCreateAxis("XPS3", 1,    "XYZ.Y",                  "100000") # VP-25XL
XPSCreateAxis("XPS3", 2,    "XYZ.Z",                  "100000") # VP-25XL

 ## XPS asyn port,  max points, FTP username, FTP password
 ## Note: this must be done after configuring axes
XPSCreateProfile("XPS3", 8192, "Administrator", "Administrator")

 ## Disable setting position
XPSEnableSetPosition(0)

 ################################################################################
 ## Motors
dbLoadTemplate("motors.template")

 ## A set of scan parameters for each positioner. This is a convenience for
 ## for the user. It can contain an entry for each scannable thing in the crate.
dbLoadTemplate("scanParms.template")

 ## Allstop, alldone
dbLoadRecords("$(MOTOR)/motorApp/Db/motorUtil.db","P=XF:04BM-ES:2:")

 ## Scan-support software
 ## crate-resident scan.  This executes 1D, 2D, 3D, and 4D scans, and caches
 ## 1D data, but it doesn't store anything to disk.  (You need the data catcher
 ## or the equivalent for that.)  This database is configured to use the
 ## "alldone" database (above) to figure out when motors have stopped moving
 ## and it's time to trigger detectors.
dbLoadRecords("$(SSCAN)/sscanApp/Db/scan.db", "P=XF:04BM-ES:2:,MAXPTS1=2000,MAXPTS2=500,MAXPTS3=50,MAXPTS4=10,MAXPTSH=10")

 ## Free-standing user string/number calculations (sCalcout records)
dbLoadRecords("$(CALC)/calcApp/Db/userStringCalcs10.db", "P=XF:04BM-ES:2:")

 ## Free-standing user transforms (transform records)
dbLoadRecords("$(CALC)/calcApp/Db/userTransforms10.db", "P=XF:04BM-ES:2:")

 ## Miscellaneous PV's, such as burtResult
dbLoadRecords("$(STD)/stdApp/Db/misc.db", "P=XF:04BM-ES:2:")

##< ../save_restore_IOCSH.cmd
 ## save_restoreSet_status_prefix("XF:04BM-ES:2:")
dbLoadRecords("$(AUTOSAVE)/asApp/Db/save_restoreStatus.db", "P=XF:04BM-ES:2:")

dbLoadRecords("$(ASYN)/db/asynRecord.db", "P=XF:04BM-ES:2:,R=asyn1,PORT=XPS3,ADDR=0,IMAX=256,OMAX=256")

 ## scan communication and meta data
dbLoadRecords("$(CARS)/CARSApp/Db/scanner.db","P=XF:04BM-ES:2:,Q=edb")

 ## fast mapping
dbLoadRecords("$(CARS)/CARSApp/Db/XFM_fastmap.db","P=XF:04BM-ES:2:,Q=map")

 ## Epics PyInstrument
dbLoadRecords("$(CARS)/CARSApp/Db/PyInstrument.db","P=XF:04BM-ES:2:,Q=Inst")

 ## ion chamber calculations
#dbLoadRecords("$(CARS)/CARSApp/Db/IonChamber.db","P=XF:04BM-ES:2:,Q=ION")

 ## TEMPORARY blank GSECARS PVs to make scan_gui happy
#dbLoadRecords("$(CARS)/CARSApp/Db/GSECARS_PVs.db")

asynSetTraceIOMask("XPS3",0,2)
asynSetTraceIOTruncateSize("XPS3",0,200)

 ## devIocStats
epicsEnvSet("ENGINEER", "Alvin Acerbo")
epicsEnvSet("LOCATION", "04BM-BMC")
epicsEnvSet("GROUP",    "XFM - GSECARS")
dbLoadRecords("$(DEVIOCSTATS)/db/iocAdminSoft.db","IOC=XF:04BM-ES:2")

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
set_savefile_path("/home/epics/support/CARS/iocBoot/iocPINK", "autosave")

 ## specify what save files should be restored.  Note these files must be
 ## in the directory specified in set_savefile_path(), or, if that function
 ## has not been called, from the directory current when iocInit is invoked
set_pass0_restoreFile("auto_positions.sav")
set_pass0_restoreFile("auto_settings.sav")
set_pass1_restoreFile("auto_settings.sav")

 ## specify directories in which to to search for included request files
set_requestfile_path("./")
set_requestfile_path("$(CARS)",          "CARSApp/Db")
set_requestfile_path("$(AREA_DETECTOR)",  "ADApp/Db")
set_requestfile_path("$(AUTOSAVE)",      "asApp/Db")
set_requestfile_path("$(CALC)",          "calcApp/Db")
#set_requestfile_path("$(MCA)",           "mcaApp/Db")
set_requestfile_path("$(MOTOR)",         "motorApp/Db")
set_requestfile_path("$(SSCAN)",         "sscanApp/Db")
set_requestfile_path("$(STD)",           "stdApp/Db")

iocInit

motorUtilInit("XF:04BM-ES:2:")

 ## set permissions for save files (ASA)
save_restoreSet_FilePermissions(0777)

 ## save positions every five seconds
create_monitor_set("auto_positions.req", 5, "P=XF:04BM-ES:2:")
 ## save other things every thirty seconds
create_monitor_set("auto_settings.req", 30, "P=XF:04BM-ES:2:")

dbpf("XF:04BM-ES:2:m1.NTM","0")
dbpf("XF:04BM-ES:2:m2.NTM","0")
dbpf("XF:04BM-ES:2:m3.NTM","0")
