< envPaths
errlogInit(5000)

 ## Register all support components
dbLoadDatabase("../../dbd/esp300.dbd",0,0)
esp300_registerRecordDeviceDriver(pdbbase) 

 ## Load record instances
dbLoadRecords("$(ASYN)/db/asynRecord.db", "P=XF:04BMC-ES:,R=DET:1-Ax,PORT=BMCmoxa09,ADDR=0,OMAX=40,IMAX=40")
dbLoadTemplate("motors.template")
dbLoadRecords("$(MOTOR)/db/motorUtil.db", "P=XF:04BMC-ES:DET:1-Ax:")

 ## Setup IP port for ESP300 - thru Moxa NPort 6650-16
drvAsynIPPortConfigure("BMCmoxa09", "10.4.130.53:4009", 0, 0, 0)
asynOctetSetInputEos("BMCmoxa09",0,">")
asynOctetSetOutputEos("BMCmoxa09",0,"\r")

 ## Newport ESP300 driver setup parameters: 
 ##     (1) maximum number of controllers in system
 ##     (2) motor task polling rate (min=1Hz,max=60Hz)
ESP300Setup(2, 10)

 ## Newport ESP300 driver configuration parameters: 
 ##     (1) controller# being configured,
 ##     (2) ASYN port name
 ##     (3) address (GPIB only)
ESP300Config(0, "BMCmoxa09")

 ## save_restoreSet_status_prefix("XF:04BMC-ES:DET:1-Ax:")
dbLoadRecords("$(AUTOSAVE)/asApp/Db/save_restoreStatus.db", "P=XF:04BMC-ES:DET:1-Ax:")

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
set_savefile_path(".", "autosave")

 ## specify what save files should be restored.  Note these files must be
 ## in the directory specified in set_savefile_path(), or, if that function
 ## has not been called, from the directory current when iocInit is invoked
set_pass0_restoreFile("auto_positions.sav")
set_pass0_restoreFile("auto_settings.sav")
set_pass1_restoreFile("auto_settings.sav")

 ## specify directories in which to to search for included request files
set_requestfile_path("./")
set_requestfile_path("$(AUTOSAVE)",      "asApp/Db")
set_requestfile_path("$(MOTOR)",         "motorApp/Db")

iocInit()

 ## motorUtil (allstop & alldone)
motorUtilInit("XF:04BMC-ES:DET:1-Ax:")

 ## save positions every five seconds
create_monitor_set("auto_positions.req", 5, "P=XF:04BMC-ES:DET:1-Ax:")
 ## save other things every thirty seconds
create_monitor_set("auto_settings.req", 30, "P=XF:04BMC-ES:DET:1-Ax:")
