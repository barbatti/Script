/*
 * =====================================================================================
 *
 *       Filename:  specrgb.c
 *
 *    Description:  
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

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "specrgb.h"
#include "spec.h"

#define FILEERROR       2 /* Error while opening a file */
#define MEMORYERROR     3 /* Error while allocating memory */
#define WLERROR         3 /* Error while finding wavelength */
#define SCHEMEERROR     4 /* The interpolation scheme was not found */
#define NYI          1000 /* Not Yet Implemented */

#define LAMBDA_MIN 380.0
#define LAMBDA_MAX 780.0
/* Default allocation size to store the spectrum */
#define DEFAULT_SIZE 4000

/* the structures to hold the data */
data spec;
data solar;

void dealloc(data *d)
{
   free(d->wl);
   free(d->P);
   free(d);
}

void print_spec(const char *outname)
{
   int i;
   FILE *out;
   out = fopen(outname,"w");
   for (i=0;i<spec.size;i++)
   {
      fprintf (out,"%13.2f %13.6e\n",spec.wl[i],spec.P[i]);
   }
   fclose(out);
}

static int SIZE = DEFAULT_SIZE;
void read_absorption(const char* filename, const char* solar_filename, bool NX)
{
   int i;
   double b[4];
   double lmax=0.;
   double S;
   double Slmax=-1.;
   double A;
   double Almax;
   read(filename,&spec,NX);
   read(solar_filename,&solar,false);
   /* Compute the emission spectra by scaling the absorption spectra and substracting from solar
    * intensity */
   /* Find Maximum Absorption */
   for (i=0;i<spec.size;i++)
   {
     /*if (Slmax < solar.P[i]) 
      {
         Slmax=solar.P[i];
         lmax=solar.wl[i];
      } 
      */
      if (Almax < spec.P[i]) 
      {
         Almax=spec.P[i];
         lmax=spec.wl[i];
      }
   }
  /* bounds(lmax,b,&spec);
   Almax = interpolate(b,lmax,'l'); 
   */
   bounds(lmax,b,&solar);
   Slmax = interpolate(b,lmax,'l'); 
   for( i=0;i<spec.size;i++)
   {
      bounds(spec.wl[i],b,&solar);
      S = interpolate(b,spec.wl[i],'l');
      bounds(spec.wl[i],b,&spec);
      A = interpolate(b,spec.wl[i],'l');
      spec.P[i] = S - A/Almax*Slmax;
      /*printf("%13.6f %13.6f %13.6f %13.6f %13.6f\n",spec.wl[i],Almax,Slmax,A,S);*/
   }

}

void read_emission(const char* filename, bool NX)
{
   read(filename,&spec,NX);
}

void read(const char* filename, data* data, bool NX)
{
   int i = 0;
   FILE *inp;
   char line[200];
   char copy[200];

   /* Energy in eV (NX) */
   double ev = 0.;
   /* Wavelength in nm */
   double nm = 0.;
   /* Intensity */
   double Pi = 0.;
   /* Error (NX) */
   double error=0.;
   int ncol;

   if (data->wl == NULL || data->P == NULL) 
   {
      fprintf(stderr,"Not able to allocate memory\n");
      exit(MEMORYERROR);
   }

   inp = fopen(filename,"r");
   if (inp == NULL)
   {
      fprintf(stderr,"Problem while opening file %s\n",filename);
      exit(FILEERROR);
   }

   /* Skip first line if Newton-X input is used */
   if (NX) fgets(line,sizeof line, inp);
   while ( fgets(line,sizeof line, inp) != NULL && nm<LAMBDA_MAX)
   {
      strcpy(copy,line);
      if (NX)
      {
         ncol = sscanf(copy, "%lf %lf %lf %lf", &ev, &nm, &Pi,&error );
         if (ncol < 4)
         {
#define NXERROR 10
            printf("Newton-X is asked but not enough columns in input file\n");
            exit(NXERROR);
         }
      }
      else
      {
         sscanf(copy, "%lf %lf", &nm, &Pi);
      }
      /* Store value only if nm is in the range of visible light */
      if(LAMBDA_MIN <= nm && nm <= LAMBDA_MAX)
      {
         data->wl[i] = nm;
         data->P[i] = Pi; 
         i++;
      } 
      /* If the default value for the array size is too small, attempt to reallocate more space*/
      if (i==SIZE)
      {
         data->wl = (double*) realloc(data->wl,2*SIZE);
         data->P = (double*) realloc(data->P,2*SIZE);
         SIZE=2*SIZE;
      } 
   }
   fclose(inp);
   data->size = i;
}

void read_solar(const char* filename)
{
   /* false = no Newton-X */
   read_emission(filename,false);
}

void bounds(double wavel, double *values, data* d)
{
   int i=0;
   while (wavel>d->wl[i] && i<d->size)
   {
      i++;
   }
   if (i == d->size)
   {
      fprintf(stderr,"No bounds found for wavelength %f\n",wavel);
      exit(WLERROR);
   }
   if (i!=0)
   {
      values[0] = d->wl[i-1];
      values[1] = d->P[i-1];
      values[2] = d->wl[i];
      values[3] = d->P[i];
      /* If we have a matching wavelength set boundaries to the same values to avoid interpolation */
      if (wavel == values[3])
      {
         values[0] = d->wl[i];
         values[1] = d->P[i];
      }
   }
   else
   {
      values[0] = d->wl[0];
      values[1] = d->P[0];
      values[2] = d->wl[0];
      values[3] = d->P[0];
   }
}

