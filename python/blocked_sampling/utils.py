import matplotlib.pyplot as plt
import numpy as np
import math
import cmath
import glob
import pickle
from xml.dom.minidom import parse
import itertools as it
import matplotlib.colors as colors
import matplotlib.cm as cmx

import networkx as nx
from igraph import *

def colors_iterator(vmin=0, vmax=1, colormap='rainbow'):
    '''Restituise un iteratore colormap in range vmin - vmax.L'oggetto iteratore riceve un valore in range
    vmin-vmax e restituisce il colore corrispondente
    Esempio:vmin = 0vmax = 1iteratore = colors_iterator(vmin,vmax)
    iteratore(0.1)-->(0.30392156862745101, 0.30315267411304353, 0.98816547208125938, 1.0)
    iteratore(0.3)-->(0.096078431372549011, 0.80538091938883261, 0.8924005832479478, 1.0)'''
    cm = plt.get_cmap(colormap)
    cNorm = colors.Normalize(vmin=vmin, vmax=vmax)
    scalarMap = cmx.ScalarMappable(norm=cNorm, cmap=cm)

    def to_rgba(value):
        return scalarMap.to_rgba(value)

    return to_rgba


def get_colors(numofcolors=20, colormap='Paired'):
    cm = plt.get_cmap(colormap)
    cNorm = colors.Normalize(vmin=0, vmax=numofcolors)
    scalarMap = cmx.ScalarMappable(norm=cNorm, cmap=cm)
    for i in range(numofcolors):
        print scalarMap.to_rgba(i)
    return scalarMap


def MATLAB_to_igraph(filename, numbers, savename):
    '''
    plotta un grafo in formato matlab come savename
    '''
    myfile = open(filename);
    # inizializzo la struttura dati
    matrix = []
    for line in myfile:
        matrix.append([int(i) for i in line.split(',')])
    myfile.close()

    N = len(matrix)

    edge_list = []
    label_list = []
    for i in xrange(N):
        for j in xrange(N):
            if i == j:
                label_list.append(matrix[i][j])
            else:
                if matrix[i][j] > 0:
                    if (j, i) not in edge_list:
                        edge_list.append((i, j))
    g = Graph()
    g.add_vertices(N)
    g.add_edges(edge_list)
    color_list = [numbers[i]['color'] for i in label_list]
    letter_list = [numbers[i]['letter'] for i in label_list]
    labels = [numbers[i]['label'] for i in label_list]
    vertex_shape = ['rect' if i == 'C' or i == 'H' or i == 'L' or i == 'E' or i == 'N' or i == 'Q' else 'circle' for i
                    in letter_list]
    g.vs["color"] = color_list
    g.vs["label"] = labels
    plot(g, savename, vertex_label_size=0, vertex_shape=vertex_shape, bbox=(700, 700), layout='kk')

    return g


def MATLAB_to_igraph_onlySELECTED(filename, numbers, savename, field, flag):
    '''
    plotta un grafo in formato matlab come savename - ma plotta solo i nodi le cui label rispettano un dato campo (field) nel dizionario Numbers e con un valore flag
    '''
    myfile = open(filename);
    # inizializzo la struttura dati
    matrix = []
    for line in myfile:
        matrix.append([int(i) for i in line.split(',')])
    myfile.close()

    N = len(matrix)

    # seleziono le labels da plottare
    accepted_keys = []
    for i in numbers.keys():
        if numbers[i][field] == flag:
            accepted_keys.append(i)
    # ottengo i nodi che poi mantengo
    indexes = []
    edge_list = []
    label_list = []
    for i in xrange(N):
        for j in xrange(N):
            if i == j:
                if matrix[i][j] in accepted_keys:
                    indexes.append(i)
                    label_list.append(matrix[i][j])
    print indexes
    # ottengo la matrice di adiacenza
    for ii, i in enumerate(indexes):
        for jj, j in enumerate(indexes):
            if j != i and matrix[i][j] > 0 and (jj, ii) not in edge_list:
                edge_list.append((ii, jj))

    # plotto tutto
    N = len(indexes)
    g = Graph()
    g.add_vertices(N)
    g.add_edges(edge_list)
    color_list = [numbers[i]['color'] for i in label_list]
    letter_list = [numbers[i]['letter'] for i in label_list]
    labels = [numbers[i]['label'] for i in label_list]
    vertex_shape = ['rect' if i == 'C' or i == 'H' or i == 'L' or i == 'E' or i == 'N' or i == 'Q' else 'circle' for i
                    in letter_list]
    g.vs["color"] = color_list
    g.vs["label"] = labels
    plot(g, savename, vertex_label_size=0, vertex_shape=vertex_shape, bbox=(700, 700), layout='kk')

    return g


