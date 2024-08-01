import platform
import sys
import iris

if __name__ == '__main__':

	pf = platform.system()
	if pf == 'Windows':
		datadir="/datavol/share/"
		sys.path += ['c:\\intersystems\\iris\\lib\\python','c:\\intersystems\\iris\\mgr\\python']
	elif pf == 'Linux':
		datadir="/datavol/share/"
		sys.path += ['/usr/irissys/lib/python/','/usr/irissys/mgr/python/']

	iris.system.Process.SetNamespace('AVRO')
	sql = "DELETE FROM MQTT.SimpleClass"
	stmt = iris.sql.prepare(sql)

	try: 
		rs=stmt.execute()
	except Exception as ex:
		if ex.sqlcode != 0:
			print ('SQL error', ex.message, ex.sqlcode, ex.statement)

