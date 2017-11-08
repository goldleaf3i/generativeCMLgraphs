#!/usr/bin/python

# COPIATO DA CARTELLLA DI SVILUPPO 15/9/14

from sys import argv
import re
import sys
import math
import numpy as np
import copy
from igraph import *
from matplotlib import pyplot
import networkx as nx
from shapely.geometry import *
from descartes.patch import PolygonPatch
from utils import *
from myDictionaries import *
import uuid
import xml.dom.minidom
# QUI ci sono le classi che gestiscono i vari oggetti. 
# Le funzioni che plottano e che salvano 
# Gli script devono andare da altre parti.
#
#
#	OK	 devo aggiungere la funzione per stampare le cose.  
#	OK	 per ciascuno
#	OK	 devo fare la funzione che crea la mappina topologica
#	OK	 e la classe "mappa topologica"
#	OK	 e la funzione per plottare le cose
#	OK	 sia per plottare la mappa topologica
#		 sia perplottare tutto
#   OK   inoltre prima devo fare leclassi Floor
#   OK   e building
# 		 e magari caricare un file di esempio da usare come test.
# 		 e testare tutto 
'''
doc = xml.dom.minidom.Document() # New XML document

# TODO Have it in a shared file so that we can just change it in one place
xml_namespace = "http://home.deib.polimi.it/luperto/" # Namespace of xml

# Create building element (root) to XML document
building_element = doc.createElementNS(xml_namespace, 
                                "building")
building_element.setAttribute("xmlns", xml_namespace)
doc.appendChild(building_element)


COME SI FA ? SI FA COSI'! per aggiungere il testo c'e' il text node! 
>>> c = doc.createElementNS(namespace, "ricor")
>>> r = doc.createTextNode("vaffanculo")
>>> c.appendChild(r)
<DOM Text node "'vaffanculo'">
>>> c.toxml(doc, namespace)
'<ricor>vaffanculo</ricor>'
>>> c.appendChild(doc.createTextNode("do it again"))
<DOM Text node "'do it agai'...">
>>> c.toxml(doc, namespace)
'<ricor>vaffanculodo it again</ricor>'
>>> doc.appendChild(c) 

doc = xml.dom.minidom.Document() # New XML document
'''

class door(object):
    #HV e' orizzontale verticale
    def __init__(self,uid,HV,typeIE,first_id = None, second_id = None, direction = "BOTH"):
        '''
        TODO DOC ! [IN|OUT|BOTH|CLOSED]
        '''
        self.id = uid
        self.HV = HV
        self.typeIE = typeIE
        # source
        self.first_id = first_id
        # target
        self.second_id = second_id
        self.direction = direction
        self.xml = None

    def toxml(self, doc, namespace) :
        if self.xml :
            return self.xml
        if self.first_id == None or self.second_id == None :
            exit("Error - cannot print a portal without specifying the two directions")
        else:
            portal_xml = doc.createElementNS(namespace,"portal")
            id_xml = doc.createElementNS(namespace,"id")
            id_xml.appendChild(doc.createTextNode(str(self.id)))
            class_xml = doc.createElementNS(namespace, "class")
            class_xml.appendChild(doc.createTextNode(str(self.HV)))
            type_xml = doc.createElementNS(namespace, "type")
            type_xml.appendChild(doc.createTextNode(str(self.typeIE)))
            direction_xml = doc.createElementNS(namespace, "direction")
            direction_xml.appendChild(doc.createTextNode(str(self.direction)))
            if self.first_id :
                source_xml = doc.createElementNS(namespace, "source")
                source_xml.appendChild(doc.createTextNode(str(self.first_id)))
            target_xml = doc.createElementNS(namespace, "target")
            target_xml.appendChild(doc.createTextNode(str(self.second_id)))

            portal_xml.appendChild(id_xml)
            portal_xml.appendChild(class_xml)
            portal_xml.appendChild(type_xml)
            portal_xml.appendChild(direction_xml)
            if self.first_id :
                portal_xml.appendChild(source_xml)
            portal_xml.appendChild(target_xml)
            self.xml = portal_xml
            return self.xml

