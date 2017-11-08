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
mylabelschema = 'office.xml'
#for i in matrix: 
#M.append( [int(j) for j in i.split(',')[:-1] +[i.split(',')[-1].split('\')[0]]])  
def parseEverything(direct) :
    global mylabelschema
    for filename in glob.glob(direct+"/*.xml") :
        #try :
        print("apro il file " , filename)
        loadXML(filename,mylabelschema)
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
        matrix.append([int(i)for i in line.split(',')])
    myfile.close()
    topologicalmap = importFromMatlabJava2012FormatToIgraph(matrix)
    graph = topologicalmap.graph
    print(".".join(filename.split(".")[:-1])+  ".png")
    print(graph.vs["label"])
    #print graph.vs["label"]
    #exit()
    vertex_shape = ['rect' if i =='C' or i =='H' or i == 'L' or i=='E' or i=='N' or i=='Q' else 'circle' for i in graph.vs["label"]]
    #print vertex_shape
    #exit()
    plot(graph,".".join(filename.split(".")[:-1])+".png",vertex_label_size = 0, vertex_shape = vertex_shape,bbox=(700,700),layout='kk')

# #for i in matrix: 
# #M.append( [int(j) for j in i.split(',')[:-1] +[i.split(',')[-1].split('\')[0]]])  
# def parseEverything(direct) :

# 	for filename in glob.glob(direct+"/*") :
# 		#try :
# 			print "apro il file " , filename 
# 			plotAdiacency(filename)
# 		#except Exception as e: 
# 		#	print str(e)
# 		#	print "cannot process " , filename
# 		#	exit()
# 	for directories in glob.glob(direct+"/*/") :
# 		parseEverything(directories)
# 		print "apro la cartella " , directories 
# 	return True 

# def plotAdiacency(filename) :
# 	myfile = open(filename);
# 	#inizializzo la struttura dati	
# 	matrix = []
# 	for line in myfile:
# 		matrix.append([int(i)for i in line.split(',')])
# 	myfile.close()
# 	topologicalmap = importFromMatlabJava2012FormatToIgraph(matrix)
# 	graph = topologicalmap.graph
# 	print ".".join(filename.split(".")[:-1])+  ".png"
# 	#print graph.vs["label"]
# 	#exit()
# 	vertex_shape = ['rect' if i =='C' or i =='H' or i == 'E' else 'circle' for i in graph.vs["label"]]
# 	#print vertex_shape
# 	#exit()
# 	plot(graph,".".join(filename.split(".")[:-1])+".png",vertex_label_size = 0, vertex_shape = vertex_shape)

def evaluateGraphs(direct, myformat = None ) :
    # calcola tutte le metriche di igraph e poi le stampa
    graphStats = dict()
    metrics = ['nodes','R','C','path_len','diameter','density','articulation_points','betweenness',
               'mu_betweenness','scaled_betweenness','mu_scaled_betweenness','Rbetweenness','mu_Rbetweenness',
               'Cbetweenness','mu_Cbetweenness','closeness','mu_closeness','Rcloseness','mu_Rcloseness',
               'Ccloseness','mu_Ccloseness','eig','mu_eig','Reig', 'mu_Reig','Ceig','mu_Ceig'
               ]
    for filename in glob.glob(direct+"/*.txt") :
        #try :
        print("apro il file " , filename)
        graphStats[filename] = analyzeGraph(filename, myformat)
    #except Exception as e:
    #	print str(e)
    #	print "cannot process " , filename
    #	exit()

    data = aggrateMetrics(graphStats,metrics)
    if data :
        text_file = open(direct+"/aggregate_graph_data.log", "w")
        text_file.write(str(data))
        text_file.close()


    for directories in glob.glob(direct+"/*/") :
        evaluateGraphs(directories, myformat=myformat)
        print("apro la cartella " , directories)
    return True

