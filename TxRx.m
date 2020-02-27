%%Se lee la fuente
tic
video = VideoReader('Marmota.mp4');
%M=input(' enter the value of M for M-QAM modulation : ');

%Check M valid value
%Ld=log2(M);
%ds=ceil(Ld);
%dif=ds-Ld;
%if(dif~=0)
%   error('the value of M is only acceptable if log2(M)is an integer');
%end

height = video.Height;
width = video.Width;

%% Preallocating: Se estructura la información del video
s = struct('cdata',zeros(width,height,3,'uint8'));
sRGB = struct('data',zeros(width*height*3,1,'uint8'));
sBIN = struct('data',zeros(width*height*3*8,1,'uint8')); 
sBINVector = struct('data',zeros(width*height*3,8,'uint8'));

i=1;
while hasFrame(video)
    %La información de cada Fotograma se encuentra en s.data: Dimens(240*320*3 = 230400)
    s(i).cdata = readFrame(video);
    
    %en SRGB.data se tiene la información vectorizada de cada fotograma: Dimens(230400*1)
    sRGB(i).data=reshape(s(i).cdata,[numel(s(i).cdata), 1]);
    
    %sBIN.data es la versión binaria de sRGB.data: Dimens(230400*8 = 1843200)
    sBIN(i).data= de2bi (sRGB(i).data);
    
    %sBINVector.data es la version vectorizada de sBIN.data: Dimens(1843200*1)
    sBINVector(i).data= reshape(sBIN(i).data,[numel(sBIN (i).data),1]);
    
    %imshow(s(i).cdata);
    i=i+1;
end
toc

%% Preparo palabras de 4 bits para hacer Hamming(7,4)
j=1;
while j <= numel (sBINVector)
    amountMsg=numel (sBINVector(j).data)/4;

    msg(j).data = reshape(sBINVector(j).data, [amountMsg, 4] );
    msgDouble(j).data = double(msg(j).data);
    size_msg = size(msg(j).data);
    j=j+1;
end
%%
%row = size_msg(1);
%column = size_msg(2);

%Creo una matriz de ceros, para los mensajes codificados,
%Dimens(filas_de_symbol,7): "Con este video son 460800 filas y 7 Columnas para Hamming(7,4)"
%msg_coded = struct('data',zeros(row,column+3));

%l=1;
%while l<= numel(msg)
 %   BlockCode = HammingCode(msgDouble(l).data);
  %  l=l+1;
%end


%%
%MSG = [0 0 1 0];
%BlockCode = HammingCode(MSG)


%size_msg = size(symbol.data)

%Codificación de fuente
%i=1;
%while i <= numel (sBINVector)

%    amountSimbols=numel (sBINVector(i).data)/Ld;
    
    %Generar los Simbolos, se tiene en cuenta el numero de bits por simbolo
    %(Log2(M))
%    symbol(i).data = reshape(sBINVector(i).data, [amountSimbols, Ld] );
%    symbol(i).data;
%    i=i+1;
%end

%Codificación Canal




