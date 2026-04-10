import os
from xml.dom import minidom
from PIL import Image

for (dirpath, dirnames, filenames) in os.walk('../../assets'):
	for file in filenames:
		if file.endswith(".xml") and os.path.isfile(dirpath + '/' + file[:-3] + 'png'):
			print('Converting ' + dirpath + '/' + file[:-4])

			xmlParse = minidom.parse(dirpath + '/' + file)

			highestWidth = 0
			highestHeight = 0
			for elem in xmlParse.getElementsByTagName('SubTexture'):
				width = int(elem.attributes['x'].value) + int(elem.attributes['width'].value)
				height = int(elem.attributes['y'].value) + int(elem.attributes['height'].value)

				if width > highestWidth:
					highestWidth = width
				if height > highestHeight:
					highestHeight = height

			image = Image.open(dirpath + '/' + file[:-3] + 'png')
			image = image.crop((0, 0, highestWidth, highestHeight))
			image.save(dirpath + '/' + file[:-3] + 'png')
