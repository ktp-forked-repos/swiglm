% Load swiglm library from /usr/lib/swi-prolog/lib/<arch>/
:- use_foreign_library(foreign(swiglm)).


% Combine a list of transformation into a single one
% Multiplies transformation from the input list from left to right
% If the transformation is in matrix format multiply directly
% If the transformation is in [translation_vector, quaternion] format, convert it to mat4 format

% transform(+InputList, -OutputList)

	% Example:

	% InputList = [['M',[[1,2,3,4],[5,6,7,8],[9,10,12,12],[13,14,15,16]]],
	%			   ['Q',[[1,1,1],[0,0,0,1]]],
	%			   ['Q',[[2,2,2],[1,0,0,0]]],
	%			   ['M',[[9,10,12,12],[1,2,3,4],[5,6,7,8],[13,14,15,16]]]]

	% OutputList = ['M', MatrixFormat]

transform(InputList, OutputList) :- transform(InputList, OutputList, ['M',[[1.0,0.0,0.0,0.0],
																	   		[0.0,1.0,0.0,0.0],
																	   		[0.0,0.0,1.0,0.0],
																	   		[0.0,0.0,0.0,1.0]]]).
transform([], Acc, Acc).
transform([['M',Matrix]|T], OutputList, ['M',Acc]) :- mul_matrix(Acc, Matrix, Multiplied), 
													   transform(T, OutputList, ['M',Multiplied]).

transform([['Q',[Vec,Quat]]|T], OutputList, ['M',Acc]) :- convert_to_mat(Vec,Quat,Converted),
														   mul_matrix(Acc, Converted, Multiplied),
														   transform(T,OutputList,['M',Multiplied]).

% Translates a point from one frame of reference to a new frame of reference
% Accepts both formats, but in case of [translation_vector, quaternion] format, convert it to mat4 format

% tf_point(+Point, +Transformation, -NewPoint)

	% Example:

	% Point = [0,0,0]
	% Transformation = ['Q', [[1,1,1],[0,0,0,1]]]
	% NewPoint = [1,1,1]

tf_point(Point, ['M',Transformation], NewPoint) :- transform_point(Point, Transformation, NewPoint).
tf_point(Point, ['Q',[Vec,Quat]], NewPoint) :- convert_to_mat(Vec,Quat,Converted),
											   transform_point(Point,Converted,NewPoint).