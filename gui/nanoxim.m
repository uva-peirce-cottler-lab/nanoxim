function varargout = nanoxim(varargin)
% NANOXIM MATLAB code for nanoxim.fig
%      NANOXIM, by itself, creates a new NANOXIM or raises the existing
%      singleton*.
%
%      H = NANOXIM returns the handle to a new NANOXIM or the handle to
%      the existing singleton*.
%
%      NANOXIM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NANOXIM.M with the given input arguments.
%
%      NANOXIM('Property','Value',...) creates a new NANOXIM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before nanoxim_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to nanoxim_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help nanoxim

% Last Modified by GUIDE v2.5 17-Dec-2019 16:31:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @nanoxim_OpeningFcn, ...
                   'gui_OutputFcn',  @nanoxim_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before nanoxim is made visible.
function nanoxim_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to nanoxim (see VARARGIN)

% Choose default command line output for nanoxim
handles.output = hObject;

% keyboard

% Create a background and forgroudn sliders
set(handles.slider_frame_ind,'units','pixels');
sld_pos = get(handles.slider_frame_ind,'position');
set(handles.slider_frame_ind,'units','characters');

set(handles.edit_bck_high,'units','pixels');
bck_pos = get(handles.edit_bck_high,'position');
set(handles.edit_bck_high,'units','characters');

set(handles.edit_for_high,'units','pixels');
for_pos = get(handles.edit_for_high,'position');
set(handles.edit_for_high,'units','characters');

[handles.rslider_bck_hcomp, handles.rslider_bck_hcont, handles.rslider_bck] = ...
    gui_RangeSlider([1 100],[sld_pos(1) bck_pos(2)-bck_pos(4) sld_pos(3) 2*bck_pos(4)],'BCK','horizontal',...
    handles.edit_bck_low,handles.edit_bck_high, handles);
% Create a forground range slider 
[handles.rslider_for_hcomp, handles.rslider_for_hcont, handles.rslider_for] = ...
    gui_RangeSlider([1 100],[sld_pos(1) for_pos(2)-for_pos(4) sld_pos(3) 2*for_pos(4)],'FOR','horizontal',...
    handles.edit_for_low, handles.edit_for_high, handles);

% Ratiometrix threshold slider
set(handles.text_ratiom_min,'units','pixels');
rmin_pos = get(handles.text_ratiom_min,'position');
set(handles.text_ratiom_min,'units','characters');

set(handles.edit_ratiom_max,'units','pixels');
rlow_pos = get(handles.edit_ratiom_max,'position');
set(handles.edit_ratiom_max,'units','characters');

% sld_pos = get(handles.uipanel_ratiom,'position');
[handles.rslider_ratiom_hcomp, handles.rslider_ratiom_hcont, handles.rslider_ratiom] = ...
    gui_RangeSlider([0 100],[rmin_pos(1) rmin_pos(2)+rmin_pos(4) 2*rmin_pos(3)...
    rlow_pos(2)-(rmin_pos(2)+rmin_pos(4))],'RAT','vertical',...
    handles.edit_ratiom_low, handles.edit_ratiom_high, handles);


% Add continuous callback for video index slider
hListener = addlistener(handles.slider_frame_ind,'ContinuousValueChange',@slider_frame_ind_Callback);
setappdata(handles.slider_frame_ind,'sliderListener',hListener)

%Initialize busy icon for calculations
% keyboard

set(handles.figure_nanoxim,'units','pixels');
fig_pos = get(handles.figure_nanoxim,'position');
set(handles.figure_nanoxim,'units','characters');

try
    % R2010a and newer
    iconsClassName = 'com.mathworks.widgets.BusyAffordance$AffordanceSize';
    iconsSizeEnums = javaMethod('values',iconsClassName);
    SIZE_32x32 = iconsSizeEnums(2);  % (1) = 16x16,  (2) = 32x32
    jObj = com.mathworks.widgets.BusyAffordance(SIZE_32x32, '');  % icon, label
catch
    % R2009b and earlier
    redColor   = java.awt.Color(1,0,0);
    blackColor = java.awt.Color(0,0,0);
    jObj = com.mathworks.widgets.BusyAffordance(redColor, blackColor);
