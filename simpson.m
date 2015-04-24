function [ Sout ] = simpson( Iin, a,b,c,d )
%Metodo de Simpson para todos os E
%   Detailed explanation goes here
  I1 = Iin;

  [rr1,cc1]=size(I1);
    Sout = I1(:,1) + I1(:,cc1); % matriz coluna igual a soma dos elementos
  Sout=Sout'; % o apostrofo transpoe a matriz
  Sout = Sout + 4*sum(I1(:,2:2:(cc1-1))') + 2*sum(I1(:,3:2:(cc1-2))');
  Sout = (d-c)/(3*(cc1-1)) * Sout;
    I1 = Sout;
  Sout = Sout(1) + I1(rr1);
  Sout = Sout + 4*sum(I1(2:2:(rr1-1))) + 2 * sum(I1(3:2:(rr1-2)));
  Sout = (b-a)/(3*(rr1-1)) * Sout;



end

