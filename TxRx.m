%%Se lee la fuente
tic
video = VideoReader('Marmota[2].mp4');

height = video.Height;
width = video.Width;

%% Preallocating: Se estructura la información del video TX
s = struct('data',zeros(width,height,3,'uint8'));
sRGB = struct('data',zeros(width*height*3,1,'uint8'));
sBIN = struct('data',zeros(width*height*3*8,1,'uint8')); 
sBINVector = struct('data',zeros(width*height*3,8,'uint8'));
sDouble = struct('data',zeros);
ii=1;
while hasFrame(video) && ii<=3
    %La información de cada Fotograma se encuentra en s.data: Dimens(240*320*3 = 230400)
    s(ii).data = readFrame(video);
    
    %en SRGB.data se tiene la información vectorizada de cada fotograma: Dimens(230400*1)
    sRGB(ii).data=reshape(s(ii).data,[numel(s(ii).data), 1]);
    
    %sBIN.data es la versión binaria de sRGB.data: Dimens(230400*8 = 1843200)
    sBIN(ii).data= de2bi (sRGB(ii).data);
    
    %sBINVector.data es la version vectorizada de sBIN.data: Dimens(1843200*1)
    sBINVector(ii).data= reshape(sBIN(ii).data,[numel(sBIN (ii).data),1]);
    sDouble(ii).data = double(sBINVector(ii).data);
    
    %imshow(s(ii).data);
    ii=ii+1;
end
%% Preparo palabras de 4 bits para hacer Hamming(7,4) TX
%Numero de mensajes de 4 bits
amountMsg=numel (sBINVector(1).data)/4;

% Preallocating
msg = struct('data',zeros(amountMsg,4,'uint8'));
BlockCode = struct('data',zeros(amountMsg,4+3,'double'));
j=1;

while j <= numel (sBINVector)
    %msg.data es la información de sBINVector, separada en palabras de 4 bits: Dimens(460800*4)
    msg(j).data = reshape(sDouble(j).data, [amountMsg, 4] );
    %En BlockCode se almacenan los mensajes codificados: Dimens(460800*7)
    BlockCode(j).data = HammingCode(msg(j).data); %Se añaden 3 bits de paridad
    j=j+1;
end
%% Modulación 4-QAM TX
%orden de la modulacion
M=4;  

n=1;
while n <= numel(BlockCode) 
    mss_symbolic(n).data = reshape(BlockCode(n).data,[numel(BlockCode(n).data)/log2(M),log2(M)]);
    mss_symbolic_adecimal(n).data = bi2de(mss_symbolic(n).data);
    for b=1: numel(mss_symbolic_adecimal(1).data)
            z(n).data(b) = Mapeo(mss_symbolic_adecimal(n).data(b));      
    end
    zVector(n).data = reshape(z(n).data,[size(z(n).data,2),1]);
    sReal(n).data = real(zVector(n).data);
    sImag(n).data = imag(zVector(n).data);
    n=n+1;
end
%% Filtro Conformador Tx

Np= 3; %numero de portadoras
w= 1.5;
%fc=((2*N)-1)*w; %frecuencia de muestreo
fs=4*Np*w;
R=0.5; %factor de Roll-Off
U=16;
L=8; % abarca 8 simbolos con 16 muestras por simbolo
T=1;
h1 = rcosfir(R, L, U, T,'sqrt') ; %la longitud del filtro es 2*L*U+1

%%% IMPLEMENTACION DEL FILTRO
%Aumenta la frecuencia de muestreo de la secuencia por un factor de 16
su1 = struct('data',zeros(amountMsg,4,'double'));
su = struct('data',zeros(amountMsg,4,'double'));
x1 = struct('data',zeros(amountMsg,4,'double'));
s1 = struct('data',zeros(amountMsg,4,'double'));
parteReal = struct('data',zeros(amountMsg,4,'double'));
parteImg = struct('data',zeros(amountMsg,4,'double'));

