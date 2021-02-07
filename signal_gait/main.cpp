#include <iostream>
#include <position_control.h>
#include <b0RemoteApi.h>


void freq(float value){

}

int main() {


    float diff_t;
    float position;
    float theta,gamma,value;
    b0RemoteApi* cl=NULL;
    b0RemoteApi client("b0RemoteApi_V","b0RemoteApi");
    cl=&client;    //为了方便在函数中调用时不用传递类对象参数

    int motor_right = client.readInt(client.simxGetObjectHandle("Right_Leg_Motor",client.simxServiceCall()),1);
    int motor_left = client.readInt(client.simxGetObjectHandle("Left_Leg_Motor",client.simxServiceCall()),1);

    client.simxStartSimulation(client.simxDefaultPublisher());
    while(1) {
        position = client.readFloat(client.simxGetJointPosition(motor_right, client.simxServiceCall()), 1);
        diff_t = client.readFloat(client.simxGetSimulationTimeStep(client.simxServiceCall()),1);
        CoupledMoveLeg(diff_t,state_gait_params[TROT],0,1,theta,gamma);
        client.simxSetJointPosition(motor_right,(gamma+theta),client.simxDefaultPublisher());
        client.simxSetJointPosition(motor_left,(-gamma+theta),client.simxDefaultPublisher());
        client.simxAddStatusbarMessage("hello",client.simxDefaultPublisher());
        //value = client.readFloat(client.simxGetFloatSignal("freq",client.simxServiceCall()),1);
        //printf("msg=%f",value);
        //printf("%f\r\n", diff_t);
    }
    //std::cout << "Hello, World!" << std::endl;
    return 0;
}


