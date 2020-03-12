function dx = interstagedx_HC(x,u,p)
    addpath('../TireAnalysis');
    %#codegen
    global index
    
    %just for the moment
    Cf = p(index.pmoi); % moment of inertia    

    %B1 = 15;
    %C1 = 1.1;
    %D1 = 9.4;
    FB = p(index.pacFB);
    FC = p(index.pacFC);
    FD = p(index.pacFD); % gravity acceleration considered

    RB = p(index.pacRB);
    RC = p(index.pacRC);
    RD = p(index.pacRD); % gravity acceleration considered
    %B2 = 5.2;
    %C2 = 1.4;
    %D2 = 10.4;
    param = [FB,FC,FD,RB,RC,RD,Cf];

    %[ab,dotbeta,ds,brake / x,y,theta,v,beta,s,braketemp]
    %evolution:
    %maxacc = casadiGetMaxAcc(x);
    %minacc = casadiGetMaxNegAcc(x);
    %ab = 0.5*(maxacc-minacc)*(u(1)+1);
    dotab = u(index.dotab);
    ab = x(index.ab-index.nu);
    tv = u(index.tv);
    dotbeta = u(index.dotbeta);
    ds = u(index.ds);
    %ds = 0.03;
    theta = x(index.theta-index.nu);
    vx = x(index.v-index.nu);
    vy = x(index.yv-index.nu);
    dottheta = x(index.dottheta-index.nu);
    beta = x(index.beta-index.nu); % from steering.
    %beta = 0;
    %temp = x(index.braketemp-index.nu);
    %braking=max(0,-ab+casadiGetMaxNegAcc(speed));
    %brakingheatup = heatupfunction(-ab-1.5);
    %brakingcooldown = cooldownfunction(temp);
    %l = 1.19; %todo unused
    ackermannAngle = -0.63.*beta.*beta.*beta+0.94*beta; %ackermann Mapping 
   
    %(VELX,VELY,VELROTZ,BETA,AB,TV, param)
    %[ACCX,ACCY,ACCROTZ,frontabcorr] = modelDx(vx,vy,dottheta,ackermannAngle,ab,tv, param);
    [ACCX,ACCY,ACCROTZ] = modelDx(vx,vy,dottheta,ackermannAngle,ab,tv, param);
    
    
    import casadi.*
    if isa(x(1), 'double')
        dx = zeros(index.ns,1);
    else
        dx = SX.zeros(index.ns,1);
    end
    rotmat = @(beta)[cos(beta),-sin(beta);sin(beta),cos(beta)];
    lv = [vx;vy];
    gv = rotmat(theta)*lv;
    dx(index.x-index.nu)=gv(1);
    dx(index.y-index.nu)=gv(2);
    dx(index.dottheta-index.nu)=ACCROTZ; % dot_dot_Phi
    dx(index.theta-index.nu)=dottheta;   % dot_Phi
    %dx(index.theta-index.nu)=vx/l*tan(ackermannAngle);
    dx(index.v-index.nu)=ACCX;           
    dx(index.yv-index.nu)=ACCY;
    dx(index.beta-index.nu)=dotbeta;
    dx(index.s-index.nu)=ds;
    %dx(index.braketemp-index.nu)=brakingheatup+brakingcooldown;
    dx(index.ab-index.nu)=dotab;
    
    %dx = [v*cos(theta);
    %v*sin(theta);
    %v/l*tan(ackermannAngle);
    %ab;
    %dotbeta;
    %ds;
    %braking+cooldownfunction(temp)];
end

