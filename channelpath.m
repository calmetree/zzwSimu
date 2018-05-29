
function [channelOut]=channelpath(Timesignal,chan,SNR)
%global sysCfg;
sysCfg=sysCfgStr();

channelchoise =chan;%'awgn';
ts=sysCfg.ts;
%channel type {'PedB', 'PedBcorr'}
%ChanMod.PDP_dB = [0   -0.9  -4.9  -8    -7.8  -23.9; % Average power [dB]
%                  0 200*10^-9 800*10^-9 1200*10^-9 2300*10^-9 3700*10^-9]; % delay (s)

%ChanMod.PDP_dB = [0   -0.9  -4.9  -8    -7.8  -23.9; % Average power [dB]
                  %%%0 1*10^-9 800*10^-9 1200*10^-9 2300*10^-9 3700*10^-9]; % delay (s)
%                  0 1*10^-9 80*10^-9 120*10^-9 230*10^-9 370*10^-9]; % delay (s)

ChanMod.PDP_dB = [0   -0.9  -0.6 -0.3; % Average power [dB]
                  %%%0 1*10^-9 800*10^-9 1200*10^-9 2300*10^-9 3700*10^-9]; % delay (s)
                  0   2*ts  4*ts  7*ts];
                  %0 2000*10^-9]; % delay (s)
ChanMod.normH = sqrt(sum(10.^(ChanMod.PDP_dB(1,:)/10)));

ChanMod2.PDP_dB = [0; % Average power [dB]
                  %%%0 1*10^-9 800*10^-9 1200*10^-9 2300*10^-9 3700*10^-9]; % delay (s)
                  0]; % delay (s)
ChanMod2.normH = sqrt(sum(10.^(ChanMod2.PDP_dB(1,:)/10)));

if strcmp(channelchoise,'awgn')
    channelmodel=ChanMod2;
    channelOut0=Timesignal;
    %channelOut0=awgn(Timesignal,SNR);%,'measured');
elseif strcmp(channelchoise,'multipath')
    channelmodel=ChanMod;
elseif strcmp(channelchoise,'raylei')
        rayleih1=rayleighchan(sysCfg.ts,10);
	    %rayleih1.StoreHistory=1; %this should be false if MaxDopplerShift is zero
	    rayleih1.ResetBeforeFiltering=0;
	    %rayleih1.DopplerSpectrum=doppler.flat;
	    rayleih1.PathDelay=[0 14*ts];% 10*ts ];%20*ts];
	    rayleih1.AvgPathGaindB=[-0.5 0];%; 0];% 0];
	    %rayleih1.NormalizePathGains=1;
        b=sqrt(sum(10.^(rayleih1.AvgPathGaindB(1,:)/10)));
        channelOut0=filter(rayleih1,Timesignal)/b;
        channelOut0=reshape(channelOut0,length(channelOut0),1);
end
% switch channelchoise
%     case 'awgn'
%         channelmodel=ChanMod2;
%     case 'multipath'
%         channelmodel=ChanMod;
%     case 'raylei'
% %         ts=1/30720;
% %         x=rayleighchan(ts,1);
% %         x.StoreHistory=1;
% %         x.PathDelay=[0 10*ts 20*ts];
% %         x.AvgPathGaindB=[1 0.8 0];
%         %ts=1/30720;
% 	    rayleih1=rayleighchan(sysCfg.ts,0);
% 	    rayleih1.StoreHistory=1;
% 	    rayleih1.ResetBeforeFiltering=0;
% 	    rayleih1.DopplerSpectrum=doppler.flat;
% 	    rayleih1.PathDelay=[10*ts];% 10*ts ];%20*ts];
% 	    rayleih1.AvgPathGaindB=[1];%; 0];% 0];
% 	    rayleih1.NormalizePathGains=1;
%         channelOut=filter(rayleih1,Timesignal);
%         %channelOut1=filter(sys.rayleih2,Timesignal(2,:));
% end

if strcmp(channelchoise,'multipath') %
%if isequal(channelchoise,'raylei') == 0
    %bandwidth=20M
    fader=round(channelmodel.PDP_dB(2,:)*1000*sysCfg.fftsize*15);

    unique_fader=unique(fader);
    %G=[1+randn(1,length(unique_fader))/20+j*(1+randn(1,length(unique_fader))/20);1+randn(1,length(unique_fader))/20+j*(1+randn(1,length(unique_fader))/20)];
    %G=[ones(1,length(unique_fader))+j*(ones(1,length(unique_fader)));ones(1,length(unique_fader))+j*(ones(1,length(unique_fader)))]/sqrt(2);
	G=[ones(1,length(unique_fader))+j*(ones(1,length(unique_fader)))]/sqrt(2);%;ones(1,length(unique_fader))+j*(ones(1,length(unique_fader)))]/sqrt(2);
    h=[];
    for fadeidx=1:length(unique_fader)
        curr_fader=(fader==unique_fader(fadeidx));
        h(:,unique_fader(fadeidx)+1)=[sqrt(sum(10.^(channelmodel.PDP_dB(1,curr_fader)./10))).*G(:,fadeidx)];
    end
    h=h./channelmodel.normH;
    %y=[];
    channelOut0 = conv(h, Timesignal);
    channelOut0=reshape(channelOut0,length(channelOut0),1);
    %channelOut1 = conv(h(2,:), Timesignal(2,:));
end

%channelOut = channelOut0(1:length(Timesignal));
%channelOut = [channelOut0(1:sum(sys.Ncplength(1:sys.Osn))+sys.Nfft*sys.Osn);channelOut1(1:sum(sys.Ncplength(1:sys.Osn))+sys.Nfft*sys.Osn)];



channelOut = channelOut0(1:length(Timesignal));

%% Add Noise
%n = 10^(-SNR/20)*(randn(size(channelOut0,1),1) + 1i*randn(size(channelOut0,1),1))/sqrt(2);%;/sqrt(ChanMod.nRX);
%channelOut0 = channelOut0 + n*sqrt(512/300);% not right for 3M and 1.4M ???

%channelOut0=awgn(channelOut0,SNR);%,'measured');

%sys.Channelnoise(1,:)=n;
%channelOut0 = channelOut0 + n*sqrt(1200/2048);
% n = 10^(-SNR/20)*(randn(1,size(channelOut1,2)) + 1i*randn(1,size(channelOut1,2)))/sqrt(2);%;/sqrt(ChanMod.nRX);
% channelOut1 = channelOut1 + n*sqrt(2048/1200);% not right for 3M and 1.4M
% sys.Channelnoise(2,:)=n;
%channelOut1 = channelOut1 + n*sqrt(1200/2048);

a=fft(channelOut); %F2T
b=awgn(a,SNR);
channelOut=ifft(b); % T2F
%channelOut = channelOut0(1:length(Timesignal));
%channelOut = [channelOut0(1:sum(sys.Ncplength(1:sys.Osn))+sys.Nfft*sys.Osn);channelOut1(1:sum(sys.Ncplength(1:sys.Osn))+sys.Nfft*sys.Osn)];



%sys.Channelht=h;






