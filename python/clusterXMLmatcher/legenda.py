#!/usr/bin/python
from rooms import *
from utils import *
from myDictionaries import *
from xml.dom.minidom import parse
import matplotlib.pyplot as plt
import numpy.random as rnd
import numpy
from matplotlib.patches import Ellipse

'''
Script che plotta i colori di labels.xml e myDictionaries.py
'''

for labelxml in ['school.xml','office.xml'] :
	if labelxml == 'office.xml' :
		offset = 2
	else 	:
		offset = 0
	#labelxml = 'school.xml'
	nobackground = False 
	xmldoc = parse(labelxml)
	labels = {}
	letters = {}
	nodeLabels = xmldoc.getElementsByTagName("label")
	counter = 1;
	for nodeLabel in nodeLabels:
		name = nodeLabel.getElementsByTagName("name")[0].childNodes[0].nodeValue
		letter = nodeLabel.getElementsByTagName("letter")[0].childNodes[0].nodeValue
		labels[name] = letter
		letters[letter] = { 
				'name' : name , 
				'color': Java2012_colorDict[letter], 
				'number' : labels_java2012toMatlab_Dict[letter],
				'RC' : labels_RC_java2012[letter],
				'ellipse' : Ellipse(xy=[0.7,counter*0.7], width=0.6, height=0.6,angle=0),
				'counter' : counter
		}
		counter+=1;

	fig = plt.figure(0)



	ax = fig.add_subplot(111, aspect='equal')
	for i in letters.keys() :
		e = letters[i]['ellipse']
		ax.add_artist(e)
		e.set_clip_box(ax.bbox)
		#e.set_alpha(rnd.rand())
		#e.set_facecolor(rnd.rand(3))
		e.set_facecolor(letters[i]['color'])
		ax.text(2,0.7*letters[i]['counter'] +0.6/4,letters[i]['name'],fontsize=12)
		ax.text(2+8+offset,0.7*letters[i]['counter'] +0.6/4,i,fontsize=12)
		ax.text(2+9+offset,0.7*letters[i]['counter'] +0.6/4,letters[i]['number'],fontsize=12)
		ax.text(2+11+offset,0.7*letters[i]['counter'] +0.6/4,letters[i]['RC'],fontsize=12)



	ax.set_xlim(0,15+offset)
	ax.set_ylim(0.7*counter+1,0)

	fig.suptitle(labelxml.split('.')[0], fontsize=14, fontweight='bold')
	plt.tick_params(axis='both', which='both', bottom='off', top='off', labelbottom='off', right='off', left='off', labelleft='off')

	if nobackground :
		ax.axis('off')

	plt.savefig(labelxml.split('.')[0]+'_legend.pdf')
	plt.show()

