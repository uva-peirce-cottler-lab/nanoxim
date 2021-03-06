function [ratio_img, bw_pix_passed, pix_st] = nanoxim_CalculateRatiomImage(bck_img, ...
    for_img,rgb_sig_thresh, numerator_chan_ind, denominator_chan_ind, blur_rad_pix, xy_shift)

blur_bck_img = imfilter(mean(bck_img,4),fspecial('gaussian',blur_rad_pix, 10*4096),'symmetric');

% Shift the forgorund image the requested degree
blur_for_img = imfilter(mean(for_img,4),fspecial('gaussian',blur_rad_pix, 10*4096),'symmetric');
shifted_blur_for_img = imtranslate(blur_for_img, xy_shift,'cubic','OutputView','same', ...
    'FillValues', NaN);


% Get back ground and forground images for each values (assigned to
% variables for clarity)
for_denominator = shifted_blur_for_img(:,:,denominator_chan_ind);
back_denominator = blur_bck_img(:,:,denominator_chan_ind);

for_numerator = shifted_blur_for_img(:,:,numerator_chan_ind);
back_numerator = blur_bck_img(:,:,numerator_chan_ind);


% background subtraction 
backsub_numerator = for_numerator - back_numerator;
backsub_denominator = for_denominator - back_denominator;

% Calculate ratio image
ratio_img = double(backsub_numerator)./double(backsub_denominator);

% Filter only valid pixels
bw_pix_passed = backsub_numerator>rgb_sig_thresh(denominator_chan_ind) & ...
    backsub_denominator>rgb_sig_thresh(numerator_chan_ind); 
% keyboard
fprintf('\tFraction of Image with Valid Data: %.2f\n',sum(bw_pix_passed(:))/numel(bw_pix_passed))

% Pixel values included are not restricted to passed pixels or the ROI
pix_st.denominator_back_vals = double(back_denominator);
pix_st.denominator_for_vals = double(for_denominator);
pix_st.denominator_backsub_vals = double(backsub_denominator);

pix_st.numerator_back_vals = double(back_numerator);
pix_st.numerator_for_vals = double(for_numerator);
pix_st.numerator_backsub_vals = double(backsub_numerator);
pix_st.bw_pix_passed = bw_pix_passed;

% keyboard
