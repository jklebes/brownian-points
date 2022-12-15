%generate a 
%cell array of tables , each table contains a list of blobs at a
%timepoint

x_dim = 500;
y_dim = 500;
n_timepoints=100;
num_particles = 51; %constant in this easy example
position_sigma=2;
split_position_sigma=10;
avg_radius = 8;
radius_interparticle_sigma = 1;
radius_time_sigma = .5;
ellipticity_time_sigma=.05;
avg_intensity = 50; 
intensity_interparticle_sigma = 10;
intensity_time_sigma = 5;
angle_time_sigma = .2;

chance_hidden =.01;
chance_dissapear = .01;
chance_appear = .01;
chance_split= .01;

%columns of initial table, time point 1
ID = 1:num_particles;
ID = ID';
POS_X = x_dim*rand(num_particles,1);
POS_Y = y_dim*rand(num_particles,1);
%correct initial overlaps
for j =1:num_particles
    dist_list = (POS_X(j)-POS_X).^2+(POS_Y(j)-POS_Y).^2;
    dist_list(j)= Inf;
    while any(dist_list<(2*avg_radius)^2)
        POS_X(j) = x_dim*rand(1,1);
        POS_Y(j) = y_dim*rand(1,1);
        dist_list = (POS_X(j)-POS_X).^2+(POS_Y(j)-POS_Y).^2;
        dist_list(j)= Inf;
    end
end
RADIUS = avg_radius+radius_interparticle_sigma*randn(num_particles,1); %normal dist
ELLIPTICITY = rand(num_particles,1); %0 to 1?
INTENSITY = avg_intensity+intensity_interparticle_sigma*randn(num_particles,1);
ANGLE = 2*pi*rand(num_particles,1); %in radians
RADIUS0=RADIUS;
ELLIPTICITY0=ELLIPTICITY;
INTENSITY0=INTENSITY;
ANGLE0=ANGLE;


table_time1 = table(ID, POS_X, POS_Y, RADIUS, INTENSITY, ELLIPTICITY, ANGLE);
%start list fo tables
tracking_example_data_2=cell(n_timepoints,1);
tracking_example_data_2{1,1}= table_time1;

