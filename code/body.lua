require "math"
xml = [[
    <ui closeable="true" onclose="closeEventHandler" resizable="true">
    <label text="Gait Params" wordwrap="true" />
    <group>//
        <label text="Freq" id = "1" wordwrap="true" />
        <hslider minimum="1" maximum="30" tick-interval="1" on-change="freqChange_callback" tick-position="below" id="2" />
    
        <label text="Down_Amp" id = "3" wordwrap="true" />
        <hslider minimum="1" maximum="6" tick-interval="1" on-change="down_amp_Change_callback" tick-position="below" id="4" />
    
        <label text="Up_Amp" id = "5" wordwrap="true" />
        <hslider minimum="1" maximum="6" tick-interval="1" on-change="up_amp_Change_callback" tick-position="below" id="6" />
    
        <label text="Stance_Height" id = "7" wordwrap="true" />
        <hslider minimum="10" maximum="20" tick-interval="1" on-change="stance_height_Change_callback" tick-position="below" id="8" />
    
        <label text="Step_Length" id = "9" wordwrap="true" />
        <hslider minimum="5" maximum="15" tick-interval="1" on-change="step_length_Change_callback" tick-position="below" id="10" />
    
        <label text="Flight_Percent" id = "11" wordwrap="true" />
        <hslider minimum="10" maximum="100" tick-interval="1" on-change="flight_percent_Change_callback" tick-position="below" id="12" />

        <label text="step_diff" id = "13" wordwrap="true" />
        <hslider minimum="-10" maximum="10" tick-interval="1" on-change="step_diff_Change_callback" tick-position="below" id="14" />
    </group>
    <group>
        <label text="State:" id = "15" wordwrap="true" />
        <button text="W"  onclick = "state_change" id = "16"/>
        <label text="front" id = "17" wordwrap="true" />
        <hslider minimum="5" maximum="20" tick-interval="1" on-change="S_front_Change_callback" tick-position="below" id="18" />
        <label text="behind" id = "19" wordwrap="true" />
        <hslider minimum="5" maximum="20" tick-interval="1" on-change="S_behind_Change_callback" tick-position="below" id="20" />
    </group>
</ui>
]]
function freqChange_callback(ui,id,newVal)
    --GaitParams.freq = newVal/10
    local value = newVal/10
    GaitParams.freq = value
    simUI.setLabelText(ui,1,'Freq='..GaitParams.freq..'Hz')
end
function down_amp_Change_callback(ui,id,newVal)
    local value = newVal/100
    GaitParams.down_amp = value
    simUI.setLabelText(ui,3,'Down_Amp='..GaitParams.down_amp..'Meters')
end

function up_amp_Change_callback(ui,id,newVal)
    local value = newVal/100
    GaitParams.up_amp = value
    simUI.setLabelText(ui,5,'Up_Amp='..GaitParams.up_amp..'Meters')
end

function stance_height_Change_callback(ui,id,newVal)
    local value = newVal/100
    GaitParams.stance_height = value
    simUI.setLabelText(ui,7,'Stance_Height='..GaitParams.stance_height..'Meters')
end

function step_length_Change_callback(ui,id,newVal)
    local value = newVal/100
    GaitParams.step_length = value
    simUI.setLabelText(ui,9,'Step_Length='..GaitParams.step_length..'Meters')
end

function flight_percent_Change_callback(ui,id,newVal)
local value = newVal/100
    GaitParams.flight_percent = value
    simUI.setLabelText(ui,11,'flight_percent='..GaitParams.flight_percent..'%')
end
function step_diff_Change_callback(ui,id,newVal)
    local value = newVal/100
    GaitParams.step_diff = value
    simUI.setLabelText(ui,13,'step_diff='..GaitParams.step_diff..'Meters')
end
function S_front_Change_callback(ui,id,newVal)
    local value = newVal/100
    S_y_f = value
    simUI.setLabelText(ui,17,'front='..S_y_f..'Meters')
end
function S_behind_Change_callback(ui,id,newVal)
    local value = newVal/100
    S_y_b = value
    simUI.setLabelText(ui,19,'behind='..S_y_b..'Meters')
end
function changeGaitParams(params)
    GaitParams["stance_height"] = params[1]
    GaitParams["down_amp"] = params[2]
    GaitParams["up_amp"] = params[3]
    GaitParams["flight_percent"] = params[4]
    GaitParams["step_length"] = params[5]
    GaitParams["freq"] = params[6]
    GaitParams["step_diff"] = params[7]
