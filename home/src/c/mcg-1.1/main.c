#include <stdio.h>
#include <time.h>
#include <time.h>
#include <stdlib.h>
#include <ctype.h>

void printMenu(){
    printf("\n1) Roll");
    printf("\n2) Quit\n");
}

int main()
{
    srand(time(NULL));
    int n, b, isSneaky, isMagical, isMighty = 0;
    char c;

    do {
        printMenu();
        scanf(" %c", &c);
        b = c - '0';
        if (isdigit(c)){
            switch (b) {
                case 1:
                    printf("\t\t\t//====================\n");

                    char *races[] = {
                        "an Altmer", "an Argonian", "a Dunmer", "an Imperial", "an Orc",
                        "a Bosmer", "a Breton", "a Khajiit", "a Nord", "a Redguard"
                    };
                    n = rand() % 10;
                    printf("\t\t\t||You will be %s,\n", races[n]);

                    char *crasses[] = {
                        "An Archer", "A Barbarian", "A Crusader", "A Knight",
                        "A Rogue", "A Scout", "A Warrior", "A Battlemage", "A Healer",
                        "A Mage", "A Knightblade", "A Sorcerer", "A Spellsword", "A Witchhunter",
                        "An Acrobat", "An Agent", "A Monk", "A Thief",
                        "An Assassin", "A Bard", "A Pilgrim"
                    };
                    n = rand() % 21;
                    printf("\t\t\t||%s born under ", crasses[n]);

                    char *signs[] = {
                        "The Mage", "The Warrior", "The Thief", "The Serpent", "The Lady", "The Steed", "The Tower",
                        "The Lord", "The Apprentice", "The Atronach", "The Ritual", "The Lover", "The Shadow"
                    };
                    n = rand() % 13;
                    printf("%s sign,\n", signs[n]);

                    if (n >= 0 && n <= 6) {
                        //printf("the Fighters Guild,\n");
                        isMighty = 1;
                    }
                    if (n >= 7 && n <= 13) {
                        //printf("the Mages Guild,\n");
                        isMagical = 1;
                    }
                    if (n >= 14 && n <= 20) {
                        //printf("the Thieves Guild,\n");
                        isSneaky = 1;
                    }

                    char *houses[] = {
                        "Hlaalu", "Redoran", "Telvanni"
                    };
                    n = rand() % 3;
                    printf("\t\t\t||Hireling of house %s.\n", houses[n]);

                    //% vamps in the game is 2.7%, or 27 in 1000.
                    char *vamps[] = {
                        "of the Aundae Clan,", "of the Berne Clan,", "of the Quarra Clan,", "clean,"
                    };
                    n = rand() % 1000;
                    //there are 27 multiples of 37 in the range between 0 and 999, so n mod any multiple of 37 should equal 0
                    if ((n % 37) == 0) {
                        //45% of vamps are Aundae, 28% are Berne, and the remaining 27% are Quarra
                        //int temp = rand() % 100;
                        if (isMighty == 1){
                            printf("\t\t\t||Your blood is %s\n", vamps[2]);
                        }
                        if (isSneaky == 1){
                            printf("\t\t\t||Your blood is %s\n", vamps[1]);
                        }
                        if (isMagical == 1){
                            printf("\t\t\t||Your blood is %s\n", vamps[0]);
                        }
                    }
                    else {
                        printf("\t\t\t||Your blood is %s\n", vamps[3]);
                    }

                    char *faiths[] = {
                        "The Tribunal Temple,", "The Imperial Cult,", "Nothing,", "The Powerful Daedra,"
                    };
                    n = rand() % 4;
                    printf("\t\t\t||You believe in %s\n", faiths[n]);

                    char *sold[] = {
                        "The Imperial Legion.", "Fortune."
                    };
                    n = rand() % 2;
                    printf("\t\t\t||You are a soldier of %s\n", sold[n]);

                    char *ass[] = {
                        "are an Assassin for The Morag Tong.", "generally eschew needless murder."
                    };
                    n = rand() % 1000;
                    if ((n % 13) == 0) {
                        printf("\t\t\t||And you %s\n", ass[0]);
                    }
                    else {
                        printf("\t\t\t||And you %s\n", ass[1]);
                    }
                    break;
            }
        }
        else {
            printf("Please enter 1 or 2.\n");
        }

        //reset variables here
        isSneaky = 0;
        isMagical = 0;
        isMighty = 0;
    } while (b != 2);
    return 0;
}
