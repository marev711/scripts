#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#define MAX_FILENAME_LENGTH 80
#define TRUE 1
#define FALSE 0
#define BUFFER_LENGTH 16
 
int main ( long argc, char **argv ) {
  long int       file_addr;
  unsigned char  buf[20];
  long int       read_length;
  FILE          *filein;
  char           filein_name[MAX_FILENAME_LENGTH];
  FILE          *fileout;
  char           fileout_name[MAX_FILENAME_LENGTH];
  long           m;
  long           no_match, start_index;
  int            write_to_outfile;

/*! \brief Extract data following a specified
 *         tag from any file
 *
 *  Usage: First, add any information to any file by, 
 *
 *             cat binary.x delimiter.txt any-information.?
 *
 *     To extract the information, run 
 *
 *             tag-dump <infile> <outfile>
 *
 *     Note that the delimiter to use is hardcoded in
 *     this program
 */

  const char    delimiter[]="This text is an EC-Earth delimiter";

/*
 * Check for the right number of arguments.
 */
  if ( argc != 3 ) {

    printf ( "\n" );
    printf ( "Usage: tag-dump <infile> <outfile>\n" );
    exit(1);
  }

    strcpy ( filein_name, argv[1] );
    strcpy ( fileout_name, argv[2] );
    fileout = fopen ( fileout_name, "wb" );

/*
 * Open the input file.
 */
  filein = fopen ( filein_name, "rb" );

  if ( filein == NULL ) {
    printf ( "\n" );
    printf ( "tag-dump - Fatal error!\n" );
    printf ( "  Cannot open the input file %s.\n", filein_name );
    exit(1);
  }



/*
 * Initialize
 */
  write_to_outfile=FALSE;
  file_addr = 0;
  no_match=0;
  start_index=0;


/*
 * Read the filein with BUFFER_LENGTH bytes at the time
 */
  while ( ( read_length = ( long ) 
    fread ( buf, sizeof ( unsigned char ), BUFFER_LENGTH, filein ) ) > 0 ) {


/*
 * Keep track of our current file_address (for debugging purposes)
 */
    file_addr = file_addr + BUFFER_LENGTH;


/*
 * Scan for the delimiter string
 */
    if ( ! write_to_outfile ) {
      for ( m = 0; m < read_length; m++ ) {   
        if ( buf[m] == delimiter[no_match] ) {
          no_match=no_match+1;
          if ( no_match > sizeof(delimiter)-2) {
            write_to_outfile=TRUE;
            start_index=m+1;
          }
        } else no_match=0;
      }
    }


/*
 * If delimiter string found, write the rest of
 * the input file to the output file
 */
    if ( write_to_outfile ) {
      for ( m = start_index; m < read_length; m++ ) {   
        fprintf ( fileout, "%c", buf[m] );
      }
    }
    start_index=0;
  } // while ( fread(...) ... ) 
 

  if ( ferror( filein ) ) {
    printf("There was an error reading %s\n", filein_name);
    exit(1);
  }
  if ( ferror( fileout ) ) {
    printf("There was an error writing to %s\n", fileout_name);
    exit(1);
  }
 
 

/*
 * Close files and exit
 */
  fclose ( filein );
  fclose ( fileout );
  return (0);
}