end

function state_change(ui,id)
    if(state == "W")then
        state = "S"
        --simUI.setText(ui,16,"S")
    elseif(state == "S")then
        state = "W"
        --simUI.setText(ui,16,"W")
    end
end
function SinTrajectory(params,gaitOffset,Body_side)
    local t_diff
    local stanceHeight = params.stance_height
    local downAMP = params.down_amp
    local upAMP = params.up_amp
    local flightPercent = params.flight_percent
    local stepLength = params.step_length
    local FREQ = params.freq
    local step_diff = params.step_diff

    local x,y
    
    if(Body_side == "L")then
        stepLength = stepLength - step_diff
    end
    if(Body_side == "R")then
        stepLength = stepLength + step_diff
    end
    t = sim.getSimulationTime()
    t_diff = t-prev_t
    if(t_diff>0.5)then
    t_diff = 0
    end

    p = p+FREQ*t_diff
    prev_t = t
    local gp = math.fmod((p+gaitOffset),1.0)

    if(gp <= flightPercent)
    then
        x = (gp/flightPercent)*stepLength - stepLength/2.0
        y = -upAMP*math.sin(math.pi*gp/flightPercent) + stanceHeight
    else
        local percentBack = (gp-flightPercent)/(1.0-flightPercent)
        x = -percentBack*stepLength + stepLength/2.0
        y = downAMP*math.sin(math.pi*percentBack) + stanceHeight
    end
    --print("p=",p)
    --print("t=",t)
    --print(t_diff)
    return x,y

end

--?????????x?y???????L?theta
--??L?theta
function CartesianToLegParams(x,y,leg_direction)
    local L,theta
    L = math.pow((math.pow(x,2.0) + math.pow(y,2.0)), 0.5)
    theta = math.atan2(leg_direction*x, y)
    return L,theta
end

--?????L?theta??????gamma?
--??gamma
function GetGamma(L)
    local gamma
    local cos_param = (math.pow(L1,2.0) + math.pow(L,2.0) - math.pow(L2,2.0)) / (2.0*L1*L)
    if(cos_param < -1.0) then
        gamma = math.pi
        end
    if(cos_param > 1.0) then
        gamma = 0
        end
    gamma = math.acos(cos_param)

    return gamma
end



function CartesianToThetaGamma(x,y,leg_direction)
    local L,theta
    local gamma
    L,theta = CartesianToLegParams(x,y,leg_direction)
    gamma = GetGamma(L)

    return theta,gamma
end
state_gait_params = {
        {NAN, NAN, NAN, NAN, NAN, NAN, NAN}, -- STOP
        {0.14, 0.02, 0.02, 0.5, 0.10, 2.0, -0.05}, -- TROT
        {0.17, 0.04, 0.06, 0.35, 0.0, 2.0, 0.0}, -- BOUND
        {0.15, 0.00, 0.06, 0.25, 0.0, 1.5, 0.0}, -- WALK
        {0.12, 0.05, 0.0, 0.75, 0.0, 1.0, 0.0}, -- PRONK
        {NAN, NAN, NAN, NAN, NAN, NAN, NAN}, -- JUMP
        {0.15, 0.05, 0.05, 0.35, 0.0, 1.5, 0.0}, -- DANCE
        {0.15, 0.05, 0.05, 0.2, 0.0, 1.0, 0.0}, -- HOP
        {NAN, NAN, NAN, NAN, NAN, 1.0, NAN}, -- TEST
        {NAN, NAN, NAN, NAN, NAN, NAN, NAN}, -- ROTATE
        {0.15, 0.07, 0.06, 0.2, 0.0, 1.0, 0.0}, -- FLIP
        {0.17, 0.04, 0.06, 0.35, 0.1, 2.0, 0.06}, -- TURN_TROT
        {NAN, NAN, NAN, NAN, NAN, NAN, NAN} -- RESET
    }
