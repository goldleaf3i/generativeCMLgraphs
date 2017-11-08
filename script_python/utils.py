#!/usr/bin/python

#COPIATO DA CARTELLLA DI SVILUPPO 15/9/14

import numpy as np
from matplotlib import pyplot
from shapely.geometry import LineString
from descartes.patch import PolygonPatch
from igraph import *


#		FARE PULIZIA DEGLI IMPORT
#	OK	SPOSTARE LE COSE CHE NON SERVONO
#		TESTARE E TENERE LE COSE CHE SERVONO
#	OK	CANCELLARE LE COSE CHE NON SERVONO
#		AGGIUNGERE LE COSE CHE MANCANO



################################################# FUNZIONE CHE GESTISCONO I COLORI #################################################


def createColorDict(list_of_labels) :
	# crea un dizionario dove le chiavi sono una lista di labels, e il valore sono dei colori. Usa le colormap di matplotlib per farlo
	# qui sotto un esempio di come si estraggono dei colori dalle colormap.
	'''>>> color = np.random.random(10)
	>>> color
	array([ 0.75188924,  0.39101616,  0.76249589,  0.09931891,  0.55436453,
	        0.35272904,  0.46937771,  0.94932506,  0.01736672,  0.60044431])
	>>> aaaaa = cm.winter(color)
	>>> aaaaa
	array([[ 0.        ,  0.75294118,  0.62352941,  1.        ],
	       [ 0.        ,  0.39215686,  0.80392157,  1.        ],
	       [ 0.        ,  0.76470588,  0.61764706,  1.        ],
	       [ 0.        ,  0.09803922,  0.95098039,  1.        ],
	       [ 0.        ,  0.55294118,  0.72352941,  1.        ],
	       [ 0.        ,  0.35294118,  0.82352941,  1.        ],
	       [ 0.        ,  0.47058824,  0.76470588,  1.        ],
	       [ 0.        ,  0.95294118,  0.52352941,  1.        ],
	       [ 0.        ,  0.01568627,  0.99215686,  1.        ],
	       [ 0.        ,  0.6       ,  0.7       ,  1.        ]])
	>>> bb = cm.RdGy(color) 
	pp = [(x,0) for x in range(len(bb))]
	>>> for i in pp :
	...     ax.plot([i[0]],[i[1]], 'o',color = bb[i[0]])
	'''
	colors = dict()
	tmp_colors = getColorFromColorMap(len(list_of_labels))
	for i in range(len(list_of_labels)) :
		colors[str(list_of_labels(i))] = tmp_colors[i]
	return colors

def getColorFromColorMap(n_colors, colormap = None ):
	# prendo un numero x e un color_map name e restituisco un array di x colori appartenenti a colormap.
	# array da 1 a n_colors
	#lista dei colormaps di matplotlib. la copio qui se serve. sono i parametri accettati come "colormap"
	'''cmaps = [('Sequential',['Blues', 'BuGn', 'BuPu',
		'GnBu', 'Greens', 'Greys', 'Oranges', 'OrRd',
		'PuBu', 'PuBuGn', 'PuRd', 'Purples', 'RdPu',
		'Reds', 'YlGn', 'YlGnBu', 'YlOrBr', 'YlOrRd']),
	 ('Sequential (2)', ['afmhot', 'autumn', 'bone', 'cool', 'copper',
		'gist_heat', 'gray', 'hot', 'pink',
		'spring', 'summer', 'winter']),
	 ('Diverging',      ['BrBG', 'bwr', 'coolwarm', 'PiYG', 'PRGn', 'PuOr',
		'RdBu', 'RdGy', 'RdYlBu', 'RdYlGn', 'Spectral',
		'seismic']),
	 ('Qualitative',    ['Accent', 'Dark2', 'Paired', 'Pastel1',
	 	'Pastel2', 'Set1', 'Set2', 'Set3']),
	 ('Miscellaneous',  ['gist_earth', 'terrain', 'ocean', 'gist_stern',
		'brg', 'CMRmap', 'cubehelix',
		'gnuplot', 'gnuplot2', 'gist_ncar',
		'nipy_spectral', 'jet', 'rainbow',
		'gist_rainbow', 'hsv', 'flag', 'prism'])]'''
	tmp_array = np.array(range(n_colors))
	# se ho un colormap dato come parametro lo uso, altrimenti ne prendo a caso da un set.
	if colormap :
		t_cm = cm.get_cmap(colormap) 
	else :
		list_of_cmap = ['Accent', 'Dark2', 'Paired', 'Pastel1','Pastel2', 'Set1', 'Set2', 'Set3']
		cm_name = list_of_cmap[np.random.randint(0,len(list_of_cmap))]
		t_cm = cm.get_cmap(cm_name)
	#restituisce un numpy-array con n_colors colori.
	return t_cm(tmp_array)	

################################################# FINE FUNZIONI CHE GESTISCONO I COLORI #################################################



################################################# FUNZIONI CHE PLOTTANO DELLE COSE #################################################

def plot_room(ax, ob , color, edgecolor = 'k') :
	#TODO : SERVE?
	patch = PolygonPatch(ob, facecolor = color, edgecolor = edgecolor, alpha=0.5, zorder=2)
	ax.add_patch(patch)
	#TODO RIMUOVERE
	#x, y = ob.exterior.xy
	#ax.plot(x, y, 'o-', color = 'k')

def plot_coords(ax, ob, color = '#999999'):
	#TODO : SERVE?
	x, y = ob.xy
	ax.plot(x, y, 'o', color = color, zorder=1)

