#include <stdio.h>
#include <string.h>

int main()
{

char *a[3];

char *x = "fasfasfas";
char *y = "faffasfasfasf";

char b[111];
strcpy(b,x);
//strcpy(a[1],y);

printf("%s\n",b);
//printf("%s\n",a[1]);
    return 0;
}
