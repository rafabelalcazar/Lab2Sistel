%%Se lee la fuente
tic
video = VideoReader('Marmota.mp4');

height = video.Height;
width = video.Width;

%% Preallocating: Se estructura la información del video
s = struct('data',zeros(width,height,3,'uint8'));
sRGB = struct('data',zeros(width*height*3,1,'uint8'));
sBIN = struct('data',zeros(width*height*3*8,1,'uint8')); 
sBINVector = struct('data',zeros(width*height*3,8,'uint8'));

i=1;
while hasFrame(video)
    %La información de cada Fotograma se encuentra en s.data: Dimens(240*320*3 = 230400)
    s(i).data = readFrame(video);
    
    %en SRGB.data se tiene la información vectorizada de cada fotograma: Dimens(230400*1)
    sRGB(i).data=reshape(s(i).data,[numel(s(i).data), 1]);
    
    %sBIN.data es la versión binaria de sRGB.data: Dimens(230400*8 = 1843200)
    sBIN(i).data= de2bi (sRGB(i).data);
    
    %sBINVector.data es la version vectorizada de sBIN.data: Dimens(1843200*1)
    sBINVector(i).data= reshape(sBIN(i).data,[numel(sBIN (i).data),1]);
    
    %imshow(s(i).cdata);
    i=i+1;
end
%% Preparo palabras de 4 bits para hacer Hamming(7,4)
%Numero de mensajes de 4 bits
amountMsg=numel (sBINVector(1).data)/4;

% Preallocating
msg = struct('data',zeros(amountMsg,4,'uint8'));
msgDouble = struct('data',zeros(amountMsg,4,'double'));
BlockCode = struct('data',zeros(amountMsg,4+3,'double'));
j=1;
while j <= numel (sBINVector)
    %msg.data es la información de sBINVector, separada en palabras de 4 bits: Dimens(460800*4)
    msg(j).data = reshape(sBINVector(j).data, [amountMsg, 4] );
    
    % msgDouble.data tiene la misma información que msg.data pero el tipo
    % de dato es 'double': Dimens(460800*4)
    msgDouble(j).data = double(msg(j).data);
    %size_msg = size(msg(j).data);
    
    %En BlockCode se almacenan los mensajes codificados: Dimens(460800*7)
    BlockCode(j).data = HammingCode(msgDouble(j).data); %Se añaden 3 bits de paridad
    j=j+1;
end


%% Decodificar y corregir

msgDecoded = struct('data',zeros(amountMsg,7,'double'));
sindrome = struct('data',zeros(amountMsg,3,'double'));
H=[1 0 0 1 0 1 1;0 1 0 1 1 1 0;0 0 1 0 1 1 1];
s1=[1 1 0];                             %Se establecen los sindromes con los cuales se realizara la decodificación del mensaje
s2=[0 1 1];
s3=[1 1 1];
s4=[1 0 1];
k=1;
while k <= numel(BlockCode)
    %Structura de sindromes para detectar errores
    sindrome(k).data=mod(BlockCode(k).data*H',2);
    if( sindrome(k).data == s1 )
        msgDecoded(k).data = rem( BlockCode(k).data+[0 0 0 1 0 0 0],2); 
    elseif(sindrome(k).data == s2)
            msgDecoded(k).data = rem( BlockCode(k).data+[0 0 0 0 1 0 0],2);
    elseif(sindrome(k).data == s3)
        msgDecoded(k).data = rem( BlockCode(k).data+[0 0 0 0 0 1 0],2);
    elseif(sindrome(k).data == s4)
        msgDecoded(k).data = rem( BlockCode(k).data+[0 0 0 0 0 0 1],2);
    else
        msgDecoded(k).data=BlockCode(k).data;
    end
    k=k+1;
end
toc




