


function [ Ixy ] = simp2D(vetorx,vetory,fxy)

Ny = length(vetory);

for jj = 1:Ny

        fx = fxy(jj,:);
             
%psien(jj,:) = vetor (matriz linha) igual a linha jj da matriz psien
      
        fy(jj) = simps(vetorx,fx);
  %Ir = int r*psien dr, q e exatamente a funcao de z q entra 
%na integral de z:
        
end
    
Ixy = simps(vetory,fy);

end