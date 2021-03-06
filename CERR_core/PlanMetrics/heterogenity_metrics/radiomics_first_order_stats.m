function [RadiomicsFirstOrder] = radiomics_first_order_stats(planC,structNum,doseNum)
%
% function [RadiomicsFirstOrder] = radiomics_first_order_stats(Data,Step)
%
% User defined radiomics metric
%
%   First Order Gray level statistics
%
%   Step is size of the bins bins (CT step is 10 HU)
%--------------------------------------------------------------------------
%   08/11/2010, Ralph Leijenaar
%   - added Mean deviation
%--------------------------------------------------------------------------

Step = 1;

if iscell(planC)
indexS = planC{end};

% Get uniformized structure Mask
maskStruct3M = getUniformStr(structNum,planC);

% Get uniformized scan mask in HU
scanNum = getAssociatedScan(planC{indexS.structures}(structNum).assocScanUID, planC);
maskScan3M = getUniformizedCTScan(1, scanNum, planC);
% Convert to HU if image is of type CT
if ~isempty(planC{indexS.scan}(scanNum).scanInfo(1).CTOffset)
    maskScan3M = double(maskScan3M) - planC{indexS.scan}(scanNum).scanInfo(1).CTOffset;
end

% % Get Pixel-size
% [xUnifV, yUnifV, zUnifV] = getUniformScanXYZVals(planC{indexS.scan}(scanNum));
% PixelSpacingXi = abs(xUnifV(2)-xUnifV(1));
% PixelSpacingYi = abs(yUnifV(2)-yUnifV(1));
% PixelSpacingZi = abs(zUnifV(2)-zUnifV(1));
% VoxelVol = PixelSpacingXi*PixelSpacingYi*PixelSpacingZi;

% Iarray = Data.Image(~isnan(Data.Image));     %    Array of Image values
indStructV = maskStruct3M(:) == 1;
Iarray = maskScan3M(indStructV);

else
    
    Iarray = planC;
    % VoxelVol = structNum;
end


% Calculate standard PET parameters
RadiomicsFirstOrder.min           = min(Iarray);
RadiomicsFirstOrder.max           = max(Iarray);
RadiomicsFirstOrder.mean          = mean(Iarray);
RadiomicsFirstOrder.range         = range(Iarray);
RadiomicsFirstOrder.std           = std(Iarray,1);
RadiomicsFirstOrder.var           = var(Iarray,1);
RadiomicsFirstOrder.median        = median(Iarray);

% Skewness is a measure of the asymmetry of the data around the sample mean.
% If skewness is negative, the data are spread out more to the left of the mean
% than to the right. If skewness is positive, the data are spread out more to the
% right. The skewness of the normal distribution (or any perfectly symmetric
% distribution) is zero.
RadiomicsFirstOrder.skewness      = skewness(Iarray);

% Kurtosis is a measure of how outlier-prone a distribution is. The kurtosis
% of the normal distribution is 3. Distributions that are more outlier-prone
% than the normal distribution have kurtosis greater than 3; distributions
% that are less outlier-prone have kurtosis less than 3.
RadiomicsFirstOrder.kurtosis      = kurtosis(Iarray) - 3;

% Entropy is a statistical measure of randomness that can be used to characterize
% the texture of the input image
N = ceil( RadiomicsFirstOrder.range/Step);  %   
%RadiomicsFirstOrder.entropy       = entropy_radiomics(Iarray,N);

% J = entropyfilt(varargin); % Misschien voor long, waar zit de hoogste
% heterogeniteit?

%   Root mean square (RMS)
RadiomicsFirstOrder.rms           = sqrt(sum(Iarray.^2)/length(Iarray));

%   Total Energy ( integraal(a^2) )
RadiomicsFirstOrder.totalEnergy   = sum(Iarray.^2);

%   Mean deviation (also called mean absolute deviation)
RadiomicsFirstOrder.meanAbsDev            = mad(Iarray);

% Median absolute deviation
RadiomicsFirstOrder.medianAbsDev = sum(abs(Iarray-RadiomicsFirstOrder.median)) / numel(Iarray);

%   P10
p10 = prctile(Iarray,10);
RadiomicsFirstOrder.P10 = p10;

%   P90
p90 = prctile(Iarray,90);
RadiomicsFirstOrder.P90 = p90;

Iarray10_90 = Iarray(Iarray >= p10 & Iarray <= p90);

%   Robust Mean Absolute Deviation
RadiomicsFirstOrder.robustMeanAbsDev  = mad(Iarray10_90);

%   Robust Median Absolute Deviation
RadiomicsFirstOrder.robustMedianAbsDev  = sum(abs(Iarray10_90-median(Iarray10_90)))...
    / numel(Iarray10_90);

% Inter-Quartile Range (IQR)
% P75 - P25
p75 = prctile(Iarray,75);
p25 = prctile(Iarray,25);
RadiomicsFirstOrder.interQuartileRange = p75 - p25;

% Quartile coefficient of Dispersion
RadiomicsFirstOrder.coeffDispersion = (p75-p25)/(p75+p25);

% Coefficient of variation
RadiomicsFirstOrder.coeffVariation = RadiomicsFirstOrder.std / RadiomicsFirstOrder.mean;


end