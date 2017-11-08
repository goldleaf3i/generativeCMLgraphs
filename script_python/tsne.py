#
#  tsne.py
#
# Implementation of t-SNE in Python. The implementation was tested on Python 2.5.1, and it requires a working
# installation of NumPy. The implementation comes with an example on the MNIST dataset. In order to plot the
# results of this example, a working installation of matplotlib is required.
# The example can be run by executing: ipython tsne.py -pylab
#
#
#  Created by Laurens van der Maaten on 20-12-08.
#  Copyright (c) 2008 Tilburg University. All rights reserved.

import numpy as Math
import pylab as Plot
import matplotlib.cm as cm

def tsne(P = Math.array([])):
    # Initialize variables
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

def plotting():
    cluster_labels = set(labels);
    # iteratore di colori su un insieme grande quanto il numero di cluster
    colors = iter(cm.rainbow(Math.linspace(0, 1, len(cluster_labels))))
    for c in cluster_labels:
        Xc = [];
        Yc = [];
        for i in range(len(Y)):
            if labels[i] == c:
                Xc.append(Y[i][0]);
                Yc.append(Y[i][1]);
        Plot.scatter(Xc[:], Yc[:], 30, color=next(colors), label=c);
    Plot.legend(scatterpoints=1, loc='lower left', fontsize=5);
    Plot.savefig("tsne_scatter_plot.png");

if __name__ == "__main__":
    print("tsne performs symmetric t-SNE on affinity matrix P");
    P = Math.loadtxt("similarity_matrix.txt",delimiter=',');
    labels = Math.loadtxt("cluster_labels.txt",delimiter=',');
    Y = tsne(P);
    plotting();