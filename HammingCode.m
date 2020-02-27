%Codigo Hamming
function Hamming = HammingCode (m)
    %Se define la matriz generadora
    G=[1 1 0 1 0 0 0;0 1 1 0 1 0 0;1 1 1 0 0 1 0;1 0 1 0 0 0 1];
    Hamming = rem (m*G,2);
end