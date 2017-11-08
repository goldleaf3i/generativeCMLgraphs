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
import networkx as nx
from loadGraph import *
import os
import glob
import shutil 
import numpy as np 

blacklist = ['GrafiFinaliSegmentati','Grafi conn clust prediz','Grafi finali segm prediz','Grafi espl durante prediz']

logsavefile = open('ploterror.log','w')
#for i in matrix:
#M.append( [int(j) for j in i.split(',')[:-1] +[i.split(',')[-1].split('\')[0]]])
def parseEverything(direct) :
    if len(filter(lambda x: x in direct, blacklist)) == 0 :
        for filename in glob.glob(direct+"/*.txt") :
            print 'GrafiFinaliSegmentati' in filename 
            try :
                print("apro il file " , filename)
                plotAdiacency(filename)
            except Exception as e:
                print(str(e))
                print("cannot process " , filename)
                exit()
    for directories in glob.glob(direct+"/*/") :
        parseEverything(directories)
        print("apro la cartella " , directories)
    return True

def plotAdiacency(filename) :
    myfile = open(filename);
    #inizializzo la struttura dati
    matrix = []
    for line in myfile:
        print line
        if line == 'E,R,R,O,R,E\n' :
            print >>logsavefile ,".".join(filename.split(".")[:-1])+".txt"
            return
        matrix.append([int(i)for i in line.split(',')])
    myfile.close()
    topologicalmap = importFromMatlabJava2012FormatToIgraph(matrix)
    graph = topologicalmap.graph
    print(".".join(filename.split(".")[:-1])+  ".png")
    plot(graph,".".join(filename.split(".")[:-1])+".png")

def evaluateGraphs(direct, myformat = None ) :
    # calcola tutte le metriche di igraph e poi le stampa
    graphStats = dict()
    metrics = ['degree_assortativity','eccentricity','mu_eccentricity','Reccentricity','mu_Reccentricity','Ceccentricity','mu_Ceccentricity',
               'katz_centrality','mu_katz_centrality','Rkatz_centrality','mu_Rkatz_centrality',
               'Ckatz_centrality','mu_Ckatz_centrality',#'rich_club_coefficient','mu_rich_club_coefficient',
               'nodes','R','C',
               'path_len','diameter','density','articulation_points','betweenness',
               'mu_betweenness','scaled_betweenness','mu_scaled_betweenness','Rbetweenness','mu_Rbetweenness',
               'Cbetweenness','mu_Cbetweenness','closeness','mu_closeness','Rcloseness','mu_Rcloseness',
               'Ccloseness','mu_Ccloseness','eig','mu_eig','Reig', 'mu_Reig','Ceig','mu_Ceig','coreness',
               'mu_coreness','Rcoreness', 'mu_Rcoreness','Ccoreness','mu_Ccoreness',
               ]

    for filename in glob.glob(direct+"/*.txt") :
        #try :
        print("apro il file " , filename)
        try :
            graphStats[filename] = analyzeGraph(filename, metrics, myformat)
        except :
            shutil.copy(filename,filename[:-3]+"wrong")
            print "WRONG - ", filename

   
    data , aggregate_dict = aggregateMetrics(graphStats,metrics)

    if data :
        # SALVO OGNI DATO AGGREGATO IN UN CSV 
        direct_aggregate = direct+direct.split('/')[-2]+"_aggregate"
        print direct_aggregate
        if not os.path.exists(direct_aggregate):
            os.mkdir(direct_aggregate)
        for ix in aggregate_dict.keys():
            print ix.split('/')[-1]
            tempnp = np.asarray(aggregate_dict[ix].getList())
            if len(tempnp > 1) :
                np.savetxt(direct_aggregate+"/"+ix.split('/')[-1]+".csv", tempnp, delimiter=",")


        text_file = open(direct+"/aggregate_graph_data.log", "w")
        text_file.write(str(data))
        text_file.close()


    for directories in glob.glob(direct+"/*/") :
        if len(filter(lambda x: x in directories, blacklist)) == 0 :
            evaluateGraphs(directories, myformat=myformat)
            print("apro la cartella " , directories)
        else :
            print "salto la cartella ", directories
    return True

