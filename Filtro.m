close all 
clear 

%%  Pruebas para la creación del SRRC

%Filtro Conformador 
%U sobremuestreo
%R roll-off
%T es el periodo de símbolo, pero es irrelevante
%L*U debe dar un número par 
R=0.25 ; U=16; L=8; T=1;
h1 = rcosfir(R, L, U, T,'sqrt') ; %la longitud del filtro es 2*L*U+1
h2 = rcosdesign(R, L, U,'sqrt'); %la longitud del filtro es L*U+1
% implementación de los filtros
s=randsrc(1, 20, [-3 -1 1 3]); %secuencia de símbolos 4-PAM 
% upsample(s,n): Aumenta la frecuencia de muestreo agregando n ceros
su1=upsample(s,U);
%se agregan ceros debido al transiente del filtro
su=[su1 zeros(1,2*L*U+1)];
%filtraje
x1=filter(h1,1,su); x1=filter(h1,1,x1); %se filtra 2 veces para simular el efecto del transmisor y el receptor
x2=filter(h2,1,su); x2=filter(h2,1,x2);
%se cortan los ceros que se agregaron 
x1=x1(2*L*U+1:end);
x2=x2(L*U+1:end-L*U);
%gráfica de las formas de onda resultantes
figure()
plot(x1), hold on 
plot(x2),grid on
% recuperación de la secuencia original
s1=downsample(x1, U);
s2=downsample(x2, U);
%gráfica de las secuencias recuperadas
figure()
stem(s,'.', 'linewidth', 2), hold on
stem(s1,'.', 'linewidth', 2),
stem(s2,'.', 'linewidth', 2), grid on 
legend('orignal', 'filtro1', 'filtro2')


%% pruebas con diferentes factores de Roll-Off

U=16; L=8; T=1;
R1=0.2;  R2=0.4;  R3=0.6;  R4=0.8; 
%filtros con diferentes valores de Roll-Off
h1 = rcosfir(R1, L, U, T,'sqrt') ; 
h2 = rcosfir(R2, L, U, T,'sqrt') ; 
h3 = rcosfir(R3, L, U, T,'sqrt') ; 
h4 = rcosfir(R4, L, U, T,'sqrt') ; 
% implementación de los filtros
s=randsrc(1, 20, [-3 -1 1 3]);  su=upsample(s,U);
%se agregan ceros debido al transiente del filtro
su=[su zeros(1,2*L*U+1)];
%filtraje
x1=filter(h1,1,su); x2=filter(h2,1,su);  x3=filter(h3,1,su);  x4=filter(h4,1,su); 
%espectro de las señales filtradas 
[X1,f]=spectrum(x1,U);
[X2,~]=spectrum(x2,U);
[X3,~]=spectrum(x3,U);
[X4,~]=spectrum(x4,U);
%gráfica de los espectros de la señal 
figure(), 
subplot(221), plot(f,abs(X1)),grid on, title({'factor de Roll-Off ' num2str(R1)})
subplot(222), plot(f,abs(X2)),grid on, title({'factor de Roll-Off ' num2str(R2)})
subplot(223), plot(f,abs(X3)),grid on, title({'factor de Roll-Off ' num2str(R3)})
subplot(224), plot(f,abs(X4)),grid on, title({'factor de Roll-Off ' num2str(R4)})