#!/usr/bin/python
#from rooms import *
#from utils import *
from myDictionaries import *
from xml.dom.minidom import parse
import os
# Qui ci vanno le funzioni che si usano per caricare (e salvare?) i grafi.



def loadXML(floorxml, labelxml,counter):
    # parsing dell'insieme di etichette della tipologia edilizia
    xmldoc = parse(labelxml)
    labels = {}
    nodeLabels = xmldoc.getElementsByTagName("label")
    for nodeLabel in nodeLabels:
        name = nodeLabel.getElementsByTagName("name")[0].childNodes[0].nodeValue
        letter = nodeLabel.getElementsByTagName("letter")[0].childNodes[0].nodeValue
        labels[name] = letter

    #parsing del floor topologico
    xmldoc = parse(floorxml)
    labelSpaces = {}
    idSpaces = {}
    spaces = xmldoc.getElementsByTagName("spaces")[0].getElementsByTagName("space")
    count = 0;
    label_idxs = []
    for space in spaces:
        idSpace = space.attributes['id'].value
        idSpaces[idSpace] = count
        labelSpace = space.getElementsByTagName("labels")[0].getElementsByTagName("label")[0].childNodes[0].nodeValue
        labelSpaces[idSpace] = labels_java2012toMatlab_Dict[labels[labelSpace]]
        count = count + 1
        label_idxs.append([idSpace,count,0])


    dim = len(labelSpaces)
    matrix = [[0 for x in range(dim)] for x in range(dim)]
    for i in range(dim):
        for j in range(dim):
            matrix[i][j] = 0
    targets = xmldoc.getElementsByTagName("target")
    for target in targets:
        ids = target.getElementsByTagName('id')
        ids0 = idSpaces[str(ids[0].childNodes[0].nodeValue)]
        ids1 = idSpaces[str(ids[1].childNodes[0].nodeValue)]
        matrix[ids0][ids1] = 1
        matrix[ids1][ids0] = 1
    for i in range(dim):
        for idSpace, count in idSpaces.items():
            if i == count:
                matrix[i][i] = labelSpaces[idSpace]

    '''
    removing all the nodes without any connections
    '''
    print "removing nodes", len(matrix),len(label_idxs)
    remove = removeDummy(matrix)
    print "removelist" , remove
    matrix = popIDXfromMatrix(matrix,remove)
    label_idxs = popIDXfromVector(label_idxs,remove)
    print "after removal", len(remove), len(matrix),len(label_idxs)
    for i in xrange(len(label_idxs)):
        label_idxs[i][2]=i+1;

    allnodes = str()
    for i in label_idxs:
        allnodes+=str(i[0])+" " + str(i[1]) +" " + str(i[2])+"\n"
    current = os.getcwd()
    textfile=open(current+"/logs/graph"+str(counter)+".log","w")
    textfile.write(allnodes)
    textfile.close()

    return [matrix,label_idxs]

def removeDummy(matrix):
    '''
    returns the index of the rows and column of unconnected nodes
    '''
    dim = len(matrix)
    remove = []
    for i in xrange(dim):
        if sum(matrix[i])-matrix[i][i] == 0 :
            remove.append(i)
    return remove 

def popIDXfromMatrix(matrix,indexes) :
    '''
    for each index in "indexes" remove the i-th row and i-th column from the matrix
    '''
    indexes.sort(reverse=True)
    for i in xrange(len(matrix)):
        for j in indexes :
            matrix[i] = matrix[i][:j]+matrix[i][j+1:]
    for i in indexes :
        matrix = matrix[:i]+matrix[i+1:]
    return matrix 

def popIDXfromVector(vector,indexes):
    '''
    removes the i-th element from the vector, for all the elements indicated as indexes
    '''
    indexes.sort(reverse=True)
    for i in indexes:
        vector=vector[:i]+vector[i+1:]

    return vector


def tab(dim):
    return [[x for x in range(dim)] for x in range(dim)]

