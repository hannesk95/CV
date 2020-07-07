function [tensor_l_out, tensor_r_out, tensor_l_scaled, tensor_r_scaled, scaling_factor] = prepare_images(tensor_l, tensor_r)
  N = size(tensor_l,3) / 3;
  img_width = size(tensor_l, 2);
  img_height = size(tensor_l, 1);
  
  %% Scale down input images and convert them to grayscale
  scaling_factor = 400 / img_width;  
  scaled_size = ceil([img_height img_width] * scaling_factor);
  tensor_l_scaled = uint8(zeros([scaled_size, N]));
  tensor_r_scaled = uint8(zeros([scaled_size, N]));
  tensor_l_out = uint8(zeros(img_height, img_width));
  tensor_r_out = uint8(zeros(img_height, img_width));
  
  for i = 1:N
      img_input = tensor_l(:,:,(1:3) + ((i-1) * 3));
      img_input = rgb2gray(img_input);
      tensor_l_out(:,:,i) = img_input;
      img_scaled = imresize(img_input, scaling_factor, 'nearest');
      w = size(img_scaled, 2);
      h = size(img_scaled, 1);
      tensor_l_scaled(1:h,1:w,i) = img_scaled;
      img_input = tensor_r(:,:,(1:3) + ((i-1) * 3));
      img_input = rgb2gray(img_input);
      tensor_r_out(:,:,i) = img_input;
      img_scaled = imresize(img_input, scaling_factor, 'nearest');
      tensor_r_scaled(1:h,1:w,i) = img_scaled;
  end
  
  %% Remove duplicates
  duplicates = zeros(1,N);
  for i = 2:N
      if nnz(tensor_l(:,:,i-1) - tensor_l(:,:,i)) == 0 || ...
         nnz(tensor_r(:,:,i-1) - tensor_r(:,:,i)) == 0
        duplicates(i) = 1;
      end
  end
  tensor_l_out(:,:,logical(duplicates)) = [];
  tensor_r_out(:,:,logical(duplicates)) = [];
  tensor_l_scaled(:,:,logical(duplicates)) = [];
  tensor_r_scaled(:,:,logical(duplicates)) = [];
  
end

