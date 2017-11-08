%script che esegue più volte la funzione ConfrontaClusterConfigurationFunctionVersion

clust_method_affinity = 'Clustering affinity propagation';
clust_method_spectral = 'Spectral clustering Ncut';

kernel_name_Embedding = 'Kernel_Embedding';
kernel_name_GH = 'Kernel_GraphHopper_linear_1_0';
kernel_name_Kashima = 'Kernel_Kashima_order=5';
kernel_name_Menchetti = 'Kernel_Menc_rad=2_type=all';
kernel_name_NSPDK = 'Kernel_NSPDK_dist=3_rad=2';
kernel_name_WL = 'Kernel_WL_iter=5';

for alpha = 1:4
    str = sprintf('Iterazione %d di 4', alpha);
    disp(str);
        
    %1
    ConfrontaClusterConfigurationFunctionVersion('EmbSubpar0,5ClustAFFINITY0,5', alpha, 200, clust_method_affinity, kernel_name_Embedding);
    
    
    %2
    ConfrontaClusterConfigurationFunctionVersion('EmbSubpar0,5ClustAFFINITY0,7', alpha, 200, clust_method_affinity, kernel_name_Embedding);
    
    
    %3
    ConfrontaClusterConfigurationFunctionVersion('EmbSubpar0,5ClustAFFINITY0,9', alpha, 200, clust_method_affinity, kernel_name_Embedding);
    
    
    %4
    ConfrontaClusterConfigurationFunctionVersion('EmbSubpar0,5Clustpar1,12', alpha, 200, clust_method_spectral, kernel_name_Embedding);
    
    
    %5
    ConfrontaClusterConfigurationFunctionVersion('EmbSubpar0,5Clustpar1,15', alpha, 200, clust_method_spectral, kernel_name_Embedding);
    
    
    %6
    ConfrontaClusterConfigurationFunctionVersion('EmbSubpar0,5Clustpar1,17', alpha, 200, clust_method_spectral, kernel_name_Embedding);
    
    
    %7
    ConfrontaClusterConfigurationFunctionVersion('GHLinear10Subpar0,5ClustAFFINITY0,5', alpha, 200, clust_method_affinity, kernel_name_GH);
    
    
    %8
    ConfrontaClusterConfigurationFunctionVersion('GHLinear10Subpar0,5ClustAFFINITY0,7', alpha, 200, clust_method_affinity, kernel_name_GH);
    
    
    %9
    ConfrontaClusterConfigurationFunctionVersion('GHLinear10Subpar0,5ClustAFFINITY0,9', alpha, 200, clust_method_affinity, kernel_name_GH);
    
    
    %10
    ConfrontaClusterConfigurationFunctionVersion('GHLinear10Subpar0,5Clustpar1,1', alpha, 200, clust_method_spectral, kernel_name_GH);
    
    
    %11
    ConfrontaClusterConfigurationFunctionVersion('GHLinear10Subpar0,5Clustpar1,06', alpha, 200, clust_method_spectral, kernel_name_GH);
    
    
    %12
    ConfrontaClusterConfigurationFunctionVersion('GHLinear10Subpar0,5Clustpar1,12', alpha, 200, clust_method_spectral, kernel_name_GH);
    
    
    %13
    ConfrontaClusterConfigurationFunctionVersion('GHLinear10Subpar0,5Clustpar1,13', alpha, 200, clust_method_spectral, kernel_name_GH);
    
    
    %14
    ConfrontaClusterConfigurationFunctionVersion('GHLinear10Subpar0,5Clustpar1,14', alpha, 200, clust_method_spectral, kernel_name_GH);
    
    
    %15
    ConfrontaClusterConfigurationFunctionVersion('GHLinear10Subpar0,5Clustpar1,15', alpha, 200, clust_method_spectral, kernel_name_GH);
    
    
    %16
    ConfrontaClusterConfigurationFunctionVersion('GHLinear10Subpar0,5Clustpar1,16', alpha, 200, clust_method_spectral, kernel_name_GH);
    
    
    %17
    ConfrontaClusterConfigurationFunctionVersion('KashOrder5Subpar0,5ClustAFFINITY0,5', alpha, 200, clust_method_affinity, kernel_name_Kashima);
    
    
    %18
    ConfrontaClusterConfigurationFunctionVersion('KashOrder5Subpar0,5ClustAFFINITY0,7', alpha, 200, clust_method_affinity, kernel_name_Kashima);
    
    
    %19
    ConfrontaClusterConfigurationFunctionVersion('KashOrder5Subpar0,5ClustAFFINITY0,9', alpha, 200, clust_method_affinity, kernel_name_Kashima);
    
    
    %20
    ConfrontaClusterConfigurationFunctionVersion('KashOrder5Subpar0,5Clustpar1,03', alpha, 200, clust_method_spectral, kernel_name_Kashima);
    
    
    %21
    ConfrontaClusterConfigurationFunctionVersion('KashOrder5Subpar0,5Clustpar1,06', alpha, 200, clust_method_spectral, kernel_name_Kashima);
    
    
    %22
    ConfrontaClusterConfigurationFunctionVersion('KashOrder5Subpar0,5Clustpar1,12', alpha, 200, clust_method_spectral, kernel_name_Kashima);
    
    
    %23
    ConfrontaClusterConfigurationFunctionVersion('MencRad2Type0Subpar0,5ClustAFFINITY0,5', alpha, 200, clust_method_affinity, kernel_name_Menchetti);
    
    
    %24
    ConfrontaClusterConfigurationFunctionVersion('MencRad2Type0Subpar0,5ClustAFFINITY0,7', alpha, 200, clust_method_affinity, kernel_name_Menchetti);
    
    
    %25
    ConfrontaClusterConfigurationFunctionVersion('MencRad2Type0Subpar0,5ClustAFFINITY0,9', alpha, 200, clust_method_affinity, kernel_name_Menchetti);
    
    
    %26
    ConfrontaClusterConfigurationFunctionVersion('MencRad2Type0Subpar0,5Clustpar1,1', alpha, 200, clust_method_spectral, kernel_name_Menchetti);
    
    
    %27
    ConfrontaClusterConfigurationFunctionVersion('MencRad2Type0Subpar0,5Clustpar1,06', alpha, 200, clust_method_spectral, kernel_name_Menchetti);
    
    
    %28
    ConfrontaClusterConfigurationFunctionVersion('MencRad2Type0Subpar0,5Clustpar1,14', alpha, 200, clust_method_spectral, kernel_name_Menchetti);
    
    
    %29
    ConfrontaClusterConfigurationFunctionVersion('NSPDKDist3Rad2Subpar0,5ClustAFFINITY0,5', alpha, 200, clust_method_affinity, kernel_name_NSPDK);
    
    
    %30
    ConfrontaClusterConfigurationFunctionVersion('NSPDKDist3Rad2Subpar0,5ClustAFFINITY0,7', alpha, 200, clust_method_affinity, kernel_name_NSPDK);
    
    
    %31
    ConfrontaClusterConfigurationFunctionVersion('NSPDKDist3Rad2Subpar0,5ClustAFFINITY0,9', alpha, 200, clust_method_affinity, kernel_name_NSPDK);
    
    
    %32
    ConfrontaClusterConfigurationFunctionVersion('NSPDKDist3Rad2Subpar0,5Clustpar1,1', alpha, 200, clust_method_spectral, kernel_name_NSPDK);
    
    
    %33
    ConfrontaClusterConfigurationFunctionVersion('NSPDKDist3Rad2Subpar0,5Clustpar1,02', alpha, 200, clust_method_spectral, kernel_name_NSPDK);
    
    
    %34
    ConfrontaClusterConfigurationFunctionVersion('NSPDKDist3Rad2Subpar0,5Clustpar1,14', alpha, 200, clust_method_spectral, kernel_name_NSPDK);
    
    
    %35
    ConfrontaClusterConfigurationFunctionVersion('WLIter5Subpar0,5ClustAFFINITY0,5', alpha, 200, clust_method_affinity, kernel_name_WL);
    
    
    %36
    ConfrontaClusterConfigurationFunctionVersion('WLIter5Subpar0,5ClustAFFINITY0,7', alpha, 200, clust_method_affinity, kernel_name_WL);
    
    
    %37
    ConfrontaClusterConfigurationFunctionVersion('WLIter5Subpar0,5ClustAFFINITY0,9', alpha, 200, clust_method_affinity, kernel_name_WL);
    
    
    %38
    ConfrontaClusterConfigurationFunctionVersion('WLIter5Subpar0,5Clustpar1,03', alpha, 200, clust_method_spectral, kernel_name_WL);
    
    
    %39
    ConfrontaClusterConfigurationFunctionVersion('WLIter5Subpar0,5Clustpar1,013', alpha, 200, clust_method_spectral, kernel_name_WL);
    
    
    %40
    ConfrontaClusterConfigurationFunctionVersion('WLIter5Subpar0,5Clustpar1,016', alpha, 200, clust_method_spectral, kernel_name_WL);

end