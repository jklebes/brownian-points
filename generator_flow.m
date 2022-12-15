%generate a 
% struct of tables , each table contains a list of blobs at a
%timepoint

x_dim = 500;
y_dim = 500;
n_timepoints=100;
num_particles = 51; %constant in this easy example
position_sigma=2;
avg_radius = 8;
radius_interparticle_sigma = 1;
radius_time_sigma = .5;
avg_intensity = 50; 
intensity_interparticle_sigma = 10;
intensity_time_sigma = 5;
ellipticity_time_sigma=.05;
angle_time_sigma = .2;

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

table_time1 = table(ID, POS_X, POS_Y, RADIUS, INTENSITY, ELLIPTICITY, ANGLE);
%start list fo tables
tracking_example_data_1=cell(n_timepoints,1);
tracking_example_data_1{1,1}= table_time1;

%generate next time points
current_table = table_time1;
for i = 2:n_timepoints
    ID = ID+num_particles;
    ID = ID(randperm(num_particles)); %shuffle labels or this is too easy
    new_POS_X = POS_X+position_sigma*randn(num_particles,1);
    new_POS_Y = POS_Y+position_sigma*randn(num_particles,1);
    for j =1:num_particles
        dist_list = (new_POS_X(j)-new_POS_X).^2+(new_POS_Y(j)-new_POS_Y).^2;
        dist_list(j)= Inf;
        while any(dist_list<(2*avg_radius)^2)
            new_POS_X(j) = POS_X(j)+position_sigma*randn(1,1);
            new_POS_Y(j) = POS_Y(j)+position_sigma*randn(1,1);
            dist_list = (new_POS_X(j)-new_POS_X).^2+(new_POS_Y(j)-new_POS_Y).^2;
            dist_list(j)= Inf;
        end
    end
    POS_X = new_POS_X;
    POS_Y = new_POS_Y;
    RADIUS = RADIUS+radius_time_sigma*randn(num_particles,1);
    INTENSITY = INTENSITY + intensity_time_sigma*randn(num_particles,1);
    ELLIPTICITY = ELLIPTICITY + ellipticity_time_sigma*randn(num_particles,1);
    ANGLE = ANGLE+mod(angle_time_sigma*randn(num_particles,1), 2 *pi);
    %collect new data in a table
    table_time_i = table(ID, POS_X, POS_Y, RADIUS, INTENSITY, ELLIPTICITY, ANGLE);
    table_time_i=sortrows(table_time_i, "ID");
    %save table in cell array of tables
    tracking_example_data_1{i, 1}= table_time_i;
end

save("tracking_exampledata_1", "tracking_example_data_1")