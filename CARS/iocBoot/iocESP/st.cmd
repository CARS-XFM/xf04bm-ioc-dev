< envPaths
errlogInit(5000)

# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in this build from CARS
dbLoadDatabase("/home/epics/support/CARS/iocBoot/iocESP/ESP300.dbd",0,0)
#esp300_registerRecordDeviceDriver(pdbbase)

#dbLoadDatabase("../../dbd/CARSLinux.dbd")
#CARSLinux_registerRecordDeviceDriver(pdbbase)

# Load record instances
dbLoadRecords("${ASYN}/db/asynRecord.db", "P=ESP300,R=port1,PORT=ESP300port1,ADDR=0,OMAX=40,IMAX=40")
dbLoadRecords("${MOTOR}/db/motorUtil.db", "P=ESP300:")


### Motors
dbLoadTemplate "ESP300.substitutions"
#dbLoadTemplate "motors.template"

################################################################################
# Asyn Setup
drvAsynIPPortConfigure("ESP300port1","10.4.130.53:4009")
asynSetTraceIOMask("ESP300port1",0,2)

asynOctetSetInputEos("ESP300port1",0,">")
asynOctetSetOutputEos("ESP300port1",0,"\r")

################################################################################
# ESP300 Setup

ESP300Setup(1, 5)
ESP300Config(1, "L0")

iocInit

motorUtilInit("ESP300:")
