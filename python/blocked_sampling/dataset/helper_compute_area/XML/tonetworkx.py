import xml.etree.ElementTree as ET
import matplotlib.pyplot as plt
import matplotlib.colors as pltcol
#from scipy.misc import imread
import matplotlib.cbook as cbook
import numpy as np
import math
import cmath
import glob
import pickle

import networkx as nx 

from SRLutils import *

### COSA FA: CARICA I RISULTATI DEL CLUSTERING DALLA CARTELLA CLUSTERLOGS (COME VIENE SALVATA DA MATLAB) E LA INSERISCE NEGLI XML


#functional_labels=["CONFERENCE ROOM","CUBICLE","OFFICE","SHARED OFFICE","EXECUTIVE OFFICE","CONFERENCE HALL","OPENSPACE","SMALL","MEDIUM","CLASSROOM","LAB"]s
# CHECK I TODO 

def find_area (array):
	a = 0
	ox,oy = array[0]
	for x,y in array[1:]:
		a += (x*oy-y*ox)
		ox,oy = x,y
	return abs(a/2)

def find_perimeter (array):
	p = 0
	ox,oy = array[0]
	for x,y in array[1:]:
		p += points_distance(ox,oy,x,y)
		ox,oy = x,y
	return p

def find_centroid (array):
	c=[0,0]
	ox,oy = array[0]
	sumx=0
	sumy=0
	for x,y in array[1:]:
		sumx += (ox+x)*((ox*y)-(x*oy))
		sumy += (oy+y)*((ox*y)-(x*oy))
		ox,oy = x,y
	area = find_area(array)
	c[0]=((1/(6*area))*sumx)
	c[1]=((1/(6*area))*sumy)
	return c

def dist_centr_bound(c,array):
	val = []
	cx,cy = c
	for x,y in array[1:]:
		val += [points_distance(cx,cy,x,y)]
	return val

def normalize_array(array):
	maxval = np.amax(array)
	for i in range(len(array)):
		array[i] = array[i]/maxval
	return array
	
def points_distance (x1,y1,x2,y2):
	return math.sqrt((x1-x2)**2+(y1-y2)**2)

def indent(elem, level=0):
  i = "\n" + level*"  "
  if len(elem):
    if not elem.text or not elem.text.strip():
      elem.text = i + "  "
    if not elem.tail or not elem.tail.strip():
      elem.tail = i
    for elem in elem:
      indent(elem, level+1)
    if not elem.tail or not elem.tail.strip():
      elem.tail = i
  else:
    if level and (not elem.tail or not elem.tail.strip()):
      elem.tail = i



data_name = 'school'
#functional_labels = get_labels_reverse_dict(get_label_dict(data_name),'function','R')
for xml_file in glob.glob('dataset/*.xml'):
	print xml_file
	xml_name = xml_file.split('/')[-1]
	print xml_name
	tree = ET.parse(xml_file)
	root = tree.getroot()
	floor = root.find('floor')
	spaces = floor.find('spaces')
	pixels = int(root.find('scale').find('represented_distance').find('value').text)

	# Mi serve per numerare gli space
	i = 0
	translator = dict()
	for r in spaces.iter('space') :
		translator[i] = r.get('id')
		i += 1
	print translator 

	G = nx.Graph()
	nSpaces = i
	adj_matrix = np.zeros([nSpaces, nSpaces])	
	labels_dict = dict()
	typeRC_dict = dict()
	portal_list = list()
	for space in spaces.iter('space'):
		ID = space.get('id')
		label = space.find('labels').find('label').text
		typeRC = space.find('labels').find('type').text
		labels_dict[ID]=label
		typeRC_dict[ID]=typeRC

		G.add_node(ID)
		G.node[ID]['label']=label
		G.node[ID]['type']=typeRC

		portals = space.find('portals')
		space_id = space.get('id')
		for portal in portals.iter('portal') :
			portal_list.append(tuple([i.text for i in portal.find('target').findall('id')]))

	# Remove double edges - undirected graph
	tmp_portal_list = list()
	for portal in portal_list :
		if not (portal[1],portal[0]) in tmp_portal_list:
			tmp_portal_list.append(portal)
	portal_list = tmp_portal_list
	G.add_edges_from(portal_list)
	#print G.nodes(data=True)
	#print G.edges()
	#nx.draw(G)
	#plt.show()
	pickle.dump(G,open("networkx/"+xml_file.split('/')[-1].split('.')[0]+".p","wb"))
