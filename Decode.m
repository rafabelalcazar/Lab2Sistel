% Correci�n de errores
%To DO: Hacer la logica para detecci�n y correcion de errores
function decodeMsg = Decode (mCoded)
    %Se define la matriz H
    H=[1 0 0 1 0 1 1;0 1 0 1 1 1 0;0 0 1 0 1 1 1];
    
    %Si no existen errores el vector Sindrome ser� [0 0 0]
    sindrome = rem(mCoded*H',2);
    decodeMsg = sindrome;
end