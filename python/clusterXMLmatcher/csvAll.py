#!/usr/bin/python

# APRE LA CARTELLA DOVE STA LO SCRIPT O, ALTERNATIVAMETNE, argv[1]. 
# PARSA TUTTE LE SOTTO CARTELLE
# PRENDE TUTTI I FILE DITESTO, CHE CONSIDERA MATRICI DI ADIACENZA DI UN GRAFO
# INSERISCE LE MATRICI TROVATE IN UN GRAFO DI IGRAPH

# COSA FA: APRE TUTTI GLI XML E CREA DA UNA PARTE I MODULI PER SALVARLI PER MALTLAB; DALL'ALTRA PARTE SALVA DEI FILE DI LOG CHE TI SERVONO PER REINSERIRE I DATI DI MATLAB NEGLI XML
import sys
import math
from loadGraph import *
import numpy as Math
import os
import glob
from multiprocessing import Process
mylabelschema = 'school.xml'


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
btypename = current+'/legenda/school.xml'
filenames = []
#btypename = 'zoffice.xml'
for filename in glob.glob(current+"/dataset/*.xml"):
    count+=1
    print filename
    newfilename = str()
    for i in filename.split('/')[:-1] :
        newfilename+="/"+i
    newfilename=newfilename[1:]
    os.rename(filename,newfilename+"/"+filename.split('/')[-1].replace(' ',''))
    filename = newfilename+"/"+filename.split('/')[-1].replace(' ','')
    filenames.append(filename.split('/')[-1])
    # LOADXML carica i TOPOLOGICAL. LOAD XML2 carica i XML standard
    if not btypename in filename :
        [matrix,labels] = loadXML(filename, btypename,count)
        Math.savetxt(current+"/CSVs/graph_"+str(count)+".csv", matrix, fmt='%s', delimiter=",")

filenamelists = str()
for i in xrange(len(filenames)):
    filenamelists+=filenames[i]+' '+str(i+1)+"\n"

filenamefile=open(current+"/CSVs/filenamesgraphsnumber.txt","w")
filenamefile.write(filenamelists)
filenamefile.close()
#     1] RIMUOVERE GLI SPAZI
#     2] TENERE SOLO IL NOME DEL FILE
#     3] SALVARE IL FORMATO GIUSTO
#TODO 4] COMMITTARE SAVECLUSTER NEL MATLAB
#TODO 5] AGGIUNGERE ANCHE LA PARTE CHE FA LOAD E POI SAVECLUSTER
print filenamelists
print "done"