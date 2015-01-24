#include <stdio.h>
#include <string.h>

#define ln(fp, s) fwrite(s, 1, strlen(s), fp)

int main(int ac, char** av)
{
	int i, j, k;
	char line[2048];
	char line2[2048];
	FILE* fp = fopen(av[2], "wb");

	ln(fp, "const char ");
	ln(fp, av[1]);
	ln(fp, "[] = \n");

	for(i=0; i<(ac-3); i++)
	{
		FILE* in = fopen(av[i + 3], "r");
		while(fgets(line, 2048, in))
		{
			for(j=0, k=0; line[j] && line[j] != '\n'; j++){
				if(line[j] == '"'){
					line2[k++] = '\\';
					line2[k++] = '"';
				}else if(line[j] == '\\'){
					line2[k++] = '\\';
					line2[k++] = '\\';
				}else{
					line2[k++] = line[j];
				}
			}
			line2[k] = 0;
			ln(fp, "\"");
			fwrite(line2, 1, k, fp);
			ln(fp, "\\n\"\n");
		}
		fclose(in);
	}

	ln(fp, ";\n");
	fclose(fp);

	return 0;
}

