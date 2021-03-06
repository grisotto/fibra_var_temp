%% Fibra variando a temperatura - referencia Tripathi-2009
% Temperaturas buscadas : 0, 5, 10 e 24(ja calculado)
% Definir o b(raio do nucleo) e o indice de refracao GRIN.
% 23-04 -email fibra-temp responde sobre b,n e t.

% Ideia seria: definir uma nova funcao para calculo do indice de refracao(ntemp) e
% apartir dae configurar o que for necessario.
% Preciso definir o b antes de calcular o n0 e calcular o ntemp
% Por este link: https://br.comsol.com/community/forums/general/thread/34208/
% Diz que devo calcular a expressao primeiramente e depois pegar o valor e
% recalcular!! Criar tudo pelo matlab mesmo.

%25-04 - Primeira tentativa, coloquei uma nova funcao no modelo do COMSOL,
%chamada n_temp.
%Dados que preciso pegar e salvar num arquivo apos a alteracao de cada temperatura: betas, neff,
%temperatura

%Consigo pegar os dados com esta versao, chamada de fibra_var_temp_2.

%TO_DO
%Colocar a equacao do b no modelo do COMSOL. OK
%Pega o n_core e n_casca, OK linha 275 OK
%Calcular os T no R apenas em deltaY, fazer meshgrid

clear all
clc
close all

tic

%% Conectando com o Comsol

disp('Conectando com o Comsol.')
model = mphload('fibra_Ge_Si');

caminho = ('/mnt/dados/Comp/Projeto_optics/novafiber/abril2015/temperatura');

nome1 = ('temp_dados.csv');


filename1 = fullfile(caminho,nome1);

disp('Abrindo o arquivo.')
fid=fopen(filename1,'wt');




fprintf(fid,'t (C)\t');
fprintf(fid,'n(nucleo)\t');
fprintf(fid,'n(casca)\t');
fprintf(fid,'neff2\t');
fprintf(fid,'neff3\t');
fprintf(fid,'neff4\t');
fprintf(fid,'neff5\t');
fprintf(fid,'neff6\t');


fprintf(fid,'BETA2\t');
fprintf(fid,'BETA3\t');
fprintf(fid,'BETA4\t');
fprintf(fid,'BETA5\t');
fprintf(fid,'BETA6\n');



model.hist.disable;% desativa o history para consumir menos memoria


neff1 = 0;
neff2 = 0;

disp('Gerando a geometria.')
 model.geom('geom1').run;
 
    disp('Gerando o mesh.')
 model.mesh('mesh1').run;
 



%constante de interesse:
%alpha = 5e-5;
%b0 = 30e-6;
%t0 = 24;
r0 = 4e-2;



%% Calculo dos modos na fibra monomodo


    model.sol('sol1').run() %Computa study1
    
    
   modosSMF = 6;
    
  neff1 = mphglobal(model,'emw.neff','Dataset','dset1','solnum',modosSMF);
    %neff2 = mphglobal(model,'emw2.neff','Dataset','dset2','solnum',6);
    %neff3 = mphglobal(model,'emw2.neff','Dataset','dset2','solnum',3);
   
   
   disp('Indice efetivo da fibra monomodo.') 
   neff1 
    
   %verifica se o modo excitado na fibra SMF teve algum problema, como:
   %1 - maior do que o chute que e um modo nao fisico
   %2 - menor que 1, que tambem e um modo nao fisico
   %3 -  e um numero real e nao um numero complexo (i)
   
   while neff1 > 1.46 || neff1 < 1.44 || isreal(neff1) == 0

       disp('Modo calculado e nao fisico.')
       disp('Calculando novamente para a fisica monomodo.')
       model.sol('sol1').run() %Computa study1
        
       neff1 = mphglobal(model,'emw.neff','Dataset','dset1','solnum',6);

               
   end
    Ebeta1 = mphglobal(model,'emw.beta','Dataset','dset1','solnum',6);

   disp('Indice calculado para a fibra monomodo.')
   neff1
   
   disp('Exportando o campo eletrico da fibra monomodo.')
    variandoSMF = strcat('E1grid_delta.csv');
    titulo1 = fullfile(caminho,variandoSMF);
        
    model.result.export('data1').set('data', 'dset1');
    model.result.export('data1').set('solnum', {'6'});    
    model.result.export('data1').setIndex('expr', 'emw.normE', 0);
    model.result.export('data1').set('filename', titulo1);
    model.result.export('data1').set('location', 'grid');
    model.result.export('data1').set('gridstruct', 'grid');
    model.result.export('data1').set('gridx2',...
 'range(-60,5,-45) range(-44,0.5,44) range(45,5,60)');
    model.result.export('data1').set('gridy2',...
 'range(-60,5,-45) range(-44,0.5,44) range(45,5,60)');
    model.result.export('data1').set('fullprec', 'off');
    model.result.export('data1').set('header', 'off');
    model.result.export('data1').run;
    
    disp('Exportando o campo eletrico sem grid.')
    %removendo as 4 primeiras linhas do arquivo
    E1delta = csvread(variandoSMF,4,0); 
    SMFsemgrid = strcat('E1delta.csv');
    csvwrite(SMFsemgrid,E1delta)
   
    
       %waitbar(m/limite)

