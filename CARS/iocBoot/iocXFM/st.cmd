< envPaths
errlogInit(5000)

 ## Tell EPICS all about the record types, device-support modules, drivers,
 ## etc. in this build from CARS
dbLoadDatabase("../../dbd/CARSLinux.dbd")
CARSLinux_registerRecordDeviceDriver(pdbbase)

 #################################################################################
 ## XPS Setup
 ## asyn port, IP address, IP port, number of axes, 
 ## active poll period (ms), idle poll period (ms), 
 ## enable set position, set position settling time (ms)
XPSCreateController("XPS1", "10.4.130.101", 5001, 8, 10, 500, 0, 500)
asynSetTraceIOMask("XPS1", 0, 2)
#asynSetTraceMask("XPS1", 0, 255)

 ## asynPort, IP address, IP port, poll period (ms)
XPSAuxConfig("XPS_AUX1", "10.4.130.101", 5001, 50)
#asynSetTraceIOMask("XPS_AUX1", 0, 2)
#asynSetTraceMask("XPS_AUX1", 0, 255)

 ## XPS asyn port,  axis, groupName.positionerName, stepSize
 ## card,  axis, groupName.positionerName, stepsPerUnit
XPSCreateAxis("XPS1", 0, "FINE.X",           "100000") # VP-25XL
XPSCreateAxis("XPS1", 1, "FINE.Y",           "100000") # VP-25XL
XPSCreateAxis("XPS1", 2, "FINE.THETA",         "2000") # URS75CC
XPSCreateAxis("XPS1", 3, "FINE.COARSEX",       "2000") # ILS200CC
XPSCreateAxis("XPS1", 4, "COARSEZ.Pos",        "2000") # ILS200CC
XPSCreateAxis("XPS1", 5, "COARSEY.Pos",        "5000") # IMS300CC
XPSCreateAxis("XPS1", 6, "UTS.X",              "3200") # UTS100PP
XPSCreateAxis("XPS1", 7, "ROT.Pos",            "2000") # SR50PP

 ## XPS asyn port,  max points, FTP username, FTP password
 ## Note: this must be done after configuring axes
XPSCreateProfile("XPS1", 8192, "Administrator", "Administrator")

 ## Disable setting position
XPSEnableSetPosition(0)

 #################################################################################
 ## Motors
dbLoadTemplate("motors.template")

 ## A set of scan parameters for each positioner. This is a convenience for
 ## the user. It can contain an entry for each scannable thing in the crate
dbLoadTemplate("scanParms.template")

 ## Allstop, alldone
dbLoadRecords("$(MOTOR)/motorApp/Db/motorUtil.db","P=XF:04BM-ES:1:")

 ### Scan-support software
 ## crate-resident scan.  This executes 1D, 2D, 3D, and 4D scans, and caches
 ## 1D data, but it doesn't store anything to disk.  (You need the data catcher
 ## or the equivalent for that.)  This database is configured to use the
 ## "alldone" database (above) to figure out when motors have stopped moving
 ## and it's time to trigger detectors.
dbLoadRecords("$(SSCAN)/sscanApp/Db/scan.db", "P=XF:04BM-ES:1:,MAXPTS1=2000,MAXPTS2=500,MAXPTS3=50,MAXPTS4=10,MAXPTSH=10")

 ## Free-standing user string/number calculations (sCalcout records)
dbLoadRecords("$(CALC)/calcApp/Db/userStringCalcs10.db", "P=XF:04BM-ES:1:")

 ## Free-standing user transforms (transform records)
dbLoadRecords("$(CALC)/calcApp/Db/userTransforms10.db", "P=XF:04BM-ES:1:")

 ## Miscellaneous PV's, such as burtResult
dbLoadRecords("$(STD)/stdApp/Db/misc.db", "P=XF:04BM-ES:1:")

#< ../save_restore_IOCSH.cmd
#save_restoreSet_status_prefix("XF:04BM-ES:1:")
dbLoadRecords("$(AUTOSAVE)/asApp/Db/save_restoreStatus.db", "P=XF:04BM-ES:1:")

dbLoadRecords("$(ASYN)/db/asynRecord.db", "P=XF:04BM-ES:1:,R=asyn1,PORT=XPS1,ADDR=0,IMAX=256,OMAX=256")

 ## scan communication and meta data
dbLoadRecords("$(CARS)/CARSApp/Db/scanner.db","P=XF:04BM-ES:1:,Q=edb")

 ## fast mapping
dbLoadRecords("$(CARS)/CARSApp/Db/XFM_fastmap.db","P=XF:04BM-ES:1:,Q=map")

 ## fast XAFS 
dbLoadRecords("qxafs.db","P=XF:04BM-ES:1:,Q=QXAFS")

 ## Epics PyInstrument
dbLoadRecords("$(CARS)/CARSApp/Db/PyInstrument.db","P=XF:04BM-ES:1:,Q=Inst")

 ## ion chamber calculations
dbLoadRecords("$(CARS)/CARSApp/Db/IonChamber.db","P=XF:04BM-ES:1:,Q=ION")

 ## TEMPORARY blank GSECARS PVs to make scan_gui happy
#dbLoadRecords("$(CARS)/CARSApp/Db/GSECARS_PVs.db")

asynSetTraceIOMask("XPS1",0,2)
asynSetTraceIOTruncateSize("XPS1",0,200)

 ## devIocStats
epicsEnvSet("ENGINEER", "Alvin Acerbo")
epicsEnvSet("LOCATION", "04BM-BMC")
epicsEnvSet("GROUP",    "XFM - GSECARS")
dbLoadRecords("$(DEVIOCSTATS)/db/iocAdminSoft.db","IOC=XF:04BM-ES:1:")

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
set_savefile_path("/home/epics/support/CARS/iocBoot/iocXFM", "autosave")

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

 ## save_restoreSet_status_prefix("XF:04BM-ES:1:")
dbLoadRecords("$(AUTOSAVE)/asApp/Db/save_restoreStatus.db", "P=XF:04BM-ES:1:")
dbLoadRecords("$(AUTOSAVE)/asApp/Db/save_restoreStatus.db", "P=XF:04BM-ES:1:")

iocInit

motorUtilInit("XF:04BM-ES:1:")

 ## set permissions for save files (ASA)
#save_restoreSet_FilePermissions(0777)

 ## save positions every five seconds
create_monitor_set("auto_positions.req", 5, "P=XF:04BM-ES:1:")
 ## save other things every thirty seconds
create_monitor_set("auto_settings.req", 30, "P=XF:04BM-ES:1:")

dbpf("XF:04BM-ES:1:m1.NTM","0")
dbpf("XF:04BM-ES:1:m2.NTM","0")
dbpf("XF:04BM-ES:1:m3.NTM","0")
dbpf("XF:04BM-ES:1:m4.NTM","0")
dbpf("XF:04BM-ES:1:m5.NTM","0")
dbpf("XF:04BM-ES:1:m6.NTM","0")
dbpf("XF:04BM-ES:1:m7.NTM","0")
dbpf("XF:04BM-ES:1:m8.NTM","0")
# dbpf("XF:04BM-ES:1:pm1C1","0.70710678")
# dbpf("XF:04BM-ES:1:pm1C2","0.70710678")
# dbpf("XF:04BM-ES:1:pm2C1","0.70710678")
# dbpf("XF:04BM-ES:1:pm2C2","0.70710678")