%generate next time points
current_table = table_time1;
for i = 2:n_timepoints
    %jiggle values
    new_POS_X = POS_X+position_sigma*randn(num_particles,1);
    new_POS_Y = POS_Y+position_sigma*randn(num_particles,1);
    for j =1:num_particles
        dist_list = (new_POS_X(j)-new_POS_X).^2+(new_POS_Y(j)-new_POS_Y).^2;
        dist_list(j)= Inf;
        while any(dist_list<(2*avg_radius)^2)
            new_POS_X(j) = new_POS_X(j)+position_sigma*randn(1,1);
            new_POS_Y(j) = new_POS_Y(j)+position_sigma*randn(1,1);
            dist_list = (new_POS_X(j)-new_POS_X).^2+(new_POS_Y(j)-new_POS_Y).^2;
            dist_list(j)= Inf;
        end
    end
    POS_X = new_POS_X;
    POS_Y = new_POS_Y;
    RADIUS = RADIUS0+radius_time_sigma*randn(num_particles,1);
    INTENSITY = INTENSITY0 + intensity_time_sigma*randn(num_particles,1);
    ELLIPTICITY = ELLIPTICITY0 + ellipticity_time_sigma*randn(num_particles,1);
    ANGLE = mod(ANGLE0+angle_time_sigma*randn(num_particles,1), 2 *pi);
    %apply other effects
    dissapear=rand(num_particles,1)<chance_dissapear;
    num_appear=sum(rand(num_particles,1)<chance_appear);
    split=rand(num_particles,1)<chance_split;
    num_hidden = sum(rand(num_particles,1)<chance_split);
    num_particles_original = num_particles;
    num_particles = num_particles + num_appear + sum(split) -sum(dissapear);
    %implement disspearances
    POS_X = POS_X(~dissapear);
    POS_Y = POS_Y(~dissapear);
    RADIUS = RADIUS(~dissapear);
    RADIUS0 = RADIUS0(~dissapear);
    INTENSITY = INTENSITY(~dissapear);
    INTENSITY0 = INTENSITY0(~dissapear);
    ANGLE = ANGLE(~dissapear);
    ANGLE0 = ANGLE0(~dissapear);
    ELLIPTICITY = ELLIPTICITY(~dissapear);
    ELLIPTICITY0 = ELLIPTICITY0(~dissapear);
    %implement appearances: add particles
    for j=1:num_appear
        new_POS_X = x_dim*rand(1,1);
        new_POS_Y = y_dim*rand(1,1);
        dist_list = (new_POS_X-POS_X).^2+(new_POS_Y-POS_Y).^2;
        while any(dist_list<(2*avg_radius)^2)
            new_POS_X = x_dim*rand(1,1);
            new_POS_Y = y_dim*rand(1,1);
            dist_list = (new_POS_X-POS_X).^2+(new_POS_Y-POS_Y).^2;
        end
        POS_X = [POS_X; new_POS_X];
        POS_Y = [POS_Y; new_POS_Y];
    end
    RADIUS = [RADIUS; avg_radius+radius_interparticle_sigma*randn(num_appear,1)];
    RADIUS0 = [RADIUS0; avg_radius+radius_interparticle_sigma*randn(num_appear,1)];
    INTENSITY = [INTENSITY ;avg_intensity+intensity_interparticle_sigma*randn(num_appear,1)];
    INTENSITY0 = [INTENSITY0 ;avg_intensity+intensity_interparticle_sigma*randn(num_appear,1)];
    ELLIPTICITY = [ELLIPTICITY; rand(num_appear,1)];
    ELLIPTICITY0 = [ELLIPTICITY0; rand(num_appear,1)];
    ANGLE = [ANGLE; 2*pi*rand(num_appear,1)];
    ANGLE0 = [ANGLE0; 2*pi*rand(num_appear,1)];
    %implement splits (hard)
    js = 1:num_particles_original;
    for j=js(split)
        new_POS_X1 = POS_X(j)+split_position_sigma*rand(1,1);
        new_POS_Y1 = POS_Y(j)+split_position_sigma*rand(1,1);
        new_POS_X2 = POS_X(j)+split_position_sigma*rand(1,1);
        new_POS_Y2 = POS_Y(j)+split_position_sigma*rand(1,1);
        dist_list = (new_POS_X2-POS_X).^2+(new_POS_Y2-POS_Y).^2;
        %potentially move 2nd particle some more
        while any(dist_list<(2*avg_radius)^2)
            new_POS_X2 = new_POS_X2+split_position_sigma*rand(1,1);
            new_POS_Y2 = new_POS_Y2+split_position_sigma*rand(1,1);
            dist_list = (new_POS_X2-POS_X).^2+(new_POS_Y2-POS_Y).^2;
        end
        POS_X(j)= new_POS_X1;
        POS_Y(j)= new_POS_Y1;
        POS_X = [POS_X; new_POS_X2];
        POS_Y = [POS_Y; new_POS_Y2];
        %add new particle's other characteritics
        RADIUS = [RADIUS; RADIUS(j)+radius_time_sigma*randn(1,1)];
        RADIUS0 = [RADIUS0; RADIUS(j)+radius_time_sigma*randn(1,1)];
        INTENSITY = [INTENSITY ;INTENSITY(j)+intensity_time_sigma*randn(1,1)];
        INTENSITY0 = [INTENSITY0 ;INTENSITY(j)+intensity_time_sigma*randn(1,1)];
        ELLIPTICITY = [ELLIPTICITY; ELLIPTICITY(j)+ellipticity_time_sigma(1,1)];
        ELLIPTICITY0 = [ELLIPTICITY0; ELLIPTICITY(j)+ellipticity_time_sigma(1,1)];
        ANGLE = [ANGLE; mod(ANGLE(j)+angle_time_sigma(1,1),2*pi)];
        ANGLE0 = [ANGLE0; mod(ANGLE(j)+angle_time_sigma(1,1),2*pi)];
    end
    %assign ids
    ID = max(ID)+1:max(ID)+1+num_particles;
    ID = ID';
    ID = ID(randperm(num_particles)); 
    %collect new data in a table 
    table_time_i = table(ID, POS_X, POS_Y, RADIUS, INTENSITY, ELLIPTICITY, ANGLE);
    table_time_i= sortrows(table_time_i, "ID");
    %don't output particles out of frame
    table_time_i(table_time_i{:,"POS_X"}>500+avg_radius|table_time_i{:,"POS_X"}<0-avg_radius, :)=[];
    table_time_i(table_time_i{:,"POS_Y"}>500+avg_radius|table_time_i{:,"POS_Y"}<0-avg_radius, :)=[];
    %- but don't output hidden particles - drop last rows
    table_time_i(end-num_hidden:end, :)=[];
    %save table in cell array of tables
    tracking_example_data_2{i, 1}= table_time_i;
end

save("tracking_exampledata_2_hard", "tracking_example_data_2")