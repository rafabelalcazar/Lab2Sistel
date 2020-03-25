function signal = Filter(m,R,U,L,T=1)

    h1 = rcosfir(R, L, U, T,'sqrt'); %la longitud del filtro es 2*L*U+1
    su=upsample(m,U);
    %se agregan ceros debido al transiente del filtro
    su(c).data=[su1(c).data zeros(1,2*L*U+1)];
    %FILTRAJE
    x1(c).data=filter(h1,1,su(c).data);
    x1(c).data=filter(h1,1,x1(c).data); %se filtra 2 veces para simular el efecto del transmisor y el receptor

    %se cortan los ceros que se agregaron
    x1(c).data=x1(c).data(2*L*U+1:end);

    % recuperación de la secuencia original
    s1(c).data=downsample(x1(c).data, U);

    parteReal(c).data=real(s1(c).data);
    parteImg(c).data=imag(s1(c).data);
    c=c+1;

end