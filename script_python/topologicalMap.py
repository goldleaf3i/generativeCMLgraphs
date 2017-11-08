#!/usr/bin/python

# COPIATO DA CARTELLLA DI SVILUPPO 15/9/14

from sys import argv
import re
import sys
import math
import numpy as np
import copy
from igraph import *
from matplotlib import pyplot
import networkx as nx
from shapely.geometry import *
from descartes.patch import PolygonPatch
from utils import *
from myDictionaries import *
import uuid
import xml.dom.minidom

def loadAdiacencyMatlabToTopological(matrix, labels_dict, labelsRC_dict=None, colors=None):
    # parametri: una matrice di adiacenza, un dizionario per convertire in label il valore numerico della diagonale
    # un dizionario per convertire le label appena ottenute in R o C e un dizionario dei colori delle label
    m = matrix
    rows = len(matrix)
    columns = len(matrix[0])
    node_id_list = [str(i) for i in range(rows)]
    labels = []
    labelRC = []
    edge_list = []
    special_edge = []
    for i in range(rows):
        for j in range(columns):
            if i == j:
                labels.append(labels_dict[m[i][j]])
                if labelsRC_dict:
                    labelRC.append(labelsRC_dict(labels_dict[m[i][j]]))
            else:
                if m[i][j] == 1:
                    edge_list.append(( i, j))
                if m[i][j] == 2:
                    special_edge.append((i, j))

    if labelRC:
        topological_map = topologicalMap(node_id_list, labels, labelsRC, edge_list, colors)
    else:
        topological_map = topologicalMap(node_id_list, labels, edge_list=edge_list, colors=colors)
        # if special_edge != [] :
    #   topological_map.add_special_edge_list(special_edge)
    return topological_map


def importFromMatlabJava2012FormatToIgraph(matrix, RC=False, nolabel=False):
    # funzione che prende una matrice di adiacenza fatta usando come dati i miei di del 2012 e poi li importa in importFromMatlabJava2012FormatToIgraph
    # Se RC e' True passo anche le variabili bipartite R-C oltre che le altre variabili.
    # se nolabel e' true sostituisco alle label R o C (3 o 100) a seconda del degree.
    if nolabel:
        rows = len(matrix)
        for i in range(rows):
            for j in range(rows):
                tmp = sum(matrix[i])
                if tmp >= 3:
                    matrix[i][i] = labels_java2012toMatlab_Dict['C']
                else:
                    matrix[i][i] = labels_java2012toMatlab_Dict['M']

    reverse_java_matrix_dict = dict()
    labels = labels_java2012toMatlab_Dict
    for i in labels.keys():
        reverse_java_matrix_dict[labels[i]] = i
    if RC:
        mygraph = loadAdiacencyMatlabToTopological(matrix, reverse_java_matrix_dict, labels_RC_java2012,
                                                   Java2012_colorDict)
    else:
        mygraph = loadAdiacencyMatlabToTopological(matrix, reverse_java_matrix_dict, colors=Java2012_colorDict)
    return mygraph