def print_hist(histogram, plot='False'):
    for i in histogram.keys():
        print histogram[i], i
    return


def indent(elem, level=0):
    i = "\n" + level * "  "
    if len(elem):
        if not elem.text or not elem.text.strip():
            elem.text = i + "  "
        if not elem.tail or not elem.tail.strip():
            elem.tail = i
        for elem in elem:
            indent(elem, level + 1)
        if not elem.tail or not elem.tail.strip():
            elem.tail = i
    else:
        if level and (not elem.tail or not elem.tail.strip()):
            elem.tail = i


def autolabel(rects, ax):
    # attach some text labels
    for rect in rects:
        height = rect.get_height()
        ax.text(rect.get_x() + rect.get_width() / 2., 1.05 * height,
                '%d' % int(height),
                ha='center', va='bottom')


def plot_barchart(ref_dict, filename='show', color='y', average=False, y_label='%', title='labels histogram'):
    '''
    receives a dictionary where keys are the columns' label and value are is an integer value with the column height.
    saves the barplot in the filename. If filename is show the barchart is displayed and not saved on a file.
    color is the colormap . Average is true if we want to plot the percentage of each labelset.
    '''

    labels = ref_dict.keys()
    values = np.array([int(ref_dict[i]) for i in ref_dict.keys()])
    if average:
        values = values / float(sum(values))
    N = len(values)
    ind = np.arange(N)

    width = 0.8
    fig, ax = plt.subplots()
    values = tuple(values)
    rects = ax.bar(ind, values, width, color=color)
    ax.set_ylabel(y_label)
    ax.set_title(title)
    ax.set_xticks(ind + float(width / 2))
    ax.set_xticklabels(labels, rotation='vertical')

    autolabel(rects, ax)
    if filename == 'show':
        plt.show()
    else:
        fig.savefig(filename, bbox_inches='tight')


def plot_multibarchart(ref_dict, others_dict, filename='show',
                       colors=['#FFB23B', '#54FF90', '#771BCC', '#E53C37', '#059939', '#E59313'], average=False,
                       y_label='%', title='', gap=False, key_order=False):
    '''
    Uguale a prima ma ne plotta piu di fianco uno all'altro.
    '''
    color = it.cycle(colors)

    '''
    Se gli passo come parametri anche l'ordine delle label sa quello
    '''
    if key_order:
        values = np.array([int(ref_dict[i]) for i in key_order])
        labels = key_order
    else:
        values = np.array([int(ref_dict[i]) for i in ref_dict.keys()])
        labels = ref_dict.keys()
    if average:
        values = values / float(sum(values))
    N = len(values)
    ind = np.arange(N)

    if type(others_dict) == dict:
        others_dict = [others_dict]
    if gap:
        width = 1.0 / (len(others_dict) + 2)
    else:
        width = 1.0 / (len(others_dict) + 1)
    fig, ax = plt.subplots()
    values = tuple(values)
    rects = ax.bar(ind, values, width, color=color.next())
    ax.set_ylabel(y_label, rotation='horizontal')
    # Nascondo il titolo
    if title != '':
        ax.set_title(title)
    # ax.set_xticks(ind+float(width/2))
    ax.set_xticks(ind)

    ax.xaxis.grid(True, linestyle='-')
    from matplotlib.ticker import NullFormatter
    ax.axes.get_xaxis().set_major_formatter(NullFormatter())
    labels = [i.replace('ADMINISTRATIVE', 'ADMIN') for i in labels]
    # ax.set_xticklabels(labels,rotation='vertical')

    # setto le label
    for lab, x in zip(labels, np.arange(0.5, N + 0.5, 1)):
        ax.annotate(lab, xy=(x, 0), xycoords=('data', 'axes fraction'),
                    xytext=(0, -5), textcoords='offset points', va='top', ha='center', rotation='vertical')

    # if not average :
    #	autolabel(rects,ax)
    i = 1

    for any_other in others_dict:
        offset = i * width
        i += 1
        if key_order:
            values = np.array([int(any_other[j]) for j in key_order])
        else:
            values = np.array([int(any_other[j]) for j in ref_dict.keys()])
        if average:
            values = values / float(sum(values))
        rects = ax.bar(ind + offset, values, width, color=color.next())
    # if not average :
    #	autolabel(rects,ax)

    if filename == 'show':
        plt.show()
    else:
        fig.savefig(filename, bbox_inches='tight')


