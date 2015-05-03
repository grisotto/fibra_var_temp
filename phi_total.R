#retirei a primeira linha, pois a leitura estava incorreta com o cabecario.
# estrutura dos temp_dados:
#header t (C)  n(nucleo)	n(casca)	neff2	neff3	neff4	neff5	neff6	BETA2	BETA3	BETA4	BETA5	BETA6
#1      0
#2      5
#3      10
#4      15
#5      20
#6      24
betas <- read.csv("temp_dados.csv", header = F, numerals = c("allow.loss", "warn.loss", "no.loss"))

#no nosso modelo o fundamental da GRIN é o beta6. Para não criar confusao irei trocar, beta2 agora é o fundamental.


beta2 <- betas[,13];
beta3 <- betas[,10];
beta4 <- betas[,11];
beta5 <- betas[,12];
beta6 <- betas[,9];


#constantes
r0 <- 4e-2;
L <- 0.82
alpha <- 5e-5;
t0 <- 24;


temp <- c(0,5,10,15,20,24);
N3 <- length(temp);

#criando um vetor de 0's
phi_total <- rep(0,N3);
r <- rep(0,N3);

for (i in 1:N3){
  #Mostro qual temperatura esta sendo calculada.
  print(temp[i])
  
  r[i] = r0 + alpha * r0 * (temp[i] - t0);
  
phi_total[i] =  (beta2[6] - beta3[6]) * (L - r0) + (beta2[i] - beta3[i] ) * r[i];

}

