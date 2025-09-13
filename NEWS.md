# cnmap 0.1.1

* Since tibble is no longer imported by ggplot2, to ensure the normal operation of the plotting examples in this package, the package of tibble has been added to the suggested packages.

* Change Maintainer Email.

# adw 0.4.0

* add functions of points2grid, points2grid\_vector, points2grid\_sf, points2grid\_sv for gridding
* add functions of awa for area weighted average
* function of adw\_terra was changed to adw\_sv
* some examples were modified.



# adw 0.3.1

* The help files for funchtions 'adw\_vector', 'adw\_sf' and 'adw\_terra' are changed, and some unnecessary content has been removed.

# adw 0.3.0

* The adw interpolation function was rewritten, and the parameter 'extent' can be a class of 'sf', 'SpatVector', or 'vector'. The calculation speed will be several times faster than before.
* delete parameter of 'maskON'. The unit of parameter 'cdd' was converted from meter to kilometer since the version 0.3.1.

# adw 0.2.1

* fix the BugReports website.
* add README file

# adw 0.2.0

* all of the functions of sf package were replaced by the functions of terra package. The calculation speed will be several times faster than before.
* add parameters of extent, nmin, nmax, and maskON
* parameter gridSize were changed to gridsize
* delete parameters of xmin, xmax, ymin, ymax
* delete adw\_land function. The new version of the function 'adw' adds a parameter 'maskON' to implement the function of the mask.