def plot_bounds(ax, ob,color= '#000000'):
	#TODO : SERVE?
	x, y = zip(*list((p.x, p.y) for p in ob.boundary))
	ax.plot(x, y, 'o', color= color, zorder=1)

def plot_line(ax, ob, removed):
	#TODO : SERVE?
	x, y = ob.xy
	ax.plot(x, y, color=COLOR[removed], alpha=0.7, linewidth=3, solid_capstyle='round', zorder=2)

################################################# FINE FUNZIONI CHE PLOTTANO #################################################


def get_cycle(graph, start = None) :
	'''
	Trova il ciclo in un grafo. Prende come parametro opzionale un nodo su cui partire.
	Altrimenti parte da il nodo con piu' connessioni.
	Restituisce il ciclo.
	Deve essere un dizionario dove la chiave e il numero del nodo, il valore e' un array che contiene i nodi connessi

	Spiegone: 
	define visit(node n):
	  if n.colour == grey: //if we're still visiting this node or its descendants
	    throw exception("Cycle found")

	  n.colour = grey //to indicate this node is being visited
	  for node child in n.children():
	    if child.colour == white: //if the child is unexplored
	      visit(child)

	  n.colour = black //to show we're done visiting this node
	  return
	'''
	maxlen = -1
	discovered = dict()
	# initialize DFS starting with the node with most connections
	for i in graph.keys() :
		discovered[i] = False
		if len(graph[i]) >= maxlen and not(start) :
			start_node = i
			maxlen = len(graph[i])
	if start :
		start_node = start
	print("startnode " , start_node , " len " , len(graph[start_node]) , " ed e' " , graph[start_node])
	print(graph)
	return  DFS_cycle_search(graph,start_node,discovered,int(start_node),None)


def DFS_cycle_search(G,V,D,init,prec) :
	'''
	Chiama DFS per trovare il ciclo in un grafo. funzione ricorsiva chiamata da get_cycle()
	'''
	value = None
	# label v as discovered
	D[V] = True
	# for all edges from v to w in G.adjacentEdges(v) do
	for i in G[V] :
		# if vertex w is not labeled as discovered then
		if not D[str(i)] :
			# recursively call DFS(G,w)
			tmp = DFS_cycle_search(G,str(i),D,init,int(V))
			if tmp :
				value = tmp
				return [V] + value
		if init == i and not prec == init :
			return [V]
	if not(value) :
		return value
	else :
		return  [V] + value

def separatePrintOut():
	print('*+' * 50)
	return

def printMatrix(M, sep = '') :
	# stampa a schermo una matrice.
	# M la matrice, sep il separatore es sep = ',' -> 3,4,5,6,7,8 
	retvalue = str()
	righe = len(M)
	colonne = len(M[0])
	print('*'*50)
	for x in xrange(colonne) :
		row = []
		temprow = str()
		for y in xrange(righe) :
			temp = str(M[x][y]) + sep
			temprow +=temp
		print(temprow)
		retvalue += temprow + "\n"
	print('*'*50)
	return retvalue


#implementa una variabile campionaria e ne calcola media e varianza;		
class variable(object):

	def __init__(self,name = None):
		self.name = name
		self.campioni = list()
		self.n = 0
		self.media  = float(0)
		self.varianza = float(0)
		self.median = 0
		self.MAD = float()
		
	def add(self, x):
		self.campioni.append(x)
		self.n += 1
		
	def getList(self):
		return self.campioni 
		
	def calcMean(self):
		self.media = 0
		for i in self.campioni:
			self.media += float(i)
		self.media /= float(self.n)
		return self.media
	
	def calcVar(self):	
		for j in self.campioni:
			self.varianza += pow(float(j) - self.media , 2)
		self.varianza /= float(self.n - 1)
		return self.varianza
		
	def calcMAD(self):
		floList = list()
		for i in self.campioni:
			floList.append(float(i))
		floList.sort()
		a = list()
		l = len(self.campioni)
		self.median = float(floList[int(l/2)])
		for i in floList:
			a.append(i-self.median if i-self.median > 0 else self.median-i)
		a.sort()
		self.MAD = a[int(l/2)]
		return self.MAD
		
	def printVar(self):
		self.calcMean()
		self.calcVar()
		self.calcMAD()
		if self.name :
			a = 'variable: ' + str(self.name) + "\n"
		else :
			a = str()
		a += "la media risulta: " + str(self.media) + " e la deviazione standard invece: " + str(math.sqrt(self.varianza)) + "\n"
		a += "la varianza invece era: " + str( self.varianza ) + "\n"
		a += "il valore mediano era invece " + str( self.median ) + " e il MAD: " + str(self.MAD) + "\n"
		return a + "questo su " + str(self.n) + " campioni\n"	
			
#implementa una variabile intera dove conteggia il numero di cose
class integerVariable(object):

	def __init__(self):
		self.conteggio = dict()
		self.probabilita = dict()
		self.n = 0
		
	def add(self, x):
		self.n+=1
		if not(self.conteggio.has_key(x)) :
			self.conteggio[x] = 1
		else :
			self.conteggio[x] += 1
		
	def calcProbability(self):
		for i in self.conteggio.keys():
			self.probabilita[i] = float(self.conteggio[i]) / float(self.n)
			
	def stampa(self):
		if self.n > 0:
			self.calcProbability()
		return str(self.probabilita)+ "\n"
