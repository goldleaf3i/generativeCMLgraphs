#script per plottare le heatmap delle clustering configuration dei grafi partendo da file in formato csv

import glob
import matplotlib.pyplot as plt
import matplotlib as mpl
import numpy as np
import csv
import os
import numpy as Math
import pylab as Plot
import matplotlib.cm as cm

def tsne(P = Math.array([])):

	# number of instances
	n = Math.size(P, 0);
	# initial momentum
	initial_momentum = 0.5;
	# value to which momentum is changed
	final_momentum = 0.8;
	# iteration at which momentum is changed
	mom_switch_iter = 250;
	# iteration at which lying about P-values is stopped
	stop_lying_iter = 100;
	# maximum number of iterations
	max_iter = 1000;
	# initial learning rate
	epsilon = 500;
	# minimum gain for delta-bar-delta
	min_gain = 0.01;

	# Make sure P-vals are set properly
	# set diagonal to zero
	Math.fill_diagonal(P, 0);
	# symmetrize P-values
	P = 0.5 * (P + P.T);
	# make sure P-values sum to one
	P = Math.maximum(P / Math.sum(P[:]), 1e-12);
	# constant in KL divergence
	const = Math.sum(P[:] * Math.log(P[:]));
	# lie about the P-vals to find better local minima
	P = P * 4;

	# Initialize the solution
	Y = 0.0001 * Math.random.randn(n, 2);
	iY = Math.zeros((n, 2));
	gains = Math.ones((n, 2));

	# Run iterations
	for iter in range(max_iter):

		# Compute pairwise affinities
		sum_Y = Math.sum(Math.square(Y), 1);
		num = 1 / (1 + Math.add(Math.add(-2 * Math.dot(Y, Y.T), sum_Y).T, sum_Y));
		num[range(n), range(n)] = 0;
		Q = num / Math.sum(num);
		Q = Math.maximum(Q, 1e-12);

		# Compute gradient (faster implementation)
		L = (P - Q) * num;
		y_grads = Math.dot(4 * (Math.diag(Math.sum(L, 0)) - L), Y);

		# update the solution
		gains = (gains + 0.2) * ((y_grads > 0) != (iY > 0)) + (gains * 0.8) * ((y_grads > 0) == (iY > 0));
		gains[gains < min_gain] = min_gain;
		iY = initial_momentum * iY - epsilon * (gains * y_grads);
		Y = Y + iY;
		Y = Y - Math.tile(Math.mean(Y, 0), (n, 1));

		# update the momentum if necessary
		if iter == mom_switch_iter:
			initial_momentum = final_momentum
		if iter == stop_lying_iter:
			P = P / 4;

		# Compute current value of cost function
		if (iter + 1) % 10 == 0:
			C = const - Math.sum(P[:] * Math.log(Q[:]));
			print("Iteration ", (iter + 1), ": error is ", C);

	return Y;

def plotting(directory='',format='pdf'):
	cluster_labels = set(labels);
	# iteratore di colori su un insieme grande quanto il numero di cluster
	if len(cluster_labels) >2 :
		colors = iter(cm.rainbow(Math.linspace(0, 1, len(cluster_labels))))
	else :
		colors = iter(['#0186BE','#FFB23B','#FFFB47','#82bebe'])
	fig,ax = plt.subplots()
	print colors
	for c in cluster_labels:
		Xc = [];
		Yc = [];
		for i in range(len(Y)):
			if labels[i] == c:
				Xc.append(Y[i][0]);
				Yc.append(Y[i][1]);
		plt.scatter(Xc[:], Yc[:], 30, color=next(colors), label=c);
	ax.set_xticks([])
	ax.set_yticks([])
	plt.axis('equal')
	#plt.legend(scatterpoints=1, loc='lower left', fontsize=5);
	plt.savefig(directory+"tsne_scatter_plot."+format);