%close(h)

%% Calculo dos modos da fibra Ge
%Como a temperatura so altera o indice da GRIN, entao a SMF ja esta
%resolvida.


temperaturas = [0,10,20,24,30];
limite = length(temperaturas);

for temp = 1:limite
    disp([' temp = ',num2str(temperaturas(temp))]);
     model.param.set('t', temperaturas(temp));
    

    disp('Gerando a geometria para novo raio da GRIN.')
 model.geom('geom1').run;
 
    disp('Gerando o mesh para novo raio da GRIN.')
 model.mesh('mesh1').run;
model.sol('sol2').run() %Computa study2

%Estes modos nao dependem de m, pois apenas a fibra monomodo se
%desloca. Assim iremos calcular estes modos apenas uma vez.
%Por isso eles estao fora do for.

        
    %irei selecionar todos os modos excitados da fibra GRIN
    %como esta definido modosGRIN = 15, entao eu devo encontrar 5 modos.
    %primeiro eu guardo todos os modos num vetor, ja verificando se ele e
    %real.
    
    
    modosGRIN=1;
    cont=0;
    contfalhas=0;
    neffGRIN(15) = zeros;
    
   
   
    
    while modosGRIN ~= 16
    
               
      %verifica se o valor e real, se for, ele armazena no vetor
  neff2 = mphglobal(model,'emw2.neff','Dataset','dset2','solnum',modosGRIN);
      %neff2
      
      %modosGRIN - modos encontrados
      if (isreal(neff2) == 1 &&  neff2 > 1.46 ) 
          
      %disp([' Entrei: ',num2str(neff2)]);    
neffGRIN(modosGRIN) = mphglobal(model,'emw2.neff','Dataset','dset2','solnum',modosGRIN);
      
      cont = cont+1;
      
      else
          contfalhas = contfalhas + 1;
          %caso ache 3 modos com problema, refaz o calculo no COMSOL
          if(contfalhas > 2)
          disp('Os 3 modos calculados nao sao validos')
          disp('Refazendo o calculo.')
          model.sol('sol2').run() %Computa study2
          
          %comeca novamente a procurar os modos
          modosGRIN=0;
          cont=0;
          contfalhas=0;
          neffGRIN(15) = zeros;
               
          
          end
      
      end
      
     modosGRIN = modosGRIN + 1;
      
    
    end
   
    
    %removo as duplicacoes, e a partir dae, eu definos os modos da
    %GRIN
    
    z=1;
      for i=1:cont
          %caso tenha um numero igual a outro, eu defino este como sendo 0
          %estou considerando apenas 5 casas apos a virgula
          
          neffGRIN(i);
          
          if neffGRIN(i) ~= 0
             if i ~= cont
            for j=i + 1: cont
  if round(neffGRIN(i).*10^6 ./ 10^1)   == round(neffGRIN(j).*10^6 ./ 10^1)
                 neffGRIN(j) = 0;
                end
              
            end
              end
          
          %defino a sequencia ou indice dos modos na fibraGRIN
          %5 modos
            posicao(z)= i;  
            z= z + 1;
          end
          
     
       
      end
      
  
  neff2 = mphglobal(model,'emw2.neff','Dataset','dset2','solnum',posicao(1));
  Ebeta2 = mphglobal(model,'emw2.beta','Dataset','dset2','solnum',posicao(1));   

  neff3 = mphglobal(model,'emw2.neff','Dataset','dset2','solnum',posicao(2));
  Ebeta3 = mphglobal(model,'emw2.beta','Dataset','dset2','solnum',posicao(2)); 

  neff4 = mphglobal(model,'emw2.neff','Dataset','dset2','solnum',posicao(3));
  Ebeta4 = mphglobal(model,'emw2.beta','Dataset','dset2','solnum',posicao(3));
 
  neff5 = mphglobal(model,'emw2.neff','Dataset','dset2','solnum',posicao(4));
  Ebeta5 = mphglobal(model,'emw2.beta','Dataset','dset2','solnum',posicao(4)); 

  neff6 = mphglobal(model,'emw2.neff','Dataset','dset2','solnum',posicao(5));
  Ebeta6 = mphglobal(model,'emw2.beta','Dataset','dset2','solnum',posicao(5)); 
  
  n_nucleo = mphmax(model,'ntemp','surface','Dataset','dset2','selection',2, 'solnum',10);
  n_casca = mphmax(model,'ntemp','surface','Dataset','dset2','selection',1, 'solnum',10);
