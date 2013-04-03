% This is a unit test to check the operation of TY_conv_func 

%function [feat, imsize] = TY_conv_func(img, npatch, params);
load('/home/gen/dpatch/dataset15.mat');

%first test image
img = imgs(151).fullpath;
%first patch
npatch = 1;
%15 scene db params
%params = 

%[feat, imsize] = TY_conv_func(img, npatch, params);
[feat, imsize] = conv_func();
keyboard