def analyzeGraph(filename, metrics , myformat = 'adjacency'):
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

    gx = topologicalmap.gx


    Cs = g.vs.select(RC_label = 'C')
    Rs = g.vs.select(RC_label = 'R')
    indexC = [i.index for i in Cs]
    indexR = [i.index for i in Rs]
    data = dict()
    #######################################           Network X

    # degree_assortativity
    degree_assortativity = nx.degree_assortativity_coefficient(gx)
    data['degree_assortativity'] = degree_assortativity
    # eccentricity
    eccentricity = (len(indexR)+len(indexC))*[0]
    for k, v in nx.eccentricity(gx).items():
        eccentricity[k] = v
    data['eccentricity'] = eccentricity
    # mu_eccentricity
    data['mu_eccentricity'] = avg(eccentricity)
    # katz_centrality
    katz_centrality = (len(indexR)+len(indexC))*[0]
    for k, v in nx.katz_centrality(gx).items():
        katz_centrality[k] = v
    data['katz_centrality'] = katz_centrality
    # mu_katz_centrality
    data['mu_katz_centrality'] = avg(katz_centrality)
    # rich_club_coefficient
    #rich_club_coefficient = nx.rich_club_coefficient(gx)
    #data['rich_club_coefficient'] = rich_club_coefficient
    # mu_rich_club_coefficient
    #data['mu_rich_club_coefficient'] = avg(rich_club_coefficient)


    #######################################           Igraph
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

    # average eccentricity solo R
    print(eccentricity)
    data['Reccentricity'] = selectLabelArray(eccentricity,indexR)
    data['mu_Reccentricity'] = avg(data['Reccentricity'])
    # average eccentricity solo C
    data['Ceccentricity'] = selectLabelArray(eccentricity,indexC)
    data['mu_Ceccentricity'] = avg(data['Ceccentricity'])
    # average katz_centrality solo R
    data['Rkatz_centrality'] = selectLabelArray(katz_centrality,indexR)
    data['mu_Rkatz_centrality'] = avg(data['Rkatz_centrality'])
    # average katz_centrality solo C
    data['Ckatz_centrality'] = selectLabelArray(katz_centrality,indexC)
    data['mu_Ckatz_centrality'] = avg(data['Ckatz_centrality'])

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
    # coreness
    coreness = g.coreness()
    data['coreness'] = coreness
    # mean coreness
    data['mu_coreness'] = avg(coreness)
    # eigenvec coreness R
    data['Rcoreness'] = selectLabelArray(coreness,indexR)
    # mean coreness R
    data['mu_Rcoreness'] = avg(data['Rcoreness'])
    # eigenvec coreness C
    data['Ccoreness'] = selectLabelArray(coreness,indexC)
    # mean coreness  C
    data['mu_Ccoreness'] = avg(data['Ccoreness'])


    #print ".".join(filename.split(".")[:-1])+  ".png"
    #plot(graph,".".join(filename.split(".")[:-1])+".png")
    order = dict()
    for i in range(len(metrics)) :
        order[str(i)] = metrics[i]
    stringa = str()
    for j in range(len(metrics)):
        i = order[str(j)]
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

def aggregateMetrics(dictionary,list_of_metrics) :
    # per ora non calcolo dati aggregati sugli array
    # prende un array di array e poi ricalcola tutto
    mydict = dict()
    # inizializzo le variabili
    for i in list_of_metrics :
        mydict[i] = variable(i)
    # per ogni grafo parso il dizionario e lo inserisco nelle variabili
    for i in dictionary.keys() :
        for j in dictionary[i].keys() :
            if type(dictionary[i][j]) is list or type(dictionary[i][j]) is dict:
                # per ora non calcolo dati aggregati sugli array.
                pass
            else :
                mydict[j].add(dictionary[i][j])
    ret_str = str()
    for i in list_of_metrics :
        if mydict[i].n > 0 :
            ret_str += mydict[i].printVar() + '\n'
    return ret_str, mydict

# apre ricorsivamente tutti i file di TXT che ci trova. usa la cartella corrente, se non specifichi una cartella di start alternativa
current = os.getcwd()
try:
    current = argv[1]
except :
    print("non hai specificato la cartella corrente")
print("inizio a parsare la cartella ", current , 'che diavleria e ques?')
evaluateGraphs(current,'matlab')
print("finito!")
