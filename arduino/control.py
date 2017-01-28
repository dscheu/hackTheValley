import serial
import subprocess

ser = serial.Serial('/dev/tty.wchusbserial410', 9600)
while True:
	command = ser.readline().strip()
	print command
	if command == "OPEN":
		print "Verifying in Blockchain if user has access to parking lot..."
		out, err = subprocess.Popen(['geth','--preload','/Users/daniel/hackathon/hackTheValley/norsborg-client/test.js','--exec','contract.hasAccess(33, "0x8c99ca0e55ec2f35ad18e9e7a20883ad1ffe859e")','attach', 'ipc:/Users/daniel/.ethereum-norsborg-data-16123/geth.ipc'], stdout=subprocess.PIPE).communicate()
		response = out.strip()
		print "Blockchain said: "
		print response

		if response == "true":
			print "Opening Gate!"
			ser.write("OPEN")
