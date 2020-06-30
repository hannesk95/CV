classdef ImageReader < handle
    
    properties
        src         % Data source
        L           % Left camera
        R           % Right camera
        start       % Initial framenumber
        N           % Number of consecutive successors       
        iterator    % Iterator variable for method 'next'
        loop        % loop variable for method 'next'
    end    
    
    methods
        function obj = ImageReader(src, L, R, start, N)           
            
            obj.iterator = 0;
            obj.loop = 0;
            
            if (nargin < 3)
                error('[Error]: At least parameters "src", "L" and "R" have to be determined!');            
            elseif (nargin < 4)                
                obj.src = src;
                obj.L = L;
                obj.R = R;
                obj.start = 0;
                obj.N = 1;               
                disp('[INFO]: No value for start and N parameter given, therefore set N=1 and start=0');                
            elseif (nargin < 5)               
                obj.src = src;
                obj.L = L;
                obj.R = R;
                obj.start = start;
                obj.N = 1;
                disp('[INFO]: No value for N parameter given, therefore set N=1');
            elseif (nargin == 5)
                obj.src = src;
                obj.L = L;
                obj.R = R;
                obj.start = start;
                obj.N = N;
            end     
            
            % Check source (src) value
            if ~(ischar(src))
               error('Data source "src" has to be a char (string) variable!'); 
            end
            
            % Check left camera (L) value
            if ~(isnumeric(L))
                error('Left camera input parameter "L" must be numeric');
            %elseif L ~= (1 | 2)
            %    error('Left camera input parameter "L" must be either 1 or 2');
            end
            
            % Check right camera (R) value
            if ~(isnumeric(R))
                error('Right camera input parameter "R must be numeric');
            %elseif R ~= (2) % Include 3 !!!!
            %    error('Right camera input parameter "R" must be either 2 or 3');
            %elseif R == L
            %    error('If left camera paramter "L = 2" then right frame paramter "R" has to be 3');
            end
            
            % Check inital framenumber (start) value
            if ~(isnumeric(start))
                error('Start paramater "start" must be numeric')
            elseif (start < 0)
                error('Start paramater "start" has to be greater or equal to zero')
                %Detect whether number is integer or not!
            end            
            
            % Check consecutive successors (N) value
            if ~(isnumeric(N))
                error('Consecutive successors paramater "N" must be numeric')
            elseif (N < 1)
                error('Consecutive successors paramater "N" has to be greater or equal to one')
                %Detect whether number is integer or not!
            end
         
            
        end       
        
        function [left, right, loop] = next(obj)        
           
            start_value = obj.start;             
            
            if (obj.loop == 1)
                start_value = 1;
                loop = 0;
                obj.start = 1;
                obj.iterator = 0;
                obj.loop = 0;                
            else
                loop = obj.loop;
            end
            
            %Build actual data path
            if (contains(obj.src, '\'))
                split = strsplit(obj.src, '\');
                framesL = strcat(obj.src, '\', split{end}, '_C', int2str(obj.L));
                framesR = strcat(obj.src, '\', split{end}, '_C', int2str(obj.R));                
            else
                split = strsplit(obj.src, '/');
                framesL = strcat(obj.src, '/', split{end}, '_C', int2str(obj.L));
                framesR = strcat(obj.src, '/', split{end}, '_C', int2str(obj.R));                
            end
            
            %Load images directroy
            dinfoL = dir(framesL);
            dinfoR = dir(framesR);
            temp_names_cell_L = {dinfoL.name};
            temp_names_cell_R = {dinfoR.name};
            
            %names_cell_L = zeros(1, length(find(contains(temp_names_cell_R, 'jpg'))));
            %names_cell_R = zeros(1, length(find(contains(temp_names_cell_R, 'jpg'))));
            
            %Prepare name cells with image names only
            names_cell_L = {};
            names_cell_R = {};
            
            j = 1;
            for i = 1:length(temp_names_cell_L)
               if (contains(temp_names_cell_L{i}, 'jpg'))                  
                  names_cell_L{j} = temp_names_cell_L{i}; 
                  names_cell_R{j} = temp_names_cell_R{i};
                  j = j + 1;
               end                   
            end           
            
            % Load first image into left and right image tensors
            temp_left = importdata(strcat(framesL, '/', names_cell_L{start_value+obj.iterator}));            
            left = temp_left;
            temp_right = importdata(strcat(framesR, '/', names_cell_R{start_value+obj.iterator}));            
            right = temp_right;            
            
            % Condition: Not enough images avialable
            if (start_value > length(names_cell_L))
                error('Start value is bigger than entries available in the dataset, please choose a smaller value');            
            elseif (abs(start_value - length(names_cell_L)) < obj.N)
                num_images = abs(start_value - length(names_cell_L));
                obj.loop = 1;
                loop = 1;
            else
                num_images = obj.N;
            end
            
            % Load consecutive successors into left and right image tensors
            for i = 1:num_images
                temp_left = importdata(strcat(framesL, '/', names_cell_L{start_value+i+obj.iterator}));
                left = cat(3, left, temp_left);
                temp_right = importdata(strcat(framesR, '/', names_cell_R{start_value+i+obj.iterator}));
                right = cat(3, right, temp_right);
            end            
            
            %Increment iterator            
            obj.iterator = obj.iterator + 1;           
            
        end
    end
end


