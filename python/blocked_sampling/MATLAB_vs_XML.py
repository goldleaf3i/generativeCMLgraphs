'''
in graph_name_dict ci metto dentro
'''
import matplotlib.pyplot as plt
import numpy as np
import math
import cmath
import glob
import pickle

import networkx as nx 

from utils import *

def plot_histograms(select_numbers = -1) :
	graph_names = open('./files/filenamesgraphsnumber.txt')
	graph_name_dict =dict()
	for i in graph_names :
		graph_name_dict[i.split()[1]] = i.split()[0]

	#leggo i file da folder	 per le aree
	real_areas = pickle.load(open('./files/real_area.p','rb'))
	areas_dict = pickle.load(open('./files/space_areas.p','rb'))
	area_log = {}
	real_area_log = {}

	average_hist = pickle.load(open('./files/average_hist.p','rb'))

	#ottengo il dizionario delle label
	(letters,numbers) = get_label_dict()
	numbgraph = 50
	for ii in xrange(1,numbgraph) :
		num_g = ii
		if select_numbers != -1:
			num_g = select_numbers
		original_graph = graph_name_dict[str(num_g)]
		original_area = real_areas[original_graph]
		real_area_log[original_graph] = original_area
		area_log[original_graph] = []

		list_of_hists = []
		it = 1
		original_hist = pickle.load(open("./Hist/"+original_graph.split('.')[0]+'.p',"rb"))
		for txt_file in glob.glob('prediction/Graph-'+str(num_g)+'/Predict/Prediction_results_/*/Grafi finali prediz/*.txt'):
			print 'open' , txt_file
			print 'corresponds to ' , original_graph
			txt_name = txt_file.split('/')[-1]
			print txt_name
			fileTXT =open(txt_file,'r')

			A = []
			for line in fileTXT:
				A.append([int(i) for i in line[:-1].split(',')])

			N = len(A[0])
			node_list = range(N)

			label_set= []
			for i in xrange(N) :
				attributes = numbers[A[i][i]]
				label_set.append(attributes['label'])


			spaces_hist = dict()
			for i in letters.keys() :
				spaces_hist[i] = 0
			for i in label_set:
				spaces_hist[i]+=1

			#calcolo la area predetta
			fake_area = 0
			for i in label_set:
				fake_area +=areas_dict[i][0]
			
			area_log[original_graph].append(fake_area)
			
			plot_multibarchart(original_hist,spaces_hist,filename = "./prediction_output/hist/"+original_graph.split('.')[0]+"_"+str(it)+".pdf")
			plot_multibarchart(original_hist,spaces_hist,filename = "./prediction_output/hist_average/"+original_graph.split('.')[0]+"_"+str(it)+"_average.pdf",average = True)
			list_of_hists.append(spaces_hist)

			# plot jacopo
			# ordino le keys per average; 
			import operator
			sorted_avg = sorted(average_hist.items(), key=operator.itemgetter(1),reverse = True)
			average_hist_cp = dict()
			spaces_hist_cp = dict()
			original_hist_cp = dict()
			key_order = []
			for i in sorted_avg :
				key = i[0]
				average_hist_cp[key] = average_hist[key]
				spaces_hist_cp[key] = spaces_hist[key]
				original_hist_cp[key] = original_hist[key]
				key_order.append(i[0])

			plot_multibarchart(original_hist_cp,[average_hist_cp,spaces_hist_cp],filename = "./prediction_output/hist_OMP/"+original_graph.split('.')[0]+"_"+str(it)+"_OMP.pdf",average = True,key_order = key_order)
			

			it+=1
		plot_multibarchart(original_hist,list_of_hists, filename = "./prediction_output/hist/"+original_graph.split('.')[0]+".pdf")
		plot_multibarchart(original_hist,list_of_hists, filename = "./prediction_output/hist_average/"+original_graph.split('.')[0]+"_average.pdf",average = True)
		
		# plot jacopo
		plot_multibarchart(original_hist,average_hist, filename = "./prediction_output/hist_mean/"+original_graph.split('.')[0]+"_orig.pdf",average = True)
		if len(list_of_hists)>=1 :
			plot_multibarchart(list_of_hists[0],list_of_hists[1:], filename = "./prediction_output/hist_mean/"+original_graph.split('.')[0]+"_pred.pdf",average = True)
		
		print "DECOMMENTAMI"'''
		if select_numbers != -1:
			print "Done"
			return'''
		print "Done"

	# stampo le aree predette
	savestr = str()
	for i in area_log.keys():
		print '#### EDIFICIO ' + str(i) + " ####"
		savestr+='#### EDIFICIO ' + str(i) + " ####"+'\n'
		print 'VERA AREA ', real_area_log[i]
		savestr+= 'VERA AREA ' + str(real_area_log[i])+'\n'
		for j in area_log[i]:
			print 'PREDETTA  ', j
			savestr+= 'PREDETTA '+ str(j)+'\n'
	out_file = open("./prediction_output/area_prediction.txt","w")
	out_file.write(savestr)
	out_file.close()

def main() :
	select_numbers = 24
	print "RIMUOVIMI"
	import os
	destination_folder = './prediction_output'
	create_folders = ['hist','hist_average','hist_mean','hist_OMP','plot','plot_C']
	for i in create_folders: 
		SAVE_FOLDER = os.path.join(destination_folder,i)
		if not os.path.exists(SAVE_FOLDER):
			os.mkdir(SAVE_FOLDER)
	print "FINE RIMUOVIMI"
	#select_numbers  = [5,6,24,25]
	if type(select_numbers) == list :
		for i in select_numbers :
			plot_histograms(i)
	else :
		plot_histograms(select_numbers)

if __name__ == '__main__':
    main()
    