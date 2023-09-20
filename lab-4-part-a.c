#include <stdio.h>
#include <stdlib.h>

int main()
{

    int state = 1;
    char input;

    while (1)
    {
        switch (state)
        {
        case 1:
            printf("We're now in state 1\n");
            input = getchar();
            if (input == 'a')
            {
                state = 2;
            }
            else
            {
                state = 4;
            };
            break;
        case 2:
            printf("We're now in state 2\n");
            input = getchar();
            if (input == 'b')
            {
                state = 1;
            }
            else if (input == 'a')
            {
                state = 3;
            }
            else
            {
                state = 4;
            };
            break;
        case 3:
            printf("We're now in state 3\n");
            printf("Done!\n");
            exit(1);
            break;
        case 4:
            printf("We're now in state 4\nInvalid input\n");
            exit(1);
            break;
        }
    }

    return 0;
}