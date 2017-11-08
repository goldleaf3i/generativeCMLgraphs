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

###ADDING FEATURES###



withCentrality = True

# per ogni sottografo - il cluster cui appartiene
cluster_results = open("clusterlogs/clusteringresult.txt")
clustersubgraphdict = dict()
for c in cluster_results :
	c = c.split(' ')
	clustersubgraphdict[int(c[0])]=int(c[1])


# qui creo per ogni numero-grafo l'elenco dei sottografi
subgraphs_per_graphs = dict()
subgraphs_file = open("clusterlogs/graphsubgraphs.txt")
ctr = 1
for es in subgraphs_file:
	subgraphs_per_graphs[ctr] = [int(i) for i in es.split(' ')[:-1]]
	ctr+=1

# in graphnumbers carico un dizionario nome-file : numero-grafo
graphsnumbersfile = open("CSVs/filenamesgraphsnumber.txt")
graphsnumbers = dict()
for i in graphsnumbersfile :
	graphsnumbers[i.split(' ')[0]] = int(i.split(' ')[1])


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

	#numero incrementale del grafo
	graph_number = graphsnumbers[xml_name]

	graphlog = open('logs/graph'+str(graph_number)+'.log')
	id_number_dict = dict()
	for i in graphlog :
		tempid = i.split(' ')[0]
		id_number_dict[tempid] = int(i.split(' ')[-1])

	nodesubgraphfile = open('clusterlogs/graphcluster_'+str(graph_number)+'.txt')
	nodesubgraph = dict()
	for i in nodesubgraphfile :
		# qui ci metto per ogni INTERO della stanza il NUMERO DEL SOTTOGRAFO
		nodesubgraph[int(i.split(' ')[0])] = int(i.split(' ')[1])

	# Mi serve per numerare gli space
	i = 0
	translator = dict()
	for r in spaces.iter('space') :
		translator[r.get('id')] = i
		i += 1

	nSpaces = i
	adj_matrix = np.zeros([nSpaces, nSpaces])	

	for space in spaces.iter('space'):
		ID = space.get('id')

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
		perimeter = find_perimeter (points)
		DCS = dist_centr_bound(cent,points)
		
		features_xml = ET.SubElement(space, 'features')
		
		area_xml = ET.SubElement(features_xml,'area')
		area_xml.set('value', str(area))

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

		if ID in id_number_dict.keys(): 
			f17_xml = ET.SubElement(features_xml,'subgraph')
			space_subgraph = nodesubgraph[id_number_dict[ID]]
			f17_xml.set('value',str(space_subgraph))

			f18_xml = ET.SubElement(features_xml,'cluster')
			f18_xml.set('value',str(clustersubgraphdict[int(space_subgraph)]))
		else  :
			print "NOT FOUND" , ID , "in the graph. Check if its a removed node"


		#legacy: for plotting
		#poly = plt.Polygon(points, closed=True, fill=None, edgecolor='r')
		#plt.gca().add_patch(poly)
		
		#MISSING FEATURES:
		#For 6 7 8
		#complex_points = []
		#for e in points:
		#	complex_points.append(complex(e[0],e[1]))
		#print complex_points
		#fftarray = np.fft.fft(complex_points)	
		# 9 10 11 MISSING



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

	# print "bs", graph.vs["bs"]
	# print "cs", graph.vs["cs"]
	# layout = graph.layout("kk")
	# plot(graph, layout = layout)

		
	for space in spaces.iter('space'):

		features_xml = space.find('features')

		# Calcolo e salvo la betweenness e la closeness
		f19_xml = ET.SubElement(features_xml,'betweenness')
		f19_xml.set('value', str(float(graph.vs[translator[space.get('id')]]["bs"])/((nSpaces-1)*(nSpaces-2))))
		f20_xml = ET.SubElement(features_xml,'closeness')
		f20_xml.set('value', str(graph.vs[translator[space.get('id')]]["cs"]))
		# Traduco i vicini in label
		
	#legacy: linesegment plot for comparison
	'''for space in spaces.iter('space'):
		for lineseg in space.find('space_representation').findall('linesegment'):
			points = []
			for point in lineseg.findall('point'):
				points += [int(point.get('x'))]
				points += [int(point.get('y'))]
			line = plt.Line2D((points[0], points[2]), (points[1], points[3]), lw=0.5, markerfacecolor='b', markeredgecolor='b')
			plt.gca().add_line(line)'''




	indent(root)
	tree.write('Output/'+xml_name)