class linesegments(object) :
    # wp e' classe
    def __init__(self,x1,x2,y1,y2,uid = None, wp='WALL',typeIE='IMPLICIT', thickness = None):
        self.x1 = x1
        self.x2 = x2
        self.y1 = y1
        self.y2 = y2
        self.wp = wp
        self.line = LineString([(x,y),(x,y)])
        self.typeIE = typeIE
        self.p1 = Point(x1,y1)
        self.p2 = Point(x2,y2)
        if not(uid) :
            self.id == uuid.uuid4()
        else :
            self.id = uid
        self.xml = None
        self.thickness = thickness
    def is_door(self) :
        return wp == 'DOOR'

    def toxml(self, doc, namespace) :
        if self.xml :
            return self.xml
        else :
            linesegment_xml = doc.createElementNS(namespace,"linesegment")
            linesegment_xml.setAttribute(id,str(self.id))
            point1_xml = doc.createElementNS(namespace,"point")
            point1_xml.setAttribute("x",str(self.x1))
            point1_xml.setAttribute("y",str(self.y1))
            point2_xml = doc.createElementNS(namespace,"point")
            point2_xml.setAttribute("x",str(self.x2))
            point2_xml.setAttribute("y",str(self.y2))
            class_xml = doc.createElementNS(namespace,"class")
            class_xml.appendChild(doc.createTextNode(str(wp)))
            type_xml = doc.createElementNS(namespace,"type")
            type_xml.appendChild(doc.createTextNode(str(self.typeIE)))
            if self.thickness :
                thickness_xml = doc.createElementNS(namespace,"thickness")
                thickness_xml.appendChild(doc.createTextNode(str(self.thickness)))

            linesegment_xml.appendChild(point1_xml)
            linesegment_xml.appendChild(point2_xml)
            linesegment_xml.appendChild(class_xml)
            linesegment_xml.appendChild(type_xml)
            if self.thickness :
                linesegment_xml.appendChild(thickness_xml)
            self.xml = linesegment_xml
            return self.xml


