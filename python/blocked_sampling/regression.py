import numpy as np
import matplotlib.pyplot as plt
from sklearn import datasets, linear_model
from sklearn.preprocessing import PolynomialFeatures
from sklearn.pipeline import Pipeline
from sklearn.neural_network import MLPRegressor
from matplotlib.font_manager import FontProperties
from matplotlib.backends.backend_pdf import PdfPages
import utils

def f(t):
    return 0.00033 * t - 1.25


def linear_regression(X, Y):
    X_polish = []
    Y_polish = []

    for i in range(len(X)):
        if X[i] <= 5000:
            X_polish.append(X[i])
            Y_polish.append(Y[i])
    regr = linear_model.LinearRegression()
    x = np.transpose(np.matrix(X_polish))
    y = np.transpose(np.matrix(Y_polish))
    print len(x)
    print len(y)
    regr.fit(x, y)
    print 'Coefficient:' + str(regr.coef_)
    pdf = PdfPages("./prediction_output/correction_recap_5000.pdf")

    plt.clf()
    plt.cla()
    plt.close()

    t1 = np.arange(0, 10000, 500)

    fig, ax = plt.subplots()
    fontP = FontProperties()
    fontP.set_size(7.0)
    ax.plot(X, Y, 'bo', label='area>5000')
    ax.plot(X_polish, Y_polish, 'ro', label='area<5000')
    ax.set_xlim([0, max(X)+500])
    ax.plot(x, regr.predict(x), 'g-', label='linear regr')
    ax.plot(t1, f(t1), 'b-', label='built regr')
    ax.legend(loc='upper right', prop=fontP)
    ax.grid(True)
    #plt.xticks(np.arange(min(X), max(X) + 500, 1000))
    plt.savefig('prediction_output/simple_regression5000.pdf')
    plt.clf()
    plt.cla()
    plt.close()

    fig, ax = plt.subplots()
    y_cor = np.array(Y)
    y_cor_regr = np.transpose(np.matrix(Y))
    x_cor = np.array(X)
    y_cor -= f(x_cor)
    X_mat = np.transpose(np.matrix(X))
    y_cor_regr -= regr.predict(X_mat)
    regr1 = linear_model.LinearRegression()

    print str(y_cor)
    print str(y_cor_regr)
    ax.plot(x_cor, y_cor, 'bo', label='a>5000')
    ax.plot(x, y-f(x), 'ro', label='a<5000')
    Y_mat = np.transpose(np.matrix(y_cor))
    X_mat = np.transpose(np.matrix(X))
    regr1.fit(X_mat, Y_mat)
    ax.plot(X_mat, regr1.predict(X_mat), 'g-')
    ax.legend(loc='upper right', prop=fontP)
    plt.title('correzione costruita con punti con area < 5000')
    plt.savefig('prediction_output/correction_a_mano_5000.pdf')
    pdf.savefig()

    plt.clf()
    fig, ax = plt.subplots()
    ax.plot(X_mat, y_cor_regr, 'bo', label='a>5000')
    ax.plot(x, y-regr.predict(x), 'ro', label='a<5000')
    regr1.fit(X_mat, y_cor_regr)
    ax.plot(X_mat, regr1.predict(X_mat), 'g-')
    plt.title('correzione con regressione lineare con punti con area < 5000')
    ax.legend(loc='upper right', prop=fontP)
    plt.savefig('prediction_output/correction_linear_regr_5000.pdf')
    pdf.savefig()

    pdf.close()


def plot_regression(X, Y, ax, fig):
    regr = linear_model.LinearRegression()
    regr.fit(X, Y)
    ax.plot(X, regr.predict(X), 'm-', label="linear regression")


def poly_regression(X, Y):
    model = Pipeline([('poly', PolynomialFeatures(degree=3)),
                      ('model', linear_model.LinearRegression())])
    model = model.fit(X, Y)
    plt.clf()
    plt.cla()
    plt.close()
    x_x = np.arange(0, 1.0, 0.01)
    x = np.transpose(np.matrix(x_x))
    fig, ax = plt.subplots()
    ax.plot(X, Y, 'ro')
    ax.plot(x, model.predict(x), 'b-')
    plt.savefig('prediction_output/prove_poly.pdf')


def ransac_regression(X, Y):
    model_ransac = linear_model.RANSACRegressor(linear_model.LinearRegression())
    model_ransac.fit(X, Y)
    inlier_mask = model_ransac.inlier_mask_
    outlier_mask = np.logical_not(inlier_mask)
    line_X = np.arange(0, 1.0, 0.01)
    line_y_ransac = model_ransac.predict(line_X[:, np.newaxis])
    plt.clf()
    plt.cla()
    plt.close()
    fig, ax = plt.subplots()
    ax.plot(X[inlier_mask], Y[inlier_mask], 'go', label='inliers')
    ax.plot(X[outlier_mask], Y[outlier_mask], 'ro', label='outliers')

    ax.plot(line_X, line_y_ransac, 'b-', label='RANSAC regression')
    ax.legend(loc='upper right')
    plt.savefig('prediction_output/prove_ransac.pdf')
    print str(model_ransac.n_trials_)
    print str(model_ransac.estimator_.intercept_)


def neural_net_regression(X, Y, ax, fig, save_name):
    """"
    SUPER PROBLEM!!!!!!!!!!! lbfgs e in generale ogni metodo da risultati diversi ad ogni run, quindi?
    """""
    list_mlp = []
    scores = {}
    for i in range(5):
        list_mlp.append(MLPRegressor(solver='lbfgs'))
        list_mlp[i].fit(X, Y)
        scores[i] = {list_mlp[i].score(X,Y)}
        print scores[i]
    mlp_lbfgs = MLPRegressor(solver='lbfgs')
    mlp_lbfgs.fit(X, Y)
    mlp_sgd = MLPRegressor(solver='sgd')
    mlp_sgd.fit(X, Y)
    mlp_adam = MLPRegressor(solver='adam')
    mlp_adam.fit(X, Y)
    line_X = np.arange(0, 1.0, 0.01)
    y_lbgfs = mlp_lbfgs.predict(line_X[:, np.newaxis])
    y_sgd = mlp_sgd.predict(line_X[:, np.newaxis])
    y_adam = mlp_adam.predict(line_X[:, np.newaxis])
    scalarMap = utils.get_colors(len(list_mlp), 'jet')
    for i in range(len(list_mlp)):
        ax.plot(line_X, list_mlp[i].predict(line_X[:, np.newaxis]), color=scalarMap.to_rgba(i), label=str(i))
    ax.plot(line_X, y_lbgfs, 'b-', label='LBGFS solver')
    ax.plot(line_X, y_sgd, 'g-', label='SGD solver')
    ax.plot(line_X, y_adam, 'm-', label='ADAM solver')

    with open('prediction_output/nn_' + save_name + '.txt', 'wb') as f:
        for val in line_X:
            pred = round(mlp_lbfgs.predict(val), 4)
            f.write(str(val) + '\t' + str(pred) + '\n')





