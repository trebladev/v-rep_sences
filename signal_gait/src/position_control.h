//
// Created by xuan on 2021/2/7.
//

#ifndef SIGNAL_GAIT_POSITION_CONTROL_H
#define SIGNAL_GAIT_POSITION_CONTROL_H

#define PI 3.1415926535897932384626433832795

struct GaitParams {
    float stance_height = 0.18; // 行走时期望身体距离地面的高度 (m)
    float down_amp = 0.00; // 正弦轨迹中低于stanceheight的峰值振幅 (m)
    float up_amp = 0.06; // 正弦轨迹中，脚在高于stanceheight的峰值 (m)
    float flight_percent = 0.6; // 在步态轨迹的下半部分时间
    float step_length = 0.0; // 整步长度 (m)
    float freq = 1.0; // 一个步态周期的频率 (Hz)
    float step_diff = 0.0; //左右腿部的步长差
};
extern struct GaitParams state_gait_params[13];

void SinTrajectory (float t, struct GaitParams params, float gaitOffset, float& x, float& y);
void CartesianToLegParams(float x, float y, float leg_direction, float& L, float& theta);
void CartesianToThetaGamma(float x, float y, float leg_direction, float& theta, float& gamma);
void GetGamma(float L, float theta, float& gamma);

#endif //SIGNAL_GAIT_POSITION_CONTROL_H
