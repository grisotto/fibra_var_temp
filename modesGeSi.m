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


%%fprintf(fid,'m\t');
%%fprintf(fid,'neff1\t');
%%fprintf(fid,'neff2\t');
%%fprintf(fid,'neff3\t');
%%fprintf(fid,'neff4\t');
%%fprintf(fid,'neff5\t');
%%fprintf(fid,'neff6\t');
%%fprintf(fid,'neff7\t');
%%fprintf(fid,'beta\n');

fprintf(fid,'neff\t');
fprintf(fid,'beta\n');


model.hist.disable;% desativa o history para consumir menos memoria


neff1 = 0;
neff2 = 0;

disp('Gerando a geometria.')
 model.geom('geom1').run;
 
    disp('Gerando o mesh.')
 model.mesh('mesh1').run;
 
h = waitbar(0,'Calculando modos COMSOL');

limite = 3;
%constante de interesse:
alpha = 5e-5;
b0 = 30e-6;
t0 = 24;
r0 = 4e-2;


temperaturas = [0,5,15];


%% Calculo dos modos na fibra monomodo

for temp = 0:limite
    
    
    
    b(temperaturas(temp)) = b0 + alpha * b0 (temperatura(temp) - t0);
    
    
    model.param.set('b', b);
    
    
    
    
    
    model.sol('sol1').run() %Computa study1
    
    
   modosSMF = 6;
    
  neff1 = mphglobal(model,'emw.neff','Dataset','dset1','solnum',modosSMF);
    %neff2 = mphglobal(model,'emw2.neff','Dataset','dset2','solnum',6);
    %neff3 = mphglobal(model,'emw2.neff','Dataset','dset2','solnum',3);
   
   disp('Espacamento:')
   m
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
    variandoSMF = strcat('E1grid_delta_',num2str(m),'.csv');
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
    SMFsemgrid = strcat('E1delta_',num2str(m),'.csv');
    csvwrite(SMFsemgrid,E1delta)
   
    
       waitbar(m/limite)
end
close(h)

%% Calculo dos modos da fibra Ge

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
      neff2
      
      %modosGRIN - modos encontrados
      if (isreal(neff2) == 1 &&  neff2 > 1.46 ) 
          
      disp([' Entrei: ',num2str(neff2)]);    
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
          
          neffGRIN(i)
          
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
   
      
  %% Gerando os dados
  
   disp('Gravando no arquivo os modos obtidos.')
    %Escreve no console os valores obtidos   
   %% fprintf(fid,[num2str(neff1),' , ']);
   %% fprintf(fid,[num2str(neff2),' , ']);
   %% fprintf(fid,[num2str(neff3),' , ']);
   %% fprintf(fid,[num2str(neff4),' , ']);
   %% fprintf(fid,[num2str(neff5),' , ']);
   %% fprintf(fid,[num2str(neff6),' \n']);

    fprintf(fid,[num2str(neff1),' , ']);
    fprintf(fid,[num2str(Ebeta1),' \n']);
    fprintf(fid,[num2str(neff2),' , ']);
    fprintf(fid,[num2str(Ebeta2),' \n']);
    fprintf(fid,[num2str(neff3),' , ']);
    fprintf(fid,[num2str(Ebeta3),' \n']);
    fprintf(fid,[num2str(neff4),' , ']);
    fprintf(fid,[num2str(Ebeta4),' \n']);
    fprintf(fid,[num2str(neff5),' , ']);
    fprintf(fid,[num2str(Ebeta5),' \n']);
    fprintf(fid,[num2str(neff6),' , ']);
    fprintf(fid,[num2str(Ebeta6),' \n']);


   
    disp('Os modos obtidos sao:')    
    disp([' m ',num2str(m),' neff1 ',num2str(neff1),...
    ' neff2 ',num2str(neff2),' neff3 ',num2str(neff3),...
    ' neff4 ',num2str(neff4),' neff5 ',num2str(neff5),...
    ' neff6 ',num2str(neff6)])

      
    disp('Exportando o campo eletrico da fibra multimodo.')
    % irei exportar todos os valores do COMSOL para ser usados no
    % outro script
    %i=1;
    for i = 1:5
        
    variando2 = strcat('MMF',num2str(i),'.csv');
    titulo2 = fullfile(caminho,variando2);
   
    model.result.export('data2').set('data', 'dset2');
    model.result.export('data2').set('solnum', {num2str(posicao(i))});
    model.result.export('data2').setIndex('expr', 'emw2.normE', 0);
    model.result.export('data2').set('filename',titulo2);
    model.result.export('data2').set('location', 'grid');
    model.result.export('data2').set('gridstruct', 'grid');
    model.result.export('data2').set('gridx2',...
 'range(-60,5,-45) range(-44,0.5,44) range(45,5,60)');
    model.result.export('data2').set('gridy2',...
 'range(-60,5,-45) range(-44,0.5,44) range(45,5,60)');
    model.result.export('data2').set('fullprec', 'off');
    model.result.export('data2').set('header', 'off');
    model.result.export('data2').run;
    
     MF1 = csvread(variando2,4,0); 
     csvwrite(variando2,MF1)
    
     
    end
    
    

fclose(fid);
disp('Calculo encerrado.')
toc




