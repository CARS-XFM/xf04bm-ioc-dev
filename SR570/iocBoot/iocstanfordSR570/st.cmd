< envPaths
errlogInit(5000)

 ## Register all support components
dbLoadDatabase("../../dbd/stanfordSR570.dbd")
stanfordSR570_registerRecordDeviceDriver(pdbbase) 

 ## Load record instances
dbLoadRecords("$(IP)/ipApp/Db/SR570.db","P=XF:04BM-BMC:SR570,A={CurrAmp:1},PORT=BMCmoxa01")
dbLoadRecords("$(IP)/ipApp/Db/SR570.db","P=XF:04BM-BMC:SR570,A={CurrAmp:2},PORT=BMCmoxa02")
#dbLoadRecords("$(IP)/ipApp/Db/SR570.db","P=XF:04BM-BMC:SR570,A={CurrAmp:3},PORT=BMCmoxa03")

 ## Setup IP port for SR570 - thru Moxa NPort 6000
drvAsynIPPortConfigure("BMCmoxa01", "10.4.130.53:4001")
drvAsynIPPortConfigure("BMCmoxa02", "10.4.130.53:4002")
#drvAsynIPPortConfigure("BMCmoxa03", "10.4.130.53:4003")

 ## save_restoreSet_status_prefix("XF:04BM-BMC:SR570{CurrAmp:x}")
dbLoadRecords("$(AUTOSAVE)/asApp/Db/save_restoreStatus.db", "P=XF:04BM-BMC:SR570{CurrAmp:1}")
dbLoadRecords("$(AUTOSAVE)/asApp/Db/save_restoreStatus.db", "P=XF:04BM-BMC:SR570{CurrAmp:2}")
#dbLoadRecords("$(AUTOSAVE)/asApp/Db/save_restoreStatus.db", "P=XF:04BM-BMC:SR570{CurrAmp:3}")

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
#set_pass0_restoreFile("auto_positions.sav")
set_pass0_restoreFile("auto_settings.sav")
set_pass1_restoreFile("auto_settings.sav")

 ## specify directories in which to to search for included request files
set_requestfile_path("./")
set_requestfile_path("$(AUTOSAVE)",      "asApp/Db")
set_requestfile_path("$(IP)",            "ipApp/Db")

iocInit()

 ## save positions and settings every 30 seconds
#create_monitor_set("auto_positions.req", 5 , "")
create_monitor_set("auto_settings.req", 5 , "")