function sysCall_init()
    -- do some initialization here
    Leg0_right = sim.getObjectHandle("Leg01_Motor")
    Leg0_left = sim.getObjectHandle("Leg02_Motor")
    Leg1_right = sim.getObjectHandle("Leg11_Motor")
    Leg1_left = sim.getObjectHandle("Leg12_Motor")
    Leg2_right = sim.getObjectHandle("Leg21_Motor")
    Leg2_left = sim.getObjectHandle("Leg22_Motor")
    Leg3_right = sim.getObjectHandle("Leg31_Motor")
    Leg3_left = sim.getObjectHandle("Leg32_Motor")
    
    L1 = 0.09
    L2 = 0.162
    p = 0
    prev_t = 0
    
    S_x = 0
    S_y_f = 0.15
    S_y_b = 0.15
    S_theta_f,S_gamma_f = CartesianToThetaGamma(S_x,S_y_f,1)
    S_theta_b,S_gamma_b = CartesianToThetaGamma(S_x,S_y_b,1)

    GaitParams = {}
    GaitParams["stance_height"] = 0.18
    GaitParams["down_amp"] = 0.00
    GaitParams["up_amp"] = 0.06
    GaitParams["flight_percent"] = 0.6
    GaitParams["step_length"] = 0.00
    GaitParams["freq"] = 1.0
    GaitParams["step_diff"] = 0.00

    state = "S"
    
    changeGaitParams(state_gait_params[2])
    ui=simUI.create(xml)
    simUI.setLabelText(ui,1,'Freq='..GaitParams.freq..'Hz')
    simUI.setLabelText(ui,3,'Down_Amp='..GaitParams.down_amp..'Meters')
    simUI.setLabelText(ui,5,'Up_Amp='..GaitParams.up_amp..'Meters')
    simUI.setLabelText(ui,7,'Stance_Height='..GaitParams.stance_height..'Meters')
    simUI.setLabelText(ui,9,'Step_Length='..GaitParams.step_length..'Meters')
    simUI.setLabelText(ui,11,'Flight_Percent='..GaitParams.flight_percent..'%')
    simUI.setLabelText(ui,13,'step_diff='..GaitParams.step_diff..'Meters')
    simUI.setLabelText(ui,17,'front='..S_y_f..'Meters')
    simUI.setLabelText(ui,19,'behind='..S_y_b..'Meters')
end

function sysCall_actuation()
    -- put your actuation code here
    if(state == "W")then
        x0,y0 = SinTrajectory(GaitParams,0,"L")
        x1,y1 = SinTrajectory(GaitParams,0.5,"L")
        x2,y2 = SinTrajectory(GaitParams,0,"R")
        x3,y3 = SinTrajectory(GaitParams,0.5,"R")
        theta0,gamma0 = CartesianToThetaGamma(x0,y0,-1)
        theta1,gamma1 = CartesianToThetaGamma(x1,y1,-1)
        theta2,gamma2 = CartesianToThetaGamma(x2,y2,1)
        theta3,gamma3 = CartesianToThetaGamma(x3,y3,1)
    
        sim.setJointTargetPosition(Leg2_right,(gamma2+theta2))
        sim.setJointTargetPosition(Leg2_left,(-gamma2+theta2))
        sim.setJointTargetPosition(Leg0_right,(gamma0+theta0))
        sim.setJointTargetPosition(Leg0_left,(-gamma0+theta0))
        sim.setJointTargetPosition(Leg1_right,(gamma1+theta1))
        sim.setJointTargetPosition(Leg1_left,(-gamma1+theta1))
    
        sim.setJointTargetPosition(Leg3_right,(gamma3+theta3))
        sim.setJointTargetPosition(Leg3_left,(-gamma3+theta3))
    elseif(state == "S") then
        S_theta_f,S_gamma_f = CartesianToThetaGamma(S_x,S_y_f,1)
        S_theta_b,S_gamma_b = CartesianToThetaGamma(S_x,S_y_b,1)
        sim.setJointTargetPosition(Leg0_right,(S_gamma_f+S_theta_f))
        sim.setJointTargetPosition(Leg0_left,(-S_gamma_f+S_theta_f))
        sim.setJointTargetPosition(Leg1_right,(S_gamma_b+S_theta_b))
        sim.setJointTargetPosition(Leg1_left,(-S_gamma_b+S_theta_b))
        sim.setJointTargetPosition(Leg2_right,(S_gamma_b+S_theta_b))
        sim.setJointTargetPosition(Leg2_left,(-S_gamma_b+S_theta_b))
        sim.setJointTargetPosition(Leg3_right,(S_gamma_f+S_theta_f))
        sim.setJointTargetPosition(Leg3_left,(-S_gamma_f+S_theta_f))
        
        
    end
    
end

function sysCall_sensing()
    -- put your sensing code here
end

function sysCall_cleanup()
    -- do some clean-up here
end

-- See the user manual or the available code snippets for additional callback functions and details