def analyzeGraph(filename, myformat = 'adjacency') :
    # format: adjacency e' la matrice di 0 e 1, valori spaziati da "," e righe termiante da ; DEFAULT
    # il formato matlab e' quello invece ce usa matlab per fare le matrici

    myfile = open(filename);
    #inizializzo la struttura dati
    matrix = []
    for line in myfile:
        print(line)
        if myformat == 'matlab' :
            line = line.replace('[','')
            line = line.replace(']','')
            line = line.replace(';','')
            print(line)
        matrix.append([int(i)for i in line.split(',')])
    myfile.close()
    topologicalmap = importFromMatlabJava2012FormatToIgraph(matrix)
    g = topologicalmap.graph
    Cs = g.vs.select(RC_label = 'C')
    Rs = g.vs.select(RC_label = 'R')
    indexC = [i.index for i in Cs]
    indexR = [i.index for i in Rs]
    data = dict()
    # numero di nodi
    data['nodes'] = len(g.vs())
    # numero di R
    data['R'] = len(indexR)
    # numero di C
    data['C'] = len(indexC)
    # average path len
    data['path_len'] = g.average_path_length()
    # diametro
    data['diameter'] = g.diameter()
    # average degree (densirt)
    data['density'] = g.density()
    # articulation points, quanti sono
    data['articulation_points'] = len(g.articulation_points())
    # betweenness
    betweenness =  g.betweenness()
    data['betweenness'] = betweenness
    # mean betweenness
    data['mu_betweenness'] = avg(betweenness)
    # scaled betweenness
    scaled_b = [ float(i)/(float(len(betweenness)-1))/(float(len(betweenness))-2) for i in betweenness ]
    data['scaled_betweenness'] = scaled_b
    # mean scaled betweenness
    data['mu_scaled_betweenness'] = avg(scaled_b)
    # betweenness scaled solo R
    data['Rbetweenness'] = selectLabelArray(scaled_b,indexR)
    # average betweennes scaled solo R
    print(data['Rbetweenness'])
    data['mu_Rbetweenness'] = avg(data['Rbetweenness'])
    # betweenness scaled solo C
    data['Cbetweenness'] = selectLabelArray(scaled_b,indexC)
    # average betwenness scaled solo C
    data['mu_Cbetweenness'] = avg(data['Cbetweenness'])
    # closenesss
    closeness = g.closeness()
    data['closeness'] = closeness
    # average closeness
    data['mu_closeness'] = avg(closeness)
    # closeness solo R
    data['Rcloseness'] = selectLabelArray(closeness,indexR)
    # avg closeness solo R
    data['mu_Rcloseness'] = avg(data['Rcloseness'])
    # closeness solo C
    data['Ccloseness'] = selectLabelArray(closeness,indexC)
    # avg closeness solo C
    data['mu_Ccloseness'] = avg(data['Ccloseness'])
    # eigenvector centrality
    eigenvec = g.eigenvector_centrality()
    data['eig'] = eigenvec
    # mean eig
    data['mu_eig'] = avg(eigenvec)
    # eigenvec centrality R
    data['Reig'] = selectLabelArray(eigenvec,indexR)
    # mean eigenvec centrality R
    data['mu_Reig'] = avg(data['Reig'])
    # eigenvec centrality C
    data['Ceig'] = selectLabelArray(eigenvec,indexC)
    # mean eigenvec centrality C
    data['mu_Ceig'] = avg(data['Ceig'])

    #print ".".join(filename.split(".")[:-1])+  ".png"
    #plot(graph,".".join(filename.split(".")[:-1])+".png")
    stringa = str()
    for i in data.keys():
        stringa+= str(i) + ":\n"
        stringa+= str(data[i]) + "\n"
    text_file = open(".".join(filename.split(".")[:-1])+"_aggregate_data.log", "w")
    text_file.write(str(stringa))
    text_file.close()
    return data

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
#try:
#    current = argv[1]
#except :
#    print("non hai specificato la cartella corrente")
#print("inizio a parsare la cartella ", current , 'che diavleria e ques?')
#parseEverything(current)
#print("finito!")

count = 0
btypename = 'zoffice.xml'
#btypename = 'zoffice.xml'
for filename in glob.glob(current+"/*.xml"):
    count+=1
    print filename
    # LOADXML carica i TOPOLOGICAL. LOAD XML2 carica i XML standard
    if not btypename in filename :
        matrix = loadXML2(filename, btypename)
        Math.savetxt("graph_"+str(count)+".csv", matrix, fmt='%s', delimiter=",")
print "done"