c=1;
while c <= numel(z)
    xReal(c).data=upsample(sReal(c).data,U);
    xImag(c).data=upsample(sImag(c).data,U);
    
    xRealFiltered(c).data = filter(h1,T,xReal(c).data);
    xImagFiltered(c).data = filter(h1,T,xImag(c).data);
    %se agregan ceros debido al transiente del filtro
%     su(c).data=[su1(c).data ;zeros(2*L*U+1,1)];
    %FILTRAJE
%     x1(c).data=filter(h1,1,su(c).data);
%     x1(c).data=filter(h1,1,x1(c).data); %se filtra 2 veces para simular el efecto del transmisor y el receptor

    %se cortan los ceros que se agregaron
%     x1(c).data=x1(c).data(2*L*U+1:end);

    % recuperación de la secuencia original
%     s1(c).data=downsample(x1(c).data, U);

%     parteReal(c).data=real(s1(c).data);
%     parteImg(c).data=imag(s1(c).data);
    c=c+1;
end
%% MULTIPLEXACION, portadoras


t=0: 1/fs : (length(x1(1).data)-1)/fs;

parteRealp = struct('data',zeros(amountMsg,4,'double'));
parteImgp = struct('data',zeros(amountMsg,4,'double'));

if mod((ii-1),Np)==0 % si el modulo entre numero de imgs y np es igual a cero, se tienen suficientes portadoras

    nfil = (ii-1)/Np;
    y = struct('data',zeros(nfil,amountMsg,'double'));
    for xx=1 : nfil
        for Npp=1 : Np
            fc=((2*Npp)-1)*w; %frecuencia de muestreo
            Sc(xx,Npp).data = x1(Npp).data.*2.*cos(2*pi*fc*t);
%             parteRealp(Npp).data=parteReal(Npp).data.*2.*cos(2*pi*fc*t);
%             parteImgp(Npp).data=parteImg(Npp).data.*(-2).*sin(2*pi*fc*t);
%             y(xx,Npp).data = complex(parteRealp(Npp).data , parteImgp(Npp).data);
        end
    end
else %si el modulo no es igual a cero
    nfil = ((ii-1)-mod((ii-1),Np))/Np;
    y = struct('data',zeros(nfil+1,amountMsg,'double'));
    for xx=1 : nfil
        for Npp=1 : Np
        fc=((2*Npp)-1)*w; %frecuencia de muestreo
        parteRealp(Npp).data=parteReal(Npp).data.*2.*cos(2*pi*fc*t);
        parteImgp(Npp).data=parteImg(Npp).data.*(-2).*sin(2*pi*fc*t);
        y(xx,Npp).data = complex(parteRealp(Npp).data , parteImgp(Npp).data);
        end
    end
%para las imagenes restantes se ubican en una fila añadida de más
    for xx=nfil+1 : nfil+1
        for Npp=1 : mod((ii-1),Np)
            fc=((2*Npp)-1)*w; %frecuencia de muestreo
            parteRealp(Npp).data=parteReal(Npp).data.*2.*cos(2*pi*fc*t);
            parteImgp(Npp).data=parteImg(Npp).data.*(-2).*sin(2*pi*fc*t);
            y(xx,Npp).data = complex(parteRealp(Npp).data , parteImgp(Npp).data);
        end
    end
end

%% DeMUX portadoras RX
% parteRealRX=struct();
% parteImgYX=struct();
% ydemo=struct();
% for xx=1 : nfil
%         for Npp=1 : Np
%         fc=((2*Npp)-1)*w; %frecuencia de muestreo
%         
%         parteRealRX(Npp).data = -parteRealp(Npp).data.*cos(2*pi*fc*t);
%         parteImgYX(Npp).data = -parteImgp(Npp).data.*sin(2*pi*fc*t);
%         ydemo(xx,Npp).data = complex(parteRealRX(Npp).data , parteImgYX(Npp).data);
%         end
% end

%% Filtro Conformador RX



