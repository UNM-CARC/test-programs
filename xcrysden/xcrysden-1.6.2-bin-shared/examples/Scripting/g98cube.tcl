# ------------------------------------------------------------------------
#****** ScriptingExamples/g98cube.tcl ***
#
# NAME
# g98cube.tcl -- a simple example for display of MO from Gaussian cube file
#
# USAGE
# xcrysden --script g98cube.tcl
#
# COPYRIGHT
# Anton Kokalj (C) 2003
#
# PURPOSE

# This is a scripting example that shows how to display a particular
# molecular orbital (MO) from Gaussian cube file. In this example the
# 11th MO is displayed as isosurface + contours.

#
# AUTHOR
# Anton Kokalj
#
# CREATION DATE
# Fri Apr  4 15:21:53 CEST 2003
# 
# SOURCE


# ------------------------------------------------------------------------
# Load the structure. The arguments to scripting::filter::g98cube are
# cube-file and the MO index, i.e., scripting::filter::g98cube
# cube_file mo_index
# ------------------------------------------------------------------------

scripting::filter::g98cube $env(XCRYSDEN_TOPDIR)/examples/GAUSSIAN_files/N2O_homo+lumo.cube.gz 11

# ------------------------------------------------------------------------
# display the structure in appropriate display-mode
# ------------------------------------------------------------------------

#-----
# uncomment this is for Lighting-On modes:
#-----
scripting::lighting On

# choose a 3D-display mode

#scripting::displayMode3D Stick
scripting::displayMode3D Pipe&Ball
#scripting::displayMode3D BallStick
#scripting::displayMode3D SpaceFill
#----



# ------------------------------------------------------------------------
# zoom and rotate the structure 
# ------------------------------------------------------------------------

scripting::zoom -0.35
scripting::rotate x -90 


# ------------------------------------------------------------------------
# load the 3D scalar field
# ------------------------------------------------------------------------

scripting::scalarField3D::load

# ------------------------------------------------------------------------
# hide the isosurface control window
# ------------------------------------------------------------------------

IsoControl_Hide .iso

