import xml.etree.ElementTree as ET
import matplotlib.pyplot as plt
import numpy as np
import math
import cmath
import glob
import pickle
import datetime as dt 

import networkx as nx 


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



for xml_file in glob.glob('dataset/*.xml'):
	print xml_file
	xml_name = xml_file.split('/')[-1]
	print xml_name
	tree = ET.parse(xml_file)
	root = tree.getroot()
	floor = root.find('floor')
	spaces = floor.find('spaces')
	pixels = int(root.find('scale').find('represented_distance').find('value').text)

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
