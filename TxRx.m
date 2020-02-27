%%Se lee la fuente
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

%Se estructura la informacion del video en una matriz
s = struct('cdata',zeros(width,height,3,'uint8'));
k=1;
%Preallocating: 
sRGB(k).data = zeros(width*height*3,1);
while hasFrame(video)
    s(k).cdata = readFrame(video);
    
    %Vectorizando cada fotograma
    sRGB(k).data=reshape(s(k).cdata,[numel(s(k).cdata), 1]);
    %imshow(s(k).cdata)
    k=k+1;
end

n=1;

%sBINVector(0:132).data = struct(zeros(1843200,1,'double'));
tic
while n<= numel (sRGB)
    %La data de cada fotograma se pasa a formato Binario
    sBIN(n).data= de2bi (sRGB(n).data);
    %Crear vector columna de cada fotograma(binario)
    sBINVector(n).data= reshape(sBIN(n).data,[numel(sBIN (n).data),1]);
    %n
    n=n+1;
end
toc

%Preparo palabras de 4 bits para hacer Hamming(7,4)
j=1;
while j <= numel (sBINVector)

    amountMsg=numel (sBINVector(j).data)/4;
    
    %Generar los Simbolos, se tiene en cuenta el numero de bits por simbolo
    %(Log2(M))
    msg(j).data = reshape(sBINVector(j).data, [amountMsg, 4] );
    msg(j).data;
    %imgs(i).a=double(imgs(i).a); 
    msgDouble(j).data = double(msg(j).data);
    size_msg = size(msg(j).data);
    j=j+1;
end

row = size_msg(1);
column = size_msg(2);

%Creo una matriz de ceros, para los mensajes codificados,
%Dimens(filas_de_symbol,7): "Con este video son 460800 filas y 7 Columnas para Hamming(7,4)"
msg_coded = struct('data',zeros(row,column+3));

%Se define la matriz generadora
G=[1 1 0 1 0 0 0;0 1 1 0 1 0 0;1 1 1 0 0 1 0;1 0 1 0 0 0 1]; 

l=1;
%while l<= numel(msg)
%    msg_coded = msgDouble(l).data * G;
%    msg_codedMod =  mod(msg_coded,2); 
%    l=l+1;
%end
MSG = [0 0 1 0];
BlockCode = HammingCode(MSG)


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




