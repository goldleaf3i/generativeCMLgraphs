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
import numpy as Math
import os
import glob
from igraph import *

from utils import * 

#ottengo il dizionario delle label
def plot_prediction() :
    (letters,numbers) = get_label_dict()
    destination_folder = './prediction_output/plot/'
    (letters,numbers) = get_label_dict()
    numbgraph = 50
    for ii in xrange(1,numbgraph) :
        SAVE_FOLDER = os.path.join(destination_folder,'graph'+str(ii))
        if not os.path.exists(SAVE_FOLDER):
            os.mkdir(SAVE_FOLDER)
        num_g = ii

        orig = MATLAB_to_igraph('./dataset/TXT/grafo_'+str(num_g)+'.txt',numbers,SAVE_FOLDER+'/real.pdf')
        it = 1
        for txt_file in glob.glob('prediction/Graph-'+str(num_g)+'/Predict/Prediction_results_/*/Grafi finali prediz/*.txt'):
            print 'open' , txt_file
            other = MATLAB_to_igraph(txt_file,numbers,SAVE_FOLDER+'/predict_'+str(it)+'.pdf')
            it+=1

#ottengo il dizionario delle label
def plot_prediction_ONLYC() :
    (letters,numbers) = get_label_dict()
    destination_folder = './prediction_output/plot_C/'
    (letters,numbers) = get_label_dict()
    # washroom e indicato come Corridoio ma in questo caso non va plottato.
    numbers[17]['RC'] = 'R'
    numbgraph = 50
    for ii in xrange(1,numbgraph) :
        SAVE_FOLDER = os.path.join(destination_folder,'graph'+str(ii))
        if not os.path.exists(SAVE_FOLDER):
            os.mkdir(SAVE_FOLDER)
        num_g = ii

        orig = MATLAB_to_igraph_onlySELECTED('./dataset/TXT/grafo_'+str(num_g)+'.txt',numbers,SAVE_FOLDER+'/real.pdf','RC','C')
        it = 1
        for txt_file in glob.glob('prediction/Graph-'+str(num_g)+'/Predict/Prediction_results_/*/Grafi finali prediz/*.txt'):
            print 'open' , txt_file
            other = MATLAB_to_igraph_onlySELECTED(txt_file,numbers,SAVE_FOLDER+'/predict_'+str(it)+'.pdf','RC','C')
            it+=1
# carico le label ordinate per label e pere numero (letters e numebers rispettivamente)
def main() :
    plot_prediction()
    plot_prediction_ONLYC()

if __name__ == '__main__':
    main()


