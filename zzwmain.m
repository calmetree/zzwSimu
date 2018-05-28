
clear all;
close all;
sysCfg=sysCfgStr();
global puschDMRS;
global FFTLxL;

Lengthdelay=sysCfg.maxGroupDelay;

Wfft=exp(-j*2*pi/sysCfg.fftsize);
%PP=2*eNB.Nrb;%RS point number!!!
for p=1:2*sysCfg.Nrb*6
    FFTpl(p,:)=power(exp(-j*2*pi/sysCfg.fftsize*(p-1)),[0:1:Lengthdelay-1]);
end
%sys.FFTpl=FFTpl;
FFTLxL=FFTpl'*FFTpl; % ctranspose - Complex conjugate transpose   


%% generate DMRS
ue.NPUSCHID = 42;
ue.NDMRSID = 1;
ue.NSubframe = 0;
chs.PRBSet = (0:24).';
puschDMRS = ltePUSCHDRS(ue,chs);
DMRS=[puschDMRS(1:300).';puschDMRS(301:end).']; % only use the DMRS(1,:)

Ber=[];
load('Bers.mat');
for SNR=1:1:30
    for i=1:20
        %BerRaw(SNR,i)=runonce('noCHE','noEQ',SNR);
        %Ber(SNR,i)=runonce('noCHE','noEQ',SNR,'awgn');
        %Ber1(SNR,i)=runonce('noCHE','noEQ',SNR,'rayleigh');
        
        %BerLS0(SNR,i)=runonce('LS0','ZF',SNR,'awgn');
        %BerLS01(SNR,i)=runonce('LS0','ZF',SNR,'rayleigh');
        
        %BerLS1(SNR,i)=runonce('LS1','ZF',SNR,'awgn');
        %BerLS11(SNR,i)=runonce('LS1','ZF',SNR,'rayleigh');
        
        BerLS2(SNR,i)=runonce('LMMSE','ZF',SNR,'awgn');
        BerLS21(SNR,i)=runonce('LMMSE','ZF',SNR,'rayleigh');
    end
    
end

save Bers.mat Ber Ber1 BerLS0 BerLS01 BerLS1 BerLS11 BerLS2 BerLS21;
drawResult();
%b=sum(BerRaw,2)/10;
%semilogy(1:SNR,b,'b--');hold on;



%save Bers.mat Ber Ber1 BerLS0 BerLS01 BerLS1 BerLS11 BerLS2 BerLS21;

%scatterplot(RxDataTd(1,:))

%a=txWaveFormWithCh(37:end);% remove CP
%a=fft(a,512);% FFT
%a=ifft(a,300);% IDFT
%scatterplot(a)
%


%'OK'