end
jObj.setPaintsWhenStopped(true);  % default = false
jObj.useWhiteDots(false);         % default = false (true is good for dark backgrounds)
sld_pos = get(handles.figure_nanoxim,'Position');
javacomponent(jObj.getComponent, [fig_pos(3)-bck_pos(4) ...
    fig_pos(4)-bck_pos(4)...
    bck_pos(4) bck_pos(4)], handles.figure_nanoxim);
handles.busy_spinner=jObj;

% Set colororder on RGB mean plot
set(handles.axes_rgb_mean, 'ColorOrder', [1 0 0; 0 1 0; 0 0 1],...
    'NextPlot', 'replacechildren');
 beautifyAxis(handles.axes_rgb_mean);
% Update handles structure
guidata(hObject, handles);
% UIWAIT makes nanoxim wait for user response (see UIRESUME)
% uiwait(handles.figure_nanoxim);


% --- Outputs from this function are returned to the command line.
function varargout = nanoxim_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function slider_frame_ind_Callback(hObject, eventdata, handles)
% hObject    handle to slider_frame_ind (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% keyboard
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles = guidata(hObject);
vid_handle = getappdata(handles.figure_nanoxim,'vid_handle');

slider_val = round(get(handles.slider_frame_ind,'Value'));

rgb_vid = getappdata(handles.figure_nanoxim,'rgb_vid');

if isempty(rgb_vid)
    vid_handle.CurrentTime=(slider_val-1)/vid_handle.FrameRate;
    img=readFrame(vid_handle);
else
    img = rgb_vid(:,:,:,slider_val);
end
% Update image in axes and image in memory
setappdata(handles.figure_nanoxim, 'current_frame',img);
imshow(img,'Parent',handles.axes_img);
set(handles.text_frame_ind,'String',sprintf('%0.f',slider_val));

set(handles.text_rgb_means,'String',sprintf('R: %.f, G: %.f, B: %.f',...
    mean(mean(img(:,:,1))),mean(mean(img(:,:,2))),mean(mean(img(:,:,3)))));



% Update RGB plot
delete(getappdata(handles.figure_nanoxim,'frame_line_handle'));
hold(handles.axes_rgb_mean,'on');
frame_line_handle = plot([slider_val slider_val],ylim(handles.axes_rgb_mean),'k','Parent',handles.axes_rgb_mean);
hold(handles.axes_rgb_mean,'off'); 
setappdata(handles.figure_nanoxim,'frame_line_handle',frame_line_handle);



% --- Executes during object creation, after setting all properties.
function slider_frame_ind_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_frame_ind (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in pushbutton_load_video.
function pushbutton_load_video_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_load_video (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
nanoxim_ResetGUI(handles);

browse_path = getappdata(handles.figure_nanoxim,'browse_path');

% Get list of movies
mv_list = get(handles.listbox_mv_names,'String');

current_mv_path = [browse_path '/' mv_list{get(handles.listbox_mv_names,'Value')}];
setappdata(handles.figure_nanoxim, 'current_mv_path',current_mv_path);
setappdata(handles.figure_nanoxim, 'current_mv_name',mv_list{get(handles.listbox_mv_names,'Value')});

handles.busy_spinner.start;
[rgb_vid, rgb_mean, vid_handle] = load_video(current_mv_path);
handles.busy_spinner.stop;

% 
% 
% % read video
% vid_handle = VideoReader(current_mv_path);
% num_frames = ceil(vid_handle.Duration * vid_handle.FrameRate);
% % keyboard
% rgb_vid = zeros(vid_handle.Height,vid_handle.Width,3,num_frames,'uint8');
% % keyboard
% rgb_mean = zeros(num_frames,3);
% 
% % keyboard
% handles.busy_spinner.start;
% tic
% hw = waitbar(0,'Loading Video...');
% for t=1:num_frames
%     rgb_vid(:,:,:,t)=readFrame(vid_handle);
%     rgb_mean(t,1:3) = squeeze(mean(mean(rgb_vid(:,:,:,t),2),1)); 
%     waitbar(t/num_frames,hw);
% end
% close(hw);
% toc
% handles.busy_spinner.stop;

% Store video data
setappdata(handles.figure_nanoxim,'rgb_vid',...
    rgb_vid);
setappdata(handles.figure_nanoxim,'rgb_mean',...
    rgb_mean);
setappdata(handles.figure_nanoxim,'vid_dim',...
    size(rgb_vid));
setappdata(handles.figure_nanoxim,'vid_handle',vid_handle);

% Show First Image
% img = readFrame(vid_handle);
imshow(rgb_vid(:,:,:,1), 'Parent', handles.axes_img);
setappdata(handles.figure_nanoxim, 'current_frame',rgb_vid(:,:,:,1));
set(handles.text_img,'String', sprintf('Input: %.fx%.f',vid_handle.Height,vid_handle.Width)); 

%Plot RGB means
set(handles.axes_rgb_mean, 'ColorOrder', [1 0 0; 0 1 0; 0 0 1],...
    'NextPlot', 'replacechildren');
 beautifyAxis(handles.axes_rgb_mean);
plot(rgb_mean,'Parent',handles.axes_rgb_mean);
hold(handles.axes_rgb_mean,'on'); 
frame_line_handle = plot([1 1],ylim(handles.axes_rgb_mean),'k','Parent',handles.axes_rgb_mean); 
hold(handles.axes_rgb_mean,'off'); 
setappdata(handles.figure_nanoxim,'frame_line_handle',frame_line_handle);

% Load ROI from disk if it exists and port it through [Add ROI] button
% if ~isempty(dir([current_mv_path '.mat']))
%     st=load([current_mv_path '.mat']);
%     pushbutton_add_roi_Callback(handles.pushbutton_add_roi, st, handles);
%     setappdata(handles.figure_nanoxim,'vert_roi_ratiom',st.vert_roi_ratiom);
%     setappdata(handles.figure_nanoxim,'bw_roi_ratiom',st.bw_roi_ratiom);
% end

% Initialize sliders to correc tange
gui_UpdateSliderMax(handles,vid_handle.Duration * vid_handle.FrameRate)

% --- Executes on selection change in listbox_mv_names.
function listbox_mv_names_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_mv_names (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_mv_names contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_mv_names


% --- Executes during object creation, after setting all properties.
function listbox_mv_names_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_mv_names (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_browse.
function pushbutton_browse_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_browse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
nanoxim_ResetGUI(handles);

browse_path = pwd;
% If previous browse path is saved to disk, load and use that so user
% doesn't have to browse from active directory
temp_data_path = getappdata(0, 'temp_data_path');
if ~isempty(dir([temp_data_path '/nanoxim_gui.mat']))
    st = load([temp_data_path '/nanoxim_gui.mat']);
    if isfield(st,'browse_path')
        browse_path = st.browse_path;
    end
else; st=struct();
end
% keyboard

browse_path = uigetdir(browse_path,'Select Movie Folder');
if browse_path==0; return; end

% Save path to memory and file system
setappdata(handles.figure_nanoxim,'browse_path',browse_path);
st.browse_path = browse_path;
save([temp_data_path '/nanoxim_gui.mat'],'-struct','st');


% Get list of movies
mv_list = dir([browse_path '/*.*']);
mv_names = {mv_list(:).name};
bv = cellfun(@(x) ~isempty(regexpi(x,'(\.mov$)|(\.avi$)|(\.mp4$)|(\.m4v$)','once')),mv_names);
set(handles.listbox_mv_names,'String',mv_names(bv)');
% keyboard
% keyboard


% --- Executes on button press in pushbutton_calculate.
function pushbutton_calculate_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_calculate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dprintf('Calculating Ratiometric Image');
setappdata(0,'calculating_flag',1);
cleanup = onCleanup(@() setappdata(0,'calculating_flag',0));

% keyboard
% Channel index for top portion of ratio
chan_str = 'RGB';
numerator_chan_ind = regexp(chan_str,get(get(handles.uibuttongroup_top,...
    'SelectedObject'),'String'),'once');
% Channel index for bottom portion of ratio
denominator_chan_ind = regexp(chan_str,get(get(handles.uibuttongroup_bot,...
    'SelectedObject'),'String'),'once');




% Handle to load video frames
vid_obj = getappdata(handles.figure_nanoxim,'rgb_vid');
if isempty(vid_obj)
    vid_obj = getappdata(handles.figure_nanoxim,'vid_handle');
end
% Degree of blurring for bck and for images
blur_rad_pix = str2double(get(handles.edit_blur_rad,'String'));
% Thresholds for min signal above background for each channel
rgb_thresh = [str2double(get(handles.edit_red_threshold,'String')) 0 ...
    str2double(get(handles.edit_blue_threshold,'String'))];
% keyboard

% Start busy spinner (calculations takes a while)
handles.busy_spinner.start;
[bck_img, for_img]=nanoxim_load_for_and_back_images(handles);

% Zero background subtraction if specified by user
if ~get(handles.ratiom_subtractbackground_checkbox,'Value')
    bck_img = zeros(size(for_img),class(for_img));
end

% Get displacement coordinates
xy_shift = [str2double(get(handles.x_shift_edit, 'String')) ...
    str2double(get(handles.y_shift_edit, 'String'))];

% Calculate ratiometric image
[ratio_img, bw_pix_pass, pix_vals_st] = nanoxim_CalculateRatiomImage(bck_img,for_img, ...
    rgb_thresh, numerator_chan_ind,denominator_chan_ind,blur_rad_pix,xy_shift);
setappdata(handles.figure_nanoxim,'ratio_img',ratio_img);
setappdata(handles.figure_nanoxim,'bw_pix_pass',bw_pix_pass);
setappdata(handles.figure_nanoxim,'pix_vals_st',pix_vals_st);


% Stop Busy Spinner
handles.busy_spinner.stop;

% keyboard

% Update GUI
gui_UpdateRatioSlider(handles);
drawnow
clear cleanup
% setappdata(0,'calculating_flag',0);
gui_UpdateRatiomImage(handles.axes_ratiom,handles);






% --- Executes on slider movement
function slider_ratiom_range_Callback(hObject, eventdata, handles)
% hObject    handle to slider_ratiom_range (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider_ratiom_range_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_ratiom_range (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in pushbutton_add_roi.
function pushbutton_add_roi_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_add_roi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% keyboard
if strcmp(get(hObject,'String'),'Add ROI')
    poly_ratiom_for_roi = impoly(handles.axes_ratiom);
    try
    setappdata(handles.figure_nanoxim,'vert_roi_ratiom',...
        poly_ratiom_for_roi.getPosition);
    catch ME
        return;
    end
    % expects ratiom image here
    bw_roi_ratiom = imresize(poly_ratiom_for_roi.createMask(),...
        size(getappdata(handles.figure_nanoxim, 'ratio_img')));
    setappdata(handles.figure_nanoxim,'bw_roi_ratiom',...
        bw_roi_ratiom);
    delete(poly_ratiom_for_roi);
else % Delete ROI
    handle_ratiom_for_roi = getappdata(handles.figure_nanoxim, 'handle_ratiom_for_roi');
    try delete(handle_ratiom_for_roi); catch; fprintf('Handle DNE\n'); end
    setappdata(handles.figure_nanoxim,'vert_roi_ratiom', []);
     setappdata(handles.figure_nanoxim,'bw_roi_ratiom', []);
    setappdata(handles.figure_nanoxim, 'handle_ratiom_for_roi',[]);
    set(handles.pushbutton_add_roi,'String','Add ROI');
    set(handles.pushbutton_show_roi,'String','Edit ROI');
end

gui_UpdateRatiomImage(handles.axes_ratiom, handles);


% --- Executes on button press in pushbutton_show_roi.
function pushbutton_show_roi_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_show_roi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
vert_roi_ratiom = getappdata(handles.figure_nanoxim,'vert_roi_ratiom');

if isempty(vert_roi_ratiom); return; end

if strcmp(get(hObject,'String'),'Edit ROI')
    handle_ratiom_for_roi= impoly(handles.axes_ratiom, vert_roi_ratiom);
    setappdata(handles.figure_nanoxim, 'handle_ratiom_for_roi',handle_ratiom_for_roi);
    set(handles.pushbutton_add_roi,'String','Delete ROI');
    set(handles.pushbutton_show_roi,'String','Hide ROI');
else % Hide ROI
    
    handle_ratiom_for_roi = getappdata(handles.figure_nanoxim, 'handle_ratiom_for_roi');
%     keyboard
      
    try 
        % Store new roi
        setappdata(handles.figure_nanoxim,'vert_roi_ratiom',...
            handle_ratiom_for_roi.getPosition());
        setappdata(handles.figure_nanoxim,'bw_roi_ratiom',...
            handle_ratiom_for_roi.createMask());
       % delete polygon
        delete(handle_ratiom_for_roi); 
    catch; fprintf('Handle DNE\n'); 
    end
    set(handles.pushbutton_add_roi,'String','Add ROI');
    set(handles.pushbutton_show_roi,'String','Edit ROI');
    gui_UpdateRatiomImage(handles.axes_ratiom,handles);
end



% --- Executes on button press in pushbutton_save_ratiom.
function pushbutton_save_ratiom_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_save_ratiom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

current_mv_name = getappdata(handles.figure_nanoxim, 'current_mv_name');
browse_path = getappdata(handles.figure_nanoxim, 'browse_path');
% keyboard
% Prompt user for mat file and load
[FileName,PathName] = uiputfile(fullfile([browse_path '\*.png']),'Load MAT metadata from disk',...
    [current_mv_name '.png']);
if FileName==0; return; end

% Get Image Name
h=figure;
ha = gca;
gui_UpdateRatiomImage(ha, handles);
saveas(ha,[PathName FileName]);
close(h);





function edit_blur_rad_Callback(hObject, eventdata, handles)
% hObject    handle to edit_blur_rad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_blur_rad as text
%        str2double(get(hObject,'String')) returns contents of edit_blur_rad as a double


% --- Executes during object creation, after setting all properties.
function edit_blur_rad_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_blur_rad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_blue_threshold_Callback(hObject, eventdata, handles)
% hObject    handle to edit_blue_threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_blue_threshold as text
%        str2double(get(hObject,'String')) returns contents of edit_blue_threshold as a double


% --- Executes during object creation, after setting all properties.
function edit_blue_threshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_blue_threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_red_threshold_Callback(hObject, eventdata, handles)
% hObject    handle to edit_red_threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_red_threshold as text
%        str2double(get(hObject,'String')) returns contents of edit_red_threshold as a double


% --- Executes during object creation, after setting all properties.
function edit_red_threshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_red_threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function menu_file_Callback(hObject, eventdata, handles)
% hObject    handle to menu_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu2_export_frame_Callback(hObject, eventdata, handles)
% hObject    handle to menu2_export_frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get current Frame and path metadata
img = getappdata(handles.figure_nanoxim, 'current_frame');
current_mv_name = getappdata(handles.figure_nanoxim,'current_mv_name');
browse_path = getappdata(handles.figure_nanoxim,'browse_path');
proj_path = getappdata(0,'proj_path');
% Get current frame index and include as default filename
ind_str = sprintf('%.f',get(handles.slider_frame_ind,'Value'));
cd(browse_path);
[FileName,PathName,FilterIndex] = uiputfile('*.tif','Filename for Exported Frame',...
    [current_mv_name '_frame_' ind_str '.tif']);
cd(proj_path); 
if FileName==0; return; end
% Export frame
imwrite(img, [PathName FileName],'tif');



% --------------------------------------------------------------------
function menu2_export_frame_ranges_Callback(hObject, eventdata, handles)
% hObject    handle to menu2_export_frame_ranges (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
vid_handle = getappdata(handles.figure_nanoxim, 'vid_handle');
% Get background range
bck_frame_range = [handles.rslider_bck.getLowValue() handles.rslider_bck.HighValue()];
for_frame_range = [handles.rslider_for.getLowValue() handles.rslider_for.HighValue()];
blur_rad_pix = str2double(get(handles.edit_blur_rad,'String'));
% Get Background and Foreground Images
bck_img = im2uint8(nanoxim_GetFrameRangeImg(vid_handle, bck_frame_range, blur_rad_pix));
for_img = im2uint8(nanoxim_GetFrameRangeImg(vid_handle, for_frame_range, blur_rad_pix));
% Get path metadata
browse_path = getappdata(handles.figure_nanoxim,'browse_path');
current_mv_name = getappdata(handles.figure_nanoxim,'current_mv_name');

imwrite(bck_img,[browse_path '/' current_mv_name '_bck_' ...
    sprintf('%.f', bck_frame_range(1)) '_' sprintf('%.f', bck_frame_range(2)) '.tif'],'tif');
imwrite(for_img,[browse_path '/' current_mv_name '_for_' ...
    sprintf('%.f', for_frame_range(1)) '_' sprintf('%.f', for_frame_range(2)) '.tif'],'tif');

dprintf('Exporting background and foreground images to movie folder');
% keyboard



% --- Executes on button press in pushbutton_bck_img_path.
function pushbutton_bck_img_path_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_bck_img_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Get path metadata
bck_img_path = getappdata(handles.figure_nanoxim, 'bck_img_path'); 
if ~isempty(bck_img_path); bck_img_dir_path = fileparts(bck_img_path);
else bck_img_dir_path=[];
end

[FileName,PathName,FilterIndex] = uigetfile([bck_img_dir_path '/*.*'],'Select BCK Image/Video');
if FileName==0; return; end
bck_img_path = [PathName FileName];
set(handles.edit_bck_img_path,'string',bck_img_path);
setappdata(handles.figure_nanoxim, 'bck_img_path',bck_img_path); 


% keyboard

% --- Executes on button press in pushbutton_for_img_path.
function pushbutton_for_img_path_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_for_img_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% browse_path = getappdata(handles.figure_nanoxim,'browse_path');

for_img_path = getappdata(handles.figure_nanoxim, 'for_img_path'); 
if ~isempty(for_img_path); for_img_dir_path = fileparts(for_img_path);
else for_img_dir_path=[];
end

[FileName,PathName,FilterIndex] = uigetfile([for_img_dir_path '/*.*'],'Select FOR Image/Video');
if FileName==0; return; end
for_img_path = [PathName FileName];
set(handles.edit_for_img_path,'string',for_img_path);
setappdata(handles.figure_nanoxim, 'for_img_path',for_img_path); 


function edit_for_img_path_Callback(hObject, eventdata, handles)
% hObject    handle to edit_for_img_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_for_img_path as text
%        str2double(get(hObject,'String')) returns contents of edit_for_img_path as a double


% --- Executes during object creation, after setting all properties.
function edit_for_img_path_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_for_img_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_bck_low_Callback(hObject, eventdata, handles)
% hObject    handle to edit_bck_low (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_bck_low as text
%        str2double(get(hObject,'String')) returns contents of edit_bck_low as a double


% --- Executes during object creation, after setting all properties.
function edit_bck_low_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_bck_low (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_bck_high_Callback(hObject, eventdata, handles)
% hObject    handle to edit_bck_high (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_bck_high as text
%        str2double(get(hObject,'String')) returns contents of edit_bck_high as a double


% --- Executes during object creation, after setting all properties.
function edit_bck_high_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_bck_high (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_for_low_Callback(hObject, eventdata, handles)
% hObject    handle to edit_for_low (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_for_low as text
%        str2double(get(hObject,'String')) returns contents of edit_for_low as a double


% --- Executes during object creation, after setting all properties.
function edit_for_low_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_for_low (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_for_high_Callback(hObject, eventdata, handles)
% hObject    handle to edit_for_high (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_for_high as text
%        str2double(get(hObject,'String')) returns contents of edit_for_high as a double


% --- Executes during object creation, after setting all properties.
function edit_for_high_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_for_high (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_ratiom_max_Callback(hObject, eventdata, handles)
% hObject    handle to edit_ratiom_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

val = str2double(get(hObject,'String'));
handles.rslider_ratiom.setMaximum(val);

% Hints: get(hObject,'String') returns contents of edit_ratiom_max as text
%        str2double(get(hObject,'String')) returns contents of edit_ratiom_max as a double


% --- Executes during object creation, after setting all properties.
function edit_ratiom_max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_ratiom_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_ratiom_high_Callback(hObject, eventdata, handles)
% hObject    handle to edit_ratiom_high (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_ratiom_high as text
%        str2double(get(hObject,'String')) returns contents of edit_ratiom_high as a double


% --- Executes during object creation, after setting all properties.
function edit_ratiom_high_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_ratiom_high (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_ratiom_low_Callback(hObject, eventdata, handles)
% hObject    handle to edit_ratiom_low (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_ratiom_low as text
%        str2double(get(hObject,'String')) returns contents of edit_ratiom_low as a double


% --- Executes during object creation, after setting all properties.
function edit_ratiom_low_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_ratiom_low (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function pushbutton_load_video_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton_load_video (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



% --- Executes on button press in pushbutton_save_metadata.
function pushbutton_save_metadata_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_save_metadata (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get roi image and vert
st.vert_roi_ratiom = getappdata(handles.figure_nanoxim,'vert_roi_ratiom');
st.bw_roi_ratiom = getappdata(handles.figure_nanoxim,'bw_roi_ratiom');

% Get movie name
st.current_mv_name = getappdata(handles.figure_nanoxim,'current_mv_name');
st.current_mv_path = getappdata(handles.figure_nanoxim,'current_mv_path');
st.browse_path = getappdata(handles.figure_nanoxim,'browse_path');

% Get movie image size
st.vid_dim = getappdata(handles.figure_nanoxim,'vid_dim');

% Get background movie range
st.edit_bck_low = str2double(get(handles.edit_bck_low,'String'));
st.edit_bck_high = str2double(get(handles.edit_bck_high,'String'));

% Get forground movie range
st.edit_for_low = str2double(get(handles.edit_for_low,'String'));
st.edit_for_high = str2double(get(handles.edit_for_high,'String'));

% Export to disk prompt user with standard name
mat_path = uiputfile([st.browse_path '/*.mat'],'Save metadata MAT file to disk',...
    [st.current_mv_name '.mat']);
save(mat_path, '-struct', 'st');



% --- Executes on button press in pushbutton_load_metadata.
function pushbutton_load_metadata_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_load_metadata (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
browse_path=getappdata(handles.figure_nanoxim,'browse_path');
current_mv_name=getappdata(handles.figure_nanoxim,'current_mv_name');

% Prompt user for mat file and load
mat_path = uigetfile([browse_path '/*.mat'],'Load MAT metadata from disk',...
    [current_mv_name '.mat']);
st = load(mat_path);

% set roi image and vert
setappdata(handles.figure_nanoxim,'vert_roi_ratiom',st.vert_roi_ratiom);
setappdata(handles.figure_nanoxim,'bw_roi_ratiom',st.bw_roi_ratiom);

% Get movie name
% setappdata(handles.figure_nanoxim,'current_mv_name',current_mv_name);
setappdata(handles.figure_nanoxim,'current_mv_path',[browse_path '/' current_mv_name]);
% setappdata(handles.figure_nanoxim,'browse_path',browse_path);

% Check movie image size
vid_dim = getappdata(handles.figure_nanoxim,'vid_dim');
st.vid_dim = getappdata(handles.figure_nanoxim,'vid_dim');
assert(all(vid_dim==st.vid_dim),'Stored pixel dim differs from actual pixel dim');


% st.edit_bck_low = str2double(get(handles.edit_bck_low,'String'));
% st.edit_bck_high = str2double(get(handles.edit_bck_low,'String'));

% Get forground movie range
% st.edit_for_low = str2double(get(handles.edit_for_low,'String'));
% st.edit_for_high = str2double(get(handles.edit_for_low,'String'));

% set background movie range
% keyboard
% handles.rslider_bck.setLowValue(st.edit_bck_low);
% set(handles.edit_bck_low,'String', num2str(st.edit_bck_low));
% handles.rslider_bck.setHighValue(st.edit_bck_high);
% set(handles.edit_bck_high,'String', num2str(st.edit_bck_high));
% % handles.rslider_bck.updateTextValues();
% 
% handles.rslider_for.setLowValue(st.edit_for_low);
% set(handles.edit_for_low,'String', num2str(st.edit_for_low));
% handles.rslider_for.setHighValue(st.edit_for_high);
% set(handles.edit_for_high,'String', num2str(st.edit_for_high));
% handles.rslider_for.updateTextValues();

% Run calculate callback
pushbutton_calculate_Callback(handles.pushbutton_calculate, eventdata, handles);




% --- Executes on button press in ratiom_subtractbackground_checkbox.
function ratiom_subtractbackground_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to ratiom_subtractbackground_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ratiom_subtractbackground_checkbox



function red_output_Callback(hObject, eventdata, handles)
% hObject    handle to numerator_output (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of numerator_output as text
%        str2double(get(hObject,'String')) returns contents of numerator_output as a double


% --- Executes during object creation, after setting all properties.
function red_output_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numerator_output (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function numerator_output_Callback(hObject, eventdata, handles)
% hObject    handle to numerator_output (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of numerator_output as text
%        str2double(get(hObject,'String')) returns contents of numerator_output as a double


% --- Executes during object creation, after setting all properties.
function numerator_output_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numerator_output (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function denominator_output_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numerator_output (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in align_togglebutton.
function align_togglebutton_Callback(hObject, eventdata, handles)
% hObject    handle to align_togglebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Display alignment image
update_alignment_image(handles)




function update_alignment_image(handles)


% Get displacement coordinates
x = str2double(get(handles.x_shift_edit, 'String'));
y = str2double(get(handles.y_shift_edit, 'String'));

% Displace second image and padd
bck_img = getappdata(handles.figure_nanoxim,'bck_img');
for_img = getappdata(handles.figure_nanoxim,'for_img');

if (isempty(bck_img) || isempty(for_img))
    [bck_img, for_img]=nanoxim_load_for_and_back_images(handles);
    setappdata(handles.figure_nanoxim,'bck_img', bck_img);
    setappdata(handles.figure_nanoxim,'for_img', for_img);
end

% Render result
shifted_for_img = imtranslate(for_img,[x, y],'OutputView','same','FillValues',NaN);
setappdata(handles.figure_nanoxim, 'shifted_for_img', shifted_for_img);


blended_img = imfuse(bck_img,shifted_for_img,'falsecolor','Scaling','none');
 setappdata(handles.figure_nanoxim, 'blended_img', blended_img);
 
imshow(blended_img,'Parent', handles.axes_img);

% keyboard




function x_shift_edit_Callback(hObject, eventdata, handles)
% hObject    handle to x_shift_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of x_shift_edit as text
%        str2double(get(hObject,'String')) returns contents of x_shift_edit as a double
update_alignment_image(handles);

% --- Executes during object creation, after setting all properties.
function x_shift_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to x_shift_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function y_shift_edit_Callback(hObject, eventdata, handles)
% hObject    handle to y_shift_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of y_shift_edit as text
%        str2double(get(hObject,'String')) returns contents of y_shift_edit as a double
update_alignment_image(handles);

% --- Executes during object creation, after setting all properties.
function y_shift_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to y_shift_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on key press with focus on figure_nanoxim or any of its controls.
function figure_nanoxim_WindowKeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure_nanoxim (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

is_align_mode = get(handles.align_togglebutton,'Value');
shift_delta = str2double(get(handles.shift_delta_edit,'String'));

switch eventdata.Key
    case 'rightarrow'
        if is_align_mode
            set(handles.x_shift_edit,'String',sprintf('%d', str2double(get(handles.x_shift_edit,'String'))+shift_delta))
        end
    case 'leftarrow'
        if is_align_mode
            set(handles.x_shift_edit,'String',sprintf('%d', str2double(get(handles.x_shift_edit,'String'))-shift_delta))
        end
    case 'uparrow'
        if is_align_mode
            set(handles.y_shift_edit,'String',sprintf('%d', str2double(get(handles.y_shift_edit,'String'))+shift_delta))
        end
    case 'downarrow'   
        if is_align_mode
            set(handles.y_shift_edit,'String',sprintf('%d', str2double(get(handles.y_shift_edit,'String'))-shift_delta))
        end
end


 if is_align_mode; update_alignment_image(handles); end



function shift_delta_edit_Callback(hObject, eventdata, handles)
% hObject    handle to shift_delta_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of shift_delta_edit as text
%        str2double(get(hObject,'String')) returns contents of shift_delta_edit as a double


% --- Executes during object creation, after setting all properties.
function shift_delta_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to shift_delta_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