#Classe che descrive una stanza.
class space(object) :

    def __init__(self,label,space_type, other_labels = [], uid = None) :
        # Scale factor e' il fattore di scala della griglia della mappa.
        #label
        self.label = label
        # R o C
        self.type = space_type
        # eventuali altre etichette
        self.other_labels = other_labels
        # id della stanza
        if not(uid) :
            self.id = uuid.uuid4()
        else :
            self.id = uid
        # elenco dei punti della stanza
        self.points = []
        # le porte
        self.doors = []
        # tutti i linesegments, unione di quelli
        self.linesgments = []
        # che fanno parte del contorno
        self.boundingPoly_linesegmets = []
        # e di quelli che non ne fanno parte
        self.NOTboundingPoly_linesegments = []
        # se e' True, ho gia' aggiunto tutto alla stanza
        self.compute = False
        # perimetro della stanza.
        self.bounding_polygon = None
        # poligono della stanza (simile a boundinpoly ma diverso)
        self.polygon = None
        # centroide. se e' la mappa topologica, lo prendo dal layout.
        self.centroid = None
        # xml
        self.xml = None

    def __str__(self) :
        return str(self.label) + ": n_doors: " + str(len(self.doors)) + " area: " + str(self.area) + "\n"

    def toxml(self, doc, namespace) :
        if self.xml :
            return self.xml
        else :
            space_xml = doc.createElementNS(namespace, "space")
            space_xml.setAttribute('id',str(self.id))
            labels_xml = doc.createElementNS(namespace, "labels")
            type_xml = doc.createElementNS(namespace, "label")
            type_xml.appendChild(doc.createTextNode(str(self.type)))
            label_xml = doc.createElementNS(namespace, "label")
            label_xml.appendChild(doc.createTextNode(str(self.label)))
            labels_xml.appendChild(type_xml)
            labels_xml.appendChild(label_xml)
            if self.other_labels != [] :
                for lab in other_labels :
                    tmp_label = doc.createElementNS(namespace,"label")
                    tmp_label.appendChild(doc.createTextNode(str(lab)))
                    labels_xml.appendChild(tmp_label)
            space_xml.appendChild(labels_xml)
            if self.centroid :
                centroid_xml = doc.createElementNS(namespace, "centroid")
                centroid_xml.setAttribute("x",str(self.centroid.x))
                centroid_xml.setAttribute("y",str(self.self.centroid.y))
                space_xml.appendChild(centroid_xml)
            if self.compute :
                # bounding box come  (minx, miny, maxx, maxy)
                minx,miny,maxx,maxy = self.bounds
                boundingBox_xml = doc.createElementNS(namespace, "boundingBox")
                maxx_xml = doc.createElementNS(namespace, "maxx")
                point_xml = doc.createElementNS(namespace, "point")
                point_xml.setAttribute("x",str(maxx))
                point_xml.setAttribute("y",str(miny))
                maxx_xml.appendChild(point_xml)
                boundingBox_xml.appendChild(maxx_xml)
                maxy_xml = doc.createElementNS(namespace, "maxy")
                point_xml = doc.createElementNS(namespace, "point")
                point_xml.setAttribute("x",str(maxx))
                point_xml.setAttribute("y",str(maxy))
                maxy_xml.appendChild(point_xml)
                boundingBox_xml.appendChild(maxy_xml)
                minx_xml = doc.createElementNS(namespace, "minx")
                point_xml = doc.createElementNS(namespace, "point")
                point_xml.setAttribute("x",str(minx))
                point_xml.setAttribute("y",str(maxy))
                minx_xml.appendChild(point_xml)
                boundingBox_xml.appendChild(min_xml)
                miny_xml = doc.createElementNS(namespace, "miny")
                point_xml = doc.createElementNS(namespace, "point")
                point_xml.setAttribute("x",str(minx))
                point_xml.setAttribute("y",str(miny))
                miny_xml.appendChild(point_xml)
                boundingBox_xml.appendChild(mint_xml)

                space_xml.appendChild(boundingBox_xml)
            if self.compute :
                data_xml = doc.createElementNS(namespace, "data")
                area_xml = doc.createElementNS(namespace, "area")
                area_xml.appendChild(doc.createTextNode(str(self.area)))
                data_xml.appendChild(area_xml)
                perimeter_xml = doc.createElementNS(namespace, "perimeter")
                perimeter.appendChild(doc.createTextNode(str(self.perimeter)))
                data_xml.appendChild(perimeter_xml)

                space_xml.appendChild(data_xml)
            if self.linesegments:
                # contour - list of points
                bounding_polygon_xml = doc.createElementNS(namespace, "bounding_polygon")
                for point in self.bounding_polygon.coords :
                    point_xml = doc.createElementNS(namespace, "point")
                    point_xml.setAttribute("x",str(point[0]))
                    point_xml.setAttribute("y",str(point[1]))
                    bounding_polygon_xml.appendChild(point_xml)
                space_xml.appendChild(bounding_polygon_xml)

                # list of linesegments
                space_representation_xml = doc.createElementNS(namespace, "space_representation")
                for line in self.linesegments :
                    space_representation_xml.appendChild(line.toxml(doc, namespace))
                space_xml.appendChild(space_representation_xml)

            portals_xml = doc.createElementNS(namespace, "portals")
            for portal in self.portals :
                portals_xml.appendChild(portal.toxml(doc, namespace))
            space_xml.appendChild(portals_xml)

            self.xml = space_xml
            return self.xml

    def plot(self, figure, color = None, edge_color = None) :
        #TODO
        pass

    def compute(self) :
        '''
        TODO doc. questa funzione mi calcola tutte le informazioni geometriche di una stanza a partire dall'anello esterno.
        '''
        self.compute = True
        if not(self.points) :
            print('error - empty room')
            exit("Error: No points in the room. This function evaluates geometrical information of the area,\
				and cannot be used only with the topological representation.")
        #X,Y = zip(*self.Points)
        # poligono!
        tmp = [ (p.x,p.y) for p in self.points  ]
        # anello esterno
        self.bounding_polygon = LinearRing(tmp)
        # rispettivo poligono
        self.polygon = Polygon(self.bounding_polygon)
        # elenco di tutte le pareti
        self.linesegments = self.boundingPoly_linesegmets + self.NOTboundingPoly_linesegments
        # area
        self.area = self.polygon.area
        self.perimeter = self.length
        # bounding box come  (minx, miny, maxx, maxy)
        self.bounds = self.polygon.bounds
        # centroide come #POINT
        self.centroid = self.polygon.centroid



    def add_linesegment(self, linesegment, bounding = True, door = None):
        '''
        TODO doc: se bounding e' true allora lo aggiungo al poligono
        # se e' una porta posso ricevere la porta come parametro o da aggiungerla dopo con la funzione add_door
        # l'ordine e' importante.
        '''
        if bounding :
            if not linesegment in  self.boundingPoly_linesegmets or \
                    not linesegment in self.NOTboundingPoly_linesegments :

                # add linesegment to contour
                self.boundingPoly_linesegmets.append(linesegment)
                # and to points
                if not(self.points) :
                    # primo segmento, aggiungo i due punti
                    self.points.append(linesegment.p1)
                    self.points.append(linesegment.p2)
                else :
                    # aggiungo il punto in coda a quelli aggiunti prima
                    if self.points[-1].almost_equals(linesegment.p1) :
                        self.points.append(linesegment.p2)
                    else :
                        exit("Error - Trying to add a linesegment in the bounding polygon but the linesegment is non adjacent to any other segment")

                if linesegment.wp == 'DOOR' and door :
                    add_door(door)

            else :
                exit("Error: - linesegment added twice to a space")
        else :
            if not linesegment in  self.boundingPoly_linesegments or \
                    not linesegment in self.NOTboundingPoly_linesegments :

                # add linesegment to contour
                self.NOTboundingPoly_linesegments.append(linesegment)

                if linesegment.wp == 'DOOR' :
                    exit("Error: door linesegment inside a room")

            else :
                exit("Error: - linesegment added twice to a space")

        # if the geometrical info about the room were already been computed, redo that step.
        if compute :
            self.compute()

    def add_door(self,door) :
        '''
        o aggiungo la porta dalla funzione add_linesegment, oppure la aggiungo da qui DOPO aver aggiunto il linesegment
        se ho una mappa topologica, invece, non ci deve essere un line_segment di riferimento.
        '''
        linesegments_id = [x.id for x in self.boundingPoly_linesegmets]
        if not door in self.doors  and door.id in linesegments_id :
            self.doors.append(door)
        else :
            if not door in self.doors :
                # porta aggiunta due volte
                exit("Error: - the door was already added ")
            else:
                # non esiste il segmento relativo all'id della porta. due casi:

                if self.boundingPoly_linesegmets == [] :
                    # Caso 1: ho solo la mappa topologica, non ho segmenti.
                    self.doors.append(door)
                else :
                    # Caso 2: manca il segmento ma ne ho altri. errore.
                    exit("Error: the linesegments of the door does not belong to the space")

    def set_centroid(self,centroid) :
        '''
        nel caso della mappa topologica e basta, o per altri motivi, potrei volere settare il centroide ad un valore separato
        '''
        if self.centroid :
            print("Warning. Centroid already been set")
        self.centroid = centroid

