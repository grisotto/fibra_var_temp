function [ Eout ] = desloca(Ein,deltaX,deltaY,vetorX)


% valores possiveis dos deslocamentos em x e y na funcao desloca
% -25< deltax,deltay < 25, com passo de 0.2
%ou seja: 2.2, -7.8, etc...

[Mf,Nf] = size(Ein);  
vetorY=vetorX;

for m1 = 1:Mf
     if vetorX(m1) == deltaX
       px = m1;
     end
   
     if vetorX(m1) == 0
       pzero = m1;
     end
     
     
end

%%%%%%%%%%%%%%%%%%%%%%%%
if deltaX > 0

   sX = px - pzero;
   

limiteX = deltaX+10;
   
for n1 = 1:Mf
  for n2 = 1:Nf
     if vetorX(n2) >= -10 & vetorX(n2) <= limiteX
          Ex(n1,n2)=Ein(n1,n2-sX);
     else
         Ex(n1,n2)=Ein(n1,n2);
     end
     
  end
end
end
%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%
if deltaX == 0
    Ex = Ein;
end
%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%
if deltaX < 0


   sX = pzero-px;
   

Xmenos = deltaX-10;
   
for n1 = 1:Mf
  for n2 = 1:Nf
     if vetorX(n2) >= Xmenos & vetorX(n2) <= 10
          Ex(n1,n2)=Ein(n1,n2+sX);
     else
         Ex(n1,n2)=Ein(n1,n2);
     end
     
  end
end
end
%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% calculando em Y

for m2 = 1:Mf
    
   if vetorY(m2) == deltaY
       py = m2;
   end
   
end

%%%%%%%%%%%%%%%%%%%%%%
if deltaY > 0


limiteY = deltaY+10;
sY = py - pzero;

for n1 = 1:Mf
  for n2 = 1:Nf
    
     
     if vetorY(n1) >= -10 & vetorY(n1) <= limiteY
          Exy(n1,n2)=Ex(n1-sY,n2);
     else
         Exy(n1,n2)=Ex(n1,n2);
     end
        
   end
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%
if deltaY == 0
    Exy = Ex;
end
%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%
if deltaY < 0

   sY = pzero-py;
   

Ymenos = deltaY-10;
   
for n1 = 1:Mf
  for n2 = 1:Nf
     if vetorY(n1) >= Ymenos & vetorX(n1) <= 10
          Exy(n1,n2)=Ex(n1+sY,n2);
     else
         Exy(n1,n2)=Ex(n1,n2);
     end
     
  end
end
end
%%%%%%%%%%%%%%%%%%%%%

Eout = Exy;


end

