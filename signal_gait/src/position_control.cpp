//
// Created by xuan on 2021/2/7.
//

#include "position_control.h"
#include <math.h>

struct GaitParams state_gait_params[] = {
        //{s.h, d.a., u.a., f.p., s.l., fr., s.d.}
        {NAN, NAN, NAN, NAN, NAN, NAN, NAN}, // STOP
        {0.17, 0.04, 0.06, 0.35, 0.15, 2.0, 0.0}, // TROT
        {0.17, 0.04, 0.06, 0.35, 0.0, 2.0, 0.0}, // BOUND
        {0.15, 0.00, 0.06, 0.25, 0.0, 1.5, 0.0}, // WALK
        {0.12, 0.05, 0.0, 0.75, 0.0, 1.0, 0.0}, // PRONK
        {NAN, NAN, NAN, NAN, NAN, NAN, NAN}, // JUMP
        {0.15, 0.05, 0.05, 0.35, 0.0, 1.5, 0.0}, // DANCE
        {0.15, 0.05, 0.05, 0.2, 0.0, 1.0, 0.0}, // HOP
        {NAN, NAN, NAN, NAN, NAN, 1.0, NAN}, // TEST
        {NAN, NAN, NAN, NAN, NAN, NAN, NAN}, // ROTATE
        {0.15, 0.07, 0.06, 0.2, 0.0, 1.0, 0.0}, // FLIP
        {0.17, 0.04, 0.06, 0.35, 0.1, 2.0, 0.06}, // TURN_TROT
        {NAN, NAN, NAN, NAN, NAN, NAN, NAN} // RESET
};



/**
 * 将笛卡尔坐标系（x, y (m)) 转换为腿部参数（L (m), theta (rad))
 * @param x
 * @param y
 * @param leg_direction
 * @param L
 * @param theta
 */
void CartesianToLegParams(float x, float y, float leg_direction, float& L, float& theta) {
    L = pow((pow(x,2.0) + pow(y,2.0)), 0.5);
    theta = atan2(leg_direction * x, y);
}

/**
 * 获取腿部参数，并返回腿部的伽马角
 * @param L
 * @param theta
 * @param gamma
 */
void GetGamma(float L, float theta, float& gamma) {
    float L1 = 0.09; // upper leg length (m)
    float L2 = 0.162; // lower leg length (m)
    float cos_param = (pow(L1,2.0) + pow(L,2.0) - pow(L2,2.0)) / (2.0*L1*L);
    if (cos_param < -1.0) {
        gamma = PI;
#ifdef DEBUG_HIGH
        Serial.println("ERROR: L is too small to find valid alpha and beta!");
#endif
    } else if (cos_param > 1.0) {
        gamma = 0;
#ifdef DEBUG_HIGH
        Serial.println("ERROR: L is too large to find valid alpha and beta!");
#endif
    } else {
        gamma = acos(cos_param);
    }
}

/**
 * 正弦轨迹发生器函数，具有以下所述参数的灵活性。可以用这个做4拍，2拍小跑等
 * @param t
 * @param params
 * @param gaitOffset
 * @param x
 * @param y
 */
void SinTrajectory (float t, struct GaitParams params, float gaitOffset, float& x, float& y) {
    static float p = 0;
    static float prev_t = 0;

    float stanceHeight = params.stance_height;     //直立高度
    float downAMP = params.down_amp;               //下幅值
    float upAMP = params.up_amp;                   //上幅值
    float flightPercent = params.flight_percent;   //飞行相占比
    float stepLength = params.step_length;         //整步长
    float FREQ = params.freq;                      //频率

    p += FREQ * (t - prev_t < 0.5 ? t - prev_t : 0); // 当开始一个步态的时候应该减少蹒跚
    // EXP1?EXP2:EXP3 如果EXP1为真，返回EXP2;如果EXP1为假，返回EXP3的值
    // t-prev_t为执行一次控制的时间
    prev_t = t;

    float gp = fmod((p+gaitOffset),1.0); // mod(a,m) 返回a除以m的余数
    if (gp <= flightPercent) {                                     // 下半轨迹
        x = (gp/flightPercent)*stepLength - stepLength/2.0;
        y = -upAMP*sin(PI*gp/flightPercent) + stanceHeight;
    }
    else {                                                         // 上半轨迹
        float percentBack = (gp-flightPercent)/(1.0-flightPercent);
        x = -percentBack*stepLength + stepLength/2.0;
        y = downAMP*sin(PI*percentBack) + stanceHeight;
    }
}

/**
 * 将笛卡尔坐标系的坐标转换为θ和γ
 * @param x
 * @param y
 * @param leg_direction
 * @param theta
 * @param gamma
 */
void CartesianToThetaGamma(float x, float y, float leg_direction, float& theta, float& gamma) {
    float L = 0.0;
    CartesianToLegParams(x, y, leg_direction, L, theta);   //将x，y转换为虚拟腿长L和虚拟腿长相对于坐标轴的角度θ
    GetGamma(L, theta, gamma);                                //通过L和θ计算得到γ
    //Serial << "Th, Gam: " << theta << " " << gamma << '\n';
}


