// output of taup_pierce can have multiple rays with very similar ray parameters.
// They are basically identical
//
// Here, grep the first ray

#include <stdio.h>
#include <string.h>
#include <math.h>
#include <stdlib.h>


int main( argc, argv )
int   argc;
char       *argv[];
{
    char      ss[140];

	// read first line
    fgets(ss,140,stdin);
    // very first character should be ">" in the taup_pierce header
    if (ss[0] == '>' ) {
		fprintf(stdout,"%s", ss);
	} else {
		fprintf(stdout,"Error reading input. Expected > but read  --%c-- character\n", ss[0]);
		exit(0);
	}


	// read following lines of the ray until we find the
	// next header line beginning with the  '>' character
    while ( fgets(ss,140,stdin) != NULL ) {
      if (ss[0] != '>' ) {
		fprintf(stdout,"%s", ss);
	  } else {
	    // reading the '>' character of the header line of the next ray. Stop
	    break;
	  }
	}
}
