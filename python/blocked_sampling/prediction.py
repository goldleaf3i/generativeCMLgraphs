import MATLAB_vs_XML
import plot_TXT
import os

# SCRIPT PRINCIPALE. CREA TUTTI I DATI

# Creo le cartelle
destination_folder = './prediction_output'
create_folders = ['hist','hist_average','hist_mean','hist_OMP','plot','plot_C']
for i in create_folders: 
	SAVE_FOLDER = os.path.join(destination_folder,i)
	if not os.path.exists(SAVE_FOLDER):
		os.mkdir(SAVE_FOLDER)

# Stampo tutti i grafi
print "UNO"
plot_TXT.plot_prediction()
# Stampo tutti i grafi solo coi corridoi
print "DUE"
plot_TXT.plot_prediction_ONLYC()
# Stampo tutti gli istogrammi
print "TRE"
MATLAB_vs_XML.plot_histograms(-1)