%%% IMPLEMENTACION DEL FILTRO
%Aumenta la frecuencia de muestreo de la secuencia por un factor de 16
% su2 = struct('data',zeros(amountMsg,4,'double'));
% suu = struct('data',zeros(amountMsg,4,'double'));
% x2 = struct('data',zeros(amountMsg,4,'double'));
% s2 = struct('data',zeros(amountMsg,4,'double'));
% parteRealdemo = struct('data',zeros(amountMsg,4,'double'));
% parteImgdemo = struct('data',zeros(amountMsg,4,'double'));
% 
% c=1;
% while c <= numel(z)
%     su2(c).data=upsample(y(c).data,U);
%     %se agregan ceros debido al transiente del filtro
%     suu(c).data=[su2(c).data zeros(1,2*L*U+1)];
%     %FILTRAJE
%     x2(c).data=filter(h1,1,suu(c).data);
%     x2(c).data=filter(h1,1,x2(c).data); %se filtra 2 veces para simular el efecto del transmisor y el receptor
% 
%     %se cortan los ceros que se agregaron
%     x2(c).data=x2(c).data(2*L*U+1:end);
% 
%     % recuperación de la secuencia original
%     s2(c).data=downsample(x2(c).data, U);
% 
%     %parteRealdemo(c).data=real(s2(c).data);
%     %(c).data=imag(s2(c).data);
%     c=c+1;
% end

%% Demodular en RX

%h=1;
%while h<= numel(y)
    
  %  p=1;
 %   while p<= numel (parteRealdemo(h).data)
       % if parteRealdemo(h).data(p) >=0
      %      parteRealdemo(h).data(p) = 1;
     %   elseif parteRealdemo(h).data(p)<0
    %        parteRealdemo(h).data(p) = -1;
   %     end
  %      p=p+1;
 %   end
    
%    r=1;
    %while r<= numel (parteImgdemo(h).data)
     %   if parteImgdemo(h).data(r) >=0
    %        parteImgdemo(h).data(r) = 1;
   %     elseif parteImgdemo(h).data(r)<0
  %          parteImgdemo(h).data(r) = -1;
 %       end
%        r=r+1;
%    end    
%    h=h+1;
%end

%% Mapeo en Rx
%sdemod=struct();
%t=1;
%while t <=numel(parteRealdemo)
%    tt=1;
%    while tt<= numel(parteRealdemo(1).data)
%        sdemod(t).data(tt)=MyQAMDemod(complex(parteRealdemo(t).data(tt),parteImgdemo(t).data(tt)));
%        tt=tt+1;
%    end
%    t=t+1;
%end
   

%% Decodificar y corregir RX

% msgDecoded = struct('data',zeros(amountMsg,4,'double'));
% %fun= arrayfun(@(row) Decode(row.data),BlockCode,'UniformOutput',false);
% %msgDecoded = structfun( @fun  ,BlockCode);
% k=1;
% 
% while k <= numel(BlockCode)
%     %Structura de sindromes para detectar errores
%     %msgDecoded = cell2mat( arrayfun(@(row) Decode(row(1,:)), BlockCode(k).data,'UniformOutput',false));
%     %result = arrayfun(@(ROWIDX) mean(M(ROWIDX,:)), (1:size(M,1)).');
%     l=1;
%     while l<=size(BlockCode(k).data,1)
%         msgDecoded(k).data(l,:) = Decode(BlockCode(k).data(l,:));
%         l=l+1; 
%     end
%     k=k+1;
% end

%% Reshaping messages RX
% msgReshaped = struct('data',zeros(numel(msgDecoded),8));
% msgBytes = struct('data',zeros(57600,1));
% videoRX = struct('data',zeros(height,width,3));
% m=1;
% while m <= numel(msgDecoded)
%     msgReshaped(m).data = reshape(msgDecoded(m).data,[57600,8]);
%     msgBytes(m).data = bi2de(uint8(msgReshaped(m).data));
%     videoRX(m).data = reshape(msgBytes(m).data,[height,width,3]);
%     imshow(videoRX(m).data)
%     m=m+1;
%       
% end

%%
%msgBytes = bi2de(uint8(msgReshaped));
%videoRX= reshape(msgBytes,[height,width,3]);



%msgBytes = 




%% Prueba de codificación y deco

%test = [1 0 1 0];
%codificado = HammingCode(test)
%decodificado = Decode([0     0     1     1     0     1     1])


toc