close ALL  
  %Exportanto figuras a partir do COMSOL
figure
model.result('pg2').feature('surf1').set('looplevel', posicao(1));
mphplot(model,'pg2');
pause(1)
saveas(gcf(),[ 'E3_',num2str(temperaturas(temp)),'.png'], 'png')
%pause(0.5)
%close(figure(1))

figure
model.result('pg2').feature('surf1').set('looplevel', posicao(2));
mphplot(model,'pg2');
pause(1)
saveas(gcf(),[ 'E4_',num2str(temperaturas(temp)),'.png'], 'png')
%pause(0.5)
%close(figure(1))


model.result('pg2').feature('surf1').set('looplevel', posicao(3));
mphplot(model,'pg2');
pause(1)
saveas(gcf(), ['E5_',num2str(temperaturas(temp)),'.png'], 'png')

%pause(0.5)
%close(figure(1))

figure
model.result('pg2').feature('surf1').set('looplevel', posicao(4));
mphplot(model,'pg2');
pause(1)
saveas(gcf(), ['E6_',num2str(temperaturas(temp)),'.png'], 'png')
%pause(0.5)
%close(figure(1))

figure
model.result('pg2').feature('surf1').set('looplevel', posicao(5));
mphplot(model,'pg2');
pause(1)
saveas(gcf(), ['E2_',num2str(temperaturas(temp)),'.png'], 'png')
%pause(0.5)

close ALL
  
  %% Gerando os dados
  
   disp('Gravando no arquivo os modos obtidos.')
    %Escreve no console os valores obtidos   
format long
    fprintf(fid,[num2str(temperaturas(temp)),' , ']);
    fprintf(fid,[num2str(n_nucleo),' , ']);
    fprintf(fid,[num2str(n_casca),' , ']);
    %gravando os neffs
    fprintf(fid,[num2str(neff2),' , ']);
    fprintf(fid,[num2str(neff3),' , ']);
    fprintf(fid,[num2str(neff4),' , ']);
    fprintf(fid,[num2str(neff5),' , ']);
    fprintf(fid,[num2str(neff6),' , ']);
     %gravando os betas
    fprintf(fid,[num2str(Ebeta2),' , ']);
    fprintf(fid,[num2str(Ebeta3),' , ']);
    fprintf(fid,[num2str(Ebeta4),' , ']);
    fprintf(fid,[num2str(Ebeta5),' , ']);
    fprintf(fid,[num2str(Ebeta6),' \n']);


   
    disp('Dados obtidos:')    
    disp([' temp ',num2str(temperaturas(temp)),' beta2 ',num2str(Ebeta2),...
    ' beta3 ',num2str(Ebeta3),' beta4 ',num2str(Ebeta4),...
    ' beta5 ',num2str(Ebeta5),' beta6 ',num2str(Ebeta6)])

 format short     
    disp('Exportando o campo eletrico da fibra multimodo.')
    % irei exportar todos os valores do COMSOL para ser usados no
    % outro script
    %i=1;
    for i = 1:5
        
    variando2 = strcat('MMF',num2str(i),'_temp_',num2str(temperaturas(temp)),'.csv');
    titulo2 = fullfile(caminho,variando2);
   
    model.result.export('data2').set('data', 'dset2');
    model.result.export('data2').set('solnum', {num2str(posicao(i))});
    model.result.export('data2').setIndex('expr', 'emw2.normE', 0);
    model.result.export('data2').set('filename',titulo2);
    model.result.export('data2').set('location', 'grid');
    model.result.export('data2').set('gridstruct', 'grid');
    model.result.export('data2').set('gridx2',...
 'range(-60,5,-45) range(-44,0.2,44) range(45,5,60)');
    model.result.export('data2').set('gridy2',...
 'range(-60,5,-45) range(-44,0.2,44) range(45,5,60)');
    model.result.export('data2').set('fullprec', 'off');
    model.result.export('data2').set('header', 'off');
    model.result.export('data2').run;
    
     MF1 = csvread(variando2,4,0); 
     csvwrite(variando2,MF1)
    
     
    end
    
end

fclose(fid);
disp('Calculo encerrado.')
toc