double interpolate(double *d, double wl, char scheme)
{
   double val;
   /* We found a matching value */
   if (d[0] == d[2]) return d[1];
   switch (scheme)
   {
      case 'l':
         val = d[3] - (d[3]-d[1])/(d[2]-d[0])*(d[2]-wl);
         break;
      default:
         fprintf(stderr,"Unknown interpolation scheme\n");
         free(d);
         exit(SCHEMEERROR);
   }
   return val;
}
double spectrum(double wl)
{
   double b[4];
   double val;
   bounds(wl,b,&spec);
   val = interpolate(b,wl,'l');
   return val;
}

void rgb_to_hexa(double r, double g, double b,char* hexa)
{
   sprintf(hexa,"#%02X%02X%02XFF", (int)(255*r),(int)(255*g),(int)(255*b));
}

void help()
{
   printf("Compute the RGB of an emission or absorption spectrum\n");
   printf("Usage:\n specrgb -i <inputfile> [-p <outfile>] [-s][-a/-e][-N][-h]\n");
   printf("Options list:\n");
   printf("    -i: Name of the input file (mandatory)\n");
   printf("    -s: Name of the solar irradiance input file(optional)\n");
   printf("        A file called SolIr.dat should be provided as a default one\n"); 
   printf("    -e: Compute RGB for an emission spectrum (default)\n");
   printf("    -a: Compute RGB for an absorption spectrum\n");
   printf("    -N: Input file is a Newton-X output (one line header and 4 columns)\n"); 
   printf("        DE/eV    lambda/nm    sigma/A^2        +/-error/A^2 "); 
   printf("    -p: Request that the data are printed in a file\n");
   printf("    -h: Print this help\n");
}

int main(int argc, char **argv)
{
   char hexa[10];
   double x=0.;
   double y=0.;
   double z=0;
   double r=0.;
   double g=0.;
   double b=0.;
   struct colourSystem *cs = &SMPTEsystem;
/* Manage Arguments */
   int i;
   const char *filename = "";
   const char *solar_filename="";
   const char *out_filename="";
   bool has_inputfile=false;
   bool has_solarfile=false;
   bool is_NX = false;
   bool is_abs = false;
   bool is_emi = false;
   bool do_print = false;
   if (argc < 2) 
   {
      help();
      exit(0);
   }
   for (i = 1; i<argc;i++)
   {
      if (argv[i][0] == '-')
      {
         switch (argv[i][1])
         {
            /* Input File */
            case 'i':
               has_inputfile = true;
               filename = argv[i+1];
               break;
            /* Solar irradiance file */
            case 's':
               has_solarfile = true;
               solar_filename = argv[i+1];
               break;
            /* The input file is a Newton-X output */
            case 'N':
               is_NX = true;
               break;
            /* Absorption */
            case 'a':
               is_abs = true;
               break;
            /* Emission */
            case 'e':
               is_emi = true;
               break;
            case 'p':
               do_print = true;
               out_filename = argv[i+1];
               break;
            case 'h':
               help();
               exit(0);
               break;
         }
      }
   }
   if(!is_emi && !is_abs)
   {
      printf("Defaulting to emission\n");
      is_emi=true;
   }
#define NOINPUT      100 /* No Input file is provided */
   if (!has_inputfile)
   {
      printf ("Hum it embarassing! No input file provided\n");
      help();
      exit(NOINPUT);
   }
#define ABSEMI       101 /* No Input file is provided */
   if (is_abs && is_emi)
   {
      printf("Are you serious? Absorption and Emission at the same time?\n");
      help();
      exit(ABSEMI);
   }
   if (is_abs && ! has_solarfile)
   {
      solar_filename = "SolIr.dat";
      printf("Using default solar irradiance file: %s\n",solar_filename);
   }
/* End of Arguments management */
   spec.wl = malloc(SIZE*sizeof(double));
   spec.P = malloc(SIZE*sizeof(double));
   if(is_emi)
   {
      read_emission(filename,is_NX);
   }
   else if(is_abs)
   {
      solar.wl = malloc(SIZE*sizeof(double));
      solar.P = malloc(SIZE*sizeof(double));
      read_absorption(filename,solar_filename, is_NX);
   }
   if(do_print) print_spec(out_filename);
   spectrum_to_xyz(spectrum,&x,&y,&z);
   xyz_to_rgb(cs, x, y, z, &r, &g, &b);
   printf("%30s: %13s %13s %13s %13s %13s %13s %13s\n",filename, "x","y","z","R","G","B","hexa (RGBA)");
   printf("%30s  %13.3f %13.3f %13.3f","", x,y,z); 
   if (constrain_rgb(&r, &g, &b)) 
   {
      norm_rgb(&r, &g, &b);
      rgb_to_hexa(r,g,b,hexa);
      printf(" %13.3f %13.3f %13.3f %13s (Approximation)\n", r, g, b,hexa);
   } 
   else 
   {
      norm_rgb(&r, &g, &b);
      rgb_to_hexa(r,g,b,hexa);
      printf(" %13.3f %13.3f %13.3f %13s\n", r, g, b,hexa);
   }
   /* Freedom for the memory */
   free(spec.wl);
   free(spec.P);
   if (is_abs)
   {
      free(solar.wl);
      free(solar.P);
   }

   return 0;
}