if __name__ == "__main__":
	current = os.getcwd()

	# PLOT TSNE
	P = Math.loadtxt(current+'/csv/similarity_matrix.csv',delimiter=',');
	labels = Math.loadtxt(current+'/csv/cluster_labels.csv',delimiter=',');
	Y = tsne(P);
	plotting(current+'/csv/');


	# READ DATA
	# leggo la matrice di similarita
	reader = csv.reader(open(current+'/csv/similarity_matrix.csv'),delimiter=',')
	data = list(reader)
	data = [[float(i) for i in j] for j in data]
	data = np.array(data)
	data_sim = data

	# leggo l'elenco delle label
	labels = [int(i) for i in open(current+'/csv/cluster_labels.csv').read()[:-1].split(',')]
	uniques_labels = list(np.unique(labels))
	N_labels = len(uniques_labels)

	clustering = dict()
	for x in uniques_labels:
		clustering[x] = []
	for x in xrange(len(labels)) :
		clustering[labels[x]].append(x)



	data_matrix =  [[[] for i in uniques_labels] for j in uniques_labels]


	N = data.shape[0]
	for i in xrange(N):
		x_L = uniques_labels.index(labels[i])
		for j in xrange(i,N):
			y_L = uniques_labels.index(labels[j])
			data_matrix[x_L][y_L].append(data[i][j])

	data =  [[[] for i in uniques_labels] for j in uniques_labels]
	data_var = [[[] for i in uniques_labels] for j in uniques_labels]
	for i in xrange(N_labels):
		for j in xrange(i,N_labels):
			tmp_np = np.array(data_matrix[i][j])
			data[i][j] = np.mean(tmp_np)
			data_var[i][j] = np.var(tmp_np)
	#print data
	for i in xrange(N_labels):
		for j in xrange(0,i):
			data[i][j] = data[j][i]
			data_var[i][j]=data_var[j][i]

	# PLOT HEATMAP

	data = np.array(data)

	x_labels = [str(i) for i in xrange(data.shape[0])]
	y_labels =x_labels
	#y_labels = list(result[1:,0])
	#print data.shape
	#print data
	fig, ax = plt.subplots()
	heatmap = ax.pcolor(data, cmap = plt.cm.hot)
	#heatmap = ax.pcolor(data,cmap=plt.cm.Blues)

	plt.ylim(0, len(y_labels))
	plt.xlim(0, len(x_labels))

	#remove all axis
	plt.axis('off')

	fig = plt.gcf()
	fig.set_size_inches(21, 22)
	ax.set_yticks(np.arange(data.shape[0]) + 0.5, minor=False)
	ax.set_xticks(np.arange(data.shape[1]) + 0.5, minor=False)
	ax.invert_yaxis()
	ax.xaxis.tick_top()
	ax.set_xticklabels([])
	#ax.set_yticklabels(y_labels, minor=False)
	ax.set_yticklabels([])
	ax.set_xticks
	#plt.xticks(rotation=90)
	min_value = np.amin(data) 
	max_value = np.amax(data)
	normalization = mpl.colors.Normalize(vmin = min_value, vmax = max_value)
	cax = fig.add_axes([0.95, 0.2, 0.02, 0.6])
	cb = mpl.colorbar.ColorbarBase(cax, cmap = plt.cm.hot, norm = normalization, spacing = 'proportional',ticks=None)
	cb.set_ticklabels([])
	cb.set_ticks([])
	#ax.set_ylabel('Indice del grafo')
	#plt.title('Indice del cluster', x = -22, y = 1.225)
	#ax.set_xlabel('Confronto tra le configurazioni dei cluster dei grafi originali e quelle campionate')
	out = current+'/csv/cluster_labels.pdf'
	plt.savefig(out)
	plt.close()


	# PLOT COLORBAR
	fig,ax = plt.subplots()

	# setto limite assi
	plt.xlim(0,len(clustering.keys()))
	ax.bar(np.arange(len(clustering.keys())),[len(clustering[i]) for i in clustering.keys()],color='#82bebe',width=1)
	ax.set_xticks([])
	#nascondo axis ticks
	ax.tick_params(axis=u'y', which=u'both',length=0)
	#plt.setp(ax.get_ytickslabels(),visible=False)
	#ax.set_xlabel([])
	ax.yaxis.set_ticks_position('left')
	plt.savefig(current+'/csv/barplot.pdf',bbox_inches='tight')
	plt.close()
	print [len(clustering[i]) for i in clustering.keys()],np.arange(len(clustering.keys()))
	print len(labels), data.shape
	exit()


	#bins = 
