k=10000;
A=1;
Delta=1;
nb_frames=100;
E_N0=-2:2:14;
phi=pi/8;
List_BER=zeros(1,8);
theoretical_ber=zeros(1,8);

for i=1:length(E_N0)
   
   sym_err=0;
   bit_err=0;
   v=((A^2*Delta^2)/4)*10^(-(E_N0(i))/10);
   temps_execution=zeros(1,nb_frames);

   for j=1:nb_frames
      %Emission
      m=randi([0 1],1,k);
      d=Bit2SymbolMappingQPSKGray(A,m);
      
      %Declage de phase entre TX/RX
      d_shift=d*exp(1i*phi);

      %Bruit
      d_bruit=AWGN(Delta,v,d);

      %Reception
      tic;
      d_est=MLSymbolDetectorQPSK(A,d_bruit);
      temps_execution(j)=toc;
        

      m_est=Symbol2BitsDemappingQPSKGray(A,Delta,d_est);

      %Transposition de d_est pour le calcul du TES
      d_est_trans=d_est.';
      
      %Interpretation
      BitDifferent=m~=m_est;
      SommeBitDifferent=sum(BitDifferent(:));
      

      SymDifferent=d~=d_est_trans;
      SommeSymDifferent=sum(SymDifferent(:));

      sym_err=sym_err+ SommeSymDifferent;
      bit_err=bit_err+ SommeBitDifferent;

   end    
   
   %theoretical_ber(i) = 2 * qfunc(sqrt(2 * E_N0_lin(i))) * (1 - 0.5 * qfunc(sqrt(2 * E_N0_lin(i))));
    
   %Stockage
   E_N0_lin(i)=10^(E_N0(i)/10);
   theoretical_ber(i) = erfc(sqrt((1/2)*E_N0_lin(i)));

   %theoretical_ber(i)=E_N0_lin(i);
   List_BER(i)=bit_err/(k*nb_frames);
   List_SER(i)=sym_err/(k*nb_frames/2);

   %Resultat
   fprintf('Temps execution moyen : %.5f secondes\n',mean(temps_execution))
   fprintf('Pour un SNR E/N0 en dB : %d\n',E_N0(i))
   fprintf('On trouve un TEB de :%.5f et un TES de :%.5f\n',bit_err/(k*nb_frames),sym_err/(k*nb_frames/2))

   %plot
   %semilogy(E_N0(i),bit_err)
  
end

List_BER
theoretical_ber
semilogy(E_N0,theoretical_ber, 'r--', 'LineWidth', 1.5)
hold on;
semilogy(E_N0,List_BER, 'g-s', 'LineWidth', 1.5)
semilogy(E_N0,List_SER, 'b-s', 'LineWidth', 1.5)
grid on;
