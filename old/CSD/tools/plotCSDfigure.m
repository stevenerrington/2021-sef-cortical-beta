function plotCSDfigure(CSD)

% Generated CSD figure
session_CSD = nanmean(CSD.CSD(2:end-1, :, :),3);
session_CSD = [session_CSD(1,:) ; session_CSD ; session_CSD(end,:)];

nele = size(session_CSD,1);
session_CSD = H_2DSMOOTH(session_CSD);
limi = nanmax(nanmax(abs(session_CSD)));

figure;
imagesc([-1000:2000], 1:size(session_CSD,1), session_CSD);

tej = flipud(colormap('jet'));
colormap(tej);
caxis([-limi limi]);
colorbar

for i = 1 : nele
    labels{i} = num2str(i);
end

set(gca,'xlim', [-250 500], 'ydir', 'rev','ylim', [1 size(session_CSD,1)],...
    'ytick', linspace(1, size(session_CSD,1), nele), 'yticklabel', labels)

vline(0,'k-')

end

