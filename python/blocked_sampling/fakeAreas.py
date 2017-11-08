'''
in graph_name_dict ci metto dentro
'''
import matplotlib.pyplot as plt
import numpy as np
import math
import cmath
import glob
import pickle
from matplotlib.font_manager import FontProperties
from numpy.core.fromnumeric import size
from matplotlib.backends.backend_pdf import PdfPages
import regression


import networkx as nx

from utils import *



def read_matlab_graph(txt_file, numbers):
    '''
    riceve un indirizzo di un file di testo e restituisce il set di labels
    '''
    fileTXT = open(txt_file, 'r')

    A = []
    for line in fileTXT:
        A.append([int(i) for i in line[:-1].split(',')])

    N = len(A[0])
    node_list = range(N)

    label_set = []
    for i in xrange(N):
        attributes = numbers[A[i][i]]
        label_set.append(attributes['label'])
    return label_set


def plot_histograms(select_numbers=-1):
    graph_names = open('./files/filenamesgraphsnumber.txt')
    graph_name_dict = dict()
    for i in graph_names:
        graph_name_dict[i.split()[1]] = i.split()[0]

    # leggo i file da folder	 per le aree
    real_areas = pickle.load(open('./files/real_area.p', 'rb'))
    areas_dict = pickle.load(open('./files/space_areas.p', 'rb'))
    # area predetta
    area_log = {}
    # area reale
    real_area_log = {}
    # area esplorata media
    area_p_log = {}
    # area totale media (fake)
    area_f_log = {}

    average_hist = pickle.load(open('./files/average_hist.p', 'rb'))

    # ottengo il dizionario delle label
    (letters, numbers) = get_label_dict()

    numbgraph = 50
    for ii in xrange(1, numbgraph):
        num_g = ii
        if select_numbers != -1:
            num_g = select_numbers
        original_graph = graph_name_dict[str(num_g)]
        original_area = real_areas[original_graph]
        real_area_log[original_graph] = original_area
        area_log[original_graph] = []
        area_p_log[original_graph] = []

        # CARICO IL GRAFO ORIGINALE
        original_graph_name = "./dataset/TXT/grafo_" + str(num_g) + ".txt"

        real_graph_label_set = read_matlab_graph(original_graph_name, numbers)

        # calcolo la area fittizia
        freal_area = 0
        for i in real_graph_label_set:
            freal_area += areas_dict[i][0]
        area_f_log[original_graph] = freal_area

        list_of_hists = []
        it = 1
        original_hist = pickle.load(open("./Hist/" + original_graph.split('.')[0] + '.p', "rb"))
        for txt_file in glob.glob('prediction/Graph-' + str(
                num_g) + '/Predict/Prediction_results_/*/Grafi finali prediz/*.txt'):
            print 'open', txt_file
            # OTTENGO FILE PREDIZIONE PARZIALE
            file_pred = txt_file.split('/')
            file_pred[-2] = 'Grafi espl durante prediz'
            file_pred[-1] = "grafo_esplorato_" + str(txt_file.split('_')[-1]).split('.')[0] + ".txt"
            file_pred_str = '/'.join(file_pred)

            print 'corresponds to ', original_graph
            txt_name = txt_file.split('/')[-1]
            print txt_name

            # GRAFO PREDETTO
            label_set = read_matlab_graph(txt_file, numbers)

            # calcolo la area predetta
            fake_area = 0
            for i in label_set:
                fake_area += areas_dict[i][0]

            area_log[original_graph].append(fake_area)

            # GRAFO ESPLORATO
            part_label_set = read_matlab_graph(file_pred_str, numbers)

            # calcolo la area esplorata parzialmente  (con le medie)
            part_fake_area = 0
            for i in part_label_set:
                part_fake_area += areas_dict[i][0]

            area_p_log[original_graph].append(part_fake_area)

            # operazioni per il plot degli istogrammi
            spaces_hist = dict()
            for i in letters.keys():
                spaces_hist[i] = 0
            for i in label_set:
                spaces_hist[i] += 1

            # plot_multibarchart(original_hist,spaces_hist,filename = "./prediction_output/hist/"+original_graph.split('.')[0]+"_"+str(it)+".pdf")
            # plot_multibarchart(original_hist,spaces_hist,filename = "./prediction_output/hist_average/"+original_graph.split('.')[0]+"_"+str(it)+"_average.pdf",average = True)
            list_of_hists.append(spaces_hist)

            # plot jacopo
            # ordino le keys per average;
            import operator
            sorted_avg = sorted(average_hist.items(), key=operator.itemgetter(1), reverse=True)
            average_hist_cp = dict()
            spaces_hist_cp = dict()
            original_hist_cp = dict()
            key_order = []
            for i in sorted_avg:
                key = i[0]
                average_hist_cp[key] = average_hist[key]
                spaces_hist_cp[key] = spaces_hist[key]
                original_hist_cp[key] = original_hist[key]
                key_order.append(i[0])

            # plot_multibarchart(original_hist_cp,[average_hist_cp,spaces_hist_cp],filename = "./prediction_output/hist_OMP/"+original_graph.split('.')[0]+"_"+str(it)+"_OMP.pdf",average = True,key_order = key_order)


            it += 1
        # plot_multibarchart(original_hist,list_of_hists, filename = "./prediction_output/hist/"+original_graph.split('.')[0]+".pdf")
        # plot_multibarchart(original_hist,list_of_hists, filename = "./prediction_output/hist_average/"+original_graph.split('.')[0]+"_average.pdf",average = True)

        # plot jacopo
        # plot_multibarchart(original_hist,average_hist, filename = "./prediction_output/hist_mean/"+original_graph.split('.')[0]+"_orig.pdf",average = True)
        # if len(list_of_hists)>=1 :
        #	plot_multibarchart(list_of_hists[0],list_of_hists[1:], filename = "./prediction_output/hist_mean/"+original_graph.split('.')[0]+"_pred.pdf",average = True)

        print "DECOMMENTAMI"
        if select_numbers != -1:
            print "Done - EXIT"
            break
        print "Done"

    print "SAVING"
    # stampo le aree predette
    savestr = str()
    save_dict = []
    print "formato"
    print "area vera, area vera (media), area predetta (media), area explorata (media),  errore (predetta-vera) (media), perc esplorata"
    for i in area_log.keys():
        # real_area_log = {}
        # area esplorata media
        # area_p_log = {}
        # area totale media (fake)
        # area_f_log = {}
        # print i
        for j in xrange(len(area_log[i])):
            perc_explo = float(area_p_log[i][j]) / float(area_f_log[i])
            errore_medio = float(area_log[i][j]) - float(area_f_log[i])
            savestr += str(
                [real_area_log[i], area_f_log[i], area_p_log[i][j], area_log[i][j], errore_medio, perc_explo])
            print real_area_log[i], area_f_log[i], area_p_log[i][j], area_log[i][
                j], errore_medio, perc_explo, errore_medio / area_f_log[i]
            save_dict.append([(i, j),
                              [real_area_log[i], area_f_log[i], area_p_log[i][j], area_log[i][j], errore_medio,
                               perc_explo]])
    out_file = open("./prediction_output/area_average_pred.txt", "w")
    out_file.write(savestr)
    out_file.close()
    for i in save_dict:
        print i

    pdf = PdfPages("./prediction_output/error_recap.pdf")

    # plotto errore
    X = []
    Y = []

    plt.clf()
    plt.cla()
    plt.close()
    fig, ax = plt.subplots()

    ax.set_xlim([0, 1])
    for i in save_dict:
        Y.append(abs(i[1][4]) / i[1][1])
        X.append(i[1][5])
    ax.plot(X, Y, 'ro')
    plt.title("Absolute error")
    pdf.savefig()
    fig.savefig('./prediction_output/error_abs.pdf')

    """
    ERRORE SENZA ABS
    """
    X = []
    Y = []

    plt.clf()
    plt.cla()
    plt.close()
    fig, ax = plt.subplots()

    ax.set_xlim([0, 1])
    for i in save_dict:
        Y.append(i[1][4] / i[1][1])
        X.append(i[1][5])
    ax.plot(X, Y, 'ro')
    plt.title("Error with sign")
    pdf.savefig()
    fig.savefig('./prediction_output/error.pdf')

    # plotto errore + mean + avg
    X = []
    Y = []

    plt.clf()
    plt.cla()
    plt.close()
    fig, ax = plt.subplots()

    ax.set_xlim([0, 1])
    for i in save_dict:
        Y.append(abs(i[1][4]) / i[1][1])
        X.append(i[1][5])
    ax.plot(X, Y, 'ro')
    Y_avg = np.average(Y)
    ax.plot([0, 1], [Y_avg] * 2, 'g-')
    ax.plot([0, 1], [1, 0], 'b-')
    plt.title("errore + mean + avg")
    pdf.savefig()
    #plt.show()
    fig.savefig('./prediction_output/error_avg.pdf')
    """
    ------------QUI INIZIA AGGIUNTA DI CODICE----------------------
    """

    """
    ERRORE ABS CON COLORI!!!! QUASI TUTTE LE COLOR MAP VENGONO MALE
    """
    plt.clf()
    plt.cla()
    plt.close()
    fig, ax = plt.subplots()
    scalarMap = get_colors(colormap='hsv', numofcolors=len(graph_name_dict))
    print graph_name_dict
    # THIS perche' era sbagliato e tutto il dizionario riferiva a grafo 49
    name_graph_dict = {v: k for k, v in graph_name_dict.iteritems()}
    print scalarMap.get_clim()
    handles = []
    labels = []
    for i in save_dict:
        y = abs(i[1][4]) / i[1][1]
        x = i[1][5]
        plot = ax.scatter(x, y, color=scalarMap.to_rgba(name_graph_dict[i[0][0]]), edgecolor='k')

        if i[0][0] not in labels:
            handles.append(plot)
            labels.append(i[0][0])
    ax.set_ylim([0, 2.5])
    box = ax.get_position()
    ax.set_position([box.x0, box.y0, box.width * 0.8, box.height])
    fontP = FontProperties()
    fontP.set_size(5.0)
    ax.legend(handles, labels, loc='center left', bbox_to_anchor=(1, 0.5), prop=fontP)
    # plt.show()
    plt.title("ERRORE con COLori per ambiente")
    pdf.savefig()
    fig.savefig('./prediction_output/error_abs_colored.pdf')

    """
    TODO: errore eliminando sopra soglia costante OK
    TODO: errore con la magnitudine OK
    TODO: filtro sui grafi? OK
    TODO: linear regression OK
    """
    # errore senza i fuorisoglia
    # la soglia al 60 %
    X = []
    Y = []

    plt.clf()
    plt.cla()
    plt.close()
    fig, ax = plt.subplots()

    ax.set_xlim([0, 1])
    ax.set_ylim([0, 2.5])

    scalarMap = get_colors(colormap='hsv', numofcolors=len(graph_name_dict))
    print graph_name_dict
    # THIS perche' era sbagliato e tutto il dizionario riferiva a grafo 49
    name_graph_dict = {v: k for k, v in graph_name_dict.iteritems()}
    print scalarMap.get_clim()
    handles = []
    labels = []
    for i in save_dict:
        y = abs(i[1][4]) / i[1][1]
        x = i[1][5]
        if x < 0.6:
            plot = ax.scatter(x, y, color=scalarMap.to_rgba(name_graph_dict[i[0][0]]), edgecolor='k')

            if i[0][0] not in labels:
                handles.append(plot)
                labels.append(i[0][0])
    box = ax.get_position()
    ax.set_position([box.x0, box.y0, box.width * 0.8, box.height])
    fontP = FontProperties()
    fontP.set_size(5.0)
    ax.legend(handles, labels, loc='center left', bbox_to_anchor=(1, 0.5), prop=fontP)
    # plt.show()
    plt.title("soglia al 60% sulle x")
    pdf.savefig()
    fig.savefig('./prediction_output/error_abs_no_outlier.pdf')

    # plot colormap su grandezza delle aree vere medie:
    plt.clf()
    plt.cla()
    plt.close()
    fig, ax = plt.subplots()

    ax.set_xlim([0, 1])
    ax.set_ylim([0, 2.5])
    areas = []
    for i in save_dict:
       areas.append(i[1][1])
    vmin = min(areas)
    vmax = max(areas)
    iteratore = colors_iterator(vmin, vmax, colormap='hot_r')
    handles = []
    labels = []
    area_list = []
    label_list = []

    for i in save_dict:
        y = abs(i[1][4]) / i[1][1]
        x = i[1][5]
        plot = ax.scatter(x, y, color=iteratore(i[1][1]), edgecolor='k', s=25)
        if i[1][1] not in area_list:
            label_list.append(((round(i[1][1], 1), i[0][0]), plot))
            area_list.append(i[1][1])

    sorted_list = sorted(label_list, key=lambda x: x[0][0])
    for el in sorted_list:
        handles.append(el[1])
        labels.append(el[0])
    box = ax.get_position()
    ax.set_position([box.x0, box.y0, box.width * 0.8, box.height])
    ax.legend(handles, labels, loc='center left', bbox_to_anchor=(1, 0.5), prop=fontP)
    fontP = FontProperties()
    fontP.set_size(5.0)

    plt.title('colori con magnitudine su area vera media')
    pdf.savefig()
    fig.savefig('./prediction_output/error_abs_magnitude.pdf')

    # plot colormap su grandezza delle aree predette medie:
    plt.clf()
    plt.cla()
    plt.close()
    fig, ax = plt.subplots()

    ax.set_xlim([0, 1])
    ax.set_ylim([0, 2.5])
    areas = []
    for i in save_dict:
        areas.append(i[1][2])
    vmin = min(areas)
    vmax = max(areas)
    iteratore = colors_iterator(vmin, vmax, colormap='hot_r')
    handles = []
    labels = []
    area_list = []
    label_list = []

    for i in save_dict:
        y = abs(i[1][4]) / i[1][1]
        x = i[1][5]
        plot = ax.scatter(x, y, color=iteratore(i[1][2]), edgecolor='k', s=25)
        if i[1][2] not in area_list:
            label_list.append(((round(i[1][2], 1), i[0][0]), plot))
            area_list.append(i[1][1])

    sorted_list = sorted(label_list, key=lambda x: x[0][0])
    for el in sorted_list:
        handles.append(el[1])
        labels.append(el[0])
    box = ax.get_position()
    ax.set_position([box.x0, box.y0, box.width * 0.8, box.height])
    ax.legend(handles, labels, loc='center left', bbox_to_anchor=(1, 0.5), prop=fontP)
    fontP = FontProperties()
    fontP.set_size(3.0)

    plt.title('colori con magnitudine su area predetta media')
    pdf.savefig()
    fig.savefig('./prediction_output/error_abs_magnitude_prediction.pdf')

    # PLOT NUOVO (SONO 2) SULLA X MAGNITUDINE DELL'AREA ESPLORATA MEDIA, Y ERRORE SIA ABS CHE NO ---->
    # SERVE i[1][3] (area explorata media) e i[1][4]/i[1][1]

    X = []
    Y_abs = []
    Y = []
    X_regr = []
    Y_regr = []

    plt.clf()
    plt.cla()
    plt.close()

    fig, ax = plt.subplots()
    for i in save_dict:
        Y.append(i[1][4] / i[1][1])
        Y_abs.append(abs(i[1][4]) / i[1][1])
        X.append(i[1][3])

    ax.plot(X, Y, 'ro')
    plt.title('Errore con segno su area esplorata media')
    fig.savefig('prediction_output/err_vs_expl_area.pdf')
    pdf.savefig()

    plt.clf()
    plt.cla()
    plt.close()
    fig, ax = plt.subplots()
    ax.plot(X, Y_abs, 'ro')
    plt.title('Errore assoluto su area esplorata media')
    fig.savefig('prediction_output/abs_err_vs_expl_area')
    pdf.savefig()

    pdf.close()

    regression.linear_regression(X, Y)

    X = []
    Y = []
    X_corr = []
    Y_abs = []

    plt.clf()
    plt.cla()
    plt.close()

    pdf = PdfPages("prediction_output/error_estimators_NN.pdf")

    fig, ax = plt.subplots()

    """
    CORREZIONE DELL'ERRORE IN PERCENTUALE E REGRESSIONI LINEARI
    """

    fontP.set_size(10.0)

    for i in save_dict:
        Y.append(i[1][4] / i[1][1])
        Y_abs.append(abs(i[1][4]) / i[1][1])
        X.append(i[1][5])
        X_corr.append(i[1][3])
    ax.plot(X, Y, 'ro')
    #ax.plot([0,1], [np.mean(Y), np.mean(Y)], 'g-', label='mean error')
    #ax.plot([0,1], [1,0], 'b-')
    ml_X = np.transpose(np.matrix(X))
    ml_Y = np.transpose(np.matrix(Y))
    regression.neural_net_regression(ml_X, ml_Y, ax, fig, "err")
    # regression.plot_regression(np.transpose(np.matrix(X)), np.transpose(np.matrix(Y)), ax, fig)
    plt.title("Error with sign")
    plt.legend()
    ax.legend(loc='upper right', prop=fontP)

    pdf.savefig()

    plt.clf()
    plt.cla()
    plt.close()
    fig, ax = plt.subplots()
    ax.plot(X, Y_abs, 'ro')
    #ax.plot([0,1], [np.mean(Y_abs), np.mean(Y_abs)], 'g-', label='mean error')
    #ax.plot([0,1], [1,0], 'b-')
    ml_X = np.transpose(np.matrix(X))
    ml_Y = np.transpose(np.matrix(Y_abs))
    regression.neural_net_regression(ml_X, ml_Y, ax, fig, "abs_err")
    # regression.plot_regression(np.transpose(np.matrix(X)), np.transpose(np.matrix(Y_abs)), ax, fig)
    plt.title("Absolute value of error")
    ax.legend(loc='upper right', prop=fontP)

    pdf.savefig()

    plt.clf()
    plt.cla()
    plt.close()
    np_X_corr = np.transpose(np.matrix(X_corr))
    np_X = np.transpose(np.matrix(X))
    np_Y = np.transpose(np.matrix(Y))
    np_Y_corr = np_Y - regression.f(np_X_corr)
    np_abs_Y_corr = abs(np_Y) - abs(regression.f(np_X_corr))
    avg_Y = np.average(np_Y)
    abs_avg_Y = np.average(abs(np_Y))
    # print str(avg_Y)

    fig, ax = plt.subplots()
    ax.plot(np_X, np_Y_corr, 'ro', label="points with correction")
    plt.title("Error with correction")
    #ax.plot([0,1], [avg_Y, avg_Y], 'g-', label='mean error')
    #ax.plot([0,1], [1,0], 'b-')
    regression.neural_net_regression(np_X, np_Y_corr, ax, fig, "err_corr")
    #regression.plot_regression(np_X, np_Y_corr, ax, fig)
    ax.legend(loc='upper right', prop=fontP)
    pdf.savefig()


    plt.clf()
    plt.cla()
    plt.close()
    fig, ax = plt.subplots()
    ax.plot(np_X, abs(np_Y_corr), 'ro', label="points with correction")
    plt.title("Absolute value of error with correction")
    # ax.plot([0, 1], [abs_avg_Y, abs_avg_Y], 'g-', label='mean error')
    # ax.plot([0, 1], [1, 0], 'b-')
    # regression.plot_regression(np_X, abs(np_Y_corr), ax, fig)
    regression.neural_net_regression(np_X, abs(np_Y_corr), ax, fig, "abs_err_corr")
    ax.set_ylim([-0.1, 2.0])
    ax.legend(loc='upper right', prop=fontP)
    pdf.savefig()
    regression.poly_regression(np_X, np_Y)
    regression.ransac_regression(np_X, np_Y)

    pdf.close()

    """
        PLOT ERRORE ESTIMATORE AREA MEDIA
        in save_dict ci sono come chiave (nome_ambiente, run) per cui se dovessi prendere i dati cosi come sono
        mi troverei in una situazione scomoda in cui alcuni ambienti contano di piu. faccio un po di
        preprocessing per avere solo una volta ogni ambiente
    """
    pdf = PdfPages('prediction_output/error_estimators_mean.pdf')
    # dict fatto con (ambiente, area vera media)
    env_dict = {}
    for i in save_dict:
        env_dict[i[0][0]] = i[1][1]
    mean = sum(env_dict.values()) / len(env_dict.values())
    # ora calcolo errore per plottare il tutto
    X = []
    Y = []
    Y_abs = []
    plt.clf()
    plt.cla()
    plt.close()

    for i in save_dict:
        X.append(i[1][5])
        Y.append((i[1][1] - mean) / i[1][1])
        Y_abs.append(abs(i[1][1] - mean) / i[1][1])
    fig, ax = plt.subplots()
    plt.title('Error using mean estimator')
    ax.plot(X, Y, 'ro', label='error with mean')
    ax.plot([0, 1], [np.mean(Y), np.mean(Y)], 'g-', label='mean error')
    ax.plot([0, 1], [1, 0], 'b-')
    ax.legend(loc='upper right', prop=fontP)
    pdf.savefig()

    plt.clf()
    plt.cla()
    plt.close()
    fig, ax = plt.subplots()
    plt.title('Absolute value of error using mean estimator, mean = ' + str(mean))
    ax.plot(X, Y_abs, 'ro', label='abs error with mean')
    ax.plot([0, 1], [np.mean(Y_abs), np.mean(Y_abs)], 'g-', label='mean error')
    ax.plot([0, 1], [1, 0], 'b-')
    ax.legend(loc='upper right', prop=fontP)
    pdf.savefig()

    pdf.close()

    with open('prediction_output/environment_list.txt', 'wb') as out_file:
        """
            Il file che viene creato avra in testa la media delle aree e poi la lista delle aree per ogni
            ambiente
        """
        out_file.write('estimated_mean')
        out_file.write('\t')
        out_file.write(str(round(mean, 2)))
        for key, value in env_dict.iteritems():
            out_file.write('\n')
            strings = str(key).split('.')
            out_file.write(strings[0])
            out_file.write('\t')
            out_file.write(str(round(value, 2)))



    """
    ------------------ QUI FINISCE AGGIUNTA------------------------
    """


def main():
    select_numbers = -1
    print "RIMUOVIMI"
    import os
    destination_folder = './prediction_output'
    create_folders = ['hist', 'hist_average', 'hist_mean', 'hist_OMP', 'plot', 'plot_C']
    for i in create_folders:
        SAVE_FOLDER = os.path.join(destination_folder, i)
        if not os.path.exists(SAVE_FOLDER):
            os.mkdir(SAVE_FOLDER)
    print "FINE RIMUOVIMI"
    # select_numbers  = [5,6,24,25]
    if type(select_numbers) == list:
        for i in select_numbers:
            plot_histograms(i)
    else:
        plot_histograms(select_numbers)


if __name__ == '__main__':
    main()
