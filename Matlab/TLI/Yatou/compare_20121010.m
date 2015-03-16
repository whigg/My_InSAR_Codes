clear;
clc;

    chlfile= 'D:\myfiles\Software\Yatou_Paper\Data\S19992441999273.L3m_MO_CHL_chlor_a_9km';
    range=[598,812,3566,3696];
    chl= load_hdf_chinasea(chlfile,range(1),range(2),range(3),range(4));%Load data of China Sea.
    X=[-180:0.0833333:180];
    Y=fliplr([-90:0.0833333:90]);
    lats_range= Y(range(1):range(2));% Get lats range.
    lons_range= X(range(3):range(4));% Get lons range.
    lats= [31.63, 31.00, 28.43, 29.25, 31.43];% Lats of  given stations.
    lons=[122.800, 122.633, 127.300, 125.500, 126.133]; % Lons of  given stations.
    lats_pix= floor((lats_range(1)-lats)/0.0833333)+1;% Y pixel coors of given stations.
    lons_pix= floor((lons-lons_range(1))/0.0833333)+1;% X pixel coors of given stations.
    %chldata= chl(lats_pix, lons_pix);
    %matlab vectoral index if bullshit.
    chl_result=[0,0,0,0,0];
    for i=1:5;
        y=lats_pix(i);
        x=lons_pix(i);
        chl_result=[chl_result; [y,x, lats(i),lons(i),chl(y,x)]];
    end
    chl_result= chl_result(2:end, : );
    disp('               y               x               lats              lons            chl');
    disp(chl_result);