class floor(object) :

    def __init__(self,floor_number = None ) :
        # id dell piano
        self.id = uuid.uuid4()
        # numero del piano. se non lo specifico lo lascio a None
        self.floor_number = floor_number
        # elenco dei punti della stanza
        self.points = []
        # tutti i linesegments che fanno parte del bordo, falcoltativo, puo' essere None
        self.linesgments = []
        # le porte
        self.doors = []
        # se e' True, ho gia' aggiunto tutto al piano e ne calcolo le informazioni
        self.compute = False
        # perimetro della stanza.
        self.bounding_polygon = None
        # poligono della stanza (simile a boundinpoly ma diverso)
        self.polygon = None
        # centroide. se e' la mappa topologica, lo prendo dal layout.
        self.centroid = None
        # puntatore alle stanze che formao il piano
        self.spaces = []
        # mappa topologica del piano
        self.topological_map
        # xml del piano
        self.xml  = None

def toxml(self, doc, namespace) :
    if self.xml :
        return self.xml
    else :

        floor_xml = doc.createElementNS(namespace, "floor")
        floor_xml.setAttribute("id",str(self.id))
        if self.floor_number :
            floor_number_xml = doc.createElementNS(namespace,"floor_number")
            floor_number_xml.appendChild(doc.createTextNode(str(self.floor_number)))
            floor_xml.appendChild(floor_number_xml)
        if self.centroid :
            centroid_xml = doc.createElementNS(namespace, "centroid")
            centroid_xml.setAttribute("x",str(self.centroid.x))
            centroid_xml.setAttribute("y",str(self.self.centroid.y))
            floor_xml.appendChild(centroid_xml)
        if self.compute :
            # bounding box come  (minx, miny, maxx, maxy)
            minx,miny,maxx,maxy = self.bounds
            boundingBox_xml = doc.createElementNS(namespace, "boundingBox")
            maxx_xml = doc.createElementNS(namespace, "maxx")
            point_xml = doc.createElementNS(namespace, "point")
            point_xml.setAttribute("x",str(maxx))
            point_xml.setAttribute("y",str(miny))
            maxx_xml.appendChild(point_xml)
            boundingBox_xml.appendChild(maxx_xml)
            maxy_xml = doc.createElementNS(namespace, "maxy")
            point_xml = doc.createElementNS(namespace, "point")
            point_xml.setAttribute("x",str(maxx))
            point_xml.setAttribute("y",str(maxy))
            maxy_xml.appendChild(point_xml)
            boundingBox_xml.appendChild(maxy_xml)
            minx_xml = doc.createElementNS(namespace, "minx")
            point_xml = doc.createElementNS(namespace, "point")
            point_xml.setAttribute("x",str(minx))
            point_xml.setAttribute("y",str(maxy))
            minx_xml.appendChild(point_xml)
            boundingBox_xml.appendChild(min_xml)
            miny_xml = doc.createElementNS(namespace, "miny")
            point_xml = doc.createElementNS(namespace, "point")
            point_xml.setAttribute("x",str(minx))
            point_xml.setAttribute("y",str(miny))
            miny_xml.appendChild(point_xml)
            boundingBox_xml.appendChild(mint_xml)

            floor_xml.appendChild(boundingBox_xml)
        if self.compute :
            data_xml = doc.createElementNS(namespace, "data")
            area_xml = doc.createElementNS(namespace, "area")
            area_xml.appendChild(doc.createTextNode(str(self.area)))
            data_xml.appendChild(area_xml)
            perimeter_xml = doc.createElementNS(namespace, "perimeter")
            perimeter.appendChild(doc.createTextNode(str(self.perimeter)))
            data_xml.appendChild(perimeter_xml)

            floor_xml.appendChild(data_xml)
        if self.linesegments:
            # contour - list of points
            bounding_polygon_xml = doc.createElementNS(namespace, "bounding_polygon")
            for point in self.bounding_polygon.coords :
                point_xml = doc.createElementNS(namespace, "point")
                point_xml.setAttribute("x",str(point[0]))
                point_xml.setAttribute("y",str(point[1]))
                bounding_polygon_xml.appendChild(point_xml)
            floor_xml.appendChild(bounding_polygon_xml)

            # list of linesegments
            space_representation_xml = doc.createElementNS(namespace, "space_representation")
            for line in self.linesegments :
                space_representation_xml.appendChild(line.toxml(doc, namespace))
            floor_xml.appendChild(space_representation_xml)

        portals_xml = doc.createElementNS(namespace, "portals")
        for portal in self.portals :
            portals_xml.appendChild(portal.toxml(doc, namespace))
        floor_xml.appendChild(portals_xml)

        spaces_xml = doc.createElementNS(namespace,"spaces")
        for space in self.spaces :
            spaces_xml.appendChild(space.toxml(doc, namespace))
        floor_xml.appendChild(spaces_xml)

        self.xml = floor_xml
        return self.xml


    def compute(self) :
        '''
        TODO doc. questa funzione mi calcola tutte le informazioni geometriche di una stanza a partire dall'anello esterno.
        '''
        self.compute = True
        if not(self.points) :
            print('error - empty room')
            exit("Error: No points in the room. This function evaluates geometrical information of the area,\
				and cannot be used only with the topological representation.")
        #X,Y = zip(*self.Points)
        # poligono!
        tmp = [ (p.x,p.y) for p in self.points  ]
        # anello esterno
        self.bounding_polygon = LinearRing(tmp)
        # rispettivo poligono
        self.polygon = Polygon(self.bounding_polygon)
        # area
        self.area = self.polygon.area
        self.perimeter = self.length
        # bounding box come  (minx, miny, maxx, maxy)
        self.bounds = self.polygon.bounds
        # centroide come #POINT
        self.centroid = self.polygon.centroid


    def compute_topological_map(self, colors = None ):
        # TODO CHECK
        # CREO LA MAPPA TOPOLOGICA DEL PIANO CON IGRAPH.
        if colors :
            node_id_list = []
            label_list = []
            label_RC_list = []
            edges = []
            for s in spaces :
                node_id_list.append(s.id)
                label_list.append(s.label)
                label_RC_list.append(s.type)
                for d in s.doors :
                    edges.append((d.first_id,d.second_id))
            self.topological_map = TopologicalMap(node_id_list,label_list,label_RC_list,edges,colors)
        else :
            node_id_list = []
            label_list = []
            label_RC_list = []
            edges = []
            for s in spaces :
                node_id_list.append(s.id)
                label_list.append(s.label)
                label_RC_list.append(s.type)
                for d in s.doors :
                    edges.append((d.first_id,d.second_id))
            self.topological_map = topologicalMap(node_id_list,label_list,label_RC_list,edges)
        return self.topological_map

    def add_space(self,space) :
        if not space in self.spaces :
            self.spaces.append(space)
        else :
            exit("Error - Space added twice to the same floor")

    def add_linesegment(self, linesegment, door = None):
        '''
        TODO doc
        # l'ordine e' importante.
        '''
        if not linesegment in  self.linesegments :
            # add linesegment to contour
            self.linesegments.append(linesegment)
            # and to points
            if not(self.points) :
                # primo segmento, aggiungo i due punti
                self.points.append(linesegmet.p1)
                self.points.append(linesegment.p2)
            else :
                # aggiungo il punto in coda a quelli aggiunti prima
                if self.points[-1].almost_equals(linesegment.p1) :
                    self.points.append(linesegment.p2)
                else :
                    exit("Error - Trying to add a linesegment in the bounding polygon but the linesegment is non adjacent to any other segment")

            if linesegment.wp == 'DOOR' and door :
                add_door(door)

        else :
            exit("Error: - linesegment added twice to a space")

        # if the geometrical info about the room were already been computed, redo that step.
        if compute :
            self.compute()

    def add_door(self,door) :
        '''
        o aggiungo la porta dalla funzione add_linesegment, oppure la aggiungo da qui DOPO aver aggiunto il linesegment
        se ho una mappa topologica, invece, non ci deve essere un line_segment di riferimento.
        '''
        linesegments_id = [x.id for x in self.boundingPoly_linesegmets]
        if not door in self.doors  and door.id in linesegments_id :
            self.doors.append(door)
        else :
            if not door in self.doors :
                # porta aggiunta due volte
                exit("Error: - the door was already added ")
            else:
                # non esiste il segmento relativo all'id della porta. due casi:

                if self.boundingPoly_linesegmets == [] :
                    # Caso 1: ho solo la mappa topologica, non ho segmenti.
                    self.doors.append(door)
                else :
                    # Caso 2: manca il segmento ma ne ho altri. errore.
                    exit("Error: the linesegments of the door does not belong to the space")

    def set_centroid(self,centroid) :
        '''
        nel caso della mappa topologica e basta, o per altri motivi, potrei volere settare il centroide ad un valore separato
        '''
        if self.centroid :
            print("Warning. Centroid already set")
        self.centroid = centroid

