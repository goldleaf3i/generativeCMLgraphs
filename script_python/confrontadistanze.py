#script per confrontare i valori delle distanze partendo da file in formato csv

import glob
import matplotlib.pyplot as plt
import matplotlib as mpl
import numpy as np
import csv

#prende la lista dei file csv nel percorso specificato e li ordina in ordine alfabetico
files = glob.glob("/home/mattia/Desktop/filecsv/*.csv")
files.sort()

data_dist_C = 0
data_dist_G = 0

for i in range(len(files)):
	#legge un file csv
	reader=csv.reader(open(files[i],"rb"),delimiter=',')
	x=list(reader)
	
	result=np.array(x).astype('float')
	tmp = files[i]
	
	if(tmp[29:31] == "C_"):
		data_dist_C = result[1,:]
    	elif(tmp[29:31] == "G_"):
		data_dist_G = result[1:,1:]
		rows = int(result[-1,0])
		for j in range(rows):
			fig = plt.figure()
			ax = fig.add_subplot(111)
			fig.set_size_inches(12, 10)
			ind = np.arange(len(data_dist_C))
			width = 0.40
			rect1 = ax.bar(ind, data_dist_C, width, color='green')
			rect2 = ax.bar(ind+width, data_dist_G[j,:], width, color='blue')
			ax.set_xlim(-width, len(ind)+width)
			#ax.set_ylabel('Dissimilarita media sottografi')
			#ax.set_xlabel('Indice del cluster')
			#ax.set_title('Dissimilarita media sottografi nei cluster generali VS dissimilarita media sottografi raggruppati per cluster in un grafo', fontsize=11)
			ax.set_xticks(ind + width)
			xTickMarks = range(1, len(data_dist_C)+1)
			xTickNames = ax.set_xticklabels([])
			#plt.setp(xTickNames, rotation=0, fontsize=12)
			ax.legend((rect1[0], rect2[0]), ('Cluster', 'Grafo'), loc = 'lower right')
			out = tmp[0:29] + "ConfrDist_grafo" + str(j+1) + tmp[45:]
			out = out[0:-3] + "png"
			plt.savefig(out)
			plt.close()