def plot_bar_area(ref_dict, filename='show', color='cornflowerblue', y_label='area', title='area histogram'):
    '''
    receives a dictionary where keys are the columns' label and value is a list of all the areas.
    Plot mean and standard deviation of that area per each column
    '''

    labels = ref_dict.keys()
    values = np.array([np.mean(np.array(ref_dict[i])) for i in ref_dict.keys()])
    std_err = np.array([np.std(np.array(ref_dict[i])) for i in ref_dict.keys()])

    N = len(values)
    ind = np.arange(N)

    width = 0.8
    fig, ax = plt.subplots()
    values = tuple(values)
    rects = ax.bar(ind, values, width, color=color, yerr=std_err)
    ax.set_ylabel(y_label)
    ax.set_title(title)
    ax.set_xticks(ind + float(width / 2))
    ax.set_xticklabels(labels, rotation='vertical')

    autolabel(rects, ax)
    if filename == 'show':
        plt.show()
    else:
        fig.savefig(filename, bbox_inches='tight')


Java2012_colorDict = {
    'C': '#F18705',
    'S': '#3FBF04',
    'H': '#BF5719',
    'B': '#2267F2',
    'M': '#2A90F2',
    'E': '#268080',
    'R': '#3FBF04',  #
    'F': '#BEB615',
    'N': '#B27ABE',
    'D': '#716D0D',
    'O': '#A81E1E',
    'K': '#282828',
    "|": "#FF0DFF",
    'X': '#BDBDBD',
    'P': '#955CA4',  #
    'Y': '#8C8C8B',
    'I': '#A5A5BE',  #
    'L': '#F24738',
    'Z': '#585859',
    'G': '#A81E1E',
    'Q': '#5BBEBE',
    'T': '#FFF87D',
    'W': '#E8CAA7',
    'A': '#3C3C3C',  #
    'J': '#BEB94E',
    'U': '#5F1978',
    'V': '#FF0DFF'
}

labels_java2012toMatlab_Dict = {
    'C': 100,
    'S': 2,
    'H': 105,
    'B': 4,
    'M': 3,
    'E': 1000,
    'R': 5,
    'F': 6,
    'N': 7,
    'D': 8,
    'O': 1,
    'K': 21,
    "|": 10000,
    'X': 12,
    'P': 9,
    'Y': 10,
    'I': 11,
    'L': 110,
    'Z': 13,
    'G': 14,
    'Q': 15,
    'T': 16,
    'W': 17,
    'A': 18,
    'J': 19,
    'U': 20,
    'V': 115
}


def get_label_dict(buildingtype='school'):
    '''
    Restituisco due dizionari: il primo contiene le label ordinate per LA LABEL.
    Il secondo invece ritorna lo stesso dizionario ordinato per il NUMERO.
    '''
    labelxml = buildingtype + '.xml'
    xmldoc = parse(labelxml)
    labels = {}
    letters = {}
    numbers = {}
    nodeLabels = xmldoc.getElementsByTagName("label")
    counter = 1;
    for nodeLabel in nodeLabels:
        name = nodeLabel.getElementsByTagName("name")[0].childNodes[0].nodeValue
        letter = nodeLabel.getElementsByTagName("letter")[0].childNodes[0].nodeValue
        function = nodeLabel.getElementsByTagName("function")[0].childNodes[0].nodeValue
        RC = nodeLabel.getElementsByTagName("type")[0].childNodes[0].nodeValue
        labels[name] = letter
        number = labels_java2012toMatlab_Dict[letter]
        letters[name] = {
            'label': name,
            'letter': letter,
            'color': Java2012_colorDict[letter],
            'number': number,
            'counter': counter,
            'RC': RC if RC != u'E' else u'R',
            'function': function if function != u'F' else u'R',
            'RCO': function if function == u'F' or function == u'C' else 'O',
        }
        numbers[number] = {
            'label': name,
            'letter': letter,
            'color': Java2012_colorDict[letter],
            'number': number,
            'counter': counter,
            'RC': RC if RC != u'E' else u'R',
            'function': function if function != u'F' else u'R',
            'RCO': function if function == u'F' or function == u'C' else 'O',
        }
        counter += 1;
    return (letters, numbers)
