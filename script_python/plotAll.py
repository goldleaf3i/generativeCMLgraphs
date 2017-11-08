#!/usr/bin/python

# APRE LA CARTELLA DOVE STA LO SCRIPT O, ALTERNATIVAMETNE, argv[1]. 
# PARSA TUTTE LE SOTTO CARTELLE
# PRENDE TUTTI I FILE DITESTO, CHE CONSIDERA MATRICI DI ADIACENZA DI UN GRAFO
# INSERISCE LE MATRICI TROVATE IN UN GRAFO DI IGRAPH

### COPIATO DA CARTELLA SVILUPPO DROPBOX, DA REINTEGRARE POI NEL PROGETTO ORIGINALE - FINITO 28/9/14
# IN PARTICOLARE INSERIRE NELLA LIBRERIA LE METRICHE PER STAMPARE LE VARIE CARATTERISTICHE DEI GRAFI

# TODO SPOSTARE LE FUNZIONI DI SUPPORTO IN UTILS
from sys import argv
import re
import sys
import math
from loadGraph import *
import numpy as Math
import os
import glob
from multiprocessing import Process


logsavefile = open('ploterror.log','w')
#for i in matrix: 
#M.append( [int(j) for j in i.split(',')[:-1] +[i.split(',')[-1].split('\')[0]]])  
def parseEverything(direct) :

    for filename in glob.glob(direct+"/*.txt") :
        #try :
        print("apro il file " , filename)
        plotAdiacency(filename)
    #except Exception as e:
    #	print str(e)
    #	print "cannot process " , filename
    #	exit()
    p = []
    i = 0
    for directories in glob.glob(direct+"/*/") :
        #p.append(Process(target = parseEverything, args =(directories,)))
        parseEverything(directories)
        #p[i].start()
        i+=1
        print("apro la cartella " , directories)

    #for j in range(i-1) :
    #	p[j].join()
    return True

def plotAdiacency(filename) :
    myfile = open(filename);
    #inizializzo la struttura dati
    matrix = []
    for line in myfile:
        #print line
        if line == 'E,R,R,O,R,E\n' :
            print >>logsavefile ,".".join(filename.split(".")[:-1])+".txt"
            return
        matrix.append([int(i)for i in line.split(',')])
    myfile.close()
    topologicalmap = importFromMatlabJava2012FormatToIgraph(matrix)
    graph = topologicalmap.graph
    print(".".join(filename.split(".")[:-1])+  ".pdf")
    print(graph.vs["label"])
    #print graph.vs["label"]
    #exit()
    vertex_shape = ['rect' if i =='C' or i =='H' or i == 'L' or i=='E' or i=='N' or i=='Q' else 'circle' for i in graph.vs["label"]]
    #print vertex_shape
    #exit()
    plot(graph,".".join(filename.split(".")[:-1])+".pdf",vertex_label_size = 0, vertex_shape = vertex_shape,bbox=(700,700),layout='kk')

def selectLabelArray(array,indexes) :
    # restituisce gli elementi del vettore array di indice contenuto in indexes
    tmp = []
    for i in indexes :
        tmp.append(array[i])
    return tmp

def averageLabel(array,indexes):
    # restituisce la media degli elementi del vettore array di indice contenuto in indexes
    tmp = []
    for i in indexes :
        tmp.append(array[i])
    return sum(tmp)/float(len(indexes))

def avg(array) :
    return sum(array)/float(len(array))

def aggrateMetrics(dictionary,list_of_metrics) :
    # per ora non calcolo dati aggregati sugli array
    # prende un array di array e poi ricalcola tutto
    mydict = dict()
    # inizializzo le variabili
    for i in list_of_metrics :
        mydict[i] = variable(i)
    # per ogni grafo parso il dizionario e lo inserisco nelle variabili
    for i in dictionary.keys() :
        for j in dictionary[i].keys() :
            if type(dictionary[i][j]) is list :
                # per ora non calcolo dati aggregati sugli array.
                pass
            else :
                mydict[j].add(dictionary[i][j])
    ret_str = str()
    for i in list_of_metrics :
        if mydict[i].n > 0 :
            ret_str += mydict[i].printVar()
    return ret_str

# apre ricorsivamente tutti i file di TXT che ci trova. usa la cartella corrente, se non specifichi una cartella di start alternativa
current = os.getcwd()
try:
    current = argv[1]
except :
    print("non hai specificato la cartella corrente")
print("inizio a parsare la cartella ", current , 'che diavleria e ques?')
parseEverything(current)
print("finito!")
logsavefile.close()
'''
count = 0
for filename in glob.glob(current+"/*.xml"):
    count+=1
    matrix = loadXML2(filename, 'z.xml')
    print(filename)

    Math.savetxt("graph_"+str(count)+".csv", matrix, fmt='%s', delimiter=",")'''
    