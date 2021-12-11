function cost = RTObjectiveFunction(int_MF)

% int_MF = int_MF(:,[1,4,1,2,2,5,3]);

%names = {vas_med,rect_fem,vas_lat,bifem,semiten,med_gas,lat_gas};
norm_mean = [58.480953,48.549939,85.576634,18.970157,7.748500,54.985703,28.492048];
norm_std = [30.817681,19.769583,31.620449,10.806113,3.845430,22.691249,15.875190];

int_MF = (int_MF - norm_mean)./norm_std;

cost = 0.10028*int_MF(1) + 0.20613*int_MF(2) + 0.12409*int_MF(6) + 0.080734*int_MF(7);

end