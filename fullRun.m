%% Detection of objects within a scene inpacted by atmospheric turbulence 
% This script takes an input sequence that is degraded by atmospheric
% turbulence and provides the optical flow, compensated optical flow,
% cartoon and texture decompositiona and centroid locations for a moving
% object.
% 
% Author: N Ferrante
% 
% Email: nicholas.b.ferrante@gmail.com

%%
% * |Input sequence| :      Load video sequence as double 3D array

% clc; clear; close all;
 seq=f;

%%
% * |Optical flow| :        The |getFlow(seq, method)| takes an input of a
%                           data sequence (seq) and a string command
%                           (method) and returns an optical flow field of
%                           size (row, column, 2, number of frames)
% 
% * |Options| :
% 
%                           Demon: Demon's algorithm
% 
%                           HS: Horn-Schunck optical flow
% 
%                           TVL1: Total Varience - L1 norm minimizaiton

[flow] = getFlow(seq, 'TVL1');


%%
% * |Camera Motion flow| :  The |getCameraMotion(flow, method)| takes an
%                           input of an optical flow and returns the
%                           optical flow field corresponding to the global
%                           camera motion
% 
% * |Options| :
% 
%                           polynomial: Performs a polynomial fit
% 
%                           gaussian: Takes a low pass gaussian filter as
%                           the camera motion field
% 
%                           analytic: Computes the analytic solution to the
%                           pinhole camera model problem by assuming a
%                           constant focal length and debth of field.

[M] = getCameraMotion(flow, 'gaussian');

% Get the compensated optical flow by removing the flow field corresponding
% to camera motion
flowComp = flow-M;

%%
% * |Cartoon+Texture| :     The |getCartoonTexture(flow, mu, lambda, number
%                           of iterations, method)| provides a decomposition
%                           of a vector field into its homoginous and 
%                           oscilatory components.  Traditionally the 
%                           mu=lambda=1.  Mu is the threshold value that
%                           seperates the space of oscilatory functions
%                           from the space of funcrtions with bounded
%                           variation.  Lambda is the regularization
%                           parameter for the decomposition to stay "close"
%                           to the input flow.  the number of iterations is
%                           normally set to 5, though fewer iterations
%                           will, under most situations, provide similar
%                           results.  Finally the mehtod is a string
%                           arguement that is set to choose the method of
%                           decomposition.
% 
% * |Options| :
% 
%                           wavelet: Wavelet decomposition method using
%                           using db6 wavelets
% 
%                           curvelet: Curvlet decomposition
% 
[u, v] = getCartoonTexture(flowComp, 1, 1, 5, 'curvelet');

%%
% * |Object Detection| :    The |trackInFlow(seq, flow)| performs a detection
%                           method on the input flow and then performs
%                           kalman filtering on the detected locations in
%                           order to track the detected object.
% 
% 

out = trackInFlow(seq, u);
