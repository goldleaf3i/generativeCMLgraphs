function [K] = kernelFunction(x, y)
sigma = 0.5;
K = exp(-((x-y).^2)/(2*(sigma.^2)));
end