class building(object) :

    def __init__(self, name, typeB, topological = True, info = False, addess = None, city = None, country = None, \
                 construction_date = None, scale_pixel = None, scale_meters = None, other_info = None, color_label_Dict = None) :
        '''
        Info about a single building
        '''
        self.id = uuid.uuid4()
        # iff topological is true I have only the topological map of the environment (no geometrical features)
        self.topological = topological
        #building type
        self.type = typeB
        self.name = name
        # da qui in poi tutte le info sono facoltative
        # se info e' true allora almeno qualche info c'e'
        self.info = info
        self.address = address
        self.city = city
        self.country = country
        self.construction_date = construction_date
        self.scale_pixel = scale_pixel
        self.scale_meters = scale_meters
        self.other_info = other_info
        self.floors = []
        # un dizionario con chiave la label (tutte), e come valore un colore. serve per plottare le cose.
        self.colors = color_label_Dict
        self.topological_maps = None
        self.xml = None

    def compute_topological_maps(self):
        for f in self.floors :
            if self.colors :
                f.compute_topological_map(self.colors)
            else :
                f.compute_topological_map()
            self.topological_maps.append(f.topological_map)
        return self.topological_maps


    def toxml(self, doc, namespace) :
        if self.xml :
            return self.xml
        else :
            building_xml = doc.createElementNS(namespace, "building")
            name_xml = doc.createElementNS(namespace, "name")

            if self.info :
                if self.scale_meters and self.scale_pixel :
                    scale_xml = doc.createElementNS(namespace,"scale")

                    represented_xml = doc.createElementNS(namespace,"represented_distance")
                    value_xml = doc.createElementNS(namespace,"value")
                    um_xml = doc.createElementNS(namespace,"um")
                    value_xml.appendChild(doc.createTextNode(str(self.scale_pixel)))
                    um_xml.appendChild(doc.createTextNode(str("pixel")))
                    represented_xml.appendChild(value_xml)
                    represented_xml.appendChild(um_xml)
                    scale_xml.appendChild(represented_xml)

                    real_xml = doc.createElementNS(namespace,"real_distance")
                    value_xml = doc.createElementNS(namespace,"value")
                    um_xml = doc.createElementNS(namespace,"um")
                    value_xml.appendChild(doc.createTextNode(str(self.scale_meters)))
                    um_xml.appendChild(doc.createTextNode(str("pixel")))
                    real_xml.appendChild(value_xml)
                    real_xml.appendChild(um_xml)
                    scale_xml.appendChild(real_xml)

                    building_xml.appendChild(scale_xml)

                info_xml = doc.createElementNS(namespace,"info")
                if self.address or self.city or self.country :
                    location_xml = doc.createElementNS(namespace,"info")
                    if self.address :
                        address_xml = doc.createElementNS(namespace,"address")
                        address_xml.appendChild(doc.createTextNode(str(self.address)))
                        location_xml.appendChild(address_xml)
                    if self.city :
                        city_xml = doc.createElementNS(namespace,"city")
                        city_xml.appendChild(doc.createTextNode(str(self.city)))
                        location_xml.appendChild(city_xml)
                    if self.country :
                        country_xml = doc.createElementNS(namespace,"country")
                        country_xml.appendChild(doc.createTextNode(str(self.country)))
                        location_xml.appendChild(country_xml)
                    info_xml.appendChild(location_xml)
                if self.construction_date :
                    construction_date_xml = doc.createElementNS(namespace,"construction_date")
                    construction_date_xml.appendChild(doc.createTextNode(str(self.construction_date)))
                    info_xml.appendChild(construction_date_xml)
                building.appendChild(info_xml)


            building_xml.setAttribute("id",str(self.id))

            building_type_xml = doc.createElementNS(namespace,"building_type")
            building_type_xml.appendChild(doc.createTextNode(str(self.type)))
            building_xml.appendChild(building_type_xml)

            for floor in self.floors :
                building_xml.appendChild(floor.toxml(doc, namespace))

            self.xml = building_xml
            return self.xml

    def plot(self, layout = None) :
        #TODO.
        # Metodi:
        # STAMPO il layout di igraph
        # STAMPO il layout dei centroidi
        # Stampo il layout dei centroidi E le pareti
        # Stampo le pareti.
        # nel caso sa solo topologico...solo igraph vale.
        pass


    def add_floor(self,floor) :
        if not floor in self.floor :
            self.floor.append(floor)
        else :
            exit("Error - Floor added twice to the same building")

