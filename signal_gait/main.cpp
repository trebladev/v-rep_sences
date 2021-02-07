#include <iostream>
#include <stdlib.h>
extern "C"{
#include <extApi.h>
}




int main() {

    int Port = 3000;
    int PositionControlHandle;
    int clientID = simxStart("127.0.0.1", Port, 1, 1, 1000, 5);
    if (clientID != -1)
    {
        printf("V-rep connected.");
        while (simxGetConnectionId(clientID) != -1)
        {

        }

        simxFinish(clientID);
    }
    else {
        printf("V-rep can't be connected.");
    }


    //std::cout << "Hello, World!" << std::endl;
    return 0;
}
