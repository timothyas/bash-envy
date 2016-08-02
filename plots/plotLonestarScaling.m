function[ ] = plotLonestarScaling()

nProcs = [72 96 192 360];
tWallAll = [16912 9446 5036 4207];
tWallAdjoint = [16889 9440 5027 4176];
tWallForward = [2996 2201 1457 1484];
tWOtaccaffinity = 15087;

T1 = tWallAll(2)*nProcs(2);
SpAll = tWallAll(2)./tWallAll;
SpForward = tWallForward(2)./tWallForward;
SpAdjoint = tWallAdjoint(2)./tWallAdjoint; 
SpWOaffinity = tWallAll(2)./tWOtaccaffinity;

% EpAll = SpAll./


figureW;
subplot(1,2,1),plot(nProcs,tWallAll,'-*',nProcs,tWallForward,'-*',nProcs,tWallAdjoint,'-*',96,tWOtaccaffinity,'k*')
    xlabel('Num. Cores')
    set(gca,'xtick',nProcs,'xticklabel',nProcs)
    ylabel('Wall Clock Time (s)')

subplot(1,2,2),plot(nProcs,SpAll,'*-',nProcs,SpForward,'-*',nProcs,SpAdjoint,'-*',96,SpWOaffinity,'k*')
    xlabel('Num. Cores')
    set(gca,'xtick',nProcs,'xticklabel',nProcs)
    ylabel('Speedup (T_p/T_{96})')
    legend('All','Forward','Adjoint','Without tacc\_affinity','location','northwest')

    
    set(gcf,'paperorientation','landscape')
    set(gcf,'paperunits','normalized')
    set(gcf,'paperposition',[0 0 1 1])
    saveas(gcf,'../write-scratch/samoc/lonestar-mitgcm-scaling','pdf')

end