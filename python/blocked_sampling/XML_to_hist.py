'''
Questo script legge i dataset in formato XML e fa l'istogramma delle label. 
Inoltre salva l'istogramma delle lable in un file .p
'''
import xml.etree.ElementTree as ET
import matplotlib.pyplot as plt
import numpy as np
import math
import cmath
import glob
import pickle
from xml.dom.minidom import parse
import pickle

import networkx as nx 

from utils import * 

# qui conto quante stanze ci sono
spaces_hist = dict()
# qui aggiungo tutte le stanze, ordinate per label
big_spaces_dict = dict()
# qui aggiungo  le aree di tutte le stanze, sempre per label
big_spaces_areas = dict()

# carico le label ordinate per label e pere numero (letters e numebers rispettivamente)
(letters,numbers) = get_label_dict()
# inizializzo la struttura dati
for i in letters.keys() :
	spaces_hist[i] = 0
	big_spaces_dict[i] = []
	big_spaces_areas[i] = []

# e poi parso tutti gli xml
hist_dict=dict()
pixel_list = []
area_list = {}
for xml_file in glob.glob('dataset/XML/*.xml'):
	print xml_file
	ones_spaces = []
	xml_name = xml_file.split('/')[-1]
	print xml_name
	tree = ET.parse(xml_file)
	root = tree.getroot()
	floor = root.find('floor')
	spaces = floor.find('spaces')
	pixels = int(root.find('scale').find('represented_distance').find('value').text)
	pixel_list.append(pixels)
	total_area = 0.0

	i = 0
	translator = dict()
	for r in spaces.iter('space') :
		translator[i] = r.get('id')
		i += 1
	print translator 

	# istrogramma delle label PER IL GRAFO
	my_own_spaces_hist = dict()
	for rr in letters.keys() :
		my_own_spaces_hist[rr] = 0

	labels = []
	for space in spaces.iter('space'):
		ID = space.get('id')
		label = space.find('labels').find('label').text

		# aggiungo la stanza all'istogramma di tutti gli ambienti 
		spaces_hist[label]+=1
		# e a quello di questo ambiente
		my_own_spaces_hist[label] +=1
		# leggo le features
		space_dict = dict()
		space_dict['label'] = label
		space_dict['connections'] = []
		labels.append(space.find('labels').find('label').text)
		portals = space.find('portals')

		
		# Appendo le features 
		features_xml = space.find('features')
		area = features_xml.find('area').get('value')
		space_dict['area'] = area
		# se l'area e' zero salto tutto
		if float(area) > 0 :
			total_area+=float(area)
			perimeter = features_xml.find('perimeter').get('value')
			space_dict['perimeter'] = perimeter
			aoverp = features_xml.find('aoverp').get('value')
			space_dict['aoverp'] = aoverp
			adcs = features_xml.find('adcs').get('value')
			space_dict['adcs'] = adcs
			ff = features_xml.find('ff').get('value')
			space_dict['ff'] = ff
			circularity = features_xml.find('circularity').get('value')
			space_dict['circularity'] = circularity
			normalcirc = features_xml.find('normalcirc').get('value')
			space_dict['normalcirc'] = normalcirc
			andcs = features_xml.find('andcs').get('value')
			space_dict['andcs'] = andcs
			# Bulding type
			space_dict['betweenness'] = features_xml.find('betweenness').get('value')
			space_dict['closeness'] = features_xml.find('closeness').get('value')
			big_spaces_dict[label].append(space_dict)
			big_spaces_areas[label].append(float(area))

	
	print labels
	print_hist(my_own_spaces_hist)
	savename = xml_file.split('/')[-1].split('.')[0]
	plot_barchart(my_own_spaces_hist,filename='./Output/'+savename+'.pdf')
	plot_barchart(my_own_spaces_hist,filename='./Output/'+savename+'_average.pdf',average=True)
	hist_dict[savename] = my_own_spaces_hist
	pickle.dump(my_own_spaces_hist,open('./Hist/'+savename+'.p',"wb"))
	
	area_list[xml_name] = total_area

print "TOTALI"
plot_barchart(spaces_hist,filename='./Output/'+'all.pdf')
plot_barchart(spaces_hist,filename='./Output/'+'all_average.pdf',average=True)
pickle.dump(spaces_hist,open('./files/average_hist.p','wb'))
print sum([spaces_hist[i] for i in spaces_hist.keys()])
for i in hist_dict.keys() :
	plot_multibarchart(spaces_hist,hist_dict[i],filename = './Output/'+i+"_compared_average.pdf",average=True)


pickle.dump(area_list,open('./files/real_area.p','wb'))
print big_spaces_areas
plot_bar_area(big_spaces_areas,'area.pdf')
print 'numero di pixel', pixel_list

# SALVO LE AREE
values = np.array([ np.mean(np.array(big_spaces_areas[i])) for i in big_spaces_areas.keys()])
std_err = np.array([ np.std(np.array(big_spaces_areas[i])) for i in big_spaces_areas.keys()])
areas_dictionary = {}
for i in xrange(len(big_spaces_areas.keys())):
	areas_dictionary[big_spaces_areas.keys()[i]] = (values[i],std_err[i])
pickle.dump(areas_dictionary,open('./files/space_areas.p',"wb"))

