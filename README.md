# STRCN-MicroExpressionRec
Spatiotemporal Recurrent Convolutional Networks for Recognizing Spontaneous Micro-Expressions

#### Descriptions
These codes are used for micro-expression recognition on individual datasets. The methods can be accessed by the paper "Spatiotemporal Recurrent Convolutional Networks for Recognizing Spontaneous Micro-Expressions, IEEE TMM2020", which includes the STRCN-A and STRCN-G.

#### Dependencies
The code was written in MATLAB R2018b, and tested on Windows 7 and 10. 
-  MATLAB's Computer Vision Toolbox
-  MatConvNet (Beta23)
-  Eulerian Video Magnification (2012):http://people.csail.mit.edu/mrub/vidmag/

#### Instructions
1.  The faces should be cropped by your own tools and all images are storaged with the format of casme2 way.
2.  The appearance connect and geometric connect needs to be performed before training the deep model. All the data needs to be prepared and storaged into the mat file.
