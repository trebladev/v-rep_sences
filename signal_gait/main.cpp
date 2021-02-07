#include <iostream>
#include <position_control.h>
#include <b0RemoteApi.h>




int main() {


    float t,prev_t = 0;
    float position;
    bool state;
    b0RemoteApi* cl=NULL;
    b0RemoteApi client("b0RemoteApi_V-REP","b0RemoteApi");
    cl=&client;    //为了方便在函数中调用时不用传递类对象参数

    int motor = client.readInt(client.simxGetObjectHandle("Right_Leg_Motor",client.simxServiceCall()),1);

    client.simxStartSimulation(client.simxDefaultPublisher());
    while(1) {
        position = client.readFloat(client.simxGetJointPosition(motor, client.simxServiceCall()), 1);
        printf("%f\r\n", position);
    }
    //std::cout << "Hello, World!" << std::endl;
    return 0;
}
