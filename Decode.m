% Correci�n de errores
%To DO: Hacer la logica para detecci�n y correcion de errores
function decodeMsg = Decode (mCoded)
    %Se define la matriz H
    H=[1 0 0 1 0 1 1;0 1 0 1 1 1 0;0 0 1 0 1 1 1];
    
    %Se establecen los sindromes con los cuales se realizara la correci�n del mensaje
    s1=[1 1 0];                             
    s2=[0 1 1];
    s3=[1 1 1];
    s4=[1 0 1];
    
    %Si no existen errores el vector Sindrome ser� [0 0 0]
    sindrome = rem(mCoded*H',2);
    if(sindrome == s1 )
        decodeMsg = rem(mCoded+[0 0 0 1 0 0 0],2);
        decodeMsg = decodeMsg(4:end);
    elseif(sindrome == s2 )
        decodeMsg = rem(mCoded+[0 0 0 0 1 0 0],2);
        decodeMsg = decodeMsg(4:end);
    elseif(sindrome == s3)
        decodeMsg = rem(mCoded+[0 0 0 0 0 1 0],2);
        decodeMsg = decodeMsg(4:end);
    elseif(sindrome == s4)
        decodeMsg = rem(mCoded+[0 0 0 0 0 0 1],2);
        decodeMsg = decodeMsg(4:end);
    else
        decodeMsg=mCoded(4:end);
    end
end