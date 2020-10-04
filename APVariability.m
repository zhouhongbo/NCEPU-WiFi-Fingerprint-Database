% Script to generate the paper's figure "APVariability" and table "APpresence"

close all;

addpath('db','files','ids','ips');

mounthAmount = 15;
notDetected = 100;

% Get the data indicate which AP was seen each month
presenceData = [];
for month = (1:mounthAmount)
    data = loadContentSpecific('db', 1, 1, month);  % Load the trn month data
    detected = (data.rss~=notDetected); % 1-> AP was detected, 0 otherwise
    atLeastOne = any(detected,1); % per column, 1-> AP was seen at least in 1 fingerprint
    presenceData = [presenceData;atLeastOne];
end

% Draw presence data
apsAmount = size(presenceData,2);
figure('PaperUnits','centimeters','PaperSize',[50,15],'PaperPosition',[-5 0 59 15]);
imagesc(presenceData);
colormap(pink);
axis([1, apsAmount, 1, mounthAmount]);
title('AP Precense in Training Sets');
xlabel('AP Number');
xticks(0:20:apsAmount);
ylabel('Month Number');
yticks((1:apsAmount));


% Data for table "APpresence"

appearSummary = zeros(mounthAmount, apsAmount);

% State machine for AP presence state determination
for ap = (1:apsAmount)
    lastState = 0;
    for month = (1:mounthAmount)
        value = presenceData(month, ap);
        if (lastState == 0)
            if(value == 1)
                appearSummary(month, ap) = 1;
                lastState = 1;
            end
        elseif (lastState == 1)
            if(value == 1)
                appearSummary(month, ap) = 11;
                lastState = 11;
            else
                appearSummary(month, ap) = -2;
                lastState = -2;
            end
        elseif (lastState == 11)
            if(value == 0)
                appearSummary(month, ap) = -2;
                lastState = -2;
            else
                appearSummary(month, ap) = 11;
            end
        elseif (lastState == -2)
            if(value == 1)
                appearSummary(month, ap) = 3;
                lastState = 3;
            else
                appearSummary(month, ap) = -22;
                lastState = -22;
            end
        elseif (lastState == -22)
            if(value == 1)
                appearSummary(month, ap) = 3;
                lastState = 3;
            else
                appearSummary(month, ap) = -22;
            end
        elseif (lastState == 3)
            if(value == 1)
                appearSummary(month, ap) = 33;
                lastState = 33;
            else
                appearSummary(month, ap) = -4;
                lastState = -4;
            end
        elseif (lastState == 33)
            if(value == 1)
                appearSummary(month, ap) = 33;
            else
                appearSummary(month, ap) = -4;
                lastState = -4;
            end
        elseif (lastState == -4)
            if(value == 1)
                appearSummary(month, ap) = 3;
                lastState = 3;
            else
                appearSummary(month, ap) = -22;
                lastState = -22;
            end
        end
    end
end

% Give meaning to states
summary = struct('total', {}, 'new', {}, 'gone', {}, 'reapp', {}, 'regone', {}, 'all', {});
summary(mounthAmount).total = 0;

for month = (1:mounthAmount)
    summary(month).total = sum(appearSummary(month,:)>0);
    summary(month).new = sum(appearSummary(month,:)==1);
    summary(month).gone = sum(appearSummary(month,:)==-2);
    summary(month).reapp = sum(appearSummary(month,:)==3);
    summary(month).regone = sum(appearSummary(month,:)==-4);
    summary(month).all = sum(appearSummary(month,:)~=0);
end

% Output to shell
struct2table(summary)
