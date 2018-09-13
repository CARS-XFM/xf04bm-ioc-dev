< envPaths
errlogInit(5000)

## Register all support components
dbLoadDatabase("../../dbd/esp300.dbd",0,0)
esp300_registerRecordDeviceDriver(pdbbase) 

## Load record instances
dbLoadRecords("$(ASYN)/db/asynRecord.db", "P=XF:04BMB-OP:,R=ESP300,PORT=BMBmoxa01,ADDR=0,OMAX=40,IMAX=40")
dbLoadRecords("$(ASYN)/db/asynRecord.db", "P=XF:04BMC-ES:,R=ESP300,PORT=BMCmoxa09,ADDR=0,OMAX=40,IMAX=40")
dbLoadTemplate("motors.template")
dbLoadRecords("$(MOTOR)/db/motorUtil.db", "P=XF:04BM-ESP:")

# Setup IP port for ESP300 - thru Moxa Nport5210
drvAsynIPPortConfigure("BMBmoxa01", "10.4.130.54:950", 0, 0, 0)
drvAsynIPPortConfigure("BMCmoxa09", "10.4.130.53:4009", 0, 0, 0)
asynOctetSetInputEos("BMBmoxa01",0,">")
asynOctetSetOutputEos("BMBmoxa01",0,"\r")
asynOctetSetInputEos("BMCmoxa09",0,">")
asynOctetSetOutputEos("BMCmoxa09",0,"\r")

# Newport ESP300 driver setup parameters: 
#     (1) maximum number of controllers in system
#     (2) motor task polling rate (min=1Hz,max=60Hz)
ESP300Setup(2, 10)

# Newport ESP300 driver configuration parameters: 
#     (1) controller# being configured,
#     (2) ASYN port name
#     (3) address (GPIB only)
ESP300Config(1, "BMCmoxa09")
ESP300Config(0, "BMBmoxa01")

iocInit()

# motorUtil (allstop & alldone)
motorUtilInit("XF:04BM-ESP:")
