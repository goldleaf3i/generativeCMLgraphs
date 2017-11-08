#!/usr/bin/python

# COPIATO DA CARTELLLA DI SVILUPPO 15/9/14

from sys import argv
import re
import sys
import math
from loadGraph import *
'''
M = [[1,1,1,0,0,0,0,0],
[1,1,1,1,0,0,0,0],
[1,1,1,0,0,0,0,0],
[0,1,0,1,1,1,0,0],
[0,0,0,1,1,1,1,1],
[0,0,0,1,1,1,0,0],
[0,0,0,0,1,0,1,1],
[0,0,0,0,1,0,1,1]]
funziona = myT(M,False,True)
#funziona = importFromMatlabJava2012FormatToIgraph(matrice, True)
'''
filenames = ["agen","bgen"]
for filename in filenames :
	try:
		myfile = open(filename+".txt");
	except:
		print "impossibile aprire il file " + filename; 

	count = 0
	tmp = 0
	hit = 0
	for line in myfile :
		thisline = [int(i)for i in line.split(',')]
		if thisline[count] == 2 :
			tmp += sum(thisline)-2 
			hit +=1 
			print "siamo in una stanza piccola, e ho ", sum(thisline)-2 , " porte"
		count += 1 
	print "in totale ci sono " , count, " stanze.\nTra queste ", hit ," sono piccole e la media porte e' " , float(tmp)/hit 
'''
	count = 0
	tmp = 0
	hit = 0
	for line in myfile :
		thisline = [int(i)for i in line.split(',')]
		if thisline[count] == 100 :
			tmp += sum(thisline)-100
			hit +=1 
			print "siamo in un corridoio, e ho ", sum(thisline)-2 , " porte"
		count += 1
	print "in totale ci sono " , count, " stanze.\nTra queste ", hit ," sono Corridoi e la media porte e' " , float(tmp)/hit

	#inizializzo la struttura dati	
	matrix = []
	for line in myfile:
		matrix.append([int(i)for i in line.split(',')])
	myfile.close()
	topologicalmap = importFromMatlabJava2012FormatToIgraph(matrix)
	graph = topologicalmap.graph
	plot(graph,filename+".png")

	#'''