class topologicalMap(object) :
    def __init__(self, node_id_list = None, label_list = None, label_RC_list = None, edge_list=None, colors = None) :
        # se ho una lista di iid, aggiungo questi. altrimenti aggiungo len(label_list) nodi un numero progressivo come id.
        # edge_list e' un array di tuple [ (id1, id2), (id2,id4) ] con id dei nodi.
        # se e' tutto none aspetto l'inizializzazione
        # colors e un dizionario di colori. se non lo ho, ho fatto la funzione!
        #
        #def add_node(self,iid,label,RC=None):
        self.init = False
        self.nodes = dict()
        self.labels = dict()
        self.RCs = dict()
        self.edges = dict()
        # numero di nodi aggiunti
        self.count = -1
        self.colors = colors

        # se mi passano tutti i nodi gia con init, aggiungo tutto qui
        if node_id_list and label_list:
            # errore di inizializzazione
            if not edge_list  or len(label_list) != len(node_id_list)  :
                exit("Error: wrong topological map initialization")
            # aggiungo nodi e label uno a uno, ho l'iid di ciascun nodo.
            if not label_RC_list or len(label_RC_list) != len(label_list) :
                for i in range(len(node_id_list)) :
                    self.add_node(node_id_list[i], label_list[i])
            else :
                for i in range(len(node_id_list)) :
                    self.add_node(node_id_list[i], label_list[i],label_RC_list)
            self.add_edge_list(edge_list)
            self.graph = self.createGraph()

        elif label_list :
            # non ho l'id dei nodi, ho solo la lista.  aggiungo tutto batch
            if not edge_list :
                exit("Error: wrong topological map initialization")
            self.add_node_list(label_list)
            #aggiungo i nodi
            self.add_edge_list(edge_list)
            self.graph = self.createGraph()

    def createGraph(self):
        # Crea il grafo con igraph.
        # TODO CHECK SE VA
        if self.init :
            return self.graph
        self.graph = Graph()
        if self.count != len(self.nodes)-1 :
            print(self.count, len(self.nodes), self.nodes)
            exit("error, count and node list don't match")
        self.graph.add_vertices(self.count+1)

        self.edgelist = []

        for i in range(self.count) :
            for j in self.edges[str(i)] :
                if not (int(i), int(j)) in self.edgelist and not (int(j), int(i)) in self.edgelist :
                    self.edgelist.append( (int(i),int(j)) )
        print(self.edgelist)
        print(self.graph)
        self.graph.add_edges(self.edgelist)


        labels = [ self.labels[str(i)] for i in range(self.count+1) ]
        RC_label = [self.RCs[str(i)] for i in range(self.count+1)]
        self.graph.vs["room_label"]=labels
        self.graph.vs["label"]=self.graph.vs["room_label"]
        self.graph.vs["RC_label"]=RC_label

        # se non ho i colori, creo una paletta di colori
        if not self.colors :
            tmp_label_list = set(self.labels.values())
            self.colors = createColorDict(tmp_label_list)

        graphcolors = [self.colors[label] for label in self.graph.vs["label"]]
        self.graph.vs["color"] = graphcolors
        self.layout = self.graph.layout("kamada_kawai")
        self.init = True

        A = self.graph.get_edgelist()
        self.gx = nx.Graph(A)


        return self.graph

    def plotIGraph(self,filename) :
        if self.graph :
            plot(self.graph ,str(filename)+".pdf",layout=layout)
        else :
            print("No Graph yet! You have to create the graph first.")

    def plotMatplotlib(self,ax) :
        # todo check
        # questa stampa la funzione
        # ma non la salva, perche' stampa i subplot

        nodes_poses = []

        for i in range(self.count) :
            nodes_poses.append(self.layout[i])
        x,y = zip(*nodes_poses)

        if not self.colors :
            tmp_label_list = set(self.labels.values())
            self.colors = createColorDict(tmp_label_list)

        labels = [ self.labels[str(i)] for i in range(self.count) ]
        graphcolors = [self.colors[label] for label in labels]


        for j in edgelist :
            x1 = x[j[0]]
            x2 = x[j[1]]
            y1 = y[j[0]]
            y2 = y[j[1]]
            ax.plot([x1,x2],[y1,y2],"k-")
        for j in range(self.count) :
            ax.plot(x[j], y[j],'o', color= graphcolors[j])

        ax.grid(True)
        return True

    def add_node(self,iid,label,RC=None):
        # un nodo come lo definisco?
        if iid in self.nodes.keys() :
            exit("error, added twice the same room")
        self.count += 1
        self.nodes[iid] = self.count
        self.edges[str(self.count)] = []
        self.labels[str(self.count)] = label
        if RC :
            self.RCs[str(self.count)] = RC
        else :
            self.RCs[str(self.count)] = labels_RC_java2012[str(label)]

    def add_node_list(self,labels):
        # funzione che inizializza senza iid o cose simili, solo con un elenco di labels.
        # per passargli una struttura dati semplice.
        self.nodes = dict()
        for l in labels :
            self.count += 1
            self.nodes[str(self.count)] = self.count
            self.edges[str(self.count)] = []
            self.labels[str(self.count)] = l
            self.RCs[str(self.count)] = labels_RC_java2012[str(l)]

    def add_edge(self, id1, id2):
        # i due parametri sono l'iid dei due nodi.
        if not id1 in self.nodes.keys() or not id2 in self.nodes.keys() :
            print(id1, id2, self.nodes.keys())
            exit("error, missing ids")
        index1 = self.nodes[str(id1)]
        index2 = self.nodes[str(id2)]
        if not index2 in self.edges[str(index1)]  :
            self.edges[str(index1)].append(index2)
        if not index1 in self.edges[str(index2)]  :
            self.edges[str(index2)].append(index1)

    def add_edge_list(self,edge_list):
        # parametro: una lista di tuple [(iid1,iid2),(iid3,iid4)]
        for i in edge_list:
            self.add_edge(str(i[0]),str(i[1]))

    def add_special_edge_list(self,special_edge_list) :

        for i in edge_list:
            self.add_edge(str(i[0]),str(i[1]))
        len_es = len(self.graph.es)
        added = []
        new_edges = []
        for i in special_edge_list :
            if not (i[1],i[0]) in added :
                added += [ (i[0],i[1]) ]
        for i,j in added :
            if not (int(i), int(j)) in self.edgelist and not (int(j), int(i)) in self.edgelist :
                self.new_edges.append( (int(i),int(j)) )
        print(self.edgelist)
        print(self.graph)
        self.graph.add_edges(self.edgelist)
        self.graph.es["color"] = ["black" if edge.index >= len_es else "red" for edge in g.es]

    # deve essere un oggetto piu agile di building (e che building ha)
    # contiene una mappa di igraph (di cui chiama le funzioni) e ha poche info. la si istanzia come una mappa di igraph (lista di vertici e di nodi)
    # e la si puo' salvare come XML o come lista di vertici e nodi.
