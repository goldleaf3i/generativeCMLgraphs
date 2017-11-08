import matplotlib.pyplot as plt
import matplotlib.colors as colors
import matplotlib.cm as cmx
import numpy as np

numofcolors = 20
cm = plt.get_cmap("Paired")
cNorm = colors.Normalize(vmin=0, vmax=numofcolors)
scalarMap = cmx.ScalarMappable(norm=cNorm, cmap = cm)
for i in range(numofcolors) :
	print scalarMap.to_rgba(i)

labelsdict = dict()
numbersdict = dict()

for i in range(numofcolors) : 
	labelsdict["N"+str(i)] = colors.rgb2hex(scalarMap.to_rgba(i))
	numbersdict["N"+str(i)] = i+11

for i in labelsdict :
	print "'"+str(i)+ "' : '" +  str(labelsdict[i]) +  "',"
for i in numbersdict :
	print "'"+str(i)+ "' : "+ str(numbersdict[i]) + ","