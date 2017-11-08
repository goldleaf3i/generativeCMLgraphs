# -*- coding: utf-8 -*-
'''
Legge i file XML ottenuto originariamente e plotta tutto
'''
from __future__ import division
from matplotlib.path import Path
import matplotlib.patches as patches
import sys
import matplotlib.colors as colors
import numpy as np
import math
import matplotlib.pyplot as plt
from igraph import *
import matplotlib.path as mplPath
from shapely.geometry import Polygon
from descartes import PolygonPatch
from shapely.geometry import Point
import random
import networkx as nx
from itertools import cycle
import cv2
import matplotlib.image as mpimg
from sklearn.cluster import DBSCAN
from scipy.spatial import ConvexHull
from shapely.ops import cascaded_union
import xml.etree.ElementTree as ET
import glob
from utils import *


def plot_XML(xml_file, letters, save_results=True, with_area = False) :
	print xml_file
	ones_spaces = []
	xml_name = xml_file.split('/')[-1]
	print xml_name
	if with_area:
		savename ='./dataset/plot/area/'+xml_name.split('.')[0]+'_AREA.pdf'	
	else :
		savename ='./dataset/plot/'+xml_name.split('.')[0]+'.pdf'

	nome_gt = xml_file

	tree = ET.parse(nome_gt)
	root = tree.getroot()

	ids = []
	stanze_gt = []
	stanze_pt = []
	#spaces = stanze nell'xml
	spaces = root.findall('.//space')
	centroids = []
	portals = []
	colors ={}
	areas =[]
	areas_dict={}
	for space in spaces: #per ogni stanza
		s_id =str(space.get('id'))
		ids.append(s_id)
		pol = space.find('.//bounding_polygon')
		punti = []
		
		# leggo la geometria della stanza 
		cen = space.find('.//centroid')
		p = cen.find('.//point')
		x = int(p.get('x'))
		y = int(p.get('y'))
		centroids.append((x,y))
		#ogni punto del bounding_polygon lo salvo nella lista punti
		for p in pol.findall('./point'):
			x = int(p.get('x'))
			y = int(p.get('y'))
			punti.append((x,y))
		punti.append(punti[0])
		
		stanze_gt.append(punti)

        # leggo le porte
		sr = space.find('.//space_representation')
		for ls in sr.findall('./linesegment') :
			ls_class = ls.find('./class').text
			if ls_class == 'PORTAL':
				p = ls.find('.//point')
				x = int(p.get('x'))
				y = int(p.get('y'))
				portals.append((x,y))

		# leggo le label 
		lb = space.find('.//labels')
		lab = lb.find('.//label').text
		colors[s_id]=letters[lab]['color']

		#leggo le features
		ft = space.find('./features')
		area =ft.find('./area').get('value')
		areas.append(area)
		areas_dict[s_id]=area







	#----------------PLOTTO LAYOUT STANZE GROUND TRUTH------------------------

	#recupero coordinate massime e minime dell'edificio utili nel plotting
	xs = []
	ys = []
	for punto in root.findall('*//point'):
		xs.append(int(punto.get('x')))
		ys.append(int(punto.get('y')))
	xmin_gt = min(xs)
	xmax_gt = max(xs)
	ymin_gt = min(ys)
	ymax_gt = max(ys)


	fig = plt.figure()
	plt.title('stanze_gt')
	ax = fig.add_subplot(111)
	for index,s in enumerate(stanze_gt):
		#col = random.choice(colors)

		x,y = zip(*s)
		ax.plot(x,y, linestyle='-', color='k', linewidth=1)

		#ax.add_patch(f_patch)
	ax.set_xlim(xmin_gt-10,xmax_gt+10)
	ax.set_ylim(ymin_gt-10,ymax_gt+10)



	#---------TROVO CONNESSIONI-----------------------------------

	#id_connessi è una lista i cui elementi sono coppie di id connessi da porte
	id_connessi = []
	for space in spaces:
		porte = space.findall('.//portal')
		for porta in porte:
			connessioni_porta = []
			for i in porta.findall('.//id'):
				connessioni_porta.append(i.text)
			id_connessi.append(connessioni_porta)


	#---------CREO GRAFO TOPOLOGICO-----------------------------

	G=nx.Graph()
	for i in ids:
		G.add_node(i)

	G.add_edges_from(id_connessi)

	pos = {ids[0]: centroids[0]}
	for i,l in enumerate(ids[1:]):
		pos[l] = (centroids[i+1])


	#---------PLOTTO GRAFO SOPRA AL LAYOUT----------------
	'''
	#plotto archi del grafo
	for coppia in id_connessi:
		i1 = ids.index(coppia[0])
		i2 = ids.index(coppia[1])
		p1 = centroids[i1]
		p2 = centroids[i2]
		ax.plot([p1[0],p2[0]],[p1[1],p2[1]],color='k',ls = 'dotted', lw=0.5)
	'''

	#plotto nodi del 
	nodi = G.nodes()
	colors = [colors[i] for i in nodi]
	nx.draw_networkx_nodes(G,pos,node_color=colors)
	nx.draw_networkx_edges(G,pos,width=1.0,alpha=0.5)
	# plotto le porte
	x,y = zip(*portals)
	ax.plot(x, y, 'ro')

	if with_area:
		nx.draw_networkx_labels(G,pos,areas_dict,font_size=16)

	if save_results:
		fig.savefig(savename,bbox_inches='tight')
	else :
		plt.show()


def all() :
	# carico le label ordinate per label e pere numero (letters e numebers rispettivamente)
	(letters,numbers) = get_label_dict()
	#----------CREO STANZE GROUND TRUTH ------------------
	for xml_file in glob.glob('dataset/XML/*.xml'):
		plot_XML(xml_file,letters,True,False)

def one() :
		# carico le label ordinate per label e pere numero (letters e numebers rispettivamente)
	(letters,numbers) = get_label_dict()
	#----------CREO STANZE GROUND TRUTH ------------------
	for xml_file in glob.glob('dataset/XML/*.xml'):
		plot_XML(xml_file,letters,False,True)
		exit()

if __name__ == '__main__':
    all()
    #one()
    #all()