class topologicalMap(object) :
    def __init__(self, node_id_list = None, label_list = None, label_RC_list = None, edge_list=None, colors = None) :
        # se ho una lista di iid, aggiungo questi. altrimenti aggiungo len(label_list) nodi un numero progressivo come id.
        # edge_list e' un array di tuple [ (id1, id2), (id2,id4) ] con id dei nodi.
        # se e' tutto none aspetto l'inizializzazione
        # colors e un dizionario di colori. se non lo ho, ho fatto la funzione!
        #
        #def add_node(self,iid,label,RC=None):
        self.init = False
        self.nodes = dict()
        self.labels = dict()
        self.RCs = dict()
        self.edges = dict()
        # numero di nodi aggiunti
        self.count = -1
        self.colors = colors

        # se mi passano tutti i nodi gia con init, aggiungo tutto qui
        if node_id_list and label_list:
            # errore di inizializzazione
            if not edge_list  or len(label_list) != len(node_id_list)  :
                exit("Error: wrong topological map initialization")
            # aggiungo nodi e label uno a uno, ho l'iid di ciascun nodo.
            if not label_RC_list or len(label_RC_list) != len(label_list) :
                for i in range(len(node_id_list)) :
                    self.add_node(node_id_list[i], label_list[i])
            else :
                for i in range(len(node_id_list)) :
                    self.add_node(node_id_list[i], label_list[i],label_RC_list)
            self.add_edge_list(edge_list)
            self.graph = self.createGraph()

        elif label_list :
            # non ho l'id dei nodi, ho solo la lista.  aggiungo tutto batch
            if not edge_list :
                exit("Error: wrong topological map initialization")
            self.add_node_list(label_list)
            #aggiungo i nodi
            self.add_edge_list(edge_list)
            self.graph = self.createGraph()

    def createGraph(self):
        # Crea il grafo con igraph.
        # TODO CHECK SE VA
        if self.init :
            return self.graph
        self.graph = Graph()
        if self.count != len(self.nodes)-1 :
            print(self.count, len(self.nodes), self.nodes)
            exit("error, count and node list don't match")
        self.graph.add_vertices(self.count+1)

        self.edgelist = []

        for i in range(self.count) :
            for j in self.edges[str(i)] :
                if not (int(i), int(j)) in self.edgelist and not (int(j), int(i)) in self.edgelist :
                    self.edgelist.append( (int(i),int(j)) )
        print(self.edgelist)
        print(self.graph)
        self.graph.add_edges(self.edgelist)


        labels = [ self.labels[str(i)] for i in range(self.count+1) ]
        RC_label = [self.RCs[str(i)] for i in range(self.count+1)]
        self.graph.vs["room_label"]=labels
        self.graph.vs["label"]=self.graph.vs["room_label"]
        self.graph.vs["RC_label"]=RC_label

        # se non ho i colori, creo una paletta di colori
        if not self.colors :
            tmp_label_list = set(self.labels.values())
            self.colors = createColorDict(tmp_label_list)

        graphcolors = [self.colors[label] for label in self.graph.vs["label"]]
        self.graph.vs["color"] = graphcolors
        self.layout = self.graph.layout("kamada_kawai")
        self.init = True

        A = self.graph.get_edgelist()
        self.gx = nx.Graph(A)


        return self.graph

    def plotIGraph(self,filename) :
        if self.graph :
            plot(self.graph ,str(filename)+".pdf",layout=layout)
        else :
            print("No Graph yet! You have to create the graph first.")

    def plotMatplotlib(self,ax) :
        # todo check
        # questa stampa la funzione
        # ma non la salva, perche' stampa i subplot

        nodes_poses = []

        for i in range(self.count) :
            nodes_poses.append(self.layout[i])
        x,y = zip(*nodes_poses)

        if not self.colors :
            tmp_label_list = set(self.labels.values())
            self.colors = createColorDict(tmp_label_list)

        labels = [ self.labels[str(i)] for i in range(self.count) ]
        graphcolors = [self.colors[label] for label in labels]


        for j in edgelist :
            x1 = x[j[0]]
            x2 = x[j[1]]
            y1 = y[j[0]]
            y2 = y[j[1]]
            ax.plot([x1,x2],[y1,y2],"k-")
        for j in range(self.count) :
            ax.plot(x[j], y[j],'o', color= graphcolors[j])

        ax.grid(True)
        return True

    def add_node(self,iid,label,RC=None):
        # un nodo come lo definisco?
        if iid in self.nodes.keys() :
            exit("error, added twice the same room")
        self.count += 1
        self.nodes[iid] = self.count
        self.edges[str(self.count)] = []
        self.labels[str(self.count)] = label
        if RC :
            self.RCs[str(self.count)] = RC
        else :
            self.RCs[str(self.count)] = labels_RC_java2012[str(label)]

    def add_node_list(self,labels):
        # funzione che inizializza senza iid o cose simili, solo con un elenco di labels.
        # per passargli una struttura dati semplice.
        self.nodes = dict()
        for l in labels :
            self.count += 1
            self.nodes[str(self.count)] = self.count
            self.edges[str(self.count)] = []
            self.labels[str(self.count)] = l
            self.RCs[str(self.count)] = labels_RC_java2012[str(l)]

    def add_edge(self, id1, id2):
        # i due parametri sono l'iid dei due nodi.
        if not id1 in self.nodes.keys() or not id2 in self.nodes.keys() :
            print(id1, id2, self.nodes.keys())
            exit("error, missing ids")
        index1 = self.nodes[str(id1)]
        index2 = self.nodes[str(id2)]
        if not index2 in self.edges[str(index1)]  :
            self.edges[str(index1)].append(index2)
        if not index1 in self.edges[str(index2)]  :
            self.edges[str(index2)].append(index1)

    def add_edge_list(self,edge_list):
        # parametro: una lista di tuple [(iid1,iid2),(iid3,iid4)]
        for i in edge_list:
            self.add_edge(str(i[0]),str(i[1]))

    def add_special_edge_list(self,special_edge_list) :

        for i in edge_list:
            self.add_edge(str(i[0]),str(i[1]))
        len_es = len(self.graph.es)
        added = []
        new_edges = []
        for i in special_edge_list :
            if not (i[1],i[0]) in added :
                added += [ (i[0],i[1]) ]
        for i,j in added :
            if not (int(i), int(j)) in self.edgelist and not (int(j), int(i)) in self.edgelist :
                self.new_edges.append( (int(i),int(j)) )
        print(self.edgelist)
        print(self.graph)
        self.graph.add_edges(self.edgelist)
        self.graph.es["color"] = ["black" if edge.index >= len_es else "red" for edge in g.es]

    # deve essere un oggetto piu agile di building (e che building ha)
    # contiene una mappa di igraph (di cui chiama le funzioni) e ha poche info. la si istanzia come una mappa di igraph (lista di vertici e di nodi)
    # e la si puo' salvare come XML o come lista di vertici e nodi.