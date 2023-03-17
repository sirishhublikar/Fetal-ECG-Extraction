clc; clear; close all;
%% Load the dataset and set the variables
x = load('r08_edfm.mat');
fs = 1000;

dn = x.val(1,:); % Desired FECG Signal

% FECG corrupted with noise and MECG
x2 = x.val(2,:);
x3 = x.val(3,:);
x4 = x.val(4,:);
x5 = x.val(5,:);
xn = (x2 + x3 + x4 + x5)/4; % Input to the LMS filter

% z = xcorr(xn); 
% Rxx = toeplitz(z); % Autocorrelation matrix of input
% lambda = max(eig(Rxx));
% upper_limit = 2/lambda % upper limit for mu

order = 100; % Order of the filter
mu = 0.95; % Learning rate (mu)    0 < mu < 2/(lambda)

lms = dsp.LMSFilter(order + 1, 'StepSize', mu, 'Method', 'Normalized LMS', 'WeightsOutputPort', true);

[yn,en,wn] = step(lms, xn', dn');
% fvtool(wn)

%% Plot the results
figure;
subplot (4,1,1), plot (dn(1:3000)) ;
title ('Desired Signal d(n) - (FECG)');
subplot (4,1,2), plot (xn(1:3000));
title ('Signal Corrupted with Noise x(n) ');
subplot (4,1,3), plot (yn(1:3000));
title ('Estimation Signal y(n) - (FECG)');
subplot (4,1,4), plot (en);
title ('Error Signal e(n)');

%% Using Pan-Tompkins to determine Heart Rate of Fetus 

[~, r_ind, ~] = pan_tompkin(en, fs, 0);

total_loc = 0;
for i = 2:length(r_ind)
    range = abs(r_ind(1,i) - r_ind(1,i-1));
    total_loc = total_loc + range;
end

mean_loc = total_loc/(length(r_ind) - 1); 

hr_fecg = (60*1000)/mean_loc;

disp(['Heart Rate of FECG = ' num2str(hr_fecg) ' BPM']);

if hr_fecg > 110 && hr_fecg < 150
    disp('Fetus Heart Rate is normal')
else
    disp('Fetus Heart Rate is Abormal!');
end