#
# description of scripting::scalarField3D::configure options:
#
# ------------------------------------------------------------------------
#   OPTION::                 ALLOWED-VALUES + Description          STATUS
# ------------------------------------------------------------------------
#   -isosurface              0|1                                 REQUIRED
#                            0 = do not render isosurface
#                            1 = render isosurface
#
#   -interpolation_degree    integer                             OPTIONAL
#                            degree of scalar-field interpolation
#
#   -isolevel                real                                REQUIRED
#                            the isovalue of isosurface
#
#   -plusminus               0|1
#                            0 = display only the isosurface of isovalue 
#                                specified by -isolevel
#                            1 = display the two isosurfaces of +-isovalue
#
#   -revertsides             pos|neg|{pos neg}
#                            pos = revert the front- and back-side of isovalue 
#                                  isosurface
#                            neg = revert the front- and back-side of -isovalue
#                                  isosurface
#   -revertnormals           pos|neg|{pos neg}
#                            pos = revert the normals of isovalue isosurface
#                            neg = revert the normals of -isovalue isosurface
#
#   -expand                  none|whole|specify
#                            none = do not expand the isosurface along the 
#                                   periodic directions
#                            whole = expand the isosurface over the
#                                    whole structure along the periodic 
#                                    directions
#                            specify = expand the isosurface along the
#                                      periodic directions as specified by 
#                                      -expand_X, -expand_Y, and -expand_Z 
#                                      factors
#
#   -expand_X	             positive-integer
#                            expand  isosurface n-times along the 1st
#                            periodic dimension
#
#
#   -expand_Y                positive-integer
#                            expand  isosurface n-times along the 2nd
#                            periodic dimension
#
#   -expand_Z                positive-integer
#                            expand  isosurface n-times along the 3rd
#                            periodic dimension
#
#   -basalplane              0|1|2
#                            show the ith basal plane (0=xy, 1=xz, 2=yz)
#                            as colorplane and/or isolines (as specified by
#                            -colorplane and -isoline options)
#
#   -colorbasis              MONOCHROME|RAINBOW|RGB|GEOGRAPHIC|BLUE-WHITE-RED
#                            the color basis for the colorplane
#
#   -scalefunction           LINEAR|LOG10|SQRT|3th-ROOT|EXP(x)|EXP(x^2)
#                            the scalefunctions for contour/colorplane plots
#
#   -expand2D                none|whole|specify
#                            none = do not expand the contour/colorplane plots
#                                   along the periodic directions
#                            whole = expand the contour/colorplane plots
#                                    over the whole structure along the 
#                                    periodic directions
#                            specify = expand the contour/colorplane plots
#                                    along the periodic directions as specified
#                                    by -expand2D_X, -expand2D_Y, and 
#                                    -expand2D_Z factors
#
#   -expand2D_X	             positive-integer
#                            expand  contour/colorplane n-times along the 1st
#                            periodic dimension
#
#
#   -expand2D_Y              positive-integer
#                            expand  contour/colorplane n-times along the 2nd
#                            periodic dimension
#
#   -expand2D_Z              positive-integer
#                            expand  contour/colorplane n-times along the 3rd
#                            periodic dimension
#
#   -colorplane              0|1
#                            do not display|display the colorplane
#
#   -isoline                 0|1
#                            do not display|display the isolines
#             
#   -colorplane_lighting     0|1
#                            0 = do not perform lighting for colorplane
#                            1 = perform lighting for colorplane
#
#   -cpl_transparency        0|1
#                            0 = render colorplane as non-transparent
#                            1 = render colorplane as transparent
#
#   -cpl_thermometer         0|1
#                            0 = do not make a legend (i.e. thermometer) for 
#                                colorplane colors
#                            1 = make a legend (i.e. thermometer) for 
#                                colorplane colors
#
#   -2Dlowvalue              real
#                            minimum rendered value of colorplane/isolines
#
#   -2Dhighvalue             real
#                            maximum rendered value of colorplane/isolines
#              
#   -2Dnisoline              positive-integer
#                            number of isoline
#
#   -anim_step               positive-integer
#                            animation step
#
#   -current_slide           positive-integer
#                            iD (i.e. sequential number) of colorplane
#
#   -isoline_color           monocolor|{property color}
#                            monocolor = all isolines have the same color
#                            {property color} = isolines are colorer according
#                            to color-basis
#
#   -isoline_width           positive-integer
#                            width (i.e. thickness) of isolines
#
#   -isoline_monocolor       #rgb
#                            color of the monolor-type isolines
#
# ------------------------------------------------------------------------
#
#
# Example:
#
# scripting::scalarField3D::configure \
#     -isosurface           1 \
#     -interpolation_degree 2 \
#     -isolevel             0.1 \
#     -plusminus            1 \
#     -revertsides          {pos neg} \
#     -revertnormal         {pos neg} \
#     -expand               specify \
#     -expand_X 	    1 \
#     -expand_Y             1 \
#     -expand_Z             1 \
#     -basalplane           0 \
#     -colorbasis           BLUE-WHITE-RED \
#     -scalefunction        LINEAR \
#     -expand2D             specify \
#     -expand2D_X 	    1 \
#     -expand2D_Y           1 \
#     -expand2D_Z           1 \
#     -colorplane           1 \
#     -isoline              1 \
#     -colorplane_lighting  0 \
#     -cpl_transparency     0 \
#     -cpl_thermometer      1 \
#     -2Dlowvalue           -0.1 \
#     -2Dhighvalue          +0.1 \
#     -2Dnisoline           11 \
#     -anim_step            1 \
#     -current_slide        30 \
#     -isoline_color        monocolor \
#     -isoline_width        3 \
#     -isoline_monocolor    \#000000
# 


# ------------------------------------------------------------------------
# configure, i.e., specify how to render the scalar field
# ------------------------------------------------------------------------
scripting::scalarField3D::configure \
    -isosurface           1 \
    -interpolation_degree 2 \
    -isolevel             0.1 \
    -plusminus            1 \
    -basalplane           2 \
    -colorbasis           BLUE-WHITE-RED \
    -scalefunction        LINEAR \
    -expand2D             specify \
    -expand2D_X 	  1 \
    -expand2D_Y           1 \
    -expand2D_Z           1 \
    -colorplane           1 \
    -isoline              1 \
    -colorplane_lighting  0 \
    -cpl_transparency     0 \
    -cpl_thermometer      1 \
    -2Dlowvalue           -0.1 \
    -2Dhighvalue          +0.1 \
    -2Dnisoline           11 \
    -anim_step            1 \
    -current_slide        19 \
    -isoline_color        monocolor \
    -isoline_width        3 \
    -isoline_monocolor    \#000000


# ------------------------------------------------------------------------
# render the 3D scalar field as requested by 
# scripting::scalarField3D::configure
# ------------------------------------------------------------------------

scripting::scalarField3D::render


# ------------------------------------------------------------------------
# now lets print to file what we have on the display window
# ------------------------------------------------------------------------

# this will query the filename:
scripting::printToFile mo-11.png; # here the colorplane legend is NOT printed 
exit
# # while this will print directly to print.png:
# scripting::printToFile print.png; # here the colorplane legend is printed 

# # while this will print directly to print.png:
# scripting::printToFile print.png windowdump; # here the colorplane legend is also printed

#****
# ------------------------------------------------------------------------
