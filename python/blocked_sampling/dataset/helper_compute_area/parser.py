import xml.etree.ElementTree as ET
import matplotlib.pyplot as plt
import matplotlib.colors as pltcol
#from scipy.misc import imread
import matplotlib.cbook as cbook
import numpy as np
import math
import cmath
import glob

from igraph import *

from SRLutils import *

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
	if area == 0 :
		return (0,0)
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

###ADDING FEATURES###

withCentrality = True
data_name  = 'school'
functional_labels = get_labels_reverse_dict(get_label_dict(data_name),'function','R')
areasnegative = 0
for xml_file in glob.glob('XML/*.xml'):
	print xml_file
	xml_name = xml_file[4:]
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
		translator[r.get('id')] = i
		i += 1

	nSpaces = i
	adj_matrix = np.zeros([nSpaces, nSpaces])	

	for space in spaces.iter('space'):
		points = []
		area = 0
		perimeter = 0
		DCS = []
		for point in space.find('bounding_polygon').findall('point'):
			points += [[int(point.get('x'))/pixels,int(point.get('y'))/pixels]]
		centxml = space.find('centroid').find('point')
		cent = [int(centxml.get('x'))/pixels,int(centxml.get('y'))/pixels]
		cent = find_centroid (points)
		area = find_area (points)

		if area == 0 :
			area = -1
			areasnegative+=1

		features_xml = ET.SubElement(space, 'features')

		area_xml = ET.SubElement(features_xml,'area')
		
		area_xml.set('value', str(area))

		if area != -1 :
			'''
			Questo se ci sono dei nodi errati come spaces, non computo i loro dati. Aggiungo solo l'area a -1
			'''
			perimeter = find_perimeter (points)
			DCS = dist_centr_bound(cent,points)
				
	

			perimeter_xml = ET.SubElement(features_xml,'perimeter')
			perimeter_xml.set('value', str(perimeter))

			f3_xml = ET.SubElement(features_xml,'aoverp')
			f3_xml.set('value', str(area/perimeter))

			f4_xml = ET.SubElement(features_xml,'adcs')
			f4_xml.set('value', str(np.mean(DCS)))

			f5_xml = ET.SubElement(features_xml,'Standard_Deviation_Dist_Cent-Shape')
			f5_xml.set('value', str(np.std(DCS)))

			f12_xml = ET.SubElement(features_xml,'ff')
			f12_xml.set('value', str(4*math.pi*area/math.sqrt(perimeter)))

			f13_xml = ET.SubElement(features_xml,'circularity')
			f13_xml.set('value', str(perimeter**2/area))

			f14_xml = ET.SubElement(features_xml,'normalcirc')
			f14_xml.set('value', str(4*math.pi*area/perimeter**2))

			f15_xml = ET.SubElement(features_xml,'andcs')
			f15_xml.set('value', str(np.mean(normalize_array(DCS))))

			f16_xml = ET.SubElement(features_xml,'Standard_Deviation_Dist_Cent-Shape')
			f16_xml.set('value', str(np.std(normalize_array(DCS))))

		portals = space.find('portals')
		space_id = space.get('id')
		for portal in portals.iter('portal') :
			tmp = tuple([i.text for i in portal.find('target').findall('id')])

			if tmp[1] != space_id :
				adj_matrix[translator[space_id]][translator[tmp[1]]] = 1
			elif tmp[0] != space_id :
				adj_matrix[translator[space_id]][translator[tmp[0]]] = 1
			else :
				print 'error!'
				exit()

	graph = Graph.Adjacency(adj_matrix.tolist(), mode=ADJ_UNDIRECTED)
	graph.vs["bs"] = graph.betweenness()
	graph.vs["cs"] = graph.closeness()

		
	for space in spaces.iter('space'):

		features_xml = space.find('features')

		# Calcolo e salvo la betweenness e la closeness
		f17_xml = ET.SubElement(features_xml,'betweenness')
		f17_xml.set('value', str(float(graph.vs[translator[space.get('id')]]["bs"])/((nSpaces-1)*(nSpaces-2))))
		f18_xml = ET.SubElement(features_xml,'closeness')
		f18_xml.set('value', str(graph.vs[translator[space.get('id')]]["cs"]))
		# Traduco i vicini in label


	indent(root)
	tree.write('Output/'+xml_name)

print "and in the end we removed " , areasnegative , 'rooms '
