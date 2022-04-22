/*
 * =====================================================================================
 *
 *       Filename:  specrgb.h
 *
 *    Description:  Compute the RGB triplet from an emission/absorption spectrum 
 *
 *        Version:  1.0
 *        Created:  12/18/2014 02:09:16 PM
 *       Revision:  none
 *       Compiler:  gcc
 *
 *         Author:  Thibaut Very, PhD (), very@mpi-muelheim.mpg.de
 *   Organization:  Max Planck Institute for Coal Research, Muelheim (Germany)
 *
 * =====================================================================================
 */

typedef struct data
{
   double* wl;
   double* P;
   int size;
}data;

/* Define boolean */
typedef int bool; 
#define true 1
#define false 0

/*
 * \brief Free memory from a data structure
 */
void dealloc(data *d);
/*
 * \brief Convert rgb to hexadecimal code
 */
void rgb_to_hexa(double r, double g, double b, char* hexa);

/*
 * \brief Print spec to a file
 * \param outname: the filename
 */
void print_spec(const char *outname);

/*
 * \brief Print help for specrgb
 */
void help();

/*
 * \brief implementation for reading data in file
 */
void read(const char* filename, data* data,bool NX);
/*
 * \brief Read the input file in case of emission spectra
 */
void read_emission(const char* filename,bool NX);

/*
 * \brief Read the input file in case of absorption spectra
 */
void read_absorption(const char* filename, const char* solar_filename,  bool NX);

/*
 * \brief Get the intensity at given wavelength
 * \param wavelength: the wavelength in meters
 * \return the intensity 
 */
double spectrum(double wavelength);

/*
 * \brief In case the requested wavelength is not present in the array, compute an interpolation of
 *        the intensity.
 * \param wavelength: The incriminated wavelength
 * \param scheme: which scheme to use
 * \return the interpolated intensity
 */
double interpolate(double *d, double wavelength, char scheme);

/*
 * \brief Find the available upper and lower bounds of wavelength
 * \param wl: the wavelength for which the upper bounds are to be found
 * \param values (out): the array containing the results
 * \param d: the data struct where to find the values
 * \return the lower and upper bounds and their intensities
 */
void bounds(double wl, double *values,data *d);

/*
 * \brief Compute a linear interpolation
 * \param wl1: the wavelength available just below wl
 * \param wl2: the wavelength available just above wl
 * \param wl: the wavelength at which the interpoation is done
 * \param P1: the intensity at wl1
 * \param P2: the intensity at wl2
 * \return the interpolated intensity
 */
double linear_interpolation(double wl1, double wl2, double wl, double P1, double P2);
