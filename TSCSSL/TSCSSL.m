%% Semi-supervised hydrochemical classification method constrained by typical samples
clear; clc;

%% Input data
data = readtable('water_data.xlsx');

Na = data.Na;
Cl = data.Cl;
B  = data.B;

n = height(data);

%% Specify typical samples
type1_idx = [1, 2, 3, 19, 20, 21, 70, 71, 72];    
type2_idx = [7, 8, 9, 10, 18, 51, 77];   

label = zeros(n,1);
label(type1_idx) = 1;
label(type2_idx) = 2;

%% Calculate ionic ratios
NaCl_ratio = Na ./ Cl;
BCl_ratio  = B  ./ Cl;

%% Set weights
w_NaCl_line = 0.5;
w_BCl_line  = 0.15;
w_NaCl_ratio = 0.05;
w_BCl_ratio  = 0.2;

%% Establish linear models for the typical samples
% Type 1
p_NaCl_1 = polyfit(Cl(type1_idx), Na(type1_idx), 1);
p_BCl_1  = polyfit(Cl(type1_idx), B(type1_idx), 1);

center_NaCl_1 = median(NaCl_ratio(type1_idx), 'omitnan');
center_BCl_1  = median(BCl_ratio(type1_idx),  'omitnan');

% Type 2
p_NaCl_2 = polyfit(Cl(type2_idx), Na(type2_idx), 1);
p_BCl_2  = polyfit(Cl(type2_idx), B(type2_idx), 1);

center_NaCl_2 = median(NaCl_ratio(type2_idx), 'omitnan');
center_BCl_2  = median(BCl_ratio(type2_idx),  'omitnan');

%% Standardization
scale_Na = std(Na, 'omitnan');
scale_B  = std(B,  'omitnan');
scale_NaCl_ratio = std(NaCl_ratio, 'omitnan');
scale_BCl_ratio  = std(BCl_ratio,  'omitnan');

%% Classify all samples
D1 = nan(n,1);
D2 = nan(n,1);

for i = 1:n
    
    % Skip samples with missing values or zero Cl concentration
    if isnan(Na(i)) || isnan(Cl(i)) || isnan(B(i)) || Cl(i) == 0
        continue;
    end
    
    %% Distance to Type 1
    Na_pred_1 = polyval(p_NaCl_1, Cl(i));
    B_pred_1  = polyval(p_BCl_1,  Cl(i));
    
    d_NaCl_line_1 = abs(Na(i) - Na_pred_1) / scale_Na;
    d_BCl_line_1  = abs(B(i)  - B_pred_1)  / scale_B;
    
    d_NaCl_ratio_1 = abs(NaCl_ratio(i) - center_NaCl_1) / scale_NaCl_ratio;
    d_BCl_ratio_1  = abs(BCl_ratio(i)  - center_BCl_1)  / scale_BCl_ratio;
    
    D1(i) = ...
        w_NaCl_line  * d_NaCl_line_1 + ...
        w_BCl_line   * d_BCl_line_1 + ...
        w_NaCl_ratio * d_NaCl_ratio_1 + ...
        w_BCl_ratio  * d_BCl_ratio_1;
    
    %% Distance to Type 2
    Na_pred_2 = polyval(p_NaCl_2, Cl(i));
    B_pred_2  = polyval(p_BCl_2,  Cl(i));
    
    d_NaCl_line_2 = abs(Na(i) - Na_pred_2) / scale_Na;
    d_BCl_line_2  = abs(B(i)  - B_pred_2)  / scale_B;
    
    d_NaCl_ratio_2 = abs(NaCl_ratio(i) - center_NaCl_2) / scale_NaCl_ratio;
    d_BCl_ratio_2  = abs(BCl_ratio(i)  - center_BCl_2)  / scale_BCl_ratio;
    
    D2(i) = ...
        w_NaCl_line  * d_NaCl_line_2 + ...
        w_BCl_line   * d_BCl_line_2 + ...
        w_NaCl_ratio * d_NaCl_ratio_2 + ...
        w_BCl_ratio  * d_BCl_ratio_2;
end

%% Classify samples based on the integrated distance
for i = 1:n
    if label(i) == 0
        if D1(i) < D2(i)
            label(i) = 1;
        else
            label(i) = 2;
        end
    end
end

%% Calculate classification confidence
confidence = abs(D1 - D2) ./ (D1 + D2);

% A higher confidence value indicates a clearer class assignment
% A lower confidence value indicates that the sample is located in a transitional zone between the two classes

%% Export results
data.Class = label;
data.Distance_Type1 = D1;
data.Distance_Type2 = D2;
data.Confidence = confidence;
data.Na_Cl_ratio = NaCl_ratio;
data.B_Cl_ratio = BCl_ratio;

writetable(data, 'classification_result.xlsx');

disp('Classification completed. The results have been saved as classification_result.xlsx');

%% Plot diagnostic figures
figure;
gscatter(Cl, Na, label, 'rb', 'o^');
xlabel('Cl');
ylabel('Na');
title('Na-Cl classification');
grid on;

figure;
gscatter(Cl, B, label, 'rb', 'o^');
xlabel('Cl');
ylabel('B');
title('B-Cl classification');
grid on;

figure;
gscatter(NaCl_ratio, BCl_ratio, label, 'rb', 'o^');
xlabel('Na/Cl');
ylabel('B/Cl');
title('Ion ratio classification');
grid on;