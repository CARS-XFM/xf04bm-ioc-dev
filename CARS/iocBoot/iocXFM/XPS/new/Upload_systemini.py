
from StringIO import StringIO
from epicsscan.xps.newportxps import NewportXPS
s = NewportXPS('10.8.128.206')

s.ftp_connect()
# s.ftpconn.cwd("/Admin/Config")
s.ftpconn.cwd("/Config")

sysini_text = open('system.ini', 'r').read()

s.ftpconn.storbinary("STOR system.ini", StringIO(sysini_text))

text = StringIO()
s.ftpconn.retrbinary("RETR system.ini", text.write)
text.seek(0)
print text.readline()
lines = text.readlines()
print "Final"
print "".join(lines)

s.ftp_disconnect()

s.reboot()
