%%Se lee la fuente
video = VideoReader('Marmota.mp4');
M=input(' enter the value of M for M-QAM modulation : ');

%Check M valid value
Ld=log2(M)
ds=ceil(Ld);
dif=ds-Ld;
if(dif~=0)
   error('the value of M is only acceptable if log2(M)is an integer');
end

height = video.Height;
width = video.Width;

%Se estructura la informacion del video en una matriz
s = struct('cdata',zeros(width,height,3,'uint8'));
k=1;
while hasFrame(video)
    s(k).cdata = readFrame(video);
    
    %Vectorizando cada fotograma
    sRGB(k).data=reshape(s(k).cdata,[numel(s(k).cdata), 1]);
    %imshow(s(k).cdata)
    %k=k+1
end

n=1;
while n<= numel (sRGB)
    %La data de cada fotograma se pasa a formato Binario
    sBIN(n).data= de2bi (sRGB(n).data);
    %Crear vector columna de cada fotograma(binario)
    sBINVector(n).data= reshape(sBIN(n).data,[numel(sBIN (n).data),1]);
    %n
    n=n+1;
end

%Codificación de fuente
i=1;
while i <= numel (sBINVector)

    amountSimbols=numel (sBINVector(i).data)/Ld;
    
    %Generar los Simbolos, se tiene en cuenta el numero de bits por simbolo
    %(Log2(M))
    symbol(i).data = reshape(sBINVector(i).data, [amountSimbols, Ld] )
    symbol(i).data